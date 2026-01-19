// Implements: Step 34 (Anthropic Client) + ybs-spec.md § 7.2 (Anthropic)
import Foundation

/// LLM client for Anthropic Claude models
class AnthropicLLMClient {
    private let httpClient: HTTPClient
    private let config: LLMConfig
    private let logger: Logger

    init(config: LLMConfig, logger: Logger) {
        self.config = config
        self.logger = logger
        self.httpClient = HTTPClient(logger: logger)
    }

    /// Send chat request to Anthropic API
    func sendChatRequest(
        messages: [Message],
        tools: [Tool]? = nil
    ) async throws -> Message {
        logger.info("Sending chat request to Anthropic")

        // Convert to Anthropic format
        let anthropicRequest = convertToAnthropicRequest(
            messages: messages,
            stream: false
        )

        let encoder = JSONEncoder()
        let requestData = try encoder.encode(anthropicRequest)

        // Build Anthropic-specific headers
        var headers = [
            "Content-Type": "application/json",
            "anthropic-version": "2023-06-01"
        ]

        if let apiKey = config.apiKey {
            headers["x-api-key"] = apiKey
        }

        // Make request
        do {
            let responseData = try await httpClient.post(
                url: config.endpoint,
                headers: headers,
                body: requestData
            )

            // Parse Anthropic response
            let decoder = JSONDecoder()
            let response = try decoder.decode(AnthropicResponse.self, from: responseData)

            // Convert back to standard Message format
            return convertFromAnthropicResponse(response)

        } catch {
            logger.error("Anthropic request failed: \(error)")
            throw YBSError.llmConnectionFailed(
                provider: "anthropic",
                error: error.localizedDescription
            )
        }
    }

    /// Send streaming chat request to Anthropic API
    func sendStreamingChatRequest(
        messages: [Message],
        tools: [Tool]? = nil,
        onToken: @escaping (String) -> Void
    ) async throws -> Message {
        logger.info("Sending streaming chat request to Anthropic")

        // Convert to Anthropic format
        let anthropicRequest = convertToAnthropicRequest(
            messages: messages,
            stream: true
        )

        let encoder = JSONEncoder()
        let requestData = try encoder.encode(anthropicRequest)

        // Build Anthropic-specific headers
        var headers = [
            "Content-Type": "application/json",
            "anthropic-version": "2023-06-01"
        ]

        if let apiKey = config.apiKey {
            headers["x-api-key"] = apiKey
        }

        // Accumulate response
        var fullText = ""

        // Stream request
        try await httpClient.streamPost(
            url: config.endpoint,
            headers: headers,
            body: requestData
        ) { eventData in
            // Parse SSE event
            // Anthropic sends events like:
            // event: content_block_delta
            // data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hello"}}

            // Simple parsing: look for "text":" in the data
            if let range = eventData.range(of: "\"text\":\"") {
                let afterText = eventData[range.upperBound...]
                if let endQuote = afterText.firstIndex(of: "\"") {
                    let text = String(afterText[..<endQuote])
                    // Unescape the text
                    let unescaped = text.replacingOccurrences(of: "\\n", with: "\n")
                        .replacingOccurrences(of: "\\\"", with: "\"")
                    fullText += unescaped
                    onToken(unescaped)
                }
            }
        }

        logger.info("Streaming response complete from Anthropic")

        // Return accumulated message
        return Message(
            role: .assistant,
            content: fullText,
            toolCalls: nil
        )
    }

    // MARK: - Conversion Helpers

    /// Convert standard messages to Anthropic format
    private func convertToAnthropicRequest(
        messages: [Message],
        stream: Bool
    ) -> AnthropicRequest {
        // Extract system message (Anthropic wants it separate)
        var systemMessage: String?
        var anthropicMessages: [AnthropicMessage] = []

        for message in messages {
            if message.role == .system {
                systemMessage = message.content
            } else {
                let role = message.role == .user ? "user" : "assistant"
                let content = message.content ?? ""
                anthropicMessages.append(AnthropicMessage(role: role, content: content))
            }
        }

        return AnthropicRequest(
            model: config.model,
            messages: anthropicMessages,
            system: systemMessage,
            max_tokens: config.maxTokens,
            temperature: config.temperature,
            stream: stream
        )
    }

    /// Convert Anthropic response to standard Message format
    private func convertFromAnthropicResponse(_ response: AnthropicResponse) -> Message {
        var textContent = ""

        for block in response.content {
            if block.type == "text", let text = block.text {
                textContent += text
            }
        }

        return Message(
            role: .assistant,
            content: textContent.isEmpty ? nil : textContent,
            toolCalls: nil
        )
    }
}
