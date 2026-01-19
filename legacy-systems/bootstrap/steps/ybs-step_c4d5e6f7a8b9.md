# Step 000036: Shell Injection Commands (!bash)

**GUID**: c4d5e6f7a8b9
**Type**: Implementation
**Status**: Planned
**Last Updated**: 2026-01-18

---

## Overview

**Purpose**: Allow users to run shell commands and inject output directly into conversation context for LLM analysis.

**What This Step Does**:
- Adds `!<command>` syntax for shell injection
- Executes shell command via existing shell tool
- Captures stdout and stderr
- Injects output into conversation context
- LLM receives output and can respond to it
- Respects sandbox and security settings

**Why This Step Exists**:
Users want to:
- Quickly inspect files without explicit tool calls: `!cat README.md`
- Check system state: `!df -h`, `!ps aux`
- Run git commands: `!git status`, `!git diff`
- Execute project commands: `!npm test`, `!make build`
- Get immediate context from command output

**Traditional way** (slower):
```
You: Can you read the README file?
AI: [Uses read_file tool]
```

**Shell injection way** (faster):
```
You: !cat README.md
[Output shown immediately]
AI: [Responds to content]
```

**Dependencies**:
- ✅ Step 13: Agent Loop (integration point)
- ✅ Step 35: Meta Commands (command infrastructure)
- ✅ Step 10: run_shell Tool (shell execution)

---

## Specifications

**Implements**:
- Spec: `systems/bootstrap/specs/technical/ybs-spec.md` § 6.4 Shell Injection Commands

**References**:
- `systems/bootstrap/specs/technical/ybs-spec.md` lines 719-881 (Shell Injection)

---

## What to Build

### File Structure

```
Sources/test7/Agent/
├── ShellInjectionHandler.swift   # NEW - Handle !commands
├── MetaCommandHandler.swift       # EXISTING (from Step 35)
└── AgentLoop.swift                # MODIFY - Integrate shell injection
```

### 1. ShellInjectionHandler.swift

**Purpose**: Execute shell commands and inject output into conversation.

**Key Components**:

```swift
import Foundation

/// Handles shell injection commands that start with !
class ShellInjectionHandler {
    private let toolExecutor: ToolExecutor
    private let logger: Logger
    private let maxOutputLength: Int

    init(toolExecutor: ToolExecutor, logger: Logger, maxOutputLength: Int = 10000) {
        self.toolExecutor = toolExecutor
        self.logger = logger
        self.maxOutputLength = maxOutputLength
    }

    /// Check if input is a shell injection command
    func isShellCommand(_ input: String) -> Bool {
        return input.hasPrefix("!")
    }

    /// Execute shell command and return formatted output for context injection
    /// Returns tuple: (shouldInject: Bool, message: String)
    func handleShellCommand(_ input: String) async -> (Bool, String) {
        // Extract command (everything after '!')
        let command = String(input.dropFirst()).trimmingCharacters(in: .whitespaces)

        guard !command.isEmpty else {
            print("\n❌ Error: No command specified")
            print("Usage: !<command>")
            print("Example: !ls -la\n")
            return (false, "")
        }

        // Show what we're running
        print("\n💻 Running: \(command)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        do {
            // Execute via run_shell tool (respects sandbox)
            let arguments = ["command": command]
            let argumentsJSON = try JSONEncoder().encode(arguments)
            let argumentsString = String(data: argumentsJSON, encoding: .utf8) ?? "{}"

            let result = try await toolExecutor.execute(
                toolName: "run_shell",
                arguments: argumentsString
            )

            // Parse result
            var stdout = ""
            var stderr = ""
            var exitCode = 0

            if result.success, let output = result.output {
                // Parse JSON output from run_shell tool
                if let data = output.data(using: .utf8),
                   let json = try? JSONDecoder().decode([String: String].self, from: data) {
                    stdout = json["stdout"] ?? ""
                    stderr = json["stderr"] ?? ""
                    exitCode = Int(json["exit_code"] ?? "0") ?? 0
                } else {
                    // Fallback: treat entire output as stdout
                    stdout = output
                }
            } else if let error = result.error {
                // Command failed
                stderr = error
                exitCode = 1
            }

            // Display output to user
            if !stdout.isEmpty {
                print(stdout)
            }
            if !stderr.isEmpty {
                print("stderr: \(stderr)")
            }
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("Exit code: \(exitCode)\n")

            // Truncate if too long
            let truncatedStdout = truncateOutput(stdout)
            let truncatedStderr = truncateOutput(stderr)

            // Format message for LLM context
            let contextMessage = formatContextMessage(
                command: command,
                stdout: truncatedStdout,
                stderr: truncatedStderr,
                exitCode: exitCode,
                wasTruncated: truncatedStdout.count < stdout.count || truncatedStderr.count < stderr.count
            )

            logger.info("Shell injection: \(command) (exit: \(exitCode))")
            return (true, contextMessage)

        } catch {
            // Execution error
            print("❌ Error executing command: \(error)\n")
            logger.error("Shell injection failed: \(error)")

            let errorMessage = """
            [Shell command failed]
            Command: \(command)
            Error: \(error.localizedDescription)
            """

            return (true, errorMessage)
        }
    }

    // MARK: - Helper Methods

    /// Truncate output if too long
    private func truncateOutput(_ output: String) -> String {
        if output.count <= maxOutputLength {
            return output
        }

        let truncated = String(output.prefix(maxOutputLength))
        return truncated + "\n\n... (output truncated, \(output.count) total characters)"
    }

    /// Format context message for LLM
    private func formatContextMessage(
        command: String,
        stdout: String,
        stderr: String,
        exitCode: Int,
        wasTruncated: Bool
    ) -> String {
        var message = """
        [Shell command output]
        Command: \(command)
        Exit code: \(exitCode)
        """

        if !stdout.isEmpty {
            message += "\n\nOutput:\n\(stdout)"
        }

        if !stderr.isEmpty {
            message += "\n\nStderr:\n\(stderr)"
        }

        if stdout.isEmpty && stderr.isEmpty {
            message += "\n\n(No output)"
        }

        if wasTruncated {
            message += "\n\nNote: Output was truncated due to length."
        }

        return message
    }
}
```

**Size**: ~180 lines

---

### 2. Update AgentLoop.swift

**Modify**: Integrate shell injection handler into main loop.

**Changes**:

```swift
class AgentLoop {
    private let llmClient: LLMClient
    private let toolExecutor: ToolExecutor
    private let context: ConversationContext
    private let logger: Logger
    private let systemPrompt: String
    private let metaCommandHandler: MetaCommandHandler
    private let shellInjectionHandler: ShellInjectionHandler  // NEW
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

        // Initialize handlers
        self.metaCommandHandler = MetaCommandHandler(
            toolExecutor: toolExecutor,
            logger: logger
        )
        self.shellInjectionHandler = ShellInjectionHandler(
            toolExecutor: toolExecutor,
            logger: logger,
            maxOutputLength: config.context.maxToolOutputChars
        )
    }

    /// Start the interactive agent loop
    func run() async {
        logger.info("YBS Agent starting...")
        displayWelcome()

        // Add system prompt
        context.addMessage(Message(role: .system, content: systemPrompt))

        while true {
            // Read user input
            print("\nYou: ", terminator: "")
            guard let userInput = readLine(), !userInput.isEmpty else {
                continue
            }

            // Check for quit
            let normalizedInput = userInput.lowercased()
            if normalizedInput == "quit" || normalizedInput == "exit" ||
               normalizedInput == "/quit" || normalizedInput == "/exit" {
                displayGoodbye()
                break
            }

            // Check for meta-commands
            if metaCommandHandler.handleCommand(userInput) {
                continue
            }

            // NEW: Check for shell injection
            if shellInjectionHandler.isShellCommand(userInput) {
                let (shouldInject, message) = await shellInjectionHandler.handleShellCommand(userInput)

                if shouldInject {
                    // Inject command output into context
                    context.addMessage(Message(role: .user, content: message))

                    // Let LLM respond to it
                    await processWithTools()
                }
                continue
            }

            // Normal chat message
            context.addMessage(Message(role: .user, content: userInput))
            await processWithTools()
        }
    }

    // ... rest unchanged ...
}
```

**Size**: ~30 lines added

---

### 3. Update MetaCommandHandler.swift (from Step 35)

**Modify**: Update help text to include shell injection.

**Change**:

```swift
private func displayHelp() {
    print("""

    📖 Available Commands:
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    Meta Commands:
      /help                Show this help message
      /tools               List available tools with descriptions
      /quit or /exit       Exit the application

    Shell Injection:
      !<command>           Run shell command and inject output into context

    Examples:
      /tools               Show all available tools
      !ls -la              List files in current directory
      !cat README.md       Show README contents
      !git status          Show git status
      !df -h               Show disk usage

    Tips:
    - Shell commands (!cmd) show output, then AI responds
    - Commands respect sandbox settings
    - Large outputs are truncated automatically
    - Use /tools to see what the AI can do directly

    Security:
    - Shell commands run in sandbox (if enabled in config)
    - Dangerous commands are blocked
    - Commands timeout after 60 seconds

    """)
}
```

---

## Tests

**Location**: `Tests/test7Tests/Agent/ShellInjectionHandlerTests.swift`

### Test Cases

**1. Command Detection**:
```swift
func testShellCommandDetection() {
    let handler = ShellInjectionHandler(
        toolExecutor: testToolExecutor,
        logger: testLogger
    )

    XCTAssertTrue(handler.isShellCommand("!ls"))
    XCTAssertTrue(handler.isShellCommand("!cat file.txt"))
    XCTAssertFalse(handler.isShellCommand("ls"))
    XCTAssertFalse(handler.isShellCommand("What is !ls?"))
}
```

**2. Command Extraction**:
```swift
func testCommandExtraction() async {
    let handler = ShellInjectionHandler(
        toolExecutor: testToolExecutor,
        logger: testLogger
    )

    let (shouldInject, message) = await handler.handleShellCommand("!echo hello")

    XCTAssertTrue(shouldInject)
    XCTAssertTrue(message.contains("echo hello"))
    XCTAssertTrue(message.contains("hello"))
}
```

**3. Output Truncation**:
```swift
func testOutputTruncation() async {
    let handler = ShellInjectionHandler(
        toolExecutor: testToolExecutor,
        logger: testLogger,
        maxOutputLength: 100  // Small limit for testing
    )

    // Generate large output
    let (_, message) = await handler.handleShellCommand("!yes | head -1000")

    XCTAssertTrue(message.contains("truncated"))
}
```

**4. Error Handling**:
```swift
func testCommandError() async {
    let handler = ShellInjectionHandler(
        toolExecutor: testToolExecutor,
        logger: testLogger
    )

    let (shouldInject, message) = await handler.handleShellCommand("!nonexistentcommand")

    XCTAssertTrue(shouldInject)
    XCTAssertTrue(message.contains("Error") || message.contains("failed"))
}
```

**Total Tests**: ~6-8 tests

---

## Verification Steps

### 1. Unit Tests

```bash
swift test --filter ShellInjectionHandlerTests
# Should pass all tests
```

### 2. Manual Testing

**Test basic command**:
```bash
swift run test7

You: !echo hello world
# Should show:
# 💻 Running: echo hello world
# ━━━━━━━━━━━━━━━━━━━━━━━━━
# hello world
# ━━━━━━━━━━━━━━━━━━━━━━━━━
# Exit code: 0

AI: [Responds to "hello world" output]
```

**Test file inspection**:
```bash
You: !cat Package.swift
# Should show file contents
AI: [Analyzes Package.swift]

You: What dependencies does this project have?
AI: Based on the Package.swift I saw, this project depends on...
```

**Test git commands**:
```bash
You: !git status
# Shows git status
AI: [Interprets git status]
```

**Test error handling**:
```bash
You: !nonexistentcommand
# Should show error gracefully
AI: [Responds to error]
```

**Test large output**:
```bash
You: !find / -name "*.txt" 2>/dev/null
# Should truncate large output
AI: [Responds to truncated output]
```

### 3. Success Criteria

- ✅ ShellInjectionHandler.swift created
- ✅ AgentLoop.swift integrated with handler
- ✅ Commands execute and output shown
- ✅ Output injected into context correctly
- ✅ LLM receives and responds to output
- ✅ Truncation works for large outputs
- ✅ Errors handled gracefully
- ✅ Sandbox respected (if enabled)
- ✅ Unit tests pass
- ✅ Build compiles without errors

---

## Configuration

**Uses existing config**:
- `context.max_tool_output_chars` - Maximum output length before truncation
- `safety.sandbox_enabled` - Whether to sandbox shell commands
- `safety.shell_timeout_seconds` - Command timeout
- `safety.blocked_commands` - Commands to block

**No new config needed**.

---

## Dependencies

**Requires**:
- Step 13: Agent Loop (integration point)
- Step 35: Meta Commands (command infrastructure)
- Step 10: run_shell Tool (shell execution)

**Enables**:
- Quick system inspection
- Faster workflow (no explicit tool requests)
- Direct command output analysis
- Better debugging experience

---

## Implementation Notes

### Why `!` Prefix?

**Considered alternatives**:
- `$command` - Conflicts with shell variable syntax
- `` `command` `` - Hard to type, conflicts with markdown
- `>command` - Less distinctive
- `!command` - ✅ Clear, distinctive, used by Jupyter

**Decision**: Use `!` prefix as it's:
- Not a shell metacharacter
- Visually distinctive
- Common convention (Jupyter notebooks)
- Easy to type

### Security Architecture

**Shell injection uses existing run_shell tool**:
```
User: !ls
  ↓
ShellInjectionHandler
  ↓
ToolExecutor.execute("run_shell", ...)
  ↓
RunShellTool (with sandbox, blocklist, timeout)
  ↓
Output captured
  ↓
Injected into context
  ↓
LLM receives and responds
```

This ensures:
- ✅ Consistent security (same as LLM-invoked shell commands)
- ✅ Sandbox enforcement
- ✅ Command blocklist
- ✅ Timeout protection

### Output Truncation Strategy

**Why truncate?**
- Prevent context overflow
- Reduce token usage
- Keep conversation manageable

**When to truncate?**
- After `max_tool_output_chars` (default: 10,000 chars)
- Truncate at character boundary (simple)
- Add note about truncation

**Alternative** (not implemented):
- Could truncate at line boundaries
- Could use smart truncation (first N + last M lines)
- Could let user configure per-command

---

## Completion Criteria

**This step is complete when**:

1. **Code Written**:
   - [ ] ShellInjectionHandler.swift implemented
   - [ ] AgentLoop.swift integrated with handler
   - [ ] MetaCommandHandler.swift updated with !cmd help

2. **Tests Pass**:
   - [ ] All ShellInjectionHandlerTests pass
   - [ ] Command detection works
   - [ ] Output injection works
   - [ ] Truncation works

3. **Verification Complete**:
   - [ ] Manual test: basic commands work
   - [ ] Manual test: output shown to user
   - [ ] Manual test: LLM receives output
   - [ ] Manual test: large output truncated
   - [ ] Manual test: errors handled
   - [ ] Build compiles without errors

4. **Documentation Updated**:
   - [ ] README mentions !command syntax
   - [ ] USAGE.md includes shell injection examples
   - [ ] /help includes !command info

**Estimated Time**: 2-3 hours
**Estimated Size**: ~210 lines total

---

## Next Steps

**After This Step**:
- All meta-commands and shell injection complete
- Users have powerful inspection tools
- Faster workflow for common tasks
- Better debugging experience

**What It Enables**:
- Quick file inspection without tool formality
- Immediate system state checks
- Fast git/project command execution
- Better integration with developer workflow

---

## Use Case Examples

### Example 1: Quick File Check
```
You: !cat .env
[Shows .env contents]
AI: I can see your environment variables. You have DATABASE_URL set to...

You: Is that secure?
AI: No, you shouldn't commit .env files...
```

### Example 2: Git Workflow
```
You: !git status
[Shows modified files]
AI: You have 3 modified files: app.js, utils.js, and package.json.

You: !git diff app.js
[Shows diff]
AI: The changes in app.js add error handling to the login function...
```

### Example 3: System Diagnostics
```
You: My build is slow
AI: Let me help diagnose. Can you check your CPU usage?

You: !top -l 1 | head -20
[Shows CPU stats]
AI: Your CPU is at 95%, with node using most of it. Try closing other applications...
```

### Example 4: Project Inspection
```
You: !npm test
[Shows test results]
AI: 3 tests are failing in the authentication module. Let me look at those files...
```

---

**Last Updated**: 2026-01-18
**Status**: Ready for implementation
