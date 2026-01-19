#!/usr/bin/env swift

import Foundation

// Copy the model structs inline for verification

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
    var name: String?

    enum CodingKeys: String, CodingKey {
        case role
        case content
        case toolCalls = "tool_calls"
        case toolCallId = "tool_call_id"
        case name
    }

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

struct ToolCall: Codable, Equatable {
    var id: String
    var type: String = "function"
    var function: FunctionCall

    struct FunctionCall: Codable, Equatable {
        var name: String
        var arguments: String

        init(name: String, arguments: String) {
            self.name = name
            self.arguments = arguments
        }
    }

    init(id: String, name: String, arguments: String) {
        self.id = id
        self.function = FunctionCall(name: name, arguments: arguments)
    }

    func parseArguments<T: Decodable>() throws -> T {
        let data = function.arguments.data(using: .utf8)!
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

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

struct ToolParameters: Codable, Equatable {
    var type: String = "object"
    var properties: [String: ToolProperty]
    var required: [String]

    init(properties: [String: ToolProperty], required: [String] = []) {
        self.properties = properties
        self.required = required
    }
}

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

// Verification tests
print("Core Data Models Verification")
print("==============================\n")

var passCount = 0
var failCount = 0

func verify(_ name: String, _ condition: Bool) {
    if condition {
        print("✓ \(name)")
        passCount += 1
    } else {
        print("✗ \(name)")
        failCount += 1
    }
}

// Test 1: Message creation
print("Test 1: Message creation")
let systemMsg = Message.system("You are helpful")
verify("System message has system role", systemMsg.role == .system)
verify("System message has content", systemMsg.content == "You are helpful")

let userMsg = Message.user("Hello")
verify("User message has user role", userMsg.role == .user)
verify("User message has content", userMsg.content == "Hello")

let assistantMsg = Message.assistant("Hi!")
verify("Assistant message has assistant role", assistantMsg.role == .assistant)
verify("Assistant message has content", assistantMsg.content == "Hi!")
print("")

// Test 2: Message JSON encoding
print("Test 2: Message JSON encoding")
do {
    let encoder = JSONEncoder()
    let data = try encoder.encode(userMsg)
    let jsonString = String(data: data, encoding: .utf8)!
    verify("Message encodes to JSON", !jsonString.isEmpty)
    verify("JSON contains role field", jsonString.contains("\"role\""))
    verify("JSON contains content field", jsonString.contains("\"content\""))
    print("")
} catch {
    print("✗ Message encoding failed: \(error)")
    failCount += 3
    print("")
}

// Test 3: Message JSON decoding
print("Test 3: Message JSON decoding")
do {
    let json = """
    {
        "role": "assistant",
        "content": "Hello!"
    }
    """
    let data = json.data(using: .utf8)!
    let decoded = try JSONDecoder().decode(Message.self, from: data)
    verify("Decoded message has correct role", decoded.role == .assistant)
    verify("Decoded message has correct content", decoded.content == "Hello!")
    print("")
} catch {
    print("✗ Message decoding failed: \(error)")
    failCount += 2
    print("")
}

// Test 4: Tool creation
print("Test 4: Tool creation")
let tool = Tool(
    name: "read_file",
    description: "Read a file",
    parameters: ToolParameters(
        properties: [
            "path": ToolProperty(type: "string", description: "File path")
        ],
        required: ["path"]
    )
)
verify("Tool has correct name", tool.function.name == "read_file")
verify("Tool has description", tool.function.description == "Read a file")
verify("Tool has required parameters", tool.function.parameters.required == ["path"])
print("")

// Test 5: Tool JSON encoding
print("Test 5: Tool JSON encoding")
do {
    let encoder = JSONEncoder()
    let data = try encoder.encode(tool)
    let jsonString = String(data: data, encoding: .utf8)!
    verify("Tool encodes to JSON", !jsonString.isEmpty)
    verify("JSON contains tool name", jsonString.contains("\"name\""))
    verify("JSON contains description", jsonString.contains("\"description\""))
    print("")
} catch {
    print("✗ Tool encoding failed: \(error)")
    failCount += 3
    print("")
}

// Test 6: ToolCall creation
print("Test 6: ToolCall creation and parsing")
let toolCall = ToolCall(
    id: "call_123",
    name: "read_file",
    arguments: "{\"path\": \"test.txt\"}"
)
verify("ToolCall has correct ID", toolCall.id == "call_123")
verify("ToolCall has correct name", toolCall.function.name == "read_file")

struct ReadFileArgs: Codable {
    var path: String
}

do {
    let args: ReadFileArgs = try toolCall.parseArguments()
    verify("ToolCall arguments parse correctly", args.path == "test.txt")
    print("")
} catch {
    print("✗ ToolCall argument parsing failed: \(error)")
    failCount += 1
    print("")
}

// Test 7: ToolResult
print("Test 7: ToolResult creation")
let successResult = ToolResult.success("File contents")
verify("Success result has success=true", successResult.success == true)
verify("Success result has output", successResult.output == "File contents")
verify("Success result has no error", successResult.error == nil)

let failureResult = ToolResult.failure("File not found")
verify("Failure result has success=false", failureResult.success == false)
verify("Failure result has no output", failureResult.output == nil)
verify("Failure result has error message", failureResult.error == "File not found")
print("")

// Summary
print("==============================")
print("Results: \(passCount) passed, \(failCount) failed")
if failCount == 0 {
    print("✓ All tests passed!")
    exit(0)
} else {
    print("✗ Some tests failed")
    exit(1)
}
