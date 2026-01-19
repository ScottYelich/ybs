// Implements: Step 19 (search_files Tool) + ybs-spec.md § 3.5 (search_files)
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
