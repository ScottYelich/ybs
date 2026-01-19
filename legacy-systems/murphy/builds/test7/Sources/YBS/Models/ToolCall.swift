// Implements: Step 6 (Core Data Models) + ybs-spec.md § 6 (Agent Loop)
import Foundation

/// Represents a tool call request from the LLM
struct ToolCall: Codable, Equatable {
    var id: String
    var type: String = "function"
    var function: FunctionCall

    struct FunctionCall: Codable, Equatable {
        var name: String
        var arguments: String // JSON string

        init(name: String, arguments: String) {
            self.name = name
            self.arguments = arguments
        }
    }

    init(id: String, name: String, arguments: String) {
        self.id = id
        self.function = FunctionCall(name: name, arguments: arguments)
    }

    /// Parse arguments from JSON string
    func parseArguments<T: Decodable>() throws -> T {
        let data = function.arguments.data(using: .utf8)!
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

/// Tool execution result
struct ToolResult: Codable, Equatable {
    var success: Bool
    var output: String?
    var error: String?

    static func success(_ output: String) -> ToolResult {
        ToolResult(success: true, output: output, error: nil)
    }

    static func failure(_ error: String) -> ToolResult {
        ToolResult(success: false, output: nil, error: error)
    }
}
