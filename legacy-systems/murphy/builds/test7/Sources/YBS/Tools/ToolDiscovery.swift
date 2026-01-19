// Implements: Step 25 (External Tool Discovery) + ybs-spec.md § 5.2 (Runtime Tool Loading)
import Foundation

/// Discovers and loads external tools from configured directories
class ToolDiscovery {
    private let logger: Logger
    private let toolPaths: [String]

    init(toolPaths: [String], logger: Logger) {
        self.toolPaths = toolPaths
        self.logger = logger
    }

    /// Discover and load all external tools
    /// - Returns: Array of discovered ExternalTool instances
    func discoverTools() async -> [ExternalTool] {
        var discoveredTools: [ExternalTool] = []

        for path in toolPaths {
            let tools = await scanDirectory(path)
            discoveredTools.append(contentsOf: tools)
        }

        logger.info("Discovered \(discoveredTools.count) external tools")
        return discoveredTools
    }

    /// Scan directory for executable files and load them as tools
    private func scanDirectory(_ path: String) async -> [ExternalTool] {
        let expandedPath = NSString(string: path).expandingTildeInPath
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: expandedPath) else {
            logger.debug("Tool directory does not exist: \(expandedPath)")
            return []
        }

        guard let enumerator = fileManager.enumerator(atPath: expandedPath) else {
            logger.warn("Failed to enumerate directory: \(expandedPath)")
            return []
        }

        var tools: [ExternalTool] = []

        for case let filename as String in enumerator {
            let fullPath = NSString(string: expandedPath).appendingPathComponent(filename)

            // Skip hidden files and directories
            if filename.hasPrefix(".") {
                continue
            }

            // Check if executable
            if isExecutable(fullPath) {
                if let tool = await loadTool(from: fullPath) {
                    tools.append(tool)
                }
            }
        }

        return tools
    }

    /// Check if file is executable
    private func isExecutable(_ path: String) -> Bool {
        let fileManager = FileManager.default

        // Check file exists
        guard fileManager.fileExists(atPath: path) else {
            return false
        }

        // Check executable bit
        guard fileManager.isExecutableFile(atPath: path) else {
            return false
        }

        // Check not a directory
        var isDirectory: ObjCBool = false
        fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
        guard !isDirectory.boolValue else {
            return false
        }

        return true
    }

    /// Load tool schema by executing tool with --schema flag
    private func loadTool(from path: String) async -> ExternalTool? {
        logger.debug("Loading tool from: \(path)")

        // Execute tool with --schema flag
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = ["--schema"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe() // Discard stderr

        do {
            try process.run()

            // Wait with timeout (5 seconds)
            let startTime = Date()
            while process.isRunning {
                if Date().timeIntervalSince(startTime) > 5.0 {
                    process.terminate()
                    logger.warn("Tool schema loading timed out: \(path)")
                    return nil
                }
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            }

            // Read schema JSON
            let data = try pipe.fileHandleForReading.readToEnd() ?? Data()
            let schema = try JSONDecoder().decode(ExternalToolSchema.self, from: data)

            logger.info("Loaded external tool: \(schema.name)")
            return ExternalTool(executablePath: path, schema: schema)

        } catch {
            logger.warn("Failed to load tool from \(path): \(error.localizedDescription)")
            return nil
        }
    }
}
