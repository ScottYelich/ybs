// Implements: Step 12 (HTTP Client & OpenAI Types) + ybs-spec.md § 7.1 (OpenAI-compatible)
import Foundation

// MARK: - Request Types

struct ChatCompletionRequest: Codable {
    var model: String
    var messages: [Message]
    var tools: [Tool]?
    var temperature: Double?
    var max_tokens: Int?
    var stream: Bool?

    enum CodingKeys: String, CodingKey {
        case model, messages, tools, temperature
        case max_tokens = "max_tokens"
        case stream
    }
}

// MARK: - Response Types

struct ChatCompletionResponse: Codable {
    var id: String
    var object: String
    var created: Int
    var model: String
    var choices: [Choice]

    struct Choice: Codable {
        var index: Int
        var message: Message
        var finish_reason: String?

        enum CodingKeys: String, CodingKey {
            case index, message
            case finish_reason = "finish_reason"
        }
    }
}

// Streaming response (SSE format)
struct ChatCompletionChunk: Codable {
    var id: String
    var object: String
    var created: Int
    var model: String
    var choices: [ChunkChoice]

    struct ChunkChoice: Codable {
        var index: Int
        var delta: Delta
        var finish_reason: String?

        enum CodingKeys: String, CodingKey {
            case index, delta
            case finish_reason = "finish_reason"
        }
    }

    struct Delta: Codable {
        var role: String?
        var content: String?
        var tool_calls: [DeltaToolCall]?

        enum CodingKeys: String, CodingKey {
            case role, content
            case tool_calls = "tool_calls"
        }
    }

    // Tool call in streaming delta (fields are optional and accumulated)
    struct DeltaToolCall: Codable {
        var id: String?
        var type: String?
        var function: DeltaFunction

        struct DeltaFunction: Codable {
            var name: String?
            var arguments: String?
        }
    }
}

// Error response
struct APIError: Codable {
    var error: ErrorDetail

    struct ErrorDetail: Codable {
        var message: String
        var type: String?
        var code: String?
    }
}
