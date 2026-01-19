# Step 000008: read_file Tool

**GUID**: c95881a2a279
**Version**: 0.1.0
**Layer**: 2 - Basic Tools
**Estimated Size**: ~120 lines of code

## Overview

Implements the `read_file` tool - the first tool the LLM can call. This tool reads file contents with optional pagination (offset/limit) for large files.

This is the foundation for the tool system. The patterns established here (parameter validation, error handling, result format) will be reused for all other tools.

## What This Step Builds

A `ReadFileTool` that:
- Reads file contents from disk
- Supports pagination (offset/limit for large files)
- Validates paths (must be within allowed directories)
- Returns content with line numbers
- Handles errors (file not found, permission denied, etc.)
- Conforms to Tool protocol

## Step Objectives

1. Define Tool protocol (interface all tools implement)
2. Implement ReadFileTool
3. Add path validation
4. Add pagination support (offset/limit)
5. Add line numbering to output
6. Handle file I/O errors
7. Create comprehensive tests

## Prerequisites

**Required Steps**:
- ✅ Step 5: Core Data Models (Tool struct)
- ✅ Step 6: Error Handling & Logging (YBSError)

## Configurable Values

**Uses config from Step 4**:
- `safety.sandbox_allowed_paths` - Paths tool can access

## Traceability

**Implements**:
- `ybs-spec.md` Section 3.1 (read_file tool)

**References**:
- D04 (Tool Architecture: Built-in core tools)

## Instructions

### 1. Define Tool Protocol

**File to create**: `Sources/YBS/Tools/ToolProtocol.swift`

```swift
import Foundation

/// Protocol that all tools must implement
protocol ToolProtocol {
    /// Tool name (must match tool schema)
    var name: String { get }

    /// Tool description for LLM
    var description: String { get }

    /// Tool parameter schema
    var parameters: ToolParameters { get }

    /// Execute the tool with given arguments
    /// - Parameter arguments: JSON string of arguments
    /// - Returns: Tool result (success or error)
    func execute(arguments: String) async throws -> ToolResult
}
```

### 2. Implement ReadFileTool

**File to create**: `Sources/YBS/Tools/ReadFileTool.swift`

```swift
import Foundation

struct ReadFileTool: ToolProtocol {
    let name = "read_file"
    let description = "Read the contents of a file. Use this before editing any file."

    var parameters: ToolParameters {
        ToolParameters(
            properties: [
                "path": ToolProperty(
                    type: "string",
                    description: "Path to file (relative to working directory)"
                ),
                "offset": ToolProperty(
                    type: "integer",
                    description: "Line number to start reading from (1-indexed, optional)"
                ),
                "limit": ToolProperty(
                    type: "integer",
                    description: "Maximum number of lines to read (optional, default 500)"
                )
            ],
            required: ["path"]
        )
    }

    func execute(arguments: String) async throws -> ToolResult {
        // Parse arguments
        struct Args: Codable {
            var path: String
            var offset: Int?
            var limit: Int?
        }

        let data = arguments.data(using: .utf8)!
        let decoder = JSONDecoder()
        let args: Args
        do {
            args = try decoder.decode(Args.self, from: data)
        } catch {
            return .failure("Invalid arguments: \(error.localizedDescription)")
        }

        // Validate path
        let expandedPath = NSString(string: args.path).expandingTildeInPath
        let fileURL = URL(fileURLWithPath: expandedPath)

        // Check if file exists
        guard FileManager.default.fileExists(atPath: expandedPath) else {
            return .failure("File not found: \(args.path)")
        }

        // TODO: Validate path is within allowed directories (Step 22)

        // Read file
        let content: String
        do {
            content = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            return .failure("Failed to read file: \(error.localizedDescription)")
        }

        // Split into lines
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false)

        // Apply pagination
        let offset = max(1, args.offset ?? 1)
        let limit = args.limit ?? 500

        let startIndex = offset - 1  // Convert to 0-indexed
        let endIndex = min(startIndex + limit, lines.count)

        if startIndex >= lines.count {
            return .failure("Offset \(offset) exceeds file length (\(lines.count) lines)")
        }

        // Add line numbers
        let selectedLines = lines[startIndex..<endIndex]
        var numberedLines: [String] = []
        for (index, line) in selectedLines.enumerated() {
            let lineNumber = startIndex + index + 1
            numberedLines.append("\(lineNumber): \(line)")
        }

        let result = numberedLines.joined(separator: "\n")

        // Add metadata
        let metadata = """
        File: \(args.path)
        Lines: \(startIndex + 1)-\(endIndex) of \(lines.count) total
        """

        return .success(metadata + "\n\n" + result)
    }
}
```

### 3. Add Tests

**File to create**: `Tests/YBSTests/ReadFileToolTests.swift`

```swift
import XCTest
@testable import YBS

final class ReadFileToolTests: XCTestCase {
    func testToolMetadata() {
        let tool = ReadFileTool()

        XCTAssertEqual(tool.name, "read_file")
        XCTAssertTrue(tool.description.contains("Read"))
        XCTAssertEqual(tool.parameters.required, ["path"])
    }

    func testReadFileBasic() async throws {
        // Create a test file
        let testPath = "/tmp/ybs-test-read.txt"
        let testContent = "Line 1\nLine 2\nLine 3"
        try testContent.write(toFile: testPath, atomically: true, encoding: .utf8)

        let tool = ReadFileTool()
        let args = "{\"path\": \"\(testPath)\"}"

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output!.contains("Line 1"))
        XCTAssertTrue(result.output!.contains("Line 2"))
        XCTAssertTrue(result.output!.contains("Line 3"))
    }

    func testReadFileWithOffset() async throws {
        let testPath = "/tmp/ybs-test-offset.txt"
        let testContent = "Line 1\nLine 2\nLine 3\nLine 4\nLine 5"
        try testContent.write(toFile: testPath, atomically: true, encoding: .utf8)

        let tool = ReadFileTool()
        let args = "{\"path\": \"\(testPath)\", \"offset\": 3}"

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output!.contains("Line 3"))
        XCTAssertFalse(result.output!.contains("Line 1"))
    }

    func testReadFileWithLimit() async throws {
        let testPath = "/tmp/ybs-test-limit.txt"
        let testContent = (1...100).map { "Line \($0)" }.joined(separator: "\n")
        try testContent.write(toFile: testPath, atomically: true, encoding: .utf8)

        let tool = ReadFileTool()
        let args = "{\"path\": \"\(testPath)\", \"limit\": 10}"

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output!.contains("Line 1"))
        XCTAssertTrue(result.output!.contains("Line 10"))
        XCTAssertFalse(result.output!.contains("Line 11"))
    }

    func testReadFileNotFound() async throws {
        let tool = ReadFileTool()
        let args = "{\"path\": \"/nonexistent/file.txt\"}"

        let result = try await tool.execute(arguments: args)

        XCTAssertFalse(result.success)
        XCTAssertTrue(result.error!.contains("not found"))
    }
}
```

### 4. Build and Test

```bash
swift build
swift test --filter ReadFileToolTests
```

## Verification

```bash
cd systems/bootstrap/builds/test6
swift build
swift test --filter ReadFileToolTests
# Expected: All tests pass
```

## Completion Checklist

- [ ] ToolProtocol defined
- [ ] ReadFileTool implemented
- [ ] Path validation works
- [ ] Pagination (offset/limit) works
- [ ] Line numbering works
- [ ] Error handling works
- [ ] Tests pass

## After Completion

Create DONE file: `docs/build-history/ybs-step_c95881a2a279-DONE.txt`

```bash
git add -A
git commit -m "Step 8: Implement read_file tool

- Define ToolProtocol interface
- Implement ReadFileTool with pagination
- Support offset/limit for large files
- Add line numbering to output
- Handle file I/O errors
- Comprehensive tests

Implements: ybs-spec.md Section 3.1

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: Step 9 - list_files Tool
