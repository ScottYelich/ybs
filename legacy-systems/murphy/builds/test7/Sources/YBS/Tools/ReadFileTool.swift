// Implements: Step 9 (read_file Tool) + ybs-spec.md § 3.1 (read_file)
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
