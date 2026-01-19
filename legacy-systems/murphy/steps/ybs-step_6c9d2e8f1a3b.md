# Step 000017: edit_file Tool (Search/Replace)

**GUID**: 6c9d2e8f1a3b
**Version**: 0.1.0
**Layer**: 5 - More Tools
**Estimated Size**: ~150 lines of code

## Overview

Implements the `edit_file` tool for making targeted edits to files using search/replace operations. This is safer and more precise than overwriting entire files.

## What This Step Builds

An `EditFileTool` that:
- Searches for exact text in a file
- Replaces with new text
- Validates search text is unique (prevents ambiguous edits)
- Supports fuzzy matching for minor whitespace differences
- Returns diff showing changes

## Step Objectives

1. Implement EditFileTool conforming to ToolProtocol
2. Add exact text search and replace
3. Validate search text is unique in file
4. Add fuzzy matching (optional whitespace tolerance)
5. Generate diff output showing changes
6. Create tests

## Prerequisites

**Required Steps**:
- ✅ Step 8: read_file (can read files)
- ✅ Step 16: write_file (can write files)

## Configurable Values

**Uses**:
- None (tool behavior only)

## Traceability

**Implements**:
- `ybs-spec.md` Section 3.4 (edit_file tool)

## Instructions

### 1. Implement EditFileTool

**File to create**: `Sources/YBS/Tools/EditFileTool.swift`

```swift
import Foundation

struct EditFileTool: ToolProtocol {
    let name = "edit_file"
    let description = """
    Edit a file by searching for exact text and replacing it with new text. \
    The search text must be unique in the file to ensure correct replacement.
    """

    var parameters: ToolParameters {
        ToolParameters(
            properties: [
                "path": ToolProperty(
                    type: "string",
                    description: "Path to file to edit"
                ),
                "search": ToolProperty(
                    type: "string",
                    description: "Exact text to search for (must be unique in file)"
                ),
                "replace": ToolProperty(
                    type: "string",
                    description: "Text to replace with"
                ),
                "fuzzy": ToolProperty(
                    type: "boolean",
                    description: "Allow fuzzy matching for whitespace (default: false)"
                )
            ],
            required: ["path", "search", "replace"]
        )
    }

    func execute(arguments: String) async throws -> ToolResult {
        // Parse arguments
        struct Args: Codable {
            var path: String
            var search: String
            var replace: String
            var fuzzy: Bool?
        }

        let data = arguments.data(using: .utf8)!
        let args: Args
        do {
            args = try JSONDecoder().decode(Args.self, from: data)
        } catch {
            return .failure("Invalid arguments: \(error.localizedDescription)")
        }

        let fuzzyMatch = args.fuzzy ?? false

        // Read file
        let expandedPath = NSString(string: args.path).expandingTildeInPath
        let fileURL = URL(fileURLWithPath: expandedPath)

        guard FileManager.default.fileExists(atPath: expandedPath) else {
            return .failure("File not found: \(args.path)")
        }

        let originalContent: String
        do {
            originalContent = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            return .failure("Failed to read file: \(error.localizedDescription)")
        }

        // Search for text
        let searchResult = findMatches(
            content: originalContent,
            search: args.search,
            fuzzy: fuzzyMatch
        )

        if searchResult.count == 0 {
            return .failure("Search text not found in file")
        }

        if searchResult.count > 1 {
            return .failure(
                "Search text appears \(searchResult.count) times in file. " +
                "Please provide more context to make search text unique."
            )
        }

        // Perform replacement
        let matchRange = searchResult[0]
        var newContent = originalContent
        newContent.replaceSubrange(matchRange, with: args.replace)

        // Write updated content
        do {
            try newContent.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            return .failure("Failed to write file: \(error.localizedDescription)")
        }

        // Generate diff
        let diff = generateDiff(
            original: originalContent,
            new: newContent,
            matchRange: matchRange
        )

        return .success("""
        File edited successfully: \(args.path)

        Changes:
        \(diff)
        """)
    }

    /// Find all matches of search text in content
    private func findMatches(content: String, search: String, fuzzy: Bool) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []

        if fuzzy {
            // Normalize whitespace for fuzzy matching
            let normalizedContent = normalizeWhitespace(content)
            let normalizedSearch = normalizeWhitespace(search)

            var searchIndex = normalizedContent.startIndex
            while searchIndex < normalizedContent.endIndex {
                if let range = normalizedContent.range(of: normalizedSearch, range: searchIndex..<normalizedContent.endIndex) {
                    // Map back to original content range
                    let offset = normalizedContent.distance(from: normalizedContent.startIndex, to: range.lowerBound)
                    let originalStart = content.index(content.startIndex, offsetBy: offset)
                    let originalEnd = content.index(originalStart, offsetBy: search.count)
                    ranges.append(originalStart..<originalEnd)

                    searchIndex = range.upperBound
                } else {
                    break
                }
            }
        } else {
            // Exact matching
            var searchIndex = content.startIndex
            while searchIndex < content.endIndex {
                if let range = content.range(of: search, range: searchIndex..<content.endIndex) {
                    ranges.append(range)
                    searchIndex = range.upperBound
                } else {
                    break
                }
            }
        }

        return ranges
    }

    /// Normalize whitespace for fuzzy matching
    private func normalizeWhitespace(_ text: String) -> String {
        return text
            .split(separator: " ", omittingEmptySubsequences: false)
            .joined(separator: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
    }

    /// Generate a diff showing changes
    private func generateDiff(original: String, new: String, matchRange: Range<String.Index>) -> String {
        let contextLines = 2

        let originalLines = original.split(separator: "\n", omittingEmptySubsequences: false)
        let newLines = new.split(separator: "\n", omittingEmptySubsequences: false)

        // Find line number of change
        let beforeMatch = original[..<matchRange.lowerBound]
        let lineNumber = beforeMatch.split(separator: "\n").count

        // Generate context diff
        var diff = ""
        let startLine = max(0, lineNumber - contextLines - 1)
        let endLine = min(originalLines.count, lineNumber + contextLines)

        for i in startLine..<endLine {
            let lineNum = i + 1
            if i < originalLines.count {
                if i == lineNumber - 1 {
                    diff += "- \(lineNum): \(originalLines[i])\n"
                } else {
                    diff += "  \(lineNum): \(originalLines[i])\n"
                }
            }
        }

        // Show new lines
        for i in startLine..<min(newLines.count, endLine) {
            let lineNum = i + 1
            if i == lineNumber - 1 {
                diff += "+ \(lineNum): \(newLines[i])\n"
            }
        }

        return diff
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
    register(tool: EditFileTool())  // Add this
}
```

### 3. Add Tests

**File to create**: `Tests/YBSTests/EditFileToolTests.swift`

```swift
import XCTest
@testable import YBS

final class EditFileToolTests: XCTestCase {
    func testToolMetadata() {
        let tool = EditFileTool()

        XCTAssertEqual(tool.name, "edit_file")
        XCTAssertTrue(tool.description.contains("Edit"))
        XCTAssertEqual(tool.parameters.required, ["path", "search", "replace"])
    }

    func testBasicEdit() async throws {
        let testPath = "/tmp/ybs-test-edit.txt"
        let content = "Hello World\nGoodbye World\n"
        try content.write(toFile: testPath, atomically: true, encoding: .utf8)

        let tool = EditFileTool()
        let args = """
        {
            "path": "\(testPath)",
            "search": "Hello World",
            "replace": "Hi Universe"
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)

        let newContent = try String(contentsOfFile: testPath, encoding: .utf8)
        XCTAssertTrue(newContent.contains("Hi Universe"))
        XCTAssertFalse(newContent.contains("Hello World"))
        XCTAssertTrue(newContent.contains("Goodbye World"))
    }

    func testSearchNotFound() async throws {
        let testPath = "/tmp/ybs-test-not-found.txt"
        try "Hello World".write(toFile: testPath, atomically: true, encoding: .utf8)

        let tool = EditFileTool()
        let args = """
        {
            "path": "\(testPath)",
            "search": "Nonexistent Text",
            "replace": "New Text"
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertFalse(result.success)
        XCTAssertTrue(result.error!.contains("not found"))
    }

    func testNonUniqueSearch() async throws {
        let testPath = "/tmp/ybs-test-non-unique.txt"
        let content = "Hello World\nHello World\n"
        try content.write(toFile: testPath, atomically: true, encoding: .utf8)

        let tool = EditFileTool()
        let args = """
        {
            "path": "\(testPath)",
            "search": "Hello World",
            "replace": "Hi"
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertFalse(result.success)
        XCTAssertTrue(result.error!.contains("2 times"))
    }

    func testMultilineEdit() async throws {
        let testPath = "/tmp/ybs-test-multiline.txt"
        let content = """
        function test() {
            console.log("old");
        }
        """
        try content.write(toFile: testPath, atomically: true, encoding: .utf8)

        let tool = EditFileTool()
        let args = """
        {
            "path": "\(testPath)",
            "search": "console.log(\\"old\\");",
            "replace": "console.log(\\"new\\");"
        }
        """

        let result = try await tool.execute(arguments: args)

        XCTAssertTrue(result.success)

        let newContent = try String(contentsOfFile: testPath, encoding: .utf8)
        XCTAssertTrue(newContent.contains("console.log(\"new\")"))
    }
}
```

### 4. Build and Test

```bash
swift build
swift test --filter EditFileToolTests
```

## Verification

```bash
cd systems/bootstrap/builds/test6
swift build
swift test --filter EditFileToolTests
# Expected: All tests pass

# Integration test
export ANTHROPIC_API_KEY="your-key-here"
swift run ybs

# You: Create a file called math.py with "def add(a, b):\n    return a + b"
# 🔧 Using tool: write_file
#    ✓ Success
#
# You: Change "return a + b" to "return a + b + 1" in math.py
# 🔧 Using tool: edit_file
#    ✓ Success
# AI: I've updated math.py:
#     - return a + b
#     + return a + b + 1
```

## Completion Checklist

- [ ] EditFileTool implemented
- [ ] Exact text search works
- [ ] Replacement works
- [ ] Uniqueness validation works
- [ ] Diff generation works
- [ ] Error handling works
- [ ] Tests pass
- [ ] Registered in ToolExecutor

## After Completion

Create DONE file: `docs/build-history/ybs-step_6c9d2e8f1a3b-DONE.txt`

```bash
git commit -m "Step 17: Implement edit_file tool

- Add EditFileTool for search/replace editing
- Validate search text uniqueness
- Generate diff output
- Support fuzzy whitespace matching
- Comprehensive tests
- Register in ToolExecutor

Implements: ybs-spec.md Section 3.4

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: Step 18 - search_files Tool
