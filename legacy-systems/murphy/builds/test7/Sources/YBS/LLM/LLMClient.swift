// Implements: Step 13 (LLM Client) + ybs-spec.md § 7 (LLM Provider Abstraction)
import Foundation

class LLMClient {
    private let httpClient: HTTPClient
    private let config: LLMConfig
    private let logger: Logger

    init(config: LLMConfig, logger: Logger) {
        self.config = config
        self.logger = logger
        self.httpClient = HTTPClient(logger: logger)
    }

    /// Send a chat completion request (non-streaming)
    func sendChatRequest(
        messages: [Message],
        tools: [Tool]? = nil
    ) async throws -> Message {
        logger.info("Sending chat request to \(config.provider)")

        // Build request
        let request = ChatCompletionRequest(
            model: config.model,
            messages: messages,
            tools: tools,
            temperature: config.temperature,
            max_tokens: config.maxTokens,
            stream: false
        )

        let requestData = try JSONEncoder().encode(request)

        // Build headers
        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]

        // Add API key if configured
        if let apiKey = config.apiKey {
            headers["Authorization"] = "Bearer \(apiKey)"
        }

        // Make request
        do {
            let responseData = try await httpClient.post(
                url: config.endpoint,
                headers: headers,
                body: requestData
            )

            // Parse response
            let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: responseData)

            guard let choice = response.choices.first else {
                throw YBSError.llmRequestFailed(
                    statusCode: 200,
                    message: "No choices in response"
                )
            }

            logger.info("Received response from \(config.provider)")
            return choice.message
        } catch let error as YBSError {
            throw error
        } catch {
            logger.error("LLM request failed: \(error)")
            throw YBSError.llmConnectionFailed(
                provider: config.provider,
                error: error.localizedDescription
            )
        }
    }

    /// Send a streaming chat completion request
    func sendStreamingChatRequest(
        messages: [Message],
        tools: [Tool]? = nil,
        onToken: @escaping (String) -> Void
    ) async throws -> Message {
        logger.info("Sending streaming chat request to \(config.provider)")

        // Build request
        let request = ChatCompletionRequest(
            model: config.model,
            messages: messages,
            tools: tools,
            temperature: config.temperature,
            max_tokens: config.maxTokens,
            stream: true
        )

        let requestData = try JSONEncoder().encode(request)

        // Build headers
        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]

        if let apiKey = config.apiKey {
            headers["Authorization"] = "Bearer \(apiKey)"
        }

        // Accumulate response
        var role: Message.Role?
        var content = ""
        var toolCalls: [ToolCall] = []
        var currentToolCall: (id: String, name: String, args: String)?

        // Stream request
        try await httpClient.streamPost(
            url: config.endpoint,
            headers: headers,
            body: requestData
        ) { chunkJSON in
            // Parse chunk
            guard let chunkData = chunkJSON.data(using: .utf8) else { return }
            guard let chunk = try? JSONDecoder().decode(ChatCompletionChunk.self, from: chunkData) else {
                return
            }

            guard let delta = chunk.choices.first?.delta else { return }

            // Extract role
            if let deltaRole = delta.role {
                role = Message.Role(rawValue: deltaRole)
            }

            // Extract content
            if let deltaContent = delta.content {
                content += deltaContent
                onToken(deltaContent)
            }

            // Extract tool calls
            if let deltaToolCalls = delta.tool_calls {
                for toolCall in deltaToolCalls {
                    if let id = toolCall.id, let name = toolCall.function.name {
                        // New tool call
                        if let current = currentToolCall {
                            // Save previous tool call
                            toolCalls.append(ToolCall(
                                id: current.id,
                                name: current.name,
                                arguments: current.args
                            ))
                        }
                        currentToolCall = (id: id, name: name, args: "")
                    }

                    // Accumulate arguments
                    if let args = toolCall.function.arguments {
                        currentToolCall?.args += args
                    }
                }
            }
        }

        // Save final tool call
        if let current = currentToolCall {
            toolCalls.append(ToolCall(
                id: current.id,
                name: current.name,
                arguments: current.args
            ))
        }

        logger.info("Streaming response complete from \(config.provider)")

        // Build message
        return Message(
            role: role ?? .assistant,
            content: content.isEmpty ? nil : content,
            toolCalls: toolCalls.isEmpty ? nil : toolCalls
        )
    }
}
