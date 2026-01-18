# Step 000019: run_shell Tool (Unsandboxed)

**GUID**: 3f7d8e2b1c9a
**Version**: 0.1.0
**Layer**: 5 - More Tools
**Estimated Size**: ~100 lines of code

## Overview

Implements the `run_shell` tool for executing shell commands. This allows the LLM to run arbitrary commands like `npm install`, `git status`, `pytest`, etc.

**⚠️ Security Note**: This step implements UNSANDBOXED execution. Sandboxing will be added in Layer 6 (Step 21).

## What This Step Builds

A `RunShellTool` that:
- Executes shell commands via Process
- Captures stdout and stderr
- Returns exit code + output
- Supports timeout
- Handles command failures

## Step Objectives

1. Implement RunShellTool conforming to ToolProtocol
2. Use Process API to execute commands
3. Capture stdout and stderr separately
4. Add timeout support
5. Handle exit codes
6. Create tests

## Prerequisites

**Required Steps**:
- ✅ Step 10: Tool Executor (can register tools)

## Configurable Values

**Uses**:
- `safety.shell_timeout_seconds` (default: 60)

## Traceability

**Implements**:
- `ybs-spec.md` Section 3.6 (run_shell tool)

## Instructions

### 1. Implement RunShellTool

**File to create**: `Sources/YBS/Tools/RunShellTool.swift`

```swift
import Foundation

struct RunShellTool: ToolProtocol {
    let name = "run_shell"
    let description = """
    Execute a shell command and return the output. Use this for running build commands, \
    tests, git operations, package managers, etc.
    """

    var parameters: ToolParameters {
        ToolParameters(
            properties: [
                "command": ToolProperty(
                    type: "string",
                    description: "Shell command to execute"
                ),
                "working_dir": ToolProperty(
                    type: "string",
                    description: "Working directory for command (default: current directory)"
                ),
                "timeout": ToolProperty(
                    type: "integer",
                    description: "Timeout in seconds (default: 60)"
                )
            ],
            required: ["command"]
        )
    }

    func execute(arguments: String) async throws -> ToolResult {
        // Parse arguments
        struct Args: Codable {
            var command: String
            var working_dir: String?
            var timeout: Int?
        }

        let data = arguments.data(using: .utf8)!
        let args: Args
        do {
            args = try JSONDecoder().decode(Args.self, from: data)
        } catch {
            return .failure("Invalid arguments: \(error.localizedDescription)")
        }

        let timeout = args.timeout ?? 60
        let workingDir = args.working_dir.map { NSString(string: $0).expandingTildeInPath }

        // Create process
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", args.command]

        if let workingDir = workingDir {
            process.currentDirectoryURL = URL(fileURLWithPath: workingDir)
        }

        // Setup pipes
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        // Capture output
        var stdoutData = Data()
        var stderrData = Data()

        stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
            stdoutData.append(handle.availableData)
        }

        stderrPipe.fileHandleForReading.readabilityHandler = { handle in
            stderrData.append(handle.availableData)
        }

        // Start process
        do {
            try process.run()
        } catch {
            return .failure("Failed to start process: \(error.localizedDescription)")
        }

        // Wait with timeout
        let startTime = Date()
        while process.isRunning {
            if Date().timeIntervalSince(startTime) > Double(timeout) {
                process.terminate()
                return .failure("Command timed out after \(timeout) seconds")
            }
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        }

        // Close pipes
        stdoutPipe.fileHandleForReading.readabilityHandler = nil
        stderrPipe.fileHandleForReading.readabilityHandler = nil

        // Get final output
        stdoutData.append(try! stdoutPipe.fileHandleForReading.readToEnd() ?? Data())
        stderrData.append(try! stderrPipe.fileHandleForReading.readToEnd() ?? Data())

        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""
        let exitCode = Int(process.terminationStatus)

        // Format result
        var output = ""

        if !stdout.isEmpty {
            output += "STDOUT:\n\(stdout)\n"
        }

        if !stderr.isEmpty {
            output += "STDERR:\n\(stderr)\n"
        }

        output += "Exit code: \(exitCode)"

        if exitCode == 0 {
            return .success(output)
        } else {
            return .failure(output)
        }
    }
}
```

### 2. Update Configuration

**File to update**: `Sources/YBS/Models/Configuration.swift`

Add safety config section:

```swift
struct SafetyConfig: Codable {
    var confirmation_required: Bool = true
    var sandbox_enabled: Bool = false  // Will enable in Step 21
    var shell_timeout_seconds: Int = 60
    var sandbox_allowed_paths: [String] = ["."]

    enum CodingKeys: String, CodingKey {
        case confirmation_required = "confirmation_required"
        case sandbox_enabled = "sandbox_enabled"
        case shell_timeout_seconds = "shell_timeout_seconds"
        case sandbox_allowed_paths = "sandbox_allowed_paths"
    }
}
```

### 3. Register Tool in ToolExecutor

**File to update**: `Sources/YBS/Core/ToolExecutor.swift`

```swift
private func registerBuiltinTools() {
    register(tool: ReadFileTool())
    register(tool: ListFilesTool())
    register(tool: WriteFileTool())
    register(tool: EditFileTool())
    register(tool: SearchFilesTool())
    register(tool: RunShellTool())  // Add this
}
```

### 4. Add Tests

**File to create**: `Tests/YBSTests/RunShellToolTests.swift`

```swift
import XCTest
@testable import YBS

final class RunShellToolTests: XCTestCase {
    func testToolMetadata() {
        let tool = RunShellTool()

        XCTAssertEqual(tool.name, "run_shell")
        XCTAssertTrue(tool.description.contains("Execute"))
        XCTAssertEqual(tool.parameters.required, ["command"])
    }

    func testBasicCommand() async throws {
        let tool = RunShellTool()
        let args = """
        {
            "command": "echo 'Hello, World!'"
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output!.contains("Hello, World!"))
        XCTAssertTrue(result.output!.contains("Exit code: 0"))
    }

    func testCommandWithStderr() async throws {
        let tool = RunShellTool()
        let args = """
        {
            "command": "echo 'error message' >&2"
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output!.contains("STDERR"))
        XCTAssertTrue(result.output!.contains("error message"))
    }

    func testCommandFailure() async throws {
        let tool = RunShellTool()
        let args = """
        {
            "command": "exit 1"
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertFalse(result.success)
        XCTAssertTrue(result.error!.contains("Exit code: 1"))
    }

    func testWorkingDirectory() async throws {
        let tool = RunShellTool()
        let args = """
        {
            "command": "pwd",
            "working_dir": "/tmp"
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output!.contains("/tmp"))
    }

    func testTimeout() async throws {
        let tool = RunShellTool()
        let args = """
        {
            "command": "sleep 10",
            "timeout": 1
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertFalse(result.success)
        XCTAssertTrue(result.error!.contains("timed out"))
    }

    func testCommandWithPipe() async throws {
        let tool = RunShellTool()
        let args = """
        {
            "command": "echo 'hello\\nworld' | grep world"
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output!.contains("world"))
        XCTAssertFalse(result.output!.contains("hello"))
    }
}
```

### 5. Build and Test

```bash
swift build
swift test --filter RunShellToolTests
```

## Verification

```bash
cd systems/bootstrap/builds/test6
swift build
swift test --filter RunShellToolTests
# Expected: All tests pass

# Integration test
export ANTHROPIC_API_KEY="your-key-here"
swift run ybs

# You: What files are in the current directory?
# 🔧 Using tool: run_shell
#    ✓ Success
# AI: The current directory contains:
#     - Package.swift
#     - README.md
#     - Sources/
#     - Tests/
#     ...
#
# You: Run swift build
# 🔧 Using tool: run_shell
#    ✓ Success
# AI: Build completed successfully. Here's the output:
#     Building for debugging...
#     Build complete!
```

## Completion Checklist

- [ ] RunShellTool implemented
- [ ] Command execution works
- [ ] Stdout/stderr capture works
- [ ] Exit code handling works
- [ ] Timeout support works
- [ ] Working directory support works
- [ ] Tests pass
- [ ] Registered in ToolExecutor

## After Completion

**Layer 5 Complete!** 🎉

Create DONE file: `docs/build-history/ybs-step_3f7d8e2b1c9a-DONE.txt`

```bash
git add -A
git commit -m "Step 19: Implement run_shell tool

- Add RunShellTool for executing shell commands
- Capture stdout and stderr
- Support timeout and working directory
- Handle exit codes
- Comprehensive tests
- Register in ToolExecutor

⚠️  Sandboxing will be added in Step 21

Layer 5 (More Tools) Complete: Agent can now read, write, edit, search, and execute!

Implements: ybs-spec.md Section 3.6

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: Layer 6 - Safety (Steps 20-22)
**Next step**: Step 20 - Confirmation System
