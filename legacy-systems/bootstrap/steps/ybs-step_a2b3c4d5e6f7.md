# Step 000034: Runtime LLM Provider Switching

**GUID**: a2b3c4d5e6f7
**Type**: Implementation
**Status**: Planned
**Last Updated**: 2026-01-18

---

## Overview

**Purpose**: Enable users to switch LLM providers and models during an active chat session without restarting the application.

**What This Step Does**:
- Adds `/provider` chat command to switch providers
- Adds `/model` chat command to switch models
- Adds `/config` command to view current configuration
- Adds `/help` command to list available commands
- Preserves conversation history when switching
- Dynamically recreates LLM client with new configuration

**Why This Step Exists**:
Users want to:
- Compare responses from different LLMs (OpenAI vs Anthropic vs Ollama)
- Switch to cheaper model for simple tasks
- Use local model when offline
- Try different models without losing conversation context
- Avoid restarting application and losing session state

**Dependencies**:
- ✅ Step 13: Agent Loop (where commands are handled)
- ✅ Step 15: Conversation Context (preserved during switch)
- ✅ Step 33: Anthropic Client (multiple providers available)

---

## Specifications

**Implements**:
- Spec: `systems/bootstrap/specs/technical/ybs-spec.md` § 7.5 Runtime Provider Switching

**References**:
- `systems/bootstrap/specs/technical/ybs-spec.md` lines 725-797 (Runtime Switching)

---

## What to Build

### File Structure

```
Sources/test7/Agent/
├── ChatCommandHandler.swift   # NEW - Command parsing and handling
└── AgentLoop.swift             # MODIFY - Integrate command handler

Sources/test7/LLM/
└── ProviderDefaults.swift      # NEW - Default endpoints/models per provider
```

### 1. ProviderDefaults.swift

**Purpose**: Define default configuration values for each provider.

**Key Components**:

```swift
import Foundation

/// Default configuration values for LLM providers
struct ProviderDefaults {
    /// Get default endpoint for a provider
    static func endpoint(for provider: String) -> String {
        switch provider.lowercased() {
        case "ollama":
            return "http://localhost:11434/api/chat"
        case "openai":
            return "https://api.openai.com/v1/chat/completions"
        case "anthropic":
            return "https://api.anthropic.com/v1/messages"
        case "apple":
            return ""  // Not used - native framework
        default:
            return ""  // User must specify
        }
    }

    /// Get default model for a provider
    static func model(for provider: String) -> String {
        switch provider.lowercased() {
        case "ollama":
            return "qwen2.5:14b"
        case "openai":
            return "gpt-4"
        case "anthropic":
            return "claude-3-5-sonnet-20241022"
        case "apple":
            return "foundation"
        default:
            return ""  // User must specify
        }
    }

    /// Get list of supported providers
    static let supportedProviders = [
        "ollama",
        "openai",
        "anthropic",
        "apple"
    ]

    /// Get provider display info
    static func info(for provider: String) -> String {
        switch provider.lowercased() {
        case "ollama":
            return "Ollama (local, free) - Default: qwen2.5:14b"
        case "openai":
            return "OpenAI (cloud, API key required) - Default: gpt-4"
        case "anthropic":
            return "Anthropic (cloud, API key required) - Default: claude-3-5-sonnet-20241022"
        case "apple":
            return "Apple Foundation Model (local, macOS 15+, free)"
        default:
            return "Unknown provider"
        }
    }

    /// Check if provider requires API key
    static func requiresAPIKey(_ provider: String) -> Bool {
        switch provider.lowercased() {
        case "openai", "anthropic":
            return true
        case "ollama", "apple":
            return false
        default:
            return false  // Assume not required unless known
        }
    }
}
```

**Size**: ~80 lines

---

### 2. ChatCommandHandler.swift

**Purpose**: Parse and handle chat commands (like `/provider`, `/model`, etc.).

**Key Components**:

```swift
import Foundation

/// Handles special chat commands that start with /
class ChatCommandHandler {
    private let logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }

    /// Check if input is a command and handle it
    /// Returns true if input was a command, false if normal chat message
    func handleCommand(
        _ input: String,
        config: inout YBSConfig,
        llmClient: inout LLMClientProtocol
    ) -> Bool {
        guard input.hasPrefix("/") else {
            return false  // Not a command
        }

        let parts = input.dropFirst().split(separator: " ", maxSplits: 2)
        guard let command = parts.first else {
            return false
        }

        switch command.lowercased() {
        case "provider":
            handleProviderCommand(Array(parts.dropFirst()), config: &config, llmClient: &llmClient)
            return true

        case "model":
            handleModelCommand(Array(parts.dropFirst()), config: &config, llmClient: &llmClient)
            return true

        case "config":
            handleConfigCommand()
            return true

        case "help":
            handleHelpCommand()
            return true

        default:
            logger.error("Unknown command: /\(command)")
            logger.info("Type /help for available commands")
            return true  // Still consumed as command attempt
        }
    }

    // MARK: - Command Handlers

    /// Handle /provider command
    private func handleProviderCommand(
        _ args: [Substring],
        config: inout YBSConfig,
        llmClient: inout LLMClientProtocol
    ) {
        // /provider list
        if args.first?.lowercased() == "list" {
            print("\n📋 Available providers:")
            for provider in ProviderDefaults.supportedProviders {
                print("  • \(provider): \(ProviderDefaults.info(for: provider))")
            }
            print()
            return
        }

        // /provider current
        if args.first?.lowercased() == "current" {
            print("\n⚙️  Current configuration:")
            print("  Provider: \(config.llm.provider)")
            print("  Model: \(config.llm.model)")
            print("  Endpoint: \(config.llm.endpoint)")
            print("  API Key: \(config.llm.apiKey != nil ? "configured" : "not configured")")
            print()
            return
        }

        // /provider <name> [model]
        guard let providerName = args.first else {
            print("Usage:")
            print("  /provider list                   - Show available providers")
            print("  /provider current                - Show current provider")
            print("  /provider <name> [model]         - Switch provider")
            print("\nExample: /provider anthropic claude-3-5-sonnet-20241022")
            return
        }

        let provider = String(providerName).lowercased()
        let model = args.count > 1 ? String(args[1]) : nil

        // Validate provider
        guard ProviderDefaults.supportedProviders.contains(provider) else {
            logger.error("Unknown provider: \(provider)")
            print("Supported providers: \(ProviderDefaults.supportedProviders.joined(separator: ", "))")
            return
        }

        // Check API key requirement
        if ProviderDefaults.requiresAPIKey(provider) && config.llm.apiKey == nil {
            logger.warning("Provider '\(provider)' requires an API key")
            print("⚠️  Warning: \(provider) requires an API key. Set it in your config file.")
            print("The switch will proceed, but API calls will fail without a key.")
        }

        // Update config
        let oldProvider = config.llm.provider
        let oldModel = config.llm.model

        config.llm.provider = provider
        config.llm.model = model ?? ProviderDefaults.model(for: provider)
        config.llm.endpoint = ProviderDefaults.endpoint(for: provider)

        // Recreate LLM client
        llmClient = LLMClientFactory.createClient(config: config.llm, logger: logger)

        logger.info("Switched from \(oldProvider)/\(oldModel) to \(config.llm.provider)/\(config.llm.model)")
        print("\n✅ Switched to \(config.llm.provider) with model \(config.llm.model)")
        print("Conversation history preserved.")
        print()
    }

    /// Handle /model command
    private func handleModelCommand(
        _ args: [Substring],
        config: inout YBSConfig,
        llmClient: inout LLMClientProtocol
    ) {
        guard let modelName = args.first else {
            print("Usage: /model <name>")
            print("Example: /model gpt-4")
            return
        }

        let oldModel = config.llm.model
        config.llm.model = String(modelName)

        // Recreate LLM client (model might affect initialization)
        llmClient = LLMClientFactory.createClient(config: config.llm, logger: logger)

        logger.info("Changed model from \(oldModel) to \(config.llm.model)")
        print("\n✅ Changed model to \(config.llm.model)")
        print("Provider remains: \(config.llm.provider)")
        print()
    }

    /// Handle /config command
    private func handleConfigCommand() {
        print("\n⚙️  Current Configuration:")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        // This will be filled in with actual config display
        print("Use /provider current for LLM settings")
        print()
    }

    /// Handle /help command
    private func handleHelpCommand() {
        print("""

        📖 Available Commands:
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        LLM Management:
          /provider list                   Show available LLM providers
          /provider current                Show current provider and model
          /provider <name> [model]         Switch to different provider
          /model <name>                    Change model (keep same provider)

        Information:
          /config                          Show current configuration
          /help                            Show this help message

        Examples:
          /provider anthropic              Switch to Anthropic (default model)
          /provider openai gpt-4           Switch to OpenAI GPT-4
          /model claude-3-opus-20240229    Change to Claude Opus
          /provider ollama qwen2.5:7b      Switch to local Ollama

        Note: Conversation history is preserved when switching providers.

        """)
    }
}
```

**Size**: ~210 lines

---

### 3. Update AgentLoop.swift

**Modify**: Integrate command handler into main loop.

**Changes**:

```swift
class AgentLoop {
    private let config: YBSConfig
    private let logger: Logger
    private var llmClient: LLMClientProtocol  // Changed from 'let' to 'var'
    private let toolExecutor: ToolExecutor
    private var context: ConversationContext
    private let commandHandler: ChatCommandHandler  // NEW

    init(config: YBSConfig, logger: Logger) {
        self.config = config  // Keep as stored property
        self.logger = logger
        self.llmClient = LLMClientFactory.createClient(config: config.llm, logger: logger)
        self.toolExecutor = ToolExecutor(logger: logger)
        self.context = ConversationContext(maxMessages: config.context.maxMessages)
        self.commandHandler = ChatCommandHandler(logger: logger)  // NEW

        // Register built-in tools
        registerBuiltinTools()
    }

    func run() async {
        logger.info("Starting agent loop")
        displayWelcome()

        while true {
            // Get user input
            print("\nYou: ", terminator: "")
            guard let userInput = readLine(), !userInput.isEmpty else {
                continue
            }

            // Check for quit commands
            if userInput.lowercased() == "quit" || userInput.lowercased() == "exit" {
                displayGoodbye()
                exit(0)
            }

            // NEW: Handle chat commands
            var mutableConfig = self.config  // Need mutable copy for command handler
            if commandHandler.handleCommand(
                userInput,
                config: &mutableConfig,
                llmClient: &llmClient
            ) {
                // Command was handled, don't send to LLM
                continue
            }

            // Normal chat message - send to LLM
            await handleUserMessage(userInput)
        }
    }

    private func displayWelcome() {
        print("""

        ╔═══════════════════════════════════════════════════════════════╗
        ║  Welcome to test7 - AI Coding Assistant                      ║
        ║                                                               ║
        ║  Provider: \(config.llm.provider.padding(toLength: 20, withPad: " ", startingAt: 0))  Model: \(config.llm.model.padding(toLength: 25, withPad: " ", startingAt: 0))║
        ║                                                               ║
        ║  Commands:                                                    ║
        ║    /provider <name>  - Switch LLM provider                    ║
        ║    /model <name>     - Change model                           ║
        ║    /help             - Show all commands                      ║
        ║    quit/exit         - Exit application                       ║
        ╚═══════════════════════════════════════════════════════════════╝

        """)
    }

    private func displayGoodbye() {
        let stats = context.getStatistics()
        print("\n\n👋 Goodbye!")
        print("Session summary:")
        print("  • Messages: \(stats.totalMessages)")
        print("  • User turns: \(stats.userTurns)")
        print("  • Assistant turns: \(stats.assistantTurns)")
        print()
    }

    // ... rest of existing methods ...
}
```

**Size**: ~40 lines modified/added

---

## Tests

**Location**: `Tests/test7Tests/Agent/ChatCommandHandlerTests.swift`

### Test Cases

**1. Command Detection**:
```swift
func testCommandDetection() {
    let handler = ChatCommandHandler(logger: testLogger)

    // Should detect commands
    XCTAssertTrue(handler.isCommand("/provider list"))
    XCTAssertTrue(handler.isCommand("/help"))

    // Should not detect non-commands
    XCTAssertFalse(handler.isCommand("Hello"))
    XCTAssertFalse(handler.isCommand("What is /provider?"))
}
```

**2. Provider Switching**:
```swift
func testProviderSwitch() {
    var config = YBSConfig()
    config.llm.provider = "ollama"

    let handler = ChatCommandHandler(logger: testLogger)
    var client: LLMClientProtocol = LLMClient(config: config.llm, logger: testLogger)

    handler.handleCommand("/provider anthropic", config: &config, llmClient: &client)

    XCTAssertEqual(config.llm.provider, "anthropic")
    XCTAssertTrue(client is AnthropicLLMClient)
}
```

**3. Model Switching**:
```swift
func testModelSwitch() {
    var config = YBSConfig()
    config.llm.model = "gpt-3.5-turbo"

    let handler = ChatCommandHandler(logger: testLogger)
    var client: LLMClientProtocol = LLMClient(config: config.llm, logger: testLogger)

    handler.handleCommand("/model gpt-4", config: &config, llmClient: &client)

    XCTAssertEqual(config.llm.model, "gpt-4")
}
```

**4. Invalid Commands**:
```swift
func testInvalidCommands() {
    let handler = ChatCommandHandler(logger: testLogger)
    var config = YBSConfig()
    var client: LLMClientProtocol = LLMClient(config: config.llm, logger: testLogger)

    // Should handle gracefully
    handler.handleCommand("/unknown", config: &config, llmClient: &client)
    handler.handleCommand("/provider", config: &config, llmClient: &client)  // No args
}
```

**Total Tests**: ~8-10 tests

---

## Verification Steps

### 1. Unit Tests

```bash
swift test --filter ChatCommandHandlerTests
# Should pass all tests
```

### 2. Manual Testing

**Test provider switching**:
```bash
swift run test7

You: /provider list
# Should show: ollama, openai, anthropic, apple

You: /provider current
# Should show: current provider and model

You: /provider anthropic
# Should switch to Anthropic with default model

You: What is 2+2?
AI: [Response from Anthropic]

You: /provider ollama
# Should switch to Ollama

You: What is 2+2?
AI: [Response from Ollama]
```

**Test model switching**:
```bash
You: /model gpt-3.5-turbo
# Should change model but keep OpenAI provider

You: Ask a question
AI: [Response from new model]
```

**Test conversation preservation**:
```bash
You: My name is Alice
AI: Nice to meet you, Alice!

You: /provider anthropic
# Switch provider

You: What is my name?
AI: Your name is Alice.
# Should remember from earlier conversation
```

### 3. Success Criteria

- ✅ ChatCommandHandler.swift created and working
- ✅ ProviderDefaults.swift provides correct defaults
- ✅ AgentLoop.swift integrated with command handler
- ✅ `/provider` command switches providers
- ✅ `/model` command changes models
- ✅ `/help` shows available commands
- ✅ Conversation history preserved during switch
- ✅ Unit tests pass
- ✅ Manual testing shows proper switching

---

## Configuration

**No config file changes needed** - all switching is runtime only.

**Supported Commands**:
- `/provider list` - Show available providers
- `/provider current` - Show current configuration
- `/provider <name> [model]` - Switch provider
- `/model <name>` - Change model
- `/config` - Show full configuration
- `/help` - Show help

---

## Dependencies

**Requires**:
- Step 13: Agent Loop (integration point)
- Step 15: Conversation Context (preserved during switch)
- Step 12: LLM Client (client recreation)
- Step 33: Anthropic Client (multiple providers)

**Enables**:
- Runtime provider comparison
- Model experimentation
- Offline/online switching (Ollama ↔ cloud)
- Cost optimization (switch to cheaper model)

---

## Implementation Notes

### Conversation Preservation

**What gets preserved**:
- Full conversation history
- Tool definitions
- Context statistics

**What gets reset**:
- LLM client instance (recreated)
- Provider-specific state (if any)

### API Key Handling

**Important**: API keys are already in config (from config file). When switching:
- Same config.llm.apiKey is used for all providers
- If provider requires different key, user must update config file first
- Warning shown if provider needs key but none configured

### Model Validation

**No validation** - assumes user knows valid model names for each provider:
- Ollama: `ollama list` shows local models
- OpenAI: Check OpenAI docs
- Anthropic: Check Anthropic docs

**Future enhancement**: Could add model validation per provider.

---

## Completion Criteria

**This step is complete when**:

1. **Code Written**:
   - [ ] ChatCommandHandler.swift with all commands
   - [ ] ProviderDefaults.swift with provider info
   - [ ] AgentLoop.swift integrated with command handler
   - [ ] Welcome message shows current provider

2. **Tests Pass**:
   - [ ] All ChatCommandHandlerTests pass
   - [ ] Command detection works
   - [ ] Provider switching works
   - [ ] Model switching works

3. **Verification Complete**:
   - [ ] Manual test: switch between all providers
   - [ ] Manual test: conversation history preserved
   - [ ] Manual test: all commands work as expected
   - [ ] Build compiles without errors

4. **Documentation Updated**:
   - [ ] README mentions runtime switching feature
   - [ ] USAGE.md includes command examples
   - [ ] In-app help (`/help`) is comprehensive

**Estimated Time**: 3-4 hours
**Estimated Size**: ~330 lines total

---

## Next Steps

**After This Step**:
- All 34 steps complete!
- Users can switch providers at runtime
- Full multi-provider support operational
- System is feature-complete

**What It Enables**:
- Provider comparison workflows
- Model experimentation
- Cost optimization strategies
- Flexible development environments

---

**Last Updated**: 2026-01-18
**Status**: Ready for implementation
