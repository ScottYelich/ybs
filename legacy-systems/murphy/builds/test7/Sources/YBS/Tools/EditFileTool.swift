// Implements: Step 18 (edit_file Tool) + ybs-spec.md § 3.3 (edit_file)
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
