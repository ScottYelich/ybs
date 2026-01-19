# Step 000035: Meta Commands (/help, /tools)

**GUID**: b3c4d5e6f7a8
**Type**: Implementation
**Status**: Planned
**Last Updated**: 2026-01-18

---

## Overview

**Purpose**: Add meta-commands that control the chat session itself rather than being sent to the LLM.

**What This Step Does**:
- Adds `/help` command to show available commands
- Adds `/tools` command to list all available tools with descriptions
- Improves `/quit` and `/exit` commands (already exist, but enhance them)
- Intercepts commands before they reach the LLM
- Provides clear, formatted output for user guidance

**Why This Step Exists**:
Users need ways to:
- Discover what tools are available without asking the LLM
- Get quick help on how to use the application
- See command syntax and examples
- Understand what capabilities exist

**Dependencies**:
- ✅ Step 13: Agent Loop (where command handling goes)
- ✅ Step 8-10: Tools Layer (tools to list)

---

## Specifications

**Implements**:
- Spec: `systems/bootstrap/specs/technical/ybs-spec.md` § 6.3 Meta Commands

**References**:
- `systems/bootstrap/specs/technical/ybs-spec.md` lines 599-717 (Meta Commands)

---

## What to Build

### File Structure

```
Sources/test7/Agent/
├── MetaCommandHandler.swift   # NEW - Handle /commands
└── AgentLoop.swift             # MODIFY - Integrate meta commands
```

### 1. MetaCommandHandler.swift

**Purpose**: Parse and handle meta-commands that start with `/`.

**Key Components**:

```swift
import Foundation

/// Handles meta-commands that control the chat session
class MetaCommandHandler {
    private let toolExecutor: ToolExecutor
    private let logger: Logger

    init(toolExecutor: ToolExecutor, logger: Logger) {
        self.toolExecutor = toolExecutor
        self.logger = logger
    }

    /// Check if input is a meta-command and handle it
    /// Returns true if input was a command (don't send to LLM)
    func handleCommand(_ input: String) -> Bool {
        guard input.hasPrefix("/") else {
            return false  // Not a command
        }

        let parts = input.dropFirst().split(separator: " ", maxSplits: 1)
        guard let command = parts.first?.lowercased() else {
            return false
        }

        switch command {
        case "help":
            displayHelp()
            return true

        case "tools":
            displayTools()
            return true

        case "quit", "exit":
            // Already handled by AgentLoop, but include for completeness
            return false

        default:
            logger.warning("Unknown command: /\(command)")
            print("\n❌ Unknown command: /\(command)")
            print("Type /help for available commands\n")
            return true  // Still consumed as command attempt
        }
    }

    // MARK: - Command Implementations

    /// Display help message
    private func displayHelp() {
        print("""

        📖 Available Commands:
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        Meta Commands:
          /help                Show this help message
          /tools               List available tools with descriptions
          /quit or /exit       Exit the application

        Shell Injection (see Step 36):
          !<command>           Run shell command and inject output into context

        Examples:
          /tools               Show all available tools
          /help                Show this help
          quit                 Exit (can also use 'exit' or '/quit')

        Tips:
        - Ask the AI to use tools: "Read the README file"
        - Tools are invoked automatically by the AI when needed
        - Shell injection (!cmd) coming in Step 36

        Note: Commands starting with / are NOT sent to the LLM.
              They control the chat application itself.

        """)
    }

    /// Display all available tools
    private func displayTools() {
        let tools = toolExecutor.toolSchemas()

        print("\n🔧 Available Tools:\n")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")

        if tools.isEmpty {
            print("  No tools available\n")
            return
        }

        // Sort tools by name for consistent display
        let sortedTools = tools.sorted { $0.name < $1.name }

        for tool in sortedTools {
            print("  \(tool.name)")
            print("    \(tool.description)")

            // Show parameters if present
            if let params = tool.parameters {
                let required = params.required
                let properties = params.properties

                if !properties.isEmpty {
                    print("    Parameters:")
                    for (name, prop) in properties.sorted(by: { $0.key < $1.key }) {
                        let requiredMark = required.contains(name) ? "*" : ""
                        print("      - \(name)\(requiredMark): \(prop.description)")
                    }
                }
            }

            print()
        }

        print("Total: \(tools.count) tools available")
        print("(*) = required parameter\n")
    }
}
```

**Size**: ~130 lines

---

### 2. Update AgentLoop.swift

**Modify**: Integrate meta-command handler into main loop.

**Changes**:

```swift
class AgentLoop {
    private let llmClient: LLMClient
    private let toolExecutor: ToolExecutor
    private let context: ConversationContext
    private let logger: Logger
    private let systemPrompt: String
    private let metaCommandHandler: MetaCommandHandler  // NEW
    private let maxToolRounds = 10

    init(config: YBSConfig, logger: Logger) {
        self.llmClient = LLMClient(config: config.llm, logger: logger)
        self.toolExecutor = ToolExecutor(logger: logger)
        self.context = ConversationContext(
            maxMessages: config.context.maxMessages,
            logger: logger
        )
        self.logger = logger
        self.systemPrompt = """
        You are a helpful AI coding assistant. You help users with programming tasks.

        You have access to tools for reading files, listing directories, and more.
        Use tools when appropriate to help answer user questions.

        Be concise, accurate, and helpful. If you're unsure, say so.
        """

        // Initialize meta-command handler
        self.metaCommandHandler = MetaCommandHandler(
            toolExecutor: toolExecutor,
            logger: logger
        )
    }

    /// Start the interactive agent loop
    func run() async {
        logger.info("YBS Agent starting...")
        displayWelcome()  // Enhanced welcome message

        // Add system prompt
        context.addMessage(Message(role: .system, content: systemPrompt))

        while true {
            // Read user input
            print("\nYou: ", terminator: "")
            guard let userInput = readLine(), !userInput.isEmpty else {
                continue
            }

            // Check for quit (handle both with and without slash)
            let normalizedInput = userInput.lowercased()
            if normalizedInput == "quit" || normalizedInput == "exit" ||
               normalizedInput == "/quit" || normalizedInput == "/exit" {
                displayGoodbye()
                break
            }

            // NEW: Check for meta-commands
            if metaCommandHandler.handleCommand(userInput) {
                // Command was handled, don't send to LLM
                continue
            }

            // Normal chat message - add to context and process
            context.addMessage(Message(role: .user, content: userInput))
            await processWithTools()
        }
    }

    /// Display welcome message
    private func displayWelcome() {
        print("""

        ╔═══════════════════════════════════════════════════════════════╗
        ║  Welcome to test7 - AI Coding Assistant                      ║
        ║                                                               ║
        ║  Commands:                                                    ║
        ║    /help             - Show available commands                ║
        ║    /tools            - List available tools                   ║
        ║    quit or exit      - Exit application                       ║
        ║                                                               ║
        ║  Type /help for more information                              ║
        ╚═══════════════════════════════════════════════════════════════╝

        """)
    }

    /// Display goodbye message with statistics
    private func displayGoodbye() {
        let stats = context.getStatistics()

        print("\n\n👋 Goodbye!")
        print("\nSession summary:")
        print("  • Messages: \(stats.totalMessages)")
        print("  • User turns: \(stats.userTurns)")
        print("  • Assistant turns: \(stats.assistantTurns)")
        print()
    }

    // ... rest of existing methods unchanged ...
}
```

**Size**: ~50 lines modified/added

---

## Tests

**Location**: `Tests/test7Tests/Agent/MetaCommandHandlerTests.swift`

### Test Cases

**1. Command Detection**:
```swift
func testCommandDetection() {
    let handler = MetaCommandHandler(
        toolExecutor: testToolExecutor,
        logger: testLogger
    )

    // Should detect commands
    XCTAssertTrue(handler.handleCommand("/help"))
    XCTAssertTrue(handler.handleCommand("/tools"))
    XCTAssertTrue(handler.handleCommand("/unknown"))

    // Should not detect non-commands
    XCTAssertFalse(handler.handleCommand("Hello"))
    XCTAssertFalse(handler.handleCommand("What is /help?"))
}
```

**2. Help Display**:
```swift
func testHelpDisplay() {
    let handler = MetaCommandHandler(
        toolExecutor: testToolExecutor,
        logger: testLogger
    )

    // Should handle without crashing
    XCTAssertTrue(handler.handleCommand("/help"))
}
```

**3. Tools Display**:
```swift
func testToolsDisplay() {
    let handler = MetaCommandHandler(
        toolExecutor: testToolExecutor,
        logger: testLogger
    )

    // Should handle without crashing
    XCTAssertTrue(handler.handleCommand("/tools"))
}
```

**4. Unknown Commands**:
```swift
func testUnknownCommand() {
    let handler = MetaCommandHandler(
        toolExecutor: testToolExecutor,
        logger: testLogger
    )

    // Should handle gracefully
    XCTAssertTrue(handler.handleCommand("/unknown"))
    XCTAssertTrue(handler.handleCommand("/notacommand"))
}
```

**Total Tests**: ~6-8 tests

---

## Verification Steps

### 1. Unit Tests

```bash
swift test --filter MetaCommandHandlerTests
# Should pass all tests
```

### 2. Manual Testing

**Test /help command**:
```bash
swift run test7

You: /help
# Should show:
# - Available commands
# - Examples
# - Usage tips
```

**Test /tools command**:
```bash
You: /tools
# Should show:
# - read_file with description
# - list_files with description
# - write_file with description
# - edit_file with description
# - search_files with description
# - Parameter information
# - Total count
```

**Test unknown command**:
```bash
You: /unknown
# Should show:
# - Error message
# - Suggestion to use /help
```

**Test non-command**:
```bash
You: What is /help?
# Should be sent to LLM (not intercepted)
AI: /help is a command that shows...
```

### 3. Success Criteria

- ✅ MetaCommandHandler.swift created
- ✅ AgentLoop.swift integrated with handler
- ✅ `/help` shows comprehensive help
- ✅ `/tools` lists all tools with descriptions
- ✅ Unknown commands show helpful error
- ✅ Non-commands (containing / but not starting with it) pass through
- ✅ Unit tests pass
- ✅ Build compiles without errors

---

## Configuration

**No config changes needed** - commands are hardcoded in the handler.

**Command List**:
- `/help` - Show help
- `/tools` - List tools
- `/quit` or `/exit` - Exit (enhanced from existing)

---

## Dependencies

**Requires**:
- Step 13: Agent Loop (integration point)
- Step 8-10: Tools (to list)

**Enables**:
- Better user experience
- Self-documenting interface
- Foundation for Step 36 (shell injection)
- Foundation for Step 34 (provider switching commands)

---

## Implementation Notes

### Command Parsing

**Design decision**: Use simple prefix matching (`hasPrefix("/")`) rather than complex parsing:
- Fast and simple
- No regex needed
- Easy to extend

**Alternative**: Could use regex pattern matching:
```swift
let commandPattern = #"^/(\w+)(?:\s+(.*))?$"#
```
But this is overkill for simple commands.

### Display Formatting

**Use Unicode box drawing**:
```
━━━━━━━━━━━━━━━━━
```
Instead of ASCII:
```
------------------
```

**Why**: More visually appealing, clear separation.

### Tool Parameter Display

Show which parameters are required:
```
  read_file
    Read contents of a file from the filesystem
    Parameters:
      - path*: Path to the file to read
      - encoding: Text encoding (default: utf-8)

(*) = required parameter
```

This helps users understand tool capabilities without asking LLM.

---

## Completion Criteria

**This step is complete when**:

1. **Code Written**:
   - [ ] MetaCommandHandler.swift with all commands
   - [ ] AgentLoop.swift integrated with handler
   - [ ] Enhanced welcome/goodbye messages

2. **Tests Pass**:
   - [ ] All MetaCommandHandlerTests pass
   - [ ] Command detection works
   - [ ] Display methods don't crash

3. **Verification Complete**:
   - [ ] Manual test: `/help` shows comprehensive info
   - [ ] Manual test: `/tools` lists all tools
   - [ ] Manual test: unknown commands handled gracefully
   - [ ] Build compiles without errors

4. **Documentation Updated**:
   - [ ] README mentions /help and /tools commands
   - [ ] USAGE.md includes command examples
   - [ ] In-app help is clear and comprehensive

**Estimated Time**: 1-2 hours
**Estimated Size**: ~180 lines total

---

## Next Steps

**After This Step**:
- Step 36: Shell Injection Commands
- Users can discover tools without LLM
- Self-documenting interface
- Better first-run experience

**What It Enables**:
- User empowerment (discover features)
- Reduced LLM token usage (fewer "what can you do?" questions)
- Foundation for additional commands
- Better debugging (see what tools exist)

---

**Last Updated**: 2026-01-18
**Status**: Ready for implementation
