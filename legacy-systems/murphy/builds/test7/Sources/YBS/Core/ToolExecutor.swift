// Implements: Step 11 (Tool Executor Framework) + ybs-spec.md § 3 (Core Tools)
import Foundation

/// Central registry and executor for all tools
class ToolExecutor {
    private var tools: [String: ToolProtocol] = [:]
    private let logger: Logger

    init(logger: Logger) {
        self.logger = logger
        registerBuiltinTools()
    }

    /// Register built-in tools
    private func registerBuiltinTools() {
        register(tool: ReadFileTool())
        register(tool: ListFilesTool())
        register(tool: WriteFileTool())
        register(tool: EditFileTool())
        register(tool: SearchFilesTool())
        register(tool: RunShellTool())
    }

    /// Register a tool
    func register(tool: ToolProtocol) {
        tools[tool.name] = tool
        logger.debug("Registered tool: \(tool.name)")
    }

    /// Get all available tools
    func availableTools() -> [ToolProtocol] {
        return Array(tools.values)
    }

    /// Get tool schemas for LLM (OpenAI format)
    func toolSchemas() -> [Tool] {
        return tools.values.map { tool in
            Tool(
                name: tool.name,
                description: tool.description,
                parameters: tool.parameters
            )
        }
    }

    /// Execute a tool by name
    func execute(toolName: String, arguments: String) async throws -> ToolResult {
        guard let tool = tools[toolName] else {
            logger.error("Tool not found: \(toolName)")
            throw YBSError.toolNotFound(name: toolName)
        }

        logger.info("Executing tool: \(toolName)")
        logger.debug("Arguments: \(arguments)")

        do {
            let result = try await tool.execute(arguments: arguments)

            if result.success {
                logger.info("Tool \(toolName) succeeded")
                if let output = result.output {
                    logger.debug("Output: \(output.prefix(200))...")
                }
            } else {
                logger.warn("Tool \(toolName) failed: \(result.error ?? "unknown")")
            }

            return result
        } catch {
            logger.error("Tool \(toolName) threw error: \(error)")
            throw YBSError.toolExecutionFailed(name: toolName, error: error.localizedDescription)
        }
    }

    /// Execute multiple tools in sequence
    func executeMultiple(toolCalls: [ToolCall]) async -> [ToolResult] {
        var results: [ToolResult] = []

        for toolCall in toolCalls {
            do {
                let result = try await execute(
                    toolName: toolCall.function.name,
                    arguments: toolCall.function.arguments
                )
                results.append(result)
            } catch {
                results.append(.failure(error.localizedDescription))
            }
        }

        return results
    }

    /// Check if a tool is registered
    func hasTool(named name: String) -> Bool {
        return tools[name] != nil
    }

    /// Get tool by name (for inspection)
    func tool(named name: String) -> ToolProtocol? {
        return tools[name]
    }

    /// Discover and register external tools from configured paths
    func loadExternalTools(toolPaths: [String]) async {
        let discovery = ToolDiscovery(toolPaths: toolPaths, logger: logger)
        let externalTools = await discovery.discoverTools()

        for tool in externalTools {
            register(tool: tool)
        }
    }
}
