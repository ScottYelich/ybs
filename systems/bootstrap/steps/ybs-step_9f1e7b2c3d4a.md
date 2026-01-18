# Step 000016: write_file Tool

**GUID**: 9f1e7b2c3d4a
**Version**: 0.1.0
**Layer**: 5 - More Tools
**Estimated Size**: ~100 lines of code

## Overview

Implements the `write_file` tool for creating or overwriting files. This allows the LLM to create new files or replace existing ones with new content.

## What This Step Builds

A `WriteFileTool` that:
- Writes content to a file path
- Creates parent directories if needed
- Overwrites existing files
- Returns success or error
- Validates paths (no sensitive directories)

## Step Objectives

1. Implement WriteFileTool conforming to ToolProtocol
2. Add file writing with error handling
3. Create parent directories automatically
4. Handle overwrite confirmation (placeholder for now)
5. Validate paths
6. Create tests

## Prerequisites

**Required Steps**:
- ✅ Step 8: read_file (Tool pattern established)
- ✅ Step 10: Tool Executor (can register tools)

## Configurable Values

**Uses**:
- `safety.sandbox_allowed_paths` (will use in Layer 6)

## Traceability

**Implements**:
- `ybs-spec.md` Section 3.2 (write_file tool)

## Instructions

### 1. Implement WriteFileTool

**File to create**: `Sources/YBS/Tools/WriteFileTool.swift`

```swift
import Foundation

struct WriteFileTool: ToolProtocol {
    let name = "write_file"
    let description = "Write content to a file. Creates the file if it doesn't exist, overwrites if it does."

    var parameters: ToolParameters {
        ToolParameters(
            properties: [
                "path": ToolProperty(
                    type: "string",
                    description: "Path to file (relative to working directory)"
                ),
                "content": ToolProperty(
                    type: "string",
                    description: "Content to write to the file"
                )
            ],
            required: ["path", "content"]
        )
    }

    func execute(arguments: String) async throws -> ToolResult {
        // Parse arguments
        struct Args: Codable {
            var path: String
            var content: String
        }

        let data = arguments.data(using: .utf8)!
        let args: Args
        do {
            args = try JSONDecoder().decode(Args.self, from: data)
        } catch {
            return .failure("Invalid arguments: \(error.localizedDescription)")
        }

        // Validate path
        let expandedPath = NSString(string: args.path).expandingTildeInPath
        let fileURL = URL(fileURLWithPath: expandedPath)

        // TODO: Validate path is within allowed directories (Step 22)

        // Create parent directories if needed
        let parentDir = fileURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(
                at: parentDir,
                withIntermediateDirectories: true
            )
        } catch {
            return .failure("Failed to create parent directories: \(error.localizedDescription)")
        }

        // Write file
        do {
            try args.content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            return .failure("Failed to write file: \(error.localizedDescription)")
        }

        // Get file size for confirmation
        let attrs = try? FileManager.default.attributesOfItem(atPath: expandedPath)
        let size = attrs?[.size] as? Int ?? 0
        let sizeStr = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)

        return .success("File written successfully: \(args.path) (\(sizeStr))")
    }
}
```

### 2. Register Tool in ToolExecutor

**File to update**: `Sources/YBS/Core/ToolExecutor.swift`

Add WriteFileTool to registration:

```swift
private func registerBuiltinTools() {
    register(tool: ReadFileTool())
    register(tool: ListFilesTool())
    register(tool: WriteFileTool())  // Add this
}
```

### 3. Add Tests

**File to create**: `Tests/YBSTests/WriteFileToolTests.swift`

```swift
import XCTest
@testable import YBS

final class WriteFileToolTests: XCTestCase {
    func testToolMetadata() {
        let tool = WriteFileTool()

        XCTAssertEqual(tool.name, "write_file")
        XCTAssertTrue(tool.description.contains("Write"))
        XCTAssertEqual(tool.parameters.required, ["path", "content"])
    }

    func testWriteFileBasic() async throws {
        let testPath = "/tmp/ybs-test-write.txt"

        // Remove if exists
        try? FileManager.default.removeItem(atPath: testPath)

        let tool = WriteFileTool()
        let args = """
        {
            "path": "\(testPath)",
            "content": "Hello, World!"
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)

        // Verify file was created
        XCTAssertTrue(FileManager.default.fileExists(atPath: testPath))

        // Verify content
        let content = try String(contentsOfFile: testPath, encoding: .utf8)
        XCTAssertEqual(content, "Hello, World!")
    }

    func testWriteFileOverwrite() async throws {
        let testPath = "/tmp/ybs-test-overwrite.txt"

        // Create initial file
        try "Initial content".write(toFile: testPath, atomically: true, encoding: .utf8)

        let tool = WriteFileTool()
        let args = """
        {
            "path": "\(testPath)",
            "content": "New content"
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)

        // Verify content was overwritten
        let content = try String(contentsOfFile: testPath, encoding: .utf8)
        XCTAssertEqual(content, "New content")
    }

    func testWriteFileWithDirectories() async throws {
        let testDir = "/tmp/ybs-test-nested"
        let testPath = "\(testDir)/subdir/file.txt"

        // Remove if exists
        try? FileManager.default.removeItem(atPath: testDir)

        let tool = WriteFileTool()
        let args = """
        {
            "path": "\(testPath)",
            "content": "Nested file content"
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)

        // Verify file was created
        XCTAssertTrue(FileManager.default.fileExists(atPath: testPath))

        // Verify content
        let content = try String(contentsOfFile: testPath, encoding: .utf8)
        XCTAssertEqual(content, "Nested file content")
    }

    func testWriteFileMultiline() async throws {
        let testPath = "/tmp/ybs-test-multiline.txt"
        try? FileManager.default.removeItem(atPath: testPath)

        let tool = WriteFileTool()
        let multilineContent = """
        Line 1
        Line 2
        Line 3
        """

        let args = """
        {
            "path": "\(testPath)",
            "content": "\(multilineContent.replacingOccurrences(of: "\n", with: "\\n"))"
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)

        let content = try String(contentsOfFile: testPath, encoding: .utf8)
        XCTAssertEqual(content.split(separator: "\n").count, 3)
    }
}
```

### 4. Build and Test

```bash
swift build
swift test --filter WriteFileToolTests
```

## Verification

```bash
cd systems/bootstrap/builds/test6
swift build
swift test --filter WriteFileToolTests
# Expected: All tests pass

# Integration test
export ANTHROPIC_API_KEY="your-key-here"
swift run ybs

# You: Create a file called hello.txt with "Hello from YBS!"
# 🔧 Using tool: write_file
#    ✓ Success
# AI: I've created hello.txt with the content "Hello from YBS!"
#
# You: Read hello.txt
# 🔧 Using tool: read_file
#    ✓ Success
# AI: The file contains: "Hello from YBS!"
```

## Completion Checklist

- [ ] WriteFileTool implemented
- [ ] File creation works
- [ ] File overwriting works
- [ ] Parent directory creation works
- [ ] Error handling works
- [ ] Tests pass
- [ ] Registered in ToolExecutor

## After Completion

Create DONE file: `docs/build-history/ybs-step_9f1e7b2c3d4a-DONE.txt`

```bash
git commit -m "Step 16: Implement write_file tool

- Add WriteFileTool for creating/overwriting files
- Create parent directories automatically
- Handle file I/O errors
- Comprehensive tests
- Register in ToolExecutor

Implements: ybs-spec.md Section 3.2

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: Step 17 - edit_file Tool
