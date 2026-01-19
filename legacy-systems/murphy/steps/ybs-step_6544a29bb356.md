# Step 000010: Tool Executor Framework

**GUID**: 6544a29bb356
**Version**: 0.1.0
**Layer**: 2 - Basic Tools
**Estimated Size**: ~100 lines of code

## Overview

Implements the Tool Executor - a registry and execution engine for all tools. This provides a unified interface for the agent loop to discover and execute tools.

This completes Layer 2 (Basic Tools). After this step, we have working file operations and a framework for adding more tools.

## What This Step Builds

A `ToolExecutor` that:
- Maintains a registry of available tools
- Executes tools by name with JSON arguments
- Handles tool errors uniformly
- Provides tool schemas for LLM
- Supports async tool execution
- Logs tool executions

## Step Objectives

1. Create ToolExecutor class
2. Implement tool registry (name → ToolProtocol)
3. Implement execute method (takes name + args, returns result)
4. Add tool discovery (list all available tools)
5. Add schema generation (for LLM tool definitions)
6. Integrate logging
7. Create tests

## Prerequisites

**Required Steps**:
- ✅ Step 8: read_file (ToolProtocol exists)
- ✅ Step 9: list_files (multiple tools exist)
- ✅ Step 6: Logging (Logger)

## Configurable Values

None - this is infrastructure.

## Traceability

**Implements**:
- `ybs-spec.md` Section 4 (Tool Architecture)

**References**:
- D04 (Tool Architecture: Built-in core + External plugins)

## Instructions

### 1. Implement ToolExecutor

**File to create**: `Sources/YBS/Core/ToolExecutor.swift`

```swift
import Foundation

/// Central registry and executor for all tools
class ToolExecutor {
    private var tools: [String: ToolProtocol] = [:]
    private let logger: Logger

    init(logger: Logger) {
        self.logger = logger
        registerBuiltinTools()
    }

    /// Register built-in tools
    private func registerBuiltinTools() {
        register(tool: ReadFileTool())
        register(tool: ListFilesTool())
    }

    /// Register a tool
    func register(tool: ToolProtocol) {
        tools[tool.name] = tool
        logger.debug("Registered tool: \(tool.name)")
    }

    /// Get all available tools
    func availableTools() -> [ToolProtocol] {
        return Array(tools.values)
    }

    /// Get tool schemas for LLM (OpenAI format)
    func toolSchemas() -> [Tool] {
        return tools.values.map { tool in
            Tool(
                name: tool.name,
                description: tool.description,
                parameters: tool.parameters
            )
        }
    }

    /// Execute a tool by name
    func execute(toolName: String, arguments: String) async throws -> ToolResult {
        guard let tool = tools[toolName] else {
            logger.error("Tool not found: \(toolName)")
            throw YBSError.toolNotFound(name: toolName)
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

    /// Execute multiple tools in sequence
    func executeMultiple(toolCalls: [ToolCall]) async -> [ToolResult] {
        var results: [ToolResult] = []

        for toolCall in toolCalls {
            do {
                let result = try await execute(
                    toolName: toolCall.function.name,
                    arguments: toolCall.function.arguments
                )
                results.append(result)
            } catch {
                results.append(.failure(error.localizedDescription))
            }
        }

        return results
    }

    /// Check if a tool is registered
    func hasTool(named name: String) -> Bool {
        return tools[name] != nil
    }

    /// Get tool by name (for inspection)
    func tool(named name: String) -> ToolProtocol? {
        return tools[name]
    }
}
```

### 2. Add Tests

**File to create**: `Tests/YBSTests/ToolExecutorTests.swift`

```swift
import XCTest
@testable import YBS

final class ToolExecutorTests: XCTestCase {
    func testToolRegistration() {
        let logger = Logger(component: "Test", useColor: false)
        let executor = ToolExecutor(logger: logger)

        XCTAssertTrue(executor.hasTool(named: "read_file"))
        XCTAssertTrue(executor.hasTool(named: "list_files"))
        XCTAssertFalse(executor.hasTool(named: "nonexistent_tool"))
    }

    func testAvailableTools() {
        let logger = Logger(component: "Test", useColor: false)
        let executor = ToolExecutor(logger: logger)

        let tools = executor.availableTools()
        XCTAssertGreaterThanOrEqual(tools.count, 2)

        let toolNames = tools.map { $0.name }
        XCTAssertTrue(toolNames.contains("read_file"))
        XCTAssertTrue(toolNames.contains("list_files"))
    }

    func testToolSchemas() {
        let logger = Logger(component: "Test", useColor: false)
        let executor = ToolExecutor(logger: logger)

        let schemas = executor.toolSchemas()
        XCTAssertGreaterThanOrEqual(schemas.count, 2)

        let readFileTool = schemas.first { $0.function.name == "read_file" }
        XCTAssertNotNil(readFileTool)
        XCTAssertTrue(readFileTool!.function.description.contains("Read"))
    }

    func testExecuteReadFile() async throws {
        // Create test file
        let testPath = "/tmp/ybs-test-executor.txt"
        try "Test content".write(toFile: testPath, atomically: true, encoding: .utf8)

        let logger = Logger(component: "Test", useColor: false)
        let executor = ToolExecutor(logger: logger)

        let args = "{\"path\": \"\(testPath)\"}"
        let result = try await executor.execute(toolName: "read_file", arguments: args)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output!.contains("Test content"))
    }

    func testExecuteNonexistentTool() async {
        let logger = Logger(component: "Test", useColor: false)
        let executor = ToolExecutor(logger: logger)

        do {
            _ = try await executor.execute(toolName: "fake_tool", arguments: "{}")
            XCTFail("Should have thrown error")
        } catch YBSError.toolNotFound(let name) {
            XCTAssertEqual(name, "fake_tool")
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
}
```

### 3. Build and Test

```bash
swift build
swift test --filter ToolExecutorTests
```

## Verification

```bash
cd systems/bootstrap/builds/test6
swift build
swift test --filter ToolExecutorTests
# Expected: All tests pass
```

## Completion Checklist

- [ ] ToolExecutor class created
- [ ] Tool registry works
- [ ] Tool execution works
- [ ] Schema generation works
- [ ] Logging integrated
- [ ] Tests pass

## After Completion

**Layer 2 Complete!** 🎉

Create DONE file: `docs/build-history/ybs-step_6544a29bb356-DONE.txt`

```bash
git add -A
git commit -m "Step 10: Implement tool executor framework

- Add ToolExecutor with tool registry
- Support tool execution by name
- Generate tool schemas for LLM
- Add logging for tool execution
- Support async execution
- Comprehensive tests

Layer 2 (Basic Tools) Complete: read_file, list_files, executor ready

Implements: ybs-spec.md Section 4

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: Layer 3 - LLM Client (Steps 11-12)
**Next step**: Step 11 - HTTP Client & OpenAI API Types
