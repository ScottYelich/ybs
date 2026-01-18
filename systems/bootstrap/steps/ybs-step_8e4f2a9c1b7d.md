# Step 000015: Conversation Context Management

**GUID**: 8e4f2a9c1b7d
**Version**: 0.1.0
**Layer**: 4 - Agent Core
**Estimated Size**: ~60 lines of code

## Overview

Implements conversation context management - properly maintains message history across multiple turns and prunes old messages when approaching token limits.

This completes Layer 4 (Agent Core). After this step, we have a WORKING AI AGENT! 🎉

## What This Step Builds

A `ConversationContext` that:
- Stores message history (system + user + assistant + tool messages)
- Tracks number of messages
- Prunes old messages when approaching limit
- Preserves system prompt and recent messages
- Provides conversation summary

## Step Objectives

1. Create ConversationContext class
2. Move message history management from AgentLoop
3. Add message pruning (keep system + last N messages)
4. Add conversation statistics (message count, turn count)
5. Integrate with AgentLoop
6. Create tests

## Prerequisites

**Required Steps**:
- ✅ Step 14: Tool Calling Integration (AgentLoop with tools)
- ✅ Step 5: Core Data Models (Message)

## Configurable Values

**Uses**:
- `context.max_messages` - Maximum messages to keep (default: 50)

## Traceability

**Implements**:
- `ybs-spec.md` Section 6.3 (Context Management)

**References**:
- D09 (Context Window: Keep recent messages)

## Instructions

### 1. Implement Conversation Context

**File to create**: `Sources/YBS/Agent/ConversationContext.swift`

```swift
import Foundation

class ConversationContext {
    private var messages: [Message] = []
    private let maxMessages: Int
    private let logger: Logger

    init(maxMessages: Int = 50, logger: Logger) {
        self.maxMessages = maxMessages
        self.logger = logger
    }

    /// Add a message to the conversation
    func addMessage(_ message: Message) {
        messages.append(message)

        // Prune if exceeding limit
        if messages.count > maxMessages {
            pruneOldMessages()
        }
    }

    /// Add multiple messages
    func addMessages(_ newMessages: [Message]) {
        for message in newMessages {
            addMessage(message)
        }
    }

    /// Get all messages in conversation
    func getMessages() -> [Message] {
        return messages
    }

    /// Get conversation statistics
    func getStats() -> (messageCount: Int, userTurns: Int, assistantTurns: Int) {
        let userTurns = messages.filter { $0.role == .user }.count
        let assistantTurns = messages.filter { $0.role == .assistant }.count
        return (messages.count, userTurns, assistantTurns)
    }

    /// Clear conversation (keep system prompt if present)
    func clear(keepSystemPrompt: Bool = true) {
        if keepSystemPrompt, let systemMessage = messages.first, systemMessage.role == .system {
            messages = [systemMessage]
        } else {
            messages = []
        }
    }

    /// Prune old messages (keep system + recent messages)
    private func pruneOldMessages() {
        logger.debug("Pruning old messages (current: \(messages.count), max: \(maxMessages))")

        // Always keep system prompt
        var systemPrompts: [Message] = []
        var otherMessages: [Message] = []

        for message in messages {
            if message.role == .system {
                systemPrompts.append(message)
            } else {
                otherMessages.append(message)
            }
        }

        // Keep recent messages (leave room for system prompts)
        let keepCount = maxMessages - systemPrompts.count
        let recentMessages = Array(otherMessages.suffix(keepCount))

        // Rebuild messages array
        messages = systemPrompts + recentMessages

        logger.info("Pruned conversation (now: \(messages.count) messages)")
    }

    /// Get conversation summary
    func getSummary() -> String {
        let stats = getStats()
        return """
        Conversation Summary:
        - Total messages: \(stats.messageCount)
        - User turns: \(stats.userTurns)
        - Assistant turns: \(stats.assistantTurns)
        """
    }
}
```

### 2. Update Configuration

**File to update**: `Sources/YBS/Models/Configuration.swift`

Add context config section:

```swift
struct ContextConfig: Codable {
    var max_messages: Int = 50
    var max_tokens: Int = 32000

    enum CodingKeys: String, CodingKey {
        case max_messages = "max_messages"
        case max_tokens = "max_tokens"
    }
}

struct YBSConfig: Codable {
    var version: String = "1.0"
    var llm: LLMConfig = LLMConfig()
    var context: ContextConfig = ContextConfig()  // Add this
    var safety: SafetyConfig = SafetyConfig()
}
```

### 3. Update Agent Loop

**File to update**: `Sources/YBS/Agent/AgentLoop.swift`

Replace conversation history management:

```swift
import Foundation

class AgentLoop {
    private let llmClient: LLMClient
    private let toolExecutor: ToolExecutor
    private let context: ConversationContext  // Use ConversationContext
    private let logger: Logger
    private let systemPrompt: String
    private let maxToolRounds = 10

    init(config: YBSConfig, logger: Logger) {
        self.llmClient = LLMClient(config: config.llm, logger: logger)
        self.toolExecutor = ToolExecutor(logger: logger)
        self.context = ConversationContext(
            maxMessages: config.context.max_messages,
            logger: logger
        )
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

        // Add system prompt
        context.addMessage(Message(role: .system, content: systemPrompt))

        while true {
            // Read user input
            print("\nYou: ", terminator: "")
            guard let userInput = readLine(), !userInput.isEmpty else {
                continue
            }

            // Check for quit
            if userInput.lowercased() == "quit" || userInput.lowercased() == "exit" {
                print("\n" + context.getSummary())
                print("Goodbye!")
                break
            }

            // Add user message
            context.addMessage(Message(role: .user, content: userInput))

            // Process with tool calling loop
            await processWithTools()
        }
    }

    /// Process user message with tool calling loop
    private func processWithTools() async {
        var toolRound = 0

        while toolRound < maxToolRounds {
            toolRound += 1

            let tools = toolExecutor.toolSchemas()

            print("\nAI: ", terminator: "")
            fflush(stdout)

            do {
                let response = try await llmClient.sendStreamingChatRequest(
                    messages: context.getMessages(),  // Use context
                    tools: tools
                ) { token in
                    print(token, terminator: "")
                    fflush(stdout)
                }

                print()

                // Add assistant response
                context.addMessage(response)

                if let toolCalls = response.toolCalls, !toolCalls.isEmpty {
                    await executeTools(toolCalls)
                    continue
                } else {
                    break
                }
            } catch {
                logger.error("Failed to get response: \(error)")
                print("\n❌ Error: \(error)")
                break
            }
        }

        if toolRound >= maxToolRounds {
            logger.warn("Max tool rounds reached")
            print("\n⚠️ Maximum tool execution rounds reached")
        }
    }

    private func executeTools(_ toolCalls: [ToolCall]) async {
        for toolCall in toolCalls {
            let toolName = toolCall.function.name
            let toolArgs = toolCall.function.arguments

            logger.info("Executing tool: \(toolName)")
            print("🔧 Using tool: \(toolName)")

            do {
                let result = try await toolExecutor.execute(
                    toolName: toolName,
                    arguments: toolArgs
                )

                let resultContent: String
                if result.success {
                    resultContent = result.output ?? "Success"
                    print("   ✓ Success")
                } else {
                    resultContent = "Error: \(result.error ?? "Unknown")"
                    print("   ✗ Error: \(result.error ?? "unknown")")
                }

                // Add tool result
                context.addMessage(Message(
                    role: .tool,
                    content: resultContent,
                    name: toolName,
                    toolCallId: toolCall.id
                ))
            } catch {
                logger.error("Tool execution failed: \(error)")
                print("   ✗ Error: \(error)")

                context.addMessage(Message(
                    role: .tool,
                    content: "Error: \(error.localizedDescription)",
                    name: toolName,
                    toolCallId: toolCall.id
                ))
            }
        }
    }
}
```

### 4. Add Tests

**File to create**: `Tests/YBSTests/ConversationContextTests.swift`

```swift
import XCTest
@testable import YBS

final class ConversationContextTests: XCTestCase {
    func testAddMessage() {
        let logger = Logger(component: "Test", useColor: false)
        let context = ConversationContext(maxMessages: 10, logger: logger)

        context.addMessage(.system("System prompt"))
        context.addMessage(.user("Hello"))
        context.addMessage(.assistant("Hi there!"))

        let messages = context.getMessages()
        XCTAssertEqual(messages.count, 3)
    }

    func testMessagePruning() {
        let logger = Logger(component: "Test", useColor: false)
        let context = ConversationContext(maxMessages: 5, logger: logger)

        // Add system prompt
        context.addMessage(.system("System"))

        // Add 10 user/assistant messages (should trigger pruning)
        for i in 1...10 {
            context.addMessage(.user("User \(i)"))
            context.addMessage(.assistant("Assistant \(i)"))
        }

        let messages = context.getMessages()

        // Should have <= maxMessages
        XCTAssertLessThanOrEqual(messages.count, 5)

        // Should still have system prompt
        XCTAssertEqual(messages.first?.role, .system)
    }

    func testConversationStats() {
        let logger = Logger(component: "Test", useColor: false)
        let context = ConversationContext(maxMessages: 100, logger: logger)

        context.addMessage(.system("System"))
        context.addMessage(.user("Hello"))
        context.addMessage(.assistant("Hi"))
        context.addMessage(.user("How are you?"))
        context.addMessage(.assistant("I'm good!"))

        let stats = context.getStats()
        XCTAssertEqual(stats.messageCount, 5)
        XCTAssertEqual(stats.userTurns, 2)
        XCTAssertEqual(stats.assistantTurns, 2)
    }

    func testClearConversation() {
        let logger = Logger(component: "Test", useColor: false)
        let context = ConversationContext(maxMessages: 100, logger: logger)

        context.addMessage(.system("System"))
        context.addMessage(.user("Hello"))
        context.addMessage(.assistant("Hi"))

        context.clear(keepSystemPrompt: true)

        let messages = context.getMessages()
        XCTAssertEqual(messages.count, 1)
        XCTAssertEqual(messages.first?.role, .system)
    }
}
```

### 5. Build and Test

```bash
swift build
swift test --filter ConversationContextTests
```

## Verification

```bash
cd systems/bootstrap/builds/test6

export ANTHROPIC_API_KEY="your-key-here"

swift run ybs

# Have a multi-turn conversation:
# You: My name is Scott
# AI: Nice to meet you, Scott!
#
# You: What's my name?
# AI: Your name is Scott.
#
# You: Create a file called test.txt with "Hello World"
# 🔧 Using tool: write_file
#    ✓ Success
# AI: I've created test.txt with "Hello World"
#
# You: Read test.txt
# 🔧 Using tool: read_file
#    ✓ Success
# AI: The file contains: "Hello World"
#
# You: quit
# Conversation Summary:
# - Total messages: 12
# - User turns: 4
# - Assistant turns: 4
# Goodbye!
```

## Completion Checklist

- [ ] ConversationContext class created
- [ ] Message history management works
- [ ] Message pruning works
- [ ] Statistics tracking works
- [ ] AgentLoop integration works
- [ ] Tests pass

## After Completion

**MILESTONE: Working AI Agent!** 🎉🎉🎉

Create DONE file: `docs/build-history/ybs-step_8e4f2a9c1b7d-DONE.txt`

```bash
git add -A
git commit -m "Step 15: Add conversation context management

- Create ConversationContext class
- Manage message history with pruning
- Track conversation statistics
- Integrate with AgentLoop
- Preserve system prompt across pruning
- Comprehensive tests

Layer 4 (Agent Core) Complete: Working AI Agent!

Implements: ybs-spec.md Section 6.3

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: Layer 5 - More Tools (Steps 16-19)
**Next step**: Step 16 - write_file Tool

**🎯 MILESTONE ACHIEVED**: You now have a working AI coding assistant that can:
- Chat with users
- Execute tools (read_file, list_files)
- Maintain conversation context
- Handle multi-turn interactions

The next layers add more tools, safety, external plugins, and polish!
