# Step 000018: search_files Tool (Grep-like)

**GUID**: 1a8e5c9f2b7d
**Version**: 0.1.0
**Layer**: 5 - More Tools
**Estimated Size**: ~120 lines of code

## Overview

Implements the `search_files` tool for searching text across multiple files (like grep). This allows the LLM to find code patterns, imports, function definitions, etc.

## What This Step Builds

A `SearchFilesTool` that:
- Searches for text/regex pattern in files
- Recursively searches directories
- Returns file paths + line numbers + matched lines
- Limits results (prevents overwhelming output)
- Supports case-insensitive search
- Filters by file extension

## Step Objectives

1. Implement SearchFilesTool conforming to ToolProtocol
2. Add recursive directory traversal
3. Add regex pattern matching
4. Return matches with context (line numbers + content)
5. Limit results (max matches per file, max total matches)
6. Create tests

## Prerequisites

**Required Steps**:
- ✅ Step 8: read_file (file operations)
- ✅ Step 9: list_files (directory traversal)

## Configurable Values

**Uses**:
- None (tool behavior only)

## Traceability

**Implements**:
- `ybs-spec.md` Section 3.5 (search_files tool)

## Instructions

### 1. Implement SearchFilesTool

**File to create**: `Sources/YBS/Tools/SearchFilesTool.swift`

```swift
import Foundation

struct SearchFilesTool: ToolProtocol {
    let name = "search_files"
    let description = """
    Search for text or regex pattern across files. Returns file paths, line numbers, and matched lines. \
    Useful for finding code patterns, imports, function definitions, etc.
    """

    var parameters: ToolParameters {
        ToolParameters(
            properties: [
                "path": ToolProperty(
                    type: "string",
                    description: "Directory to search (default: current directory)"
                ),
                "pattern": ToolProperty(
                    type: "string",
                    description: "Text or regex pattern to search for"
                ),
                "recursive": ToolProperty(
                    type: "boolean",
                    description: "Recursively search subdirectories (default: true)"
                ),
                "case_insensitive": ToolProperty(
                    type: "boolean",
                    description: "Case-insensitive search (default: false)"
                ),
                "file_pattern": ToolProperty(
                    type: "string",
                    description: "Filter files by pattern (e.g., '*.swift', '*.py')"
                ),
                "max_results": ToolProperty(
                    type: "integer",
                    description: "Maximum total results to return (default: 50)"
                )
            ],
            required: ["pattern"]
        )
    }

    func execute(arguments: String) async throws -> ToolResult {
        // Parse arguments
        struct Args: Codable {
            var path: String?
            var pattern: String
            var recursive: Bool?
            var case_insensitive: Bool?
            var file_pattern: String?
            var max_results: Int?
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
        let recursive = args.recursive ?? true
        let caseInsensitive = args.case_insensitive ?? false
        let maxResults = args.max_results ?? 50

        // Check if path exists
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: expandedPath, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            return .failure("Path not found or not a directory: \(basePath)")
        }

        // Create regex
        let regexOptions: NSRegularExpression.Options = caseInsensitive ? [.caseInsensitive] : []
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: args.pattern, options: regexOptions)
        } catch {
            return .failure("Invalid regex pattern: \(error.localizedDescription)")
        }

        // Search files
        var allMatches: [SearchMatch] = []
        let filePattern = args.file_pattern

        func searchDirectory(_ path: String) throws {
            let contents = try FileManager.default.contentsOfDirectory(atPath: path)

            for item in contents {
                // Skip hidden files/directories
                if item.hasPrefix(".") {
                    continue
                }

                let itemPath = (path as NSString).appendingPathComponent(item)

                var isDir: ObjCBool = false
                FileManager.default.fileExists(atPath: itemPath, isDirectory: &isDir)

                if isDir.boolValue {
                    if recursive {
                        try searchDirectory(itemPath)
                    }
                } else {
                    // Check file pattern filter
                    if let pattern = filePattern {
                        if !matchesFilePattern(filename: item, pattern: pattern) {
                            continue
                        }
                    }

                    // Search file
                    if let matches = searchFile(path: itemPath, regex: regex) {
                        allMatches.append(contentsOf: matches)

                        // Stop if max results reached
                        if allMatches.count >= maxResults {
                            return
                        }
                    }
                }
            }
        }

        do {
            try searchDirectory(expandedPath)
        } catch {
            return .failure("Failed to search directory: \(error.localizedDescription)")
        }

        // Format results
        if allMatches.isEmpty {
            return .success("No matches found for pattern: \(args.pattern)")
        }

        // Trim to max results
        let results = Array(allMatches.prefix(maxResults))

        var output = "Found \(results.count) matches"
        if allMatches.count > maxResults {
            output += " (showing first \(maxResults))"
        }
        output += ":\n\n"

        // Group by file
        var matchesByFile: [String: [SearchMatch]] = [:]
        for match in results {
            matchesByFile[match.filePath, default: []].append(match)
        }

        for (filePath, matches) in matchesByFile.sorted(by: { $0.key < $1.key }) {
            let relativePath = filePath.replacingOccurrences(of: expandedPath + "/", with: "")
            output += "📄 \(relativePath) (\(matches.count) matches):\n"

            for match in matches {
                output += "   \(match.lineNumber): \(match.lineContent.trimmingCharacters(in: .whitespaces))\n"
            }
            output += "\n"
        }

        return .success(output)
    }

    /// Search a single file for pattern
    private func searchFile(path: String, regex: NSRegularExpression) -> [SearchMatch]? {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return nil
        }

        let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
        var matches: [SearchMatch] = []

        for (index, line) in lines.enumerated() {
            let lineStr = String(line)
            let range = NSRange(lineStr.startIndex..., in: lineStr)

            if regex.firstMatch(in: lineStr, options: [], range: range) != nil {
                matches.append(SearchMatch(
                    filePath: path,
                    lineNumber: index + 1,
                    lineContent: lineStr
                ))
            }
        }

        return matches.isEmpty ? nil : matches
    }

    /// Check if filename matches glob-like pattern
    private func matchesFilePattern(filename: String, pattern: String) -> Bool {
        // Simple glob matching (* wildcard only)
        let regexPattern = pattern
            .replacingOccurrences(of: ".", with: "\\.")
            .replacingOccurrences(of: "*", with: ".*")

        guard let regex = try? NSRegularExpression(pattern: "^" + regexPattern + "$") else {
            return false
        }

        let range = NSRange(filename.startIndex..., in: filename)
        return regex.firstMatch(in: filename, options: [], range: range) != nil
    }

    struct SearchMatch {
        let filePath: String
        let lineNumber: Int
        let lineContent: String
    }
}
```

### 2. Register Tool in ToolExecutor

**File to update**: `Sources/YBS/Core/ToolExecutor.swift`

```swift
private func registerBuiltinTools() {
    register(tool: ReadFileTool())
    register(tool: ListFilesTool())
    register(tool: WriteFileTool())
    register(tool: EditFileTool())
    register(tool: SearchFilesTool())  // Add this
}
```

### 3. Add Tests

**File to create**: `Tests/YBSTests/SearchFilesToolTests.swift`

```swift
import XCTest
@testable import YBS

final class SearchFilesToolTests: XCTestCase {
    func testToolMetadata() {
        let tool = SearchFilesTool()

        XCTAssertEqual(tool.name, "search_files")
        XCTAssertTrue(tool.description.contains("Search"))
        XCTAssertEqual(tool.parameters.required, ["pattern"])
    }

    func testBasicSearch() async throws {
        // Create test directory
        let testDir = "/tmp/ybs-test-search"
        try? FileManager.default.removeItem(atPath: testDir)
        try FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)

        // Create test files
        try "import Foundation\nlet x = 1".write(toFile: "\(testDir)/file1.swift", atomically: true, encoding: .utf8)
        try "import UIKit\nlet y = 2".write(toFile: "\(testDir)/file2.swift", atomically: true, encoding: .utf8)
        try "let z = 3".write(toFile: "\(testDir)/file3.swift", atomically: true, encoding: .utf8)

        let tool = SearchFilesTool()
        let args = """
        {
            "path": "\(testDir)",
            "pattern": "import",
            "recursive": false
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output!.contains("file1.swift"))
        XCTAssertTrue(result.output!.contains("file2.swift"))
        XCTAssertFalse(result.output!.contains("file3.swift"))
    }

    func testFilePatternFilter() async throws {
        let testDir = "/tmp/ybs-test-filter"
        try? FileManager.default.removeItem(atPath: testDir)
        try FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)

        try "test content".write(toFile: "\(testDir)/file.swift", atomically: true, encoding: .utf8)
        try "test content".write(toFile: "\(testDir)/file.py", atomically: true, encoding: .utf8)
        try "test content".write(toFile: "\(testDir)/file.txt", atomically: true, encoding: .utf8)

        let tool = SearchFilesTool()
        let args = """
        {
            "path": "\(testDir)",
            "pattern": "test",
            "file_pattern": "*.swift"
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output!.contains("file.swift"))
        XCTAssertFalse(result.output!.contains("file.py"))
        XCTAssertFalse(result.output!.contains("file.txt"))
    }

    func testCaseInsensitive() async throws {
        let testDir = "/tmp/ybs-test-case"
        try? FileManager.default.removeItem(atPath: testDir)
        try FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)

        try "HELLO world".write(toFile: "\(testDir)/file.txt", atomically: true, encoding: .utf8)

        let tool = SearchFilesTool()
        let args = """
        {
            "path": "\(testDir)",
            "pattern": "hello",
            "case_insensitive": true
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output!.contains("HELLO"))
    }

    func testRegexPattern() async throws {
        let testDir = "/tmp/ybs-test-regex"
        try? FileManager.default.removeItem(atPath: testDir)
        try FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)

        try "func test1() {}\nfunc test2() {}\nlet x = 1".write(toFile: "\(testDir)/file.swift", atomically: true, encoding: .utf8)

        let tool = SearchFilesTool()
        let args = """
        {
            "path": "\(testDir)",
            "pattern": "func \\\\w+\\\\(\\\\)"
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output!.contains("test1"))
        XCTAssertTrue(result.output!.contains("test2"))
    }
}
```

### 4. Build and Test

```bash
swift build
swift test --filter SearchFilesToolTests
```

## Verification

```bash
cd systems/bootstrap/builds/test6
swift build
swift test --filter SearchFilesToolTests
# Expected: All tests pass

# Integration test
export ANTHROPIC_API_KEY="your-key-here"
swift run ybs

# You: Find all files that import Foundation
# 🔧 Using tool: search_files
#    ✓ Success
# AI: I found 8 files that import Foundation:
#     📄 Sources/YBS/Core/Logger.swift (1 match):
#        1: import Foundation
#     📄 Sources/YBS/LLM/HTTPClient.swift (1 match):
#        1: import Foundation
#     ...
```

## Completion Checklist

- [ ] SearchFilesTool implemented
- [ ] Recursive directory search works
- [ ] Regex pattern matching works
- [ ] File pattern filtering works
- [ ] Case-insensitive search works
- [ ] Result limiting works
- [ ] Tests pass
- [ ] Registered in ToolExecutor

## After Completion

Create DONE file: `docs/build-history/ybs-step_1a8e5c9f2b7d-DONE.txt`

```bash
git commit -m "Step 18: Implement search_files tool

- Add SearchFilesTool for grep-like searching
- Support regex patterns and file filtering
- Recursive directory traversal
- Case-insensitive option
- Result limiting and formatting
- Comprehensive tests
- Register in ToolExecutor

Implements: ybs-spec.md Section 3.5

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: Step 19 - run_shell Tool
