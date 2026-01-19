// Implements: Step 34 (Anthropic Client) + ybs-spec.md § 7.2 (Anthropic)
import Foundation

// MARK: - Anthropic Request Types

struct AnthropicRequest: Codable {
    var model: String
    var messages: [AnthropicMessage]
    var system: String?
    var max_tokens: Int
    var temperature: Double?
    var stream: Bool?
}

struct AnthropicMessage: Codable {
    var role: String  // "user" or "assistant"
    var content: String
}

// MARK: - Anthropic Response Types

struct AnthropicResponse: Codable {
    var id: String
    var type: String  // "message"
    var role: String  // "assistant"
    var content: [AnthropicContentBlock]
    var model: String
    var stop_reason: String?
    var usage: AnthropicUsage
}

struct AnthropicContentBlock: Codable {
    var type: String  // "text"
    var text: String?
}

struct AnthropicUsage: Codable {
    var input_tokens: Int
    var output_tokens: Int
}

// MARK: - Anthropic Streaming Types

struct AnthropicStreamEvent: Codable {
    var type: String
}

struct AnthropicMessageStart: Codable {
    var type: String  // "message_start"
    var message: AnthropicResponse
}

struct AnthropicContentBlockDelta: Codable {
    var type: String  // "content_block_delta"
    var index: Int
    var delta: AnthropicDelta
}

struct AnthropicDelta: Codable {
    var type: String  // "text_delta"
    var text: String?
}
