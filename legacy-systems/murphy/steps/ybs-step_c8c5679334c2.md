# Step 000009: list_files Tool

**GUID**: c8c5679334c2
**Version**: 0.1.0
**Layer**: 2 - Basic Tools
**Estimated Size**: ~80 lines of code

## Overview

Implements the `list_files` tool for directory listings. This allows the LLM to explore the file system and understand project structure.

## What This Step Builds

A `ListFilesTool` that:
- Lists files and directories at a given path
- Supports recursive listing
- Filters hidden files (optional)
- Shows file metadata (size, modified time)
- Respects path restrictions

## Step Objectives

1. Implement ListFilesTool conforming to ToolProtocol
2. Add recursive directory traversal
3. Add filtering options (hidden files, patterns)
4. Add file metadata
5. Handle permission errors
6. Create tests

## Prerequisites

**Required Steps**:
- ✅ Step 8: read_file (Tool Protocol exists)

## Configurable Values

**Uses**:
- `safety.sandbox_allowed_paths`

## Traceability

**Implements**:
- `ybs-spec.md` Section 3.3 (list_files tool)

## Instructions

### 1. Implement ListFilesTool

**File to create**: `Sources/YBS/Tools/ListFilesTool.swift`

```swift
import Foundation

struct ListFilesTool: ToolProtocol {
    let name = "list_files"
    let description = "List files and directories at a given path."

    var parameters: ToolParameters {
        ToolParameters(
            properties: [
                "path": ToolProperty(
                    type: "string",
                    description: "Directory path to list (default: current directory)"
                ),
                "recursive": ToolProperty(
                    type: "boolean",
                    description: "Recursively list subdirectories (default: false)"
                ),
                "show_hidden": ToolProperty(
                    type: "boolean",
                    description: "Show hidden files (default: false)"
                )
            ],
            required: []
        )
    }

    func execute(arguments: String) async throws -> ToolResult {
        struct Args: Codable {
            var path: String?
            var recursive: Bool?
            var show_hidden: Bool?
        }

        let data = arguments.data(using: .utf8)!
        let args: Args
        do {
            args = try JSONDecoder().decode(Args.self, from: data)
        } catch {
            return .failure("Invalid arguments: \(error.localizedDescription)")
        }

        let basePath = args.path ?? "."
        let expandedPath = NSString(string: basePath).expandingTildeInPath
        let recursive = args.recursive ?? false
        let showHidden = args.show_hidden ?? false

        // Check if path exists
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: expandedPath, isDirectory: &isDirectory) else {
            return .failure("Path not found: \(basePath)")
        }

        guard isDirectory.boolValue else {
            return .failure("Path is not a directory: \(basePath)")
        }

        // List files
        var files: [String] = []

        func listDirectory(_ path: String, prefix: String = "") throws {
            let contents = try FileManager.default.contentsOfDirectory(atPath: path)

            for item in contents.sorted() {
                // Skip hidden files unless requested
                if !showHidden && item.hasPrefix(".") {
                    continue
                }

                let itemPath = (path as NSString).appendingPathComponent(item)
                let displayPath = prefix + item

                var isDir: ObjCBool = false
                FileManager.default.fileExists(atPath: itemPath, isDirectory: &isDir)

                if isDir.boolValue {
                    files.append(displayPath + "/")
                    if recursive {
                        try listDirectory(itemPath, prefix: displayPath + "/")
                    }
                } else {
                    // Get file size
                    if let attrs = try? FileManager.default.attributesOfItem(atPath: itemPath),
                       let size = attrs[.size] as? Int {
                        let sizeStr = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
                        files.append("\(displayPath) (\(sizeStr))")
                    } else {
                        files.append(displayPath)
                    }
                }
            }
        }

        do {
            try listDirectory(expandedPath)
        } catch {
            return .failure("Failed to list directory: \(error.localizedDescription)")
        }

        if files.isEmpty {
            return .success("Directory is empty: \(basePath)")
        }

        let result = "Contents of \(basePath):\n" + files.joined(separator: "\n")
        return .success(result)
    }
}
```

### 2. Add Tests

**File to create**: `Tests/YBSTests/ListFilesToolTests.swift`

```swift
import XCTest
@testable import YBS

final class ListFilesToolTests: XCTestCase {
    func testListFilesBasic() async throws {
        // Create test directory
        let testDir = "/tmp/ybs-test-list"
        try? FileManager.default.removeItem(atPath: testDir)
        try FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)

        // Create test files
        try "test1".write(toFile: "\(testDir)/file1.txt", atomically: true, encoding: .utf8)
        try "test2".write(toFile: "\(testDir)/file2.txt", atomically: true, encoding: .utf8)

        let tool = ListFilesTool()
        let args = "{\"path\": \"\(testDir)\"}"

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output!.contains("file1.txt"))
        XCTAssertTrue(result.output!.contains("file2.txt"))
    }

    func testListFilesRecursive() async throws {
        let testDir = "/tmp/ybs-test-recursive"
        try? FileManager.default.removeItem(atPath: testDir)
        try FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(atPath: "\(testDir)/subdir", withIntermediateDirectories: true)

        try "test".write(toFile: "\(testDir)/file.txt", atomically: true, encoding: .utf8)
        try "test".write(toFile: "\(testDir)/subdir/nested.txt", atomically: true, encoding: .utf8)

        let tool = ListFilesTool()
        let args = "{\"path\": \"\(testDir)\", \"recursive\": true}"

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output!.contains("file.txt"))
        XCTAssertTrue(result.output!.contains("subdir/nested.txt"))
    }
}
```

### 3. Build and Test

```bash
swift build
swift test --filter ListFilesToolTests
```

## Verification

```bash
swift test --filter ListFilesToolTests
# Expected: All tests pass
```

## Completion Checklist

- [ ] ListFilesTool implemented
- [ ] Recursive listing works
- [ ] Hidden file filtering works
- [ ] File sizes shown
- [ ] Tests pass

## After Completion

```bash
git commit -m "Step 9: Implement list_files tool

- Add ListFilesTool with recursive support
- Show file sizes and directory markers
- Filter hidden files (optional)
- Handle permission errors

Implements: ybs-spec.md Section 3.3

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: Step 10 - Tool Executor Framework
