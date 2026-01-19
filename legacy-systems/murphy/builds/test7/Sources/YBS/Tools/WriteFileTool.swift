// Implements: Step 17 (write_file Tool) + ybs-spec.md § 3.2 (write_file)
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
