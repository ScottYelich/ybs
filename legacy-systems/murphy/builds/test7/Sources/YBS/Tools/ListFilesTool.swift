// Implements: Step 10 (list_files Tool) + ybs-spec.md § 3.4 (list_files)
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
