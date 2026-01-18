# Step 000011: HTTP Client & OpenAI API Types

**GUID**: 57ceeecb6edc
**Version**: 0.1.0
**Layer**: 3 - LLM Client
**Estimated Size**: ~150 lines of code

## Overview

Implements HTTP client for communicating with LLM APIs. Supports streaming responses (Server-Sent Events) and OpenAI-compatible request/response formats.

This step provides the foundation for talking to any OpenAI-compatible API (Anthropic, OpenAI, Ollama, etc.).

## What This Step Builds

An `HTTPClient` that:
- Makes async HTTP POST requests
- Handles streaming responses (SSE format)
- Supports timeouts
- Handles connection errors
- Works with OpenAI-compatible APIs

Plus OpenAI API types:
- Chat completion request format
- Streaming response format
- Error responses

## Step Objectives

1. Implement HTTPClient with URLSession
2. Add streaming support (Server-Sent Events)
3. Define OpenAI request/response types
4. Handle HTTP errors (4xx, 5xx, network)
5. Add timeout support
6. Create tests (mock responses)

## Prerequisites

**Required Steps**:
- ✅ Step 5: Core Data Models (Message, Tool)
- ✅ Step 6: Error Handling (YBSError)
- ✅ Step 4: Configuration (LLMConfig)

## Configurable Values

**Uses**:
- `llm.endpoint` - API endpoint URL
- `llm.api_key` - API authentication
- `llm.timeout_seconds` - Request timeout

## Traceability

**Implements**:
- `ybs-spec.md` Section 5.2 (LLM Communication)

**References**:
- D03 (API Abstraction: OpenAI-compatible)
- D12 (Streaming: Required for responses)

## Instructions

### 1. Define OpenAI API Types

**File to create**: `Sources/YBS/LLM/OpenAITypes.swift`

```swift
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
        var tool_calls: [ToolCall]?

        enum CodingKeys: String, CodingKey {
            case role, content
            case tool_calls = "tool_calls"
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
```

### 2. Implement HTTP Client

**File to create**: `Sources/YBS/HTTP/HTTPClient.swift`

```swift
import Foundation

class HTTPClient {
    private let session: URLSession
    private let logger: Logger

    init(logger: Logger) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        self.session = URLSession(configuration: config)
        self.logger = logger
    }

    /// Make a POST request with JSON body
    func post(url: String, headers: [String: String], body: Data) async throws -> Data {
        guard let requestURL = URL(string: url) else {
            throw YBSError.invalidInput(field: "url", reason: "Invalid URL format")
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.httpBody = body

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        logger.debug("POST \(url)")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw YBSError.llmConnectionFailed(
                    provider: "unknown",
                    error: "Invalid response type"
                )
            }

            logger.debug("Response status: \(httpResponse.statusCode)")

            // Handle error status codes
            if httpResponse.statusCode >= 400 {
                // Try to parse error response
                if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                    throw YBSError.llmRequestFailed(
                        statusCode: httpResponse.statusCode,
                        message: apiError.error.message
                    )
                } else {
                    let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw YBSError.llmRequestFailed(
                        statusCode: httpResponse.statusCode,
                        message: errorText
                    )
                }
            }

            return data
        } catch let error as YBSError {
            throw error
        } catch {
            logger.error("HTTP request failed: \(error)")
            throw YBSError.llmConnectionFailed(
                provider: "unknown",
                error: error.localizedDescription
            )
        }
    }

    /// Stream a POST request (Server-Sent Events)
    func streamPost(
        url: String,
        headers: [String: String],
        body: Data,
        onChunk: @escaping (String) -> Void
    ) async throws {
        guard let requestURL = URL(string: url) else {
            throw YBSError.invalidInput(field: "url", reason: "Invalid URL format")
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.httpBody = body

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        logger.debug("POST (stream) \(url)")

        do {
            let (bytes, response) = try await session.bytes(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw YBSError.llmConnectionFailed(
                    provider: "unknown",
                    error: "Invalid response type"
                )
            }

            if httpResponse.statusCode >= 400 {
                // Read error response
                var errorData = Data()
                for try await byte in bytes {
                    errorData.append(byte)
                }

                if let apiError = try? JSONDecoder().decode(APIError.self, from: errorData) {
                    throw YBSError.llmRequestFailed(
                        statusCode: httpResponse.statusCode,
                        message: apiError.error.message
                    )
                } else {
                    throw YBSError.llmRequestFailed(
                        statusCode: httpResponse.statusCode,
                        message: "Request failed"
                    )
                }
            }

            // Parse SSE stream
            var buffer = ""
            for try await byte in bytes {
                buffer.append(String(UnicodeScalar(byte)))

                // SSE lines end with \n
                if buffer.hasSuffix("\n") {
                    let line = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
                    buffer = ""

                    // SSE format: "data: {json}\n\n"
                    if line.hasPrefix("data: ") {
                        let data = String(line.dropFirst(6))
                        if data != "[DONE]" {
                            onChunk(data)
                        }
                    }
                }
            }
        } catch let error as YBSError {
            throw error
        } catch {
            logger.error("Streaming request failed: \(error)")
            throw YBSError.llmConnectionFailed(
                provider: "unknown",
                error: error.localizedDescription
            )
        }
    }
}
```

### 3. Add Tests

**File to create**: `Tests/YBSTests/HTTPClientTests.swift`

```swift
import XCTest
@testable import YBS

final class HTTPClientTests: XCTestCase {
    func testOpenAIRequestEncoding() throws {
        let request = ChatCompletionRequest(
            model: "gpt-4",
            messages: [.user("Hello")],
            tools: nil,
            temperature: 0.7,
            max_tokens: 1000,
            stream: false
        )

        let data = try JSONEncoder().encode(request)
        let json = String(data: data, encoding: .utf8)!

        XCTAssertTrue(json.contains("\"model\":\"gpt-4\""))
        XCTAssertTrue(json.contains("\"role\":\"user\""))
    }

    func testOpenAIResponseDecoding() throws {
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
                    "content": "Hello!"
                },
                "finish_reason": "stop"
            }]
        }
        """

        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)

        XCTAssertEqual(response.id, "chatcmpl-123")
        XCTAssertEqual(response.model, "gpt-4")
        XCTAssertEqual(response.choices[0].message.content, "Hello!")
    }

    func testStreamChunkDecoding() throws {
        let json = """
        {
            "id": "chatcmpl-123",
            "object": "chat.completion.chunk",
            "created": 1234567890,
            "model": "gpt-4",
            "choices": [{
                "index": 0,
                "delta": {
                    "content": "Hello"
                },
                "finish_reason": null
            }]
        }
        """

        let data = json.data(using: .utf8)!
        let chunk = try JSONDecoder().decode(ChatCompletionChunk.self, from: data)

        XCTAssertEqual(chunk.id, "chatcmpl-123")
        XCTAssertEqual(chunk.choices[0].delta.content, "Hello")
    }
}
```

### 4. Build and Test

```bash
swift build
swift test --filter HTTPClientTests
```

## Verification

```bash
cd systems/bootstrap/builds/test6
swift build
swift test --filter HTTPClientTests
# Expected: All tests pass
```

## Completion Checklist

- [ ] OpenAI API types defined
- [ ] HTTPClient implemented
- [ ] Streaming support works
- [ ] Error handling works
- [ ] Tests pass

## After Completion

Create DONE file: `docs/build-history/ybs-step_57ceeecb6edc-DONE.txt`

```bash
git commit -m "Step 11: Implement HTTP client and OpenAI API types

- Add HTTPClient with URLSession
- Support streaming responses (SSE)
- Define OpenAI-compatible request/response types
- Handle HTTP errors and timeouts
- Comprehensive tests

Implements: ybs-spec.md Section 5.2

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: Step 12 - LLM Client
