// Implements: Step 6 (Core Data Models) + ybs-spec.md § 6 (Agent Loop)
import Foundation

/// Represents a message in the conversation
struct Message: Codable, Equatable {
    enum Role: String, Codable {
        case system = "system"
        case user = "user"
        case assistant = "assistant"
        case tool = "tool"
    }

    var role: Role
    var content: String?
    var toolCalls: [ToolCall]?
    var toolCallId: String?
    var name: String? // For tool results

    enum CodingKeys: String, CodingKey {
        case role
        case content
        case toolCalls = "tool_calls"
        case toolCallId = "tool_call_id"
        case name
    }

    // Full initializer
    init(role: Role, content: String? = nil, toolCalls: [ToolCall]? = nil, name: String? = nil, toolCallId: String? = nil) {
        self.role = role
        self.content = content
        self.toolCalls = toolCalls
        self.name = name
        self.toolCallId = toolCallId
    }

    // Convenience initializers
    static func system(_ content: String) -> Message {
        Message(role: .system, content: content)
    }

    static func user(_ content: String) -> Message {
        Message(role: .user, content: content)
    }

    static func assistant(_ content: String) -> Message {
        Message(role: .assistant, content: content)
    }

    static func assistantWithTools(_ toolCalls: [ToolCall]) -> Message {
        Message(role: .assistant, content: nil, toolCalls: toolCalls)
    }

    static func toolResult(id: String, name: String, content: String) -> Message {
        Message(role: .tool, content: content, name: name, toolCallId: id)
    }
}
