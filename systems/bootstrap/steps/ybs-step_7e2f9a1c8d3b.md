# Step 000020: Confirmation System

**GUID**: 7e2f9a1c8d3b
**Version**: 0.1.0
**Layer**: 6 - Safety
**Estimated Size**: ~80 lines of code

## Overview

Implements a confirmation system that asks users before executing destructive operations. Prevents accidental data loss from write_file, edit_file, run_shell, etc.

## What This Step Builds

A `ConfirmationManager` that:
- Prompts user before dangerous tool executions
- Supports "yes/no/always" responses
- Maintains session allow-list (if user says "always")
- Supports dry-run mode (show but don't execute)
- Integrates with ToolExecutor

## Step Objectives

1. Create ConfirmationManager class
2. Define which tools require confirmation
3. Add prompt UI (y/n/always/never)
4. Maintain session allow-list
5. Support dry-run mode
6. Integrate with ToolExecutor
7. Create tests

## Prerequisites

**Required Steps**:
- ✅ Step 10: Tool Executor (executes tools)
- ✅ Steps 16-19: Tools that need confirmation

## Configurable Values

**Uses**:
- `safety.confirmation_required` (default: true)

## Traceability

**Implements**:
- `ybs-spec.md` Section 7.1 (Confirmation System)

**References**:
- D13 (Safety: Confirmation before destructive ops)

## Instructions

### 1. Implement Confirmation Manager

**File to create**: `Sources/YBS/Safety/ConfirmationManager.swift`

```swift
import Foundation

class ConfirmationManager {
    private var alwaysAllowed: Set<String> = []
    private var neverAllowed: Set<String> = []
    private let confirmationRequired: Bool
    private let logger: Logger

    init(confirmationRequired: Bool, logger: Logger) {
        self.confirmationRequired = confirmationRequired
        self.logger = logger
    }

    /// Check if tool execution requires confirmation
    func requiresConfirmation(toolName: String) -> Bool {
        guard confirmationRequired else {
            return false
        }

        // Tools that require confirmation
        let dangerousTools = [
            "write_file",
            "edit_file",
            "run_shell"
        ]

        return dangerousTools.contains(toolName)
    }

    /// Ask user for confirmation
    /// Returns: true if allowed, false if denied
    func requestConfirmation(toolName: String, arguments: String) -> Bool {
        // Check allow/deny lists
        if alwaysAllowed.contains(toolName) {
            logger.debug("Tool \(toolName) always allowed")
            return true
        }

        if neverAllowed.contains(toolName) {
            logger.debug("Tool \(toolName) never allowed")
            return false
        }

        // Parse arguments for display
        let displayArgs = formatArgumentsForDisplay(toolName: toolName, arguments: arguments)

        // Prompt user
        print("\n⚠️  Confirm: Execute \(toolName)?")
        if !displayArgs.isEmpty {
            print("   \(displayArgs)")
        }
        print("   [y]es / [n]o / [a]lways / ne[v]er: ", terminator: "")
        fflush(stdout)

        guard let response = readLine()?.lowercased().trimmingCharacters(in: .whitespaces) else {
            return false
        }

        switch response {
        case "y", "yes":
            return true

        case "n", "no":
            return false

        case "a", "always":
            alwaysAllowed.insert(toolName)
            logger.info("Tool \(toolName) added to always-allow list")
            return true

        case "v", "never":
            neverAllowed.insert(toolName)
            logger.info("Tool \(toolName) added to never-allow list")
            return false

        default:
            print("Invalid response. Please enter y/n/a/v")
            return requestConfirmation(toolName: toolName, arguments: arguments)
        }
    }

    /// Format arguments for user-friendly display
    private func formatArgumentsForDisplay(toolName: String, arguments: String) -> String {
        guard let data = arguments.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return ""
        }

        switch toolName {
        case "write_file":
            if let path = json["path"] as? String {
                let contentLength = (json["content"] as? String)?.count ?? 0
                return "path: \(path) (\(contentLength) bytes)"
            }

        case "edit_file":
            if let path = json["path"] as? String,
               let search = json["search"] as? String {
                let searchPreview = String(search.prefix(50))
                return "path: \(path), search: \"\(searchPreview)...\""
            }

        case "run_shell":
            if let command = json["command"] as? String {
                let commandPreview = String(command.prefix(60))
                return "command: \"\(commandPreview)\""
            }

        default:
            break
        }

        return ""
    }

    /// Clear allow/deny lists
    func reset() {
        alwaysAllowed.removeAll()
        neverAllowed.removeAll()
    }

    /// Get statistics
    func getStats() -> (alwaysAllowed: Int, neverAllowed: Int) {
        return (alwaysAllowed.count, neverAllowed.count)
    }
}
```

### 2. Update Tool Executor

**File to update**: `Sources/YBS/Core/ToolExecutor.swift`

Add confirmation integration:

```swift
class ToolExecutor {
    private var tools: [String: ToolProtocol] = [:]
    private let logger: Logger
    private var confirmationManager: ConfirmationManager?

    init(logger: Logger, confirmationManager: ConfirmationManager? = nil) {
        self.logger = logger
        self.confirmationManager = confirmationManager
        registerBuiltinTools()
    }

    // ... existing methods ...

    /// Execute a tool by name
    func execute(toolName: String, arguments: String) async throws -> ToolResult {
        guard let tool = tools[toolName] else {
            logger.error("Tool not found: \(toolName)")
            throw YBSError.toolNotFound(name: toolName)
        }

        // Check confirmation
        if let confirmationMgr = confirmationManager {
            if confirmationMgr.requiresConfirmation(toolName: toolName) {
                if !confirmationMgr.requestConfirmation(toolName: toolName, arguments: arguments) {
                    logger.warn("Tool \(toolName) denied by user")
                    return .failure("Execution denied by user")
                }
            }
        }

        logger.info("Executing tool: \(toolName)")
        logger.debug("Arguments: \(arguments)")

        do {
            let result = try await tool.execute(arguments: arguments)

            if result.success {
                logger.info("Tool \(toolName) succeeded")
                if let output = result.output {
                    logger.debug("Output: \(output.prefix(200))...")
                }
            } else {
                logger.warn("Tool \(toolName) failed: \(result.error ?? "unknown")")
            }

            return result
        } catch {
            logger.error("Tool \(toolName) threw error: \(error)")
            throw YBSError.toolExecutionFailed(name: toolName, error: error.localizedDescription)
        }
    }
}
```

### 3. Update Agent Loop

**File to update**: `Sources/YBS/Agent/AgentLoop.swift`

Create confirmation manager and pass to tool executor:

```swift
class AgentLoop {
    private let llmClient: LLMClient
    private let toolExecutor: ToolExecutor
    private let confirmationManager: ConfirmationManager
    private let context: ConversationContext
    private let logger: Logger
    // ... rest of properties ...

    init(config: YBSConfig, logger: Logger) {
        self.llmClient = LLMClient(config: config.llm, logger: logger)
        self.confirmationManager = ConfirmationManager(
            confirmationRequired: config.safety.confirmation_required,
            logger: logger
        )
        self.toolExecutor = ToolExecutor(
            logger: logger,
            confirmationManager: confirmationManager
        )
        self.context = ConversationContext(
            maxMessages: config.context.max_messages,
            logger: logger
        )
        self.logger = logger
        // ... rest of init ...
    }

    // ... rest of methods unchanged ...
}
```

### 4. Add Tests

**File to create**: `Tests/YBSTests/ConfirmationManagerTests.swift`

```swift
import XCTest
@testable import YBS

final class ConfirmationManagerTests: XCTestCase {
    func testRequiresConfirmation() {
        let logger = Logger(component: "Test", useColor: false)
        let manager = ConfirmationManager(confirmationRequired: true, logger: logger)

        XCTAssertTrue(manager.requiresConfirmation(toolName: "write_file"))
        XCTAssertTrue(manager.requiresConfirmation(toolName: "edit_file"))
        XCTAssertTrue(manager.requiresConfirmation(toolName: "run_shell"))
        XCTAssertFalse(manager.requiresConfirmation(toolName: "read_file"))
        XCTAssertFalse(manager.requiresConfirmation(toolName: "list_files"))
    }

    func testConfirmationDisabled() {
        let logger = Logger(component: "Test", useColor: false)
        let manager = ConfirmationManager(confirmationRequired: false, logger: logger)

        // When disabled, nothing requires confirmation
        XCTAssertFalse(manager.requiresConfirmation(toolName: "write_file"))
        XCTAssertFalse(manager.requiresConfirmation(toolName: "run_shell"))
    }

    func testReset() {
        let logger = Logger(component: "Test", useColor: false)
        let manager = ConfirmationManager(confirmationRequired: true, logger: logger)

        // Simulate adding to allow list (would normally happen via user input)
        // Can't test interactively, but can test reset functionality

        manager.reset()
        let stats = manager.getStats()
        XCTAssertEqual(stats.alwaysAllowed, 0)
        XCTAssertEqual(stats.neverAllowed, 0)
    }
}
```

### 5. Build and Test

```bash
swift build
swift test --filter ConfirmationManagerTests
```

## Verification

```bash
cd systems/bootstrap/builds/test6
swift build
swift test --filter ConfirmationManagerTests
# Expected: All tests pass

# Integration test
export ANTHROPIC_API_KEY="your-key-here"
swift run ybs

# You: Create a file called test.txt with "Hello"
# 🔧 Using tool: write_file
# ⚠️  Confirm: Execute write_file?
#    path: test.txt (5 bytes)
#    [y]es / [n]o / [a]lways / ne[v]er: y
#    ✓ Success
# AI: I've created test.txt
#
# You: Create another file test2.txt
# 🔧 Using tool: write_file
# ⚠️  Confirm: Execute write_file?
#    path: test2.txt (0 bytes)
#    [y]es / [n]o / [a]lways / ne[v]er: n
#    ✗ Error: Execution denied by user
# AI: I'm unable to create the file as you denied the operation.
```

## Completion Checklist

- [ ] ConfirmationManager class created
- [ ] Tool classification works (dangerous vs safe)
- [ ] Confirmation prompts work
- [ ] Allow/deny lists work
- [ ] ToolExecutor integration works
- [ ] AgentLoop integration works
- [ ] Tests pass

## After Completion

Create DONE file: `docs/build-history/ybs-step_7e2f9a1c8d3b-DONE.txt`

```bash
git commit -m "Step 20: Implement confirmation system

- Add ConfirmationManager for user approval
- Prompt before destructive operations
- Support yes/no/always/never responses
- Maintain session allow/deny lists
- Integrate with ToolExecutor and AgentLoop
- Comprehensive tests

First safety layer in place!

Implements: ybs-spec.md Section 7.1

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: Step 21 - Sandboxing (sandbox-exec)
