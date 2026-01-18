# Step 000033: Anthropic LLM Client Implementation

**GUID**: f1a2b3c4d5e6
**Type**: Implementation
**Status**: Planned
**Last Updated**: 2026-01-18

---

## Overview

**Purpose**: Implement native Anthropic API client for proper Claude integration.

**What This Step Does**:
- Creates dedicated `AnthropicLLMClient` class
- Implements Anthropic-specific request/response format
- Handles Anthropic authentication headers
- Converts between OpenAI-compatible and Anthropic formats
- Supports streaming with Anthropic's event format
- Enables proper tool use with Claude models

**Why This Step Exists**:
Anthropic's API differs significantly from OpenAI's:
- Different authentication (`x-api-key` header)
- Different message format (separate system field)
- Different tool calling format
- Different response structure
- Requires version header (`anthropic-version`)

Without this, Anthropic provider doesn't actually work (current implementation only supports OpenAI-compatible APIs).

**Dependencies**:
- ✅ Step 11: HTTP Client (for making requests)
- ✅ Step 12: LLM Client (existing patterns)
- ✅ Step 5: Core Data Models (Message, Tool, ToolCall)

---

## Specifications

**Implements**:
- Spec: `systems/bootstrap/specs/technical/ybs-spec.md` § 7.4 Anthropic Provider Implementation
- Provider: "Anthropic" - Claude models via official API

**References**:
- `systems/bootstrap/specs/technical/ybs-spec.md` lines 645-723 (Anthropic Implementation)
- Anthropic API Documentation: https://docs.anthropic.com/en/api

---

## What to Build

### File Structure

```
Sources/test7/LLM/
├── AnthropicTypes.swift       # Anthropic request/response types
├── AnthropicLLMClient.swift   # Anthropic client implementation
└── LLMClientFactory.swift     # Factory to create correct client
```

### 1. AnthropicTypes.swift

**Purpose**: Define Anthropic-specific API request/response structures.

**Key Components**:

```swift
import Foundation

// MARK: - Anthropic Request Types

struct AnthropicRequest: Codable {
    var model: String
    var messages: [AnthropicMessage]
    var system: String?
    var max_tokens: Int
    var temperature: Double?
    var tools: [AnthropicTool]?
    var stream: Bool?
}

struct AnthropicMessage: Codable {
    var role: String  // "user" or "assistant"
    var content: AnthropicContent

    enum AnthropicContent: Codable {
        case text(String)
        case blocks([AnthropicContentBlock])

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let text = try? container.decode(String.self) {
                self = .text(text)
            } else if let blocks = try? container.decode([AnthropicContentBlock].self) {
                self = .blocks(blocks)
            } else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode content"
                )
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .text(let text):
                try container.encode(text)
            case .blocks(let blocks):
                try container.encode(blocks)
            }
        }
    }
}

struct AnthropicContentBlock: Codable {
    var type: String  // "text" or "tool_use"
    var text: String?
    var id: String?
    var name: String?
    var input: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case type, text, id, name, input
    }
}

struct AnthropicTool: Codable {
    var name: String
    var description: String
    var input_schema: [String: AnyCodable]
}

// MARK: - Anthropic Response Types

struct AnthropicResponse: Codable {
    var id: String
    var type: String  // "message"
    var role: String  // "assistant"
    var content: [AnthropicResponseContent]
    var model: String
    var stop_reason: String?
    var stop_sequence: String?
    var usage: AnthropicUsage
}

struct AnthropicResponseContent: Codable {
    var type: String  // "text" or "tool_use"
    var text: String?
    var id: String?
    var name: String?
    var input: [String: AnyCodable]?
}

struct AnthropicUsage: Codable {
    var input_tokens: Int
    var output_tokens: Int
}

// MARK: - Streaming Types

struct AnthropicStreamEvent: Codable {
    var type: String  // "message_start", "content_block_start", "content_block_delta", etc.
    var message: AnthropicResponse?
    var index: Int?
    var content_block: AnthropicResponseContent?
    var delta: AnthropicDelta?
}

struct AnthropicDelta: Codable {
    var type: String
    var text: String?
    var partial_json: String?
}

// MARK: - Helper for Any Codable Values

struct AnyCodable: Codable {
    var value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}
```

**Size**: ~180 lines

---

### 2. AnthropicLLMClient.swift

**Purpose**: LLM client implementation for Anthropic Claude models.

**Key Components**:

```swift
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
        let anthropicRequest = try convertToAnthropicRequest(
            messages: messages,
            tools: tools,
            stream: false
        )

        let requestData = try JSONEncoder().encode(anthropicRequest)

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
            let response = try JSONDecoder().decode(AnthropicResponse.self, from: responseData)

            // Convert back to standard Message format
            return try convertFromAnthropicResponse(response)
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
        let anthropicRequest = try convertToAnthropicRequest(
            messages: messages,
            tools: tools,
            stream: true
        )

        let requestData = try JSONEncoder().encode(anthropicRequest)

        // Build Anthropic-specific headers
        var headers = [
            "Content-Type": "application/json",
            "anthropic-version": "2023-06-01"
        ]

        if let apiKey = config.apiKey {
            headers["x-api-key"] = apiKey
        }

        // Accumulate response
        var contentBlocks: [AnthropicResponseContent] = []
        var currentText = ""
        var usage: AnthropicUsage?

        // Stream request
        try await httpClient.streamPost(
            url: config.endpoint,
            headers: headers,
            body: requestData
        ) { eventData in
            // Parse SSE event
            guard let event = try? JSONDecoder().decode(
                AnthropicStreamEvent.self,
                from: Data(eventData.utf8)
            ) else {
                return
            }

            switch event.type {
            case "message_start":
                if let msg = event.message {
                    usage = msg.usage
                }
            case "content_block_start":
                if let block = event.content_block {
                    contentBlocks.append(block)
                }
            case "content_block_delta":
                if let delta = event.delta, delta.type == "text_delta", let text = delta.text {
                    currentText += text
                    onToken(text)
                }
            case "content_block_stop":
                if !currentText.isEmpty {
                    if var lastBlock = contentBlocks.last {
                        lastBlock.text = currentText
                        contentBlocks[contentBlocks.count - 1] = lastBlock
                    }
                    currentText = ""
                }
            default:
                break
            }
        }

        // Build response
        let response = AnthropicResponse(
            id: UUID().uuidString,
            type: "message",
            role: "assistant",
            content: contentBlocks,
            model: config.model,
            stop_reason: "end_turn",
            stop_sequence: nil,
            usage: usage ?? AnthropicUsage(input_tokens: 0, output_tokens: 0)
        )

        return try convertFromAnthropicResponse(response)
    }

    // MARK: - Conversion Helpers

    /// Convert standard messages to Anthropic format
    private func convertToAnthropicRequest(
        messages: [Message],
        tools: [Tool]?,
        stream: Bool
    ) throws -> AnthropicRequest {
        // Extract system message (Anthropic wants it separate)
        var systemMessage: String?
        var anthropicMessages: [AnthropicMessage] = []

        for message in messages {
            if message.role == .system {
                systemMessage = message.content
            } else {
                let role = message.role == .user ? "user" : "assistant"
                let content: AnthropicMessage.AnthropicContent

                if let toolCalls = message.toolCalls, !toolCalls.isEmpty {
                    // Convert tool calls to content blocks
                    let blocks = toolCalls.map { toolCall in
                        AnthropicContentBlock(
                            type: "tool_use",
                            text: nil,
                            id: toolCall.id,
                            name: toolCall.name,
                            input: try? parseJSON(toolCall.arguments)
                        )
                    }
                    content = .blocks(blocks)
                } else {
                    content = .text(message.content ?? "")
                }

                anthropicMessages.append(AnthropicMessage(role: role, content: content))
            }
        }

        // Convert tools to Anthropic format
        let anthropicTools = tools?.map { tool in
            AnthropicTool(
                name: tool.name,
                description: tool.description,
                input_schema: convertToJSONSchema(tool.parameters)
            )
        }

        return AnthropicRequest(
            model: config.model,
            messages: anthropicMessages,
            system: systemMessage,
            max_tokens: config.maxTokens,
            temperature: config.temperature,
            tools: anthropicTools,
            stream: stream
        )
    }

    /// Convert Anthropic response to standard Message format
    private func convertFromAnthropicResponse(_ response: AnthropicResponse) throws -> Message {
        var textContent = ""
        var toolCalls: [ToolCall] = []

        for block in response.content {
            if block.type == "text", let text = block.text {
                textContent += text
            } else if block.type == "tool_use",
                      let id = block.id,
                      let name = block.name,
                      let input = block.input {
                let arguments = try JSONEncoder().encode(input)
                toolCalls.append(ToolCall(
                    id: id,
                    name: name,
                    arguments: String(data: arguments, encoding: .utf8) ?? "{}"
                ))
            }
        }

        return Message(
            role: .assistant,
            content: textContent.isEmpty ? nil : textContent,
            toolCalls: toolCalls.isEmpty ? nil : toolCalls
        )
    }

    /// Convert tool parameters to JSON Schema
    private func convertToJSONSchema(_ params: Tool.Parameters?) -> [String: AnyCodable] {
        guard let params = params else {
            return ["type": AnyCodable("object"), "properties": AnyCodable([:])]
        }

        var schema: [String: AnyCodable] = [
            "type": AnyCodable("object"),
            "properties": AnyCodable(params.properties.mapValues { prop in
                [
                    "type": AnyCodable(prop.type),
                    "description": AnyCodable(prop.description)
                ]
            })
        ]

        if !params.required.isEmpty {
            schema["required"] = AnyCodable(params.required)
        }

        return schema
    }

    /// Parse JSON string to dictionary
    private func parseJSON(_ jsonString: String) -> [String: AnyCodable]? {
        guard let data = jsonString.data(using: .utf8),
              let dict = try? JSONDecoder().decode([String: AnyCodable].self, from: data) else {
            return nil
        }
        return dict
    }
}
```

**Size**: ~280 lines

---

### 3. LLMClientFactory.swift

**Purpose**: Factory pattern to create the correct LLM client based on provider.

**Key Components**:

```swift
import Foundation

/// Factory for creating LLM clients based on provider
class LLMClientFactory {
    /// Create appropriate LLM client for the given config
    static func createClient(config: LLMConfig, logger: Logger) -> LLMClientProtocol {
        switch config.provider.lowercased() {
        case "anthropic":
            return AnthropicLLMClient(config: config, logger: logger)
        case "ollama", "openai", "openai-compatible":
            return LLMClient(config: config, logger: logger)
        default:
            logger.warning("Unknown provider '\(config.provider)', using generic OpenAI-compatible client")
            return LLMClient(config: config, logger: logger)
        }
    }
}

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
```

**Size**: ~40 lines

---

### 4. Update AgentLoop.swift

**Modify**: Use factory to create client

```swift
// In AgentLoop.swift init():
self.llmClient = LLMClientFactory.createClient(
    config: config.llm,
    logger: logger
)
```

---

## Tests

**Location**: `Tests/test7Tests/LLM/AnthropicClientTests.swift`

### Test Cases

**1. Message Format Conversion**:
```swift
func testMessageConversion() throws {
    let messages = [
        Message(role: .system, content: "You are a helpful assistant"),
        Message(role: .user, content: "Hello")
    ]

    // Test conversion to Anthropic format
    // Should extract system message
    // Should convert user message
}
```

**2. Tool Format Conversion**:
```swift
func testToolConversion() throws {
    let tool = Tool(
        name: "read_file",
        description: "Read a file",
        parameters: Tool.Parameters(
            properties: ["path": Tool.Property(type: "string", description: "File path")],
            required: ["path"]
        )
    )

    // Test conversion to Anthropic tool format
}
```

**3. Response Parsing**:
```swift
func testResponseParsing() throws {
    let anthropicJSON = """
    {
      "id": "msg_123",
      "type": "message",
      "role": "assistant",
      "content": [
        {"type": "text", "text": "Hello!"}
      ],
      "model": "claude-3-5-sonnet-20241022",
      "stop_reason": "end_turn",
      "usage": {"input_tokens": 10, "output_tokens": 5}
    }
    """

    // Test parsing and conversion
}
```

**4. Client Creation**:
```swift
func testClientFactory() {
    let config = LLMConfig(
        provider: "anthropic",
        model: "claude-3-5-sonnet-20241022",
        endpoint: "https://api.anthropic.com/v1/messages",
        api_key: "test-key"
    )

    let client = LLMClientFactory.createClient(config: config, logger: testLogger)
    XCTAssertTrue(client is AnthropicLLMClient)
}
```

**Total Tests**: ~8-10 tests

---

## Verification Steps

### 1. Unit Tests

```bash
swift test --filter AnthropicClientTests
# Should pass all tests
```

### 2. Manual Testing with Real API

**Test configuration**:
```json
{
  "llm": {
    "provider": "anthropic",
    "model": "claude-3-5-sonnet-20241022",
    "endpoint": "https://api.anthropic.com/v1/messages",
    "api_key": "sk-ant-api03-..."
  }
}
```

**Test basic chat**:
```bash
swift run test7
You: What is 2+2?
AI: [Should respond correctly]
```

**Test tool use**:
```bash
You: Read the README file
AI: [Should use read_file tool]
```

### 3. Success Criteria

- ✅ AnthropicTypes.swift created with all necessary types
- ✅ AnthropicLLMClient.swift implements full client
- ✅ LLMClientFactory.swift routes to correct client
- ✅ Unit tests pass (format conversions)
- ✅ Manual test with real Anthropic API succeeds
- ✅ Tool calling works with Anthropic
- ✅ Streaming works with Anthropic
- ✅ Build compiles without errors

---

## Configuration

**Anthropic Default Values**:

```swift
// In Config.swift defaults for Anthropic:
provider: "anthropic"
model: "claude-3-5-sonnet-20241022"
endpoint: "https://api.anthropic.com/v1/messages"
api_key: nil  // Must be provided
```

**Supported Models**:
- `claude-3-5-sonnet-20241022` (recommended)
- `claude-3-opus-20240229`
- `claude-3-sonnet-20240229`
- `claude-3-haiku-20240307`

---

## Dependencies

**Requires**:
- Step 11: HTTP Client (HTTPClient class)
- Step 12: LLM Client (existing patterns)
- Step 5: Core Data Models (Message, Tool, ToolCall)

**Enables**:
- Full Anthropic Claude support
- Native Claude tool use
- Proper authentication with Anthropic API
- Foundation for Step 34 (runtime switching)

---

## Implementation Notes

### Anthropic API Differences

**Key challenges**:
1. **System message extraction** - Must pull system messages out of conversation history
2. **Content blocks** - Anthropic uses content block arrays instead of simple strings
3. **Tool format** - Different JSON Schema format for tool definitions
4. **Authentication** - Different header format
5. **Streaming** - Different SSE event types

### Error Handling

**Common errors**:
- 401: Invalid API key
- 429: Rate limit exceeded
- 400: Invalid request format (usually schema mismatch)

**Rate limits**:
- Claude Sonnet: ~5 requests/minute (free tier)
- Claude Opus: ~5 requests/minute (free tier)
- Paid tiers: Much higher

---

## Completion Criteria

**This step is complete when**:

1. **Code Written**:
   - [ ] AnthropicTypes.swift with all request/response types
   - [ ] AnthropicLLMClient.swift with full implementation
   - [ ] LLMClientFactory.swift for client creation
   - [ ] AgentLoop updated to use factory

2. **Tests Pass**:
   - [ ] All AnthropicClientTests pass
   - [ ] Format conversion tests work
   - [ ] Response parsing tests work

3. **Verification Complete**:
   - [ ] Manual test with real Anthropic API succeeds
   - [ ] Tool calling works correctly
   - [ ] Streaming displays properly
   - [ ] Build compiles without errors

4. **Documentation Updated**:
   - [ ] README mentions Anthropic support
   - [ ] USAGE.md includes Anthropic configuration example
   - [ ] Code comments explain Anthropic-specific behavior

**Estimated Time**: 4-6 hours
**Estimated Size**: ~500 lines total

---

## Next Steps

**After This Step**:
- Step 34: Runtime Provider Switching
- Anthropic provider is fully functional
- Users can use Claude models natively
- Foundation for multi-provider workflows

**What It Enables**:
- Native Claude API support
- Proper tool use with Claude
- Better error messages for Anthropic-specific issues
- Cleaner separation of provider implementations

---

**Last Updated**: 2026-01-18
**Status**: Ready for implementation
