# Step 000014: Tool Calling Integration

**GUID**: 5b3c9e8a4f21
**Version**: 0.1.0
**Layer**: 4 - Agent Core
**Estimated Size**: ~100 lines of code

## Overview

Integrates tool calling into the agent loop. When the LLM requests a tool (e.g., "read this file"), the agent executes it via ToolExecutor and sends the result back to the LLM.

This is the key step that transforms a simple chatbot into an agentic system!

## What This Step Builds

Enhanced `AgentLoop` that:
- Detects when LLM requests tool calls
- Executes tools via ToolExecutor
- Adds tool results to conversation
- Sends updated conversation back to LLM
- Continues until no more tool calls (multi-turn loop)

## Step Objectives

1. Update AgentLoop to detect tool calls
2. Integrate ToolExecutor from Step 10
3. Execute tools when requested
4. Format tool results as messages
5. Handle tool execution errors
6. Add multi-turn tool calling loop
7. Create tests

## Prerequisites

**Required Steps**:
- ✅ Step 13: Basic Agent Loop (agent exists)
- ✅ Step 10: Tool Executor (can execute tools)
- ✅ Step 8-9: Tools (read_file, list_files)

## Configurable Values

**Uses**:
- Existing config (no new config needed)

## Traceability

**Implements**:
- `ybs-spec.md` Section 6.2 (Tool Calling)

**References**:
- D04 (Tool Architecture: Built-in + external)
- D11 (Tool Calling: OpenAI-compatible)

## Instructions

### 1. Update Agent Loop

**File to update**: `Sources/YBS/Agent/AgentLoop.swift`

Replace the existing file with this enhanced version:

```swift
import Foundation

class AgentLoop {
    private let llmClient: LLMClient
    private let toolExecutor: ToolExecutor
    private let logger: Logger
    private var conversationHistory: [Message] = []
    private let systemPrompt: String
    private let maxToolRounds = 10 // Prevent infinite loops

    init(config: YBSConfig, logger: Logger) {
        self.llmClient = LLMClient(config: config.llm, logger: logger)
        self.toolExecutor = ToolExecutor(logger: logger)
        self.logger = logger
        self.systemPrompt = """
        You are a helpful AI coding assistant. You help users with programming tasks.

        You have access to tools for reading files, listing directories, and more.
        Use tools when appropriate to help answer user questions.

        Be concise, accurate, and helpful. If you're unsure, say so.
        """
    }

    /// Start the interactive agent loop
    func run() async {
        logger.info("YBS Agent starting...")
        print("YBS Agent (type 'quit' or 'exit' to stop)")
        print("─────────────────────────────────────────")

        // Add system prompt to history
        conversationHistory.append(Message(
            role: "system",
            content: systemPrompt
        ))

        while true {
            // Read user input
            print("\nYou: ", terminator: "")
            guard let userInput = readLine(), !userInput.isEmpty else {
                continue
            }

            // Check for quit
            if userInput.lowercased() == "quit" || userInput.lowercased() == "exit" {
                print("Goodbye!")
                break
            }

            // Add user message to history
            let userMessage = Message(role: "user", content: userInput)
            conversationHistory.append(userMessage)

            // Process with tool calling loop
            await processWithTools()
        }
    }

    /// Process user message with tool calling loop
    private func processWithTools() async {
        var toolRound = 0

        while toolRound < maxToolRounds {
            toolRound += 1

            // Get available tools
            let tools = toolExecutor.toolSchemas()

            // Send to LLM
            print("\nAI: ", terminator: "")
            fflush(stdout)

            do {
                // Stream response
                let response = try await llmClient.sendStreamingChatRequest(
                    messages: conversationHistory,
                    tools: tools
                ) { token in
                    print(token, terminator: "")
                    fflush(stdout)
                }

                print() // Newline after response

                // Add assistant response to history
                conversationHistory.append(response)

                // Check if LLM wants to call tools
                if let toolCalls = response.toolCalls, !toolCalls.isEmpty {
                    // Execute tools
                    await executeTools(toolCalls)

                    // Continue loop (LLM will see tool results and respond)
                    continue
                } else {
                    // No tool calls - done with this user message
                    break
                }
            } catch {
                logger.error("Failed to get response: \(error)")
                print("\n❌ Error: \(error)")
                break
            }
        }

        if toolRound >= maxToolRounds {
            logger.warn("Max tool rounds reached (\(maxToolRounds))")
            print("\n⚠️ Maximum tool execution rounds reached")
        }
    }

    /// Execute tool calls and add results to conversation
    private func executeTools(_ toolCalls: [ToolCall]) async {
        for toolCall in toolCalls {
            let toolName = toolCall.function.name
            let toolArgs = toolCall.function.arguments

            logger.info("Executing tool: \(toolName)")
            print("🔧 Using tool: \(toolName)")

            do {
                // Execute tool
                let result = try await toolExecutor.execute(
                    toolName: toolName,
                    arguments: toolArgs
                )

                // Format result for LLM
                let resultContent: String
                if result.success {
                    resultContent = result.output ?? "Success (no output)"
                    print("   ✓ Success")
                } else {
                    resultContent = "Error: \(result.error ?? "Unknown error")"
                    print("   ✗ Error: \(result.error ?? "unknown")")
                }

                // Add tool result to conversation
                let toolResultMessage = Message(
                    role: "tool",
                    content: resultContent,
                    name: toolName,
                    toolCallId: toolCall.id
                )
                conversationHistory.append(toolResultMessage)
            } catch {
                logger.error("Tool execution failed: \(error)")
                print("   ✗ Error: \(error)")

                // Add error result to conversation
                let toolErrorMessage = Message(
                    role: "tool",
                    content: "Error: \(error.localizedDescription)",
                    name: toolName,
                    toolCallId: toolCall.id
                )
                conversationHistory.append(toolErrorMessage)
            }
        }
    }
}
```

### 2. Update Message Model (If Needed)

**File to check**: `Sources/YBS/Models/Message.swift`

Ensure Message supports tool-related fields:

```swift
struct Message: Codable, Equatable {
    enum Role: String, Codable {
        case system
        case user
        case assistant
        case tool
    }

    var role: Role
    var content: String?
    var toolCalls: [ToolCall]?
    var name: String?        // Tool name (for tool role)
    var toolCallId: String?  // Tool call ID (for tool role)

    enum CodingKeys: String, CodingKey {
        case role
        case content
        case toolCalls = "tool_calls"
        case name
        case toolCallId = "tool_call_id"
    }

    init(role: Role, content: String? = nil, toolCalls: [ToolCall]? = nil, name: String? = nil, toolCallId: String? = nil) {
        self.role = role
        self.content = content
        self.toolCalls = toolCalls
        self.name = name
        self.toolCallId = toolCallId
    }

    // Convenience constructors
    static func system(_ content: String) -> Message {
        Message(role: .system, content: content)
    }

    static func user(_ content: String) -> Message {
        Message(role: .user, content: content)
    }

    static func assistant(_ content: String) -> Message {
        Message(role: .assistant, content: content)
    }
}
```

### 3. Add Tests

**File to create**: `Tests/YBSTests/ToolCallingTests.swift`

```swift
import XCTest
@testable import YBS

final class ToolCallingTests: XCTestCase {
    func testToolCallDetection() {
        let message = Message(
            role: .assistant,
            content: nil,
            toolCalls: [
                ToolCall(
                    id: "call_123",
                    type: "function",
                    function: FunctionCall(
                        name: "read_file",
                        arguments: "{\"path\": \"test.txt\"}"
                    )
                )
            ]
        )

        XCTAssertNotNil(message.toolCalls)
        XCTAssertEqual(message.toolCalls?.count, 1)
        XCTAssertEqual(message.toolCalls?[0].function.name, "read_file")
    }

    func testToolResultMessage() {
        let toolResult = Message(
            role: .tool,
            content: "File contents here",
            name: "read_file",
            toolCallId: "call_123"
        )

        XCTAssertEqual(toolResult.role, .tool)
        XCTAssertEqual(toolResult.name, "read_file")
        XCTAssertEqual(toolResult.toolCallId, "call_123")
    }

    func testToolExecutorIntegration() async throws {
        // Create test file
        let testPath = "/tmp/ybs-test-tool-calling.txt"
        try "Test content".write(toFile: testPath, atomically: true, encoding: .utf8)

        let logger = Logger(component: "Test", useColor: false)
        let executor = ToolExecutor(logger: logger)

        // Execute tool
        let args = "{\"path\": \"\(testPath)\"}"
        let result = try await executor.execute(toolName: "read_file", arguments: args)

        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output!.contains("Test content"))
    }
}
```

### 4. Build and Test

```bash
swift build
swift test --filter ToolCallingTests
```

## Verification

```bash
cd systems/bootstrap/builds/test6

# Set API key
export ANTHROPIC_API_KEY="your-key-here"

# Create test file
echo "Hello from YBS!" > test-file.txt

# Run agent
swift run ybs

# Expected interaction:
# You: Read the file test-file.txt
# 🔧 Using tool: read_file
#    ✓ Success
# AI: The file test-file.txt contains: "Hello from YBS!"
#
# You: List files in the current directory
# 🔧 Using tool: list_files
#    ✓ Success
# AI: The current directory contains the following files:
#     - Package.swift
#     - README.md
#     - test-file.txt
#     ...
```

## Completion Checklist

- [ ] AgentLoop updated with tool calling
- [ ] Tool detection works
- [ ] Tool execution via ToolExecutor works
- [ ] Tool results added to conversation
- [ ] Multi-turn tool loop works
- [ ] Error handling works
- [ ] Tests pass

## After Completion

Create DONE file: `docs/build-history/ybs-step_5b3c9e8a4f21-DONE.txt`

```bash
git add -A
git commit -m "Step 14: Add tool calling integration

- Integrate ToolExecutor into AgentLoop
- Detect and execute tool calls from LLM
- Add tool results to conversation
- Multi-turn tool calling loop
- Handle tool execution errors
- Comprehensive tests

Agent can now use tools to complete tasks!

Implements: ybs-spec.md Section 6.2

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: Step 15 - Conversation Context Management
