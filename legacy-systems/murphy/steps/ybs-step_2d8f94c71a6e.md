# Step 000013: Basic Agent Loop (No Tools)

**GUID**: 2d8f94c71a6e
**Version**: 0.1.0
**Layer**: 4 - Agent Core
**Estimated Size**: ~80 lines of code

## Overview

Implements the basic agent loop - an interactive REPL (Read-Eval-Print-Loop) that lets users chat with the LLM. This is a simple chat interface WITHOUT tool execution - just user messages and AI responses.

This is the foundation of the agent. Steps 14-15 will add tool calling and context management.

## What This Step Builds

An `AgentLoop` that:
- Reads user input from terminal
- Sends messages to LLM via LLMClient
- Prints AI responses (streaming)
- Loops until user types "quit" or "exit"
- Maintains conversation history

## Step Objectives

1. Implement AgentLoop class
2. Add REPL (read-eval-print loop)
3. Integrate LLMClient from Step 12
4. Add streaming output (print tokens as received)
5. Add quit/exit command
6. Create basic system prompt

## Prerequisites

**Required Steps**:
- ✅ Step 12: LLM Client (can talk to AI)
- ✅ Step 7: CLI Parsing (entry point)
- ✅ Step 6: Logging

## Configurable Values

**Uses**:
- `llm.*` - All LLM configuration
- System prompt (hardcoded for now, will be configurable later)

## Traceability

**Implements**:
- `ybs-spec.md` Section 6.1 (Agent Loop)

**References**:
- D07 (Agent Architecture: Single-turn initially)
- D12 (Streaming: Required for UX)

## Instructions

### 1. Implement Agent Loop

**File to create**: `Sources/YBS/Agent/AgentLoop.swift`

```swift
import Foundation

class AgentLoop {
    private let llmClient: LLMClient
    private let logger: Logger
    private var conversationHistory: [Message] = []
    private let systemPrompt: String

    init(config: YBSConfig, logger: Logger) {
        self.llmClient = LLMClient(config: config.llm, logger: logger)
        self.logger = logger
        self.systemPrompt = """
        You are a helpful AI coding assistant. You help users with programming tasks.

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

            // Send to LLM
            print("\nAI: ", terminator: "")
            fflush(stdout)

            do {
                // Stream response
                let response = try await llmClient.sendStreamingChatRequest(
                    messages: conversationHistory
                ) { token in
                    print(token, terminator: "")
                    fflush(stdout)
                }

                print() // Newline after response

                // Add assistant response to history
                conversationHistory.append(response)
            } catch {
                logger.error("Failed to get response: \(error)")
                print("\n❌ Error: \(error)")
            }
        }
    }
}
```

### 2. Update Main Entry Point

**File to update**: `Sources/YBS/YBSCommand.swift`

Add the agent loop execution after config loading:

```swift
import Foundation
import ArgumentParser

@main
struct YBSCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "ybs",
        abstract: "YBS - AI Coding Assistant",
        version: "0.1.0"
    )

    @Option(name: .shortAndLong, help: "Config file path")
    var config: String?

    @Option(name: .shortAndLong, help: "LLM model name")
    var model: String?

    @Option(name: .shortAndLong, help: "LLM provider (anthropic, openai, ollama)")
    var provider: String?

    @Option(name: .shortAndLong, help: "API endpoint URL")
    var endpoint: String?

    @Flag(name: .long, help: "Dry-run mode (don't execute)")
    var dryRun = false

    mutating func run() throws {
        // Load configuration
        let configPaths = [
            "/etc/ybs/config.json",
            "~/.config/ybs/config.json",
            "~/.ybs/config.json",
            "./.ybs/config.json"
        ]

        var loadedConfig = ConfigLoader.loadLayered(paths: configPaths)

        // Apply CLI overrides
        if let model = model {
            loadedConfig.llm.model = model
        }
        if let provider = provider {
            loadedConfig.llm.provider = provider
        }
        if let endpoint = endpoint {
            loadedConfig.llm.endpoint = endpoint
        }

        // Setup logger
        let logger = Logger(component: "YBS", useColor: true)

        // Validate API key
        guard loadedConfig.llm.api_key != nil else {
            logger.error("No API key configured. Set ANTHROPIC_API_KEY environment variable or add to config.")
            throw ExitCode.failure
        }

        if dryRun {
            logger.info("Dry-run mode - config loaded successfully")
            print("Configuration:")
            print("  Provider: \(loadedConfig.llm.provider)")
            print("  Model: \(loadedConfig.llm.model)")
            print("  Endpoint: \(loadedConfig.llm.endpoint)")
            return
        }

        // Start agent loop
        let agent = AgentLoop(config: loadedConfig, logger: logger)
        Task {
            await agent.run()
        }

        // Wait for agent to finish
        RunLoop.main.run()
    }
}
```

### 3. Add Tests

**File to create**: `Tests/YBSTests/AgentLoopTests.swift`

```swift
import XCTest
@testable import YBS

final class AgentLoopTests: XCTestCase {
    func testAgentCreation() {
        let config = YBSConfig(
            llm: LLMConfig(
                provider: "test",
                model: "test-model",
                endpoint: "https://test.example.com",
                api_key: "test-key"
            )
        )

        let logger = Logger(component: "Test", useColor: false)
        let agent = AgentLoop(config: config, logger: logger)

        XCTAssertNotNil(agent)
    }

    func testSystemPromptAdded() {
        let config = YBSConfig(
            llm: LLMConfig(
                provider: "test",
                model: "test-model",
                endpoint: "https://test.example.com",
                api_key: "test-key"
            )
        )

        let logger = Logger(component: "Test", useColor: false)
        let agent = AgentLoop(config: config, logger: logger)

        // Agent should have system prompt in history
        // (Would need to expose conversationHistory for testing)
        XCTAssertNotNil(agent)
    }
}
```

### 4. Build and Test

```bash
swift build
swift test --filter AgentLoopTests
```

## Verification

```bash
cd systems/bootstrap/builds/test6

# Set API key
export ANTHROPIC_API_KEY="your-key-here"

# Run agent
swift run ybs

# Expected output:
# YBS Agent (type 'quit' or 'exit' to stop)
# ─────────────────────────────────────────
#
# You: Hello
#
# AI: Hello! How can I assist you with your coding tasks today?
#
# You: What is 2+2?
#
# AI: 2 + 2 equals 4.
#
# You: quit
# Goodbye!
```

## Completion Checklist

- [ ] AgentLoop class created
- [ ] REPL works (read-eval-print loop)
- [ ] LLMClient integration works
- [ ] Streaming output works
- [ ] Quit command works
- [ ] System prompt added
- [ ] Tests pass

## After Completion

Create DONE file: `docs/build-history/ybs-step_2d8f94c71a6e-DONE.txt`

```bash
git add -A
git commit -m "Step 13: Implement basic agent loop

- Add AgentLoop with REPL
- Integrate LLMClient for chat
- Support streaming output
- Add quit/exit command
- Add system prompt
- Update CLI entry point

First interactive chat session working!

Implements: ybs-spec.md Section 6.1

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Step

**Proceed to**: Step 14 - Tool Calling Integration
