// Implements: Step 13 (LLM Client) + ybs-spec.md § 7 (LLM Provider Abstraction)
import Foundation

/// Protocol that all LLM clients must implement
protocol LLMClientProtocol {
    func sendChatRequest(messages: [Message], tools: [Tool]?) async throws -> Message
    func sendStreamingChatRequest(
        messages: [Message],
        tools: [Tool]?,
        onToken: @escaping (String) -> Void
    ) async throws -> Message
}

// Make existing clients conform to protocol
extension LLMClient: LLMClientProtocol {}
extension AnthropicLLMClient: LLMClientProtocol {}
extension AppleLLMClient: LLMClientProtocol {}
