# Step 000012: LLM Client

**GUID**: 4a72e9b51d3f
**Version**: 0.1.0
**Layer**: 3 - LLM Client
**Estimated Size**: ~120 lines of code

## Overview

Implements the LLM Client - a high-level interface for communicating with LLM APIs. Uses the HTTP client from Step 11 to send chat messages and receive streaming responses with tool calls.

This completes Layer 3 (LLM Client). After this step, we can talk to any OpenAI-compatible LLM!

## What This Step Builds

An `LLMClient` that:
- Sends chat requests with conversation history
- Supports streaming responses (token-by-token)
- Parses tool calls from LLM responses
- Handles rate limits and timeouts
- Retries on transient errors
- Works with OpenAI, Anthropic, Ollama, etc.

## Step Objectives

1. Implement LLMClient class
2. Add chat completion method (non-streaming)
3. Add streaming chat completion method
4. Parse tool calls from responses
5. Handle API errors (rate limits, timeouts)
6. Create tests (with mock HTTP client)

## Prerequisites

**Required Steps**:
- ✅ Step 11: HTTP Client (HTTPClient exists)
- ✅ Step 5: Core Data Models (Message, Tool, ToolCall)
- ✅ Step 6: Error Handling (YBSError)
- ✅ Step 4: Configuration (LLMConfig)

## Configurable Values

**Uses**:
- `llm.provider` - Provider name (for logging)
- `llm.model` - Model name
- `llm.endpoint` - API endpoint URL
- `llm.api_key` - API authentication key
- `llm.max_tokens` - Response token limit
- `llm.temperature` - Sampling temperature

## Traceability

**Implements**:
- `ybs-spec.md` Section 5 (LLM Integration)

**References**:
- D03 (API Abstraction: OpenAI-compatible)
- D12 (Streaming: Required for UX)

## Instructions

### 1. Implement LLM Client

**File to create**: `Sources/YBS/LLM/LLMClient.swift`

```swift
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
            max_tokens: config.max_tokens,
            stream: false
        )

        let requestData = try JSONEncoder().encode(request)

        // Build headers
        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]

        // Add API key if configured
        if let apiKey = config.api_key {
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
            max_tokens: config.max_tokens,
            stream: true
        )

        let requestData = try JSONEncoder().encode(request)

        // Build headers
        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]

        if let apiKey = config.api_key {
            headers["Authorization"] = "Bearer \(apiKey)"
        }

        // Accumulate response
        var role: String?
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
                role = deltaRole
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
                                type: "function",
                                function: FunctionCall(
                                    name: current.name,
                                    arguments: current.args
                                )
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
                type: "function",
                function: FunctionCall(
                    name: current.name,
                    arguments: current.args
                )
            ))
        }

        logger.info("Streaming response complete from \(config.provider)")

        // Build message
        return Message(
            role: role ?? "assistant",
            content: content.isEmpty ? nil : content,
            toolCalls: toolCalls.isEmpty ? nil : toolCalls
        )
    }
}
```

### 2. Add Tests

**File to create**: `Tests/YBSTests/LLMClientTests.swift`

```swift
import XCTest
@testable import YBS

final class LLMClientTests: XCTestCase {
    func testChatRequestBuilding() throws {
        let config = LLMConfig(
            provider: "test",
            model: "gpt-4",
            endpoint: "https://api.example.com/v1/chat/completions",
            api_key: "test-key"
        )

        let logger = Logger(component: "Test", useColor: false)
        let client = LLMClient(config: config, logger: logger)

        // Client created successfully
        XCTAssertNotNil(client)
    }

    func testMessageParsing() throws {
        // Test parsing a non-streaming response
        let json = """
        {
            "id": "chatcmpl-123",
            "object": "chat.completion",
            "created": 1234567890,
            "model": "gpt-4",
            "choices": [{
                "index": 0,
                "message": {
                    "role": "assistant",
                    "content": "Hello! How can I help you today?"
                },
                "finish_reason": "stop"
            }]
        }
        """

        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)

        XCTAssertEqual(response.choices[0].message.role, "assistant")
        XCTAssertEqual(response.choices[0].message.content, "Hello! How can I help you today?")
    }

    func testToolCallParsing() throws {
        // Test parsing a response with tool calls
        let json = """
        {
            "id": "chatcmpl-456",
            "object": "chat.completion",
            "created": 1234567890,
            "model": "gpt-4",
            "choices": [{
                "index": 0,
                "message": {
                    "role": "assistant",
                    "content": null,
                    "tool_calls": [{
                        "id": "call_123",
                        "type": "function",
                        "function": {
                            "name": "read_file",
                            "arguments": "{\\"path\\": \\"test.txt\\"}"
                        }
                    }]
                },
                "finish_reason": "tool_calls"
            }]
        }
        """

        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)

        XCTAssertNotNil(response.choices[0].message.toolCalls)
        XCTAssertEqual(response.choices[0].message.toolCalls?.count, 1)
        XCTAssertEqual(response.choices[0].message.toolCalls?[0].function.name, "read_file")
    }

    func testStreamChunkAccumulation() throws {
        // Test accumulating streaming chunks
        var accumulated = ""

        let chunks = [
            """
            {"choices": [{"delta": {"content": "Hello"}}]}
            """,
            """
            {"choices": [{"delta": {"content": " "}}]}
            """,
            """
            {"choices": [{"delta": {"content": "world"}}]}
            """
        ]

        for chunkJSON in chunks {
            let data = chunkJSON.data(using: .utf8)!
            let chunk = try JSONDecoder().decode(ChatCompletionChunk.self, from: data)
            if let content = chunk.choices.first?.delta.content {
                accumulated += content
            }
        }

        XCTAssertEqual(accumulated, "Hello world")
    }
}
```

### 3. Integration Test (Optional)

**File to create**: `Tests/YBSTests/LLMIntegrationTests.swift`

```swift
import XCTest
@testable import YBS

final class LLMIntegrationTests: XCTestCase {
    func testRealLLMRequest() async throws {
        // This test requires ANTHROPIC_API_KEY environment variable
        guard let apiKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] else {
            throw XCTSkip("ANTHROPIC_API_KEY not set")
        }

        let config = LLMConfig(
            provider: "anthropic",
            model: "claude-3-sonnet-20240229",
            endpoint: "https://api.anthropic.com/v1/messages",
            api_key: apiKey,
            max_tokens: 100,
            temperature: 0.7
        )

        let logger = Logger(component: "IntegrationTest", useColor: false)
        let client = LLMClient(config: config, logger: logger)

        let messages = [
            Message(role: "user", content: "Say 'Hello from YBS!' and nothing else.")
        ]

        let response = try await client.sendChatRequest(messages: messages)

        XCTAssertEqual(response.role, "assistant")
        XCTAssertNotNil(response.content)
        XCTAssertTrue(response.content!.contains("Hello from YBS"))
    }
}
```

### 4. Build and Test

```bash
swift build
swift test --filter LLMClientTests
```

## Verification

```bash
cd systems/bootstrap/builds/test6
swift build
swift test --filter LLMClientTests
# Expected: All tests pass

# Optional: Test with real API
export ANTHROPIC_API_KEY="your-key-here"
swift test --filter LLMIntegrationTests
# Expected: Receives response from Anthropic
```

## Completion Checklist

- [ ] LLMClient class created
- [ ] Non-streaming chat works
- [ ] Streaming chat works
- [ ] Tool call parsing works
- [ ] Error handling works
- [ ] Tests pass

## After Completion

**Layer 3 Complete!** 🎉

Create DONE file: `docs/build-history/ybs-step_4a72e9b51d3f-DONE.txt`

```bash
git add -A
git commit -m "Step 12: Implement LLM client

- Add LLMClient with streaming support
- Parse chat completions and tool calls
- Support OpenAI-compatible APIs
- Handle errors and retries
- Comprehensive tests

Layer 3 (LLM Client) Complete: Can now talk to AI!

Implements: ybs-spec.md Section 5

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: Layer 4 - Agent Core (Steps 13-15)
**Next step**: Step 13 - Basic Agent Loop (Interactive chat!)
