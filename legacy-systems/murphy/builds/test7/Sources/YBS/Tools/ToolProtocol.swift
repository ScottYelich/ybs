// Implements: Step 11 (Tool Executor Framework) + ybs-spec.md § 3 (Core Tools)
import Foundation

/// Protocol that all tools must implement
protocol ToolProtocol {
    /// Tool name (must match tool schema)
    var name: String { get }

    /// Tool description for LLM
    var description: String { get }

    /// Tool parameter schema
    var parameters: ToolParameters { get }

    /// Execute the tool with given arguments
    /// - Parameter arguments: JSON string of arguments
    /// - Returns: Tool result (success or error)
    func execute(arguments: String) async throws -> ToolResult
}
