// Implements: Step 33 (Apple Integration) + ybs-spec.md § 7.4 (Apple Foundation Models)
import Foundation

/// Placeholder LLM client for Apple Foundation Model
/// Note: Actual implementation requires macOS 15+ and Apple ML frameworks
class AppleLLMClient {
    private let config: LLMConfig
    private let logger: Logger

    init(config: LLMConfig, logger: Logger) {
        self.config = config
        self.logger = logger
    }

    /// Send chat request to Apple Foundation Model
    func sendChatRequest(
        messages: [Message],
        tools: [Tool]? = nil
    ) async throws -> Message {
        logger.info("Apple Foundation Model requested")

        // Check availability
        guard AppleMLDetection.isAvailable() else {
            let errorMessage = """
            Apple Foundation Model is not available.
            \(AppleMLDetection.systemInfo())

            Please use a different provider (ollama, openai, anthropic).
            """
            throw YBSError.llmConnectionFailed(
                provider: "apple",
                error: errorMessage
            )
        }

        // Placeholder implementation
        let errorMessage = """
        Apple Foundation Model integration is not yet implemented.
        This is a placeholder for future native Apple ML support.

        Available providers:
        - ollama (local, free)
        - openai (requires API key)
        - anthropic (requires API key)
        """

        throw YBSError.llmConnectionFailed(
            provider: "apple",
            error: errorMessage
        )
    }

    /// Send streaming chat request (placeholder)
    func sendStreamingChatRequest(
        messages: [Message],
        tools: [Tool]? = nil,
        onToken: @escaping (String) -> Void
    ) async throws -> Message {
        // Delegate to non-streaming for now
        return try await sendChatRequest(messages: messages, tools: tools)
    }
}
