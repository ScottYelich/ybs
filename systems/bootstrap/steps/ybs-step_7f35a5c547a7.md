# Step 000005: Core Data Models

**GUID**: 7f35a5c547a7
**Version**: 0.1.0
**Layer**: 1 - Foundation
**Estimated Size**: ~100 lines of code

## Overview

This step defines the fundamental data structures used throughout the YBS system. These models represent conversations, tools, messages, and LLM interactions.

This is a pure data modeling step - no business logic, just type definitions. These structures will be used by every other component of the system.

## What This Step Builds

Core Swift structs and enums that model:
- **Message** - Chat messages (user, assistant, system, tool result)
- **Tool** - Tool definitions (name, description, parameters, schema)
- **ToolCall** - Tool invocations (tool name, arguments, execution result)
- **ToolParameter** - Tool parameter definitions (type, description, required/optional)

These models must be:
- `Codable` for JSON serialization (sending to/from LLM)
- Clean and simple (no business logic)
- Well-documented (clear purpose of each field)

## Step Objectives

1. Define `Message` struct for chat messages
2. Define `Tool` struct for tool definitions
3. Define `ToolCall` struct for tool invocations
4. Define `ToolParameter` struct for tool schemas
5. Add Codable conformance for JSON serialization
6. Create comprehensive tests for encoding/decoding
7. Verify models match OpenAI API format

## Prerequisites

**Required Steps**:
- ✅ `ybs-step_478a8c4b0cef` - Project Skeleton (Swift project exists)

**Optional Steps**:
- `ybs-step_3a85545f660c` - Configuration (Config models provide examples)

**Required Conditions**:
- Swift project compiles

## Configurable Values

**This step has no configurable values.**

These are pure data models, not configuration.

## Traceability

**Implements**:
- `ybs-spec.md` Section 3 (Core Tools - tool schema format)
- `ybs-spec.md` Section 5 (Agent Loop - message format)

**References**:
- OpenAI Chat Completion API format (message structure)
- OpenAI Function Calling format (tool call structure)

## Instructions

### Before Starting

1. **Record start time**: `date -u +"%Y-%m-%d %H:%M UTC"`
2. **Verify prerequisites**: Swift project builds
3. **Review OpenAI API docs**: Understand message/tool format

### 1. Define Message Model

Messages represent chat turns (user input, assistant response, tool results).

**File to create**: `Sources/YBS/Models/Message.swift`

```swift
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
        Message(role: .tool, content: content, toolCallId: id, name: name)
    }
}
```

### 2. Define Tool Model

Tools represent functions the LLM can call.

**File to create**: `Sources/YBS/Models/Tool.swift`

```swift
import Foundation

/// Represents a tool (function) that the LLM can call
struct Tool: Codable, Equatable {
    var type: String = "function"
    var function: ToolFunction

    struct ToolFunction: Codable, Equatable {
        var name: String
        var description: String
        var parameters: ToolParameters

        init(name: String, description: String, parameters: ToolParameters) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }
    }

    init(name: String, description: String, parameters: ToolParameters) {
        self.function = ToolFunction(
            name: name,
            description: description,
            parameters: parameters
        )
    }
}

/// Tool parameters schema (JSON Schema format)
struct ToolParameters: Codable, Equatable {
    var type: String = "object"
    var properties: [String: ToolProperty]
    var required: [String]

    init(properties: [String: ToolProperty], required: [String] = []) {
        self.properties = properties
        self.required = required
    }
}

/// Individual tool parameter definition
struct ToolProperty: Codable, Equatable {
    var type: String
    var description: String
    var enumValues: [String]?

    enum CodingKeys: String, CodingKey {
        case type
        case description
        case enumValues = "enum"
    }

    init(type: String, description: String, enumValues: [String]? = nil) {
        self.type = type
        self.description = description
        self.enumValues = enumValues
    }
}
```

### 3. Define ToolCall Model

ToolCalls represent LLM requests to execute tools.

**File to create**: `Sources/YBS/Models/ToolCall.swift`

```swift
import Foundation

/// Represents a tool call request from the LLM
struct ToolCall: Codable, Equatable {
    var id: String
    var type: String = "function"
    var function: FunctionCall

    struct FunctionCall: Codable, Equatable {
        var name: String
        var arguments: String // JSON string

        init(name: String, arguments: String) {
            self.name = name
            self.arguments = arguments
        }
    }

    init(id: String, name: String, arguments: String) {
        self.id = id
        self.function = FunctionCall(name: name, arguments: arguments)
    }

    /// Parse arguments from JSON string
    func parseArguments<T: Decodable>() throws -> T {
        let data = function.arguments.data(using: .utf8)!
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

/// Tool execution result
struct ToolResult: Codable, Equatable {
    var success: Bool
    var output: String?
    var error: String?

    static func success(_ output: String) -> ToolResult {
        ToolResult(success: true, output: output, error: nil)
    }

    static func failure(_ error: String) -> ToolResult {
        ToolResult(success: false, output: nil, error: error)
    }
}
```

### 4. Add Tests

Create comprehensive tests for all models.

**File to create**: `Tests/YBSTests/MessageTests.swift`

```swift
import XCTest
@testable import YBS

final class MessageTests: XCTestCase {
    func testSystemMessage() {
        let message = Message.system("You are a helpful assistant")

        XCTAssertEqual(message.role, .system)
        XCTAssertEqual(message.content, "You are a helpful assistant")
        XCTAssertNil(message.toolCalls)
    }

    func testUserMessage() {
        let message = Message.user("Hello")

        XCTAssertEqual(message.role, .user)
        XCTAssertEqual(message.content, "Hello")
    }

    func testAssistantMessage() {
        let message = Message.assistant("Hi there!")

        XCTAssertEqual(message.role, .assistant)
        XCTAssertEqual(message.content, "Hi there!")
    }

    func testMessageEncoding() throws {
        let message = Message.user("Test message")

        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        let jsonString = String(data: data, encoding: .utf8)!

        XCTAssertTrue(jsonString.contains("\"role\":\"user\""))
        XCTAssertTrue(jsonString.contains("\"content\":\"Test message\""))
    }

    func testMessageDecoding() throws {
        let json = """
        {
            "role": "assistant",
            "content": "Hello!"
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let message = try decoder.decode(Message.self, from: data)

        XCTAssertEqual(message.role, .assistant)
        XCTAssertEqual(message.content, "Hello!")
    }
}
```

**File to create**: `Tests/YBSTests/ToolTests.swift`

```swift
import XCTest
@testable import YBS

final class ToolTests: XCTestCase {
    func testToolCreation() {
        let tool = Tool(
            name: "read_file",
            description: "Read contents of a file",
            parameters: ToolParameters(
                properties: [
                    "path": ToolProperty(type: "string", description: "File path")
                ],
                required: ["path"]
            )
        )

        XCTAssertEqual(tool.function.name, "read_file")
        XCTAssertEqual(tool.function.parameters.required, ["path"])
    }

    func testToolEncoding() throws {
        let tool = Tool(
            name: "test_tool",
            description: "A test tool",
            parameters: ToolParameters(
                properties: [
                    "arg1": ToolProperty(type: "string", description: "First arg")
                ],
                required: ["arg1"]
            )
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(tool)
        let jsonString = String(data: data, encoding: .utf8)!

        XCTAssertTrue(jsonString.contains("\"name\":\"test_tool\""))
        XCTAssertTrue(jsonString.contains("\"description\":\"A test tool\""))
    }
}
```

**File to create**: `Tests/YBSTests/ToolCallTests.swift`

```swift
import XCTest
@testable import YBS

final class ToolCallTests: XCTestCase {
    func testToolCallCreation() {
        let toolCall = ToolCall(
            id: "call_123",
            name: "read_file",
            arguments: "{\"path\": \"test.txt\"}"
        )

        XCTAssertEqual(toolCall.id, "call_123")
        XCTAssertEqual(toolCall.function.name, "read_file")
    }

    func testToolCallArgumentParsing() throws {
        struct ReadFileArgs: Codable {
            var path: String
        }

        let toolCall = ToolCall(
            id: "call_123",
            name: "read_file",
            arguments: "{\"path\": \"test.txt\"}"
        )

        let args: ReadFileArgs = try toolCall.parseArguments()
        XCTAssertEqual(args.path, "test.txt")
    }

    func testToolResultSuccess() {
        let result = ToolResult.success("File contents here")

        XCTAssertTrue(result.success)
        XCTAssertEqual(result.output, "File contents here")
        XCTAssertNil(result.error)
    }

    func testToolResultFailure() {
        let result = ToolResult.failure("File not found")

        XCTAssertFalse(result.success)
        XCTAssertNil(result.output)
        XCTAssertEqual(result.error, "File not found")
    }
}
```

### 5. Build and Test

Verify all models compile and tests pass.

**Commands**:
```bash
# Build
swift build

# Run all tests
swift test

# Run specific test suites
swift test --filter MessageTests
swift test --filter ToolTests
swift test --filter ToolCallTests
```

## Verification

### Build Verification

```bash
cd systems/bootstrap/builds/test6
swift build
# Expected: Build succeeds with no errors
```

### Test Verification

```bash
swift test --filter MessageTests
swift test --filter ToolTests
swift test --filter ToolCallTests
# Expected: All tests pass (12+ tests)
```

### Manual Verification

Create a small test to verify JSON serialization:

```swift
// Test that models round-trip through JSON correctly
let message = Message.user("Hello")
let encoded = try JSONEncoder().encode(message)
let decoded = try JSONDecoder().decode(Message.self, from: encoded)
assert(message == decoded)
print("✓ Message round-trip successful")

let tool = Tool(
    name: "test",
    description: "Test tool",
    parameters: ToolParameters(properties: [:], required: [])
)
let toolEncoded = try JSONEncoder().encode(tool)
let toolDecoded = try JSONDecoder().decode(Tool.self, from: toolEncoded)
assert(tool == toolDecoded)
print("✓ Tool round-trip successful")
```

### OpenAI API Compatibility Check

Verify JSON format matches OpenAI's expected format:

```swift
let message = Message.assistant("Test")
let data = try JSONEncoder().encode(message)
let json = String(data: data, encoding: .utf8)!
// Should match: {"role":"assistant","content":"Test"}
```

## Completion Checklist

When this step is complete, verify:

- [ ] Message model defined in `Sources/YBS/Models/Message.swift`
- [ ] Tool model defined in `Sources/YBS/Models/Tool.swift`
- [ ] ToolCall model defined in `Sources/YBS/Models/ToolCall.swift`
- [ ] All models are `Codable` and `Equatable`
- [ ] Tests created for all models
- [ ] `swift build` succeeds
- [ ] `swift test` passes all model tests
- [ ] JSON serialization works correctly
- [ ] Models match OpenAI API format

## After Completion

**Record completion**:
1. Note completion timestamp
2. Create DONE file: `docs/build-history/ybs-step_7f35a5c547a7-DONE.txt`
3. Update BUILD_STATUS.md

**DONE file contents**:
```
Step: ybs-step_7f35a5c547a7
Title: Core Data Models
Status: COMPLETED
Started: [timestamp]
Completed: [timestamp]
Duration: [duration]

Changes:
- Created Sources/YBS/Models/Message.swift
- Created Sources/YBS/Models/Tool.swift
- Created Sources/YBS/Models/ToolCall.swift
- Created Tests/YBSTests/MessageTests.swift
- Created Tests/YBSTests/ToolTests.swift
- Created Tests/YBSTests/ToolCallTests.swift
- All tests passing

Verification:
✓ Build succeeds
✓ All tests pass (12+ tests)
✓ JSON serialization works
✓ Models match OpenAI format
```

**Commit**:
```bash
git add -A
git commit -m "Step 5: Define core data models

- Add Message model (user, assistant, system, tool roles)
- Add Tool model (function definitions with parameters)
- Add ToolCall model (LLM tool invocation requests)
- Add ToolResult model (tool execution results)
- All models Codable and Equatable
- Comprehensive tests for encoding/decoding
- Compatible with OpenAI API format

Implements: ybs-spec.md Section 3, 5

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: `ybs-step_[next-guid]` - Step 6: Error Handling & Logging

**Dependencies satisfied**: These data models will be used throughout the system for messages, tools, and LLM communication.
