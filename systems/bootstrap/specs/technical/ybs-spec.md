# YBS (Yelich Build System): Swift Implementation Specification

> A local-first, extensible AI agent (reasoning + tool using LLM chat) written in Swift.
>
> **Name**: `ybs` — Yelich Build System framework for building LLM-based coding assistants.

---

## 1. Overview

### 1.1 Purpose
A command-line tool that provides an interactive chat interface for AI-assisted coding. The tool maintains conversation context, executes tools on behalf of the LLM, and supports both local and remote LLM backends.

### 1.2 Design Principles
- **Local-first**: All tool execution happens locally; LLM can be local or remote
- **Minimal dependencies**: Use Swift standard library and Foundation where possible
- **Extensible**: Tools can be added without recompiling
- **Secure by default**: Sandbox shell execution, require confirmation for destructive ops
- **Simple core**: Agent loop should be understandable in <100 lines

### 1.3 Target Environment
- macOS 14+ (primary)
- Linux (future, via Swift on Linux)
- RAM: Works within user's system constraints
- No GUI required (CLI-first)

---

## 2. Configuration

### 2.1 Configuration File Resolution

Config files are loaded in order, with later files overriding earlier values:

```
1. /etc/ybs/config.json          (system-wide defaults)
2. ~/.config/ybs/config.json     (user defaults)
3. ~/.ybs.json                   (user home shorthand)
4. ./.ybs.json                   (project-specific)
5. --config <path>               (explicit override)
```

### 2.2 Command Line Interface

```
USAGE: ybs[options]

OPTIONS:
  -c, --config <file>       Path to configuration file
  -m, --model <name>        Override model from config
  -p, --provider <name>     Override provider (ollama, openai, anthropic, apple)
  --endpoint <url>          Override API endpoint
  --no-sandbox              Disable shell sandboxing (DANGEROUS)
  --dry-run                 Show tool calls without executing
  --version                 Print version and exit
  --help                    Show help
```

### 2.3 Configuration Schema

```json
{
  "version": "1.0",

  "llm": {
    "provider": "ollama",
    "model": "qwen3:14b",
    "endpoint": "http://localhost:11434",
    "api_key": null,
    "temperature": 0.7,
    "max_tokens": 4096,
    "timeout_seconds": 120
  },

  "context": {
    "max_tokens": 32000,
    "compaction_threshold": 0.95,
    "repo_map_tokens": 1024,
    "max_tool_output_chars": 10000
  },

  "agent": {
    "max_iterations": 25,
    "retry_attempts": 3,
    "retry_backoff_base_ms": 1000
  },

  "safety": {
    "sandbox_enabled": true,
    "sandbox_allowed_paths": ["./"],
    "sandbox_blocked_paths": ["~/.ssh", "~/.aws", "~/.config"],
    "require_confirmation": ["write_file", "run_shell", "delete_file"],
    "blocked_commands": ["rm -rf /", "sudo", "chmod 777"]
  },

  "tools": {
    "builtin": {
      "read_file": {"enabled": true},
      "write_file": {"enabled": true},
      "edit_file": {"enabled": true},
      "list_files": {"enabled": true},
      "search_files": {"enabled": true},
      "run_shell": {"enabled": true, "timeout_seconds": 30}
    },
    "external": [
      {
        "name": "web_search",
        "type": "executable",
        "path": "~/.ybs/tools/web-search",
        "enabled": true
      },
      {
        "name": "web_fetch",
        "type": "executable",
        "path": "~/.ybs/tools/web-fetch",
        "enabled": true
      }
    ]
  },

  "git": {
    "auto_commit": true,
    "commit_message_prefix": "[ybs]"
  },

  "ui": {
    "color": true,
    "show_token_usage": true,
    "show_tool_calls": true,
    "stream_responses": true
  }
}
```

---

## 3. Core Tools (Built-in)

These tools are compiled into the binary. They require tight integration with the agent loop for security and performance.

### 3.1 read_file

**Purpose**: Read contents of a file.

```json
{
  "name": "read_file",
  "description": "Read the contents of a file. Use this before editing any file.",
  "parameters": {
    "path": {
      "type": "string",
      "description": "Path to file (relative to working directory)",
      "required": true
    },
    "offset": {
      "type": "integer",
      "description": "Line number to start reading from (1-indexed)",
      "required": false,
      "default": 1
    },
    "limit": {
      "type": "integer",
      "description": "Maximum number of lines to read",
      "required": false,
      "default": 500
    }
  },
  "returns": {
    "content": "string (file contents with line numbers)",
    "total_lines": "integer",
    "truncated": "boolean"
  }
}
```

**Security**: Path must resolve within allowed directories.

---

### 3.2 write_file

**Purpose**: Create or overwrite a file.

```json
{
  "name": "write_file",
  "description": "Write content to a file. Creates parent directories if needed. REQUIRES CONFIRMATION.",
  "parameters": {
    "path": {
      "type": "string",
      "description": "Path to file (relative to working directory)",
      "required": true
    },
    "content": {
      "type": "string",
      "description": "Complete file contents to write",
      "required": true
    }
  },
  "returns": {
    "success": "boolean",
    "bytes_written": "integer"
  }
}
```

**Security**: Requires user confirmation. Path traversal blocked.

---

### 3.3 edit_file

**Purpose**: Make surgical edits using search/replace.

```json
{
  "name": "edit_file",
  "description": "Edit a file by replacing exact text matches. Use read_file first to see current content.",
  "parameters": {
    "path": {
      "type": "string",
      "description": "Path to file",
      "required": true
    },
    "old_text": {
      "type": "string",
      "description": "Exact text to find and replace (must be unique in file)",
      "required": true
    },
    "new_text": {
      "type": "string",
      "description": "Text to replace with",
      "required": true
    },
    "replace_all": {
      "type": "boolean",
      "description": "Replace all occurrences (default: false, fails if not unique)",
      "required": false,
      "default": false
    }
  },
  "returns": {
    "success": "boolean",
    "replacements": "integer",
    "error": "string or null"
  }
}
```

**Security**: Requires confirmation if file was not recently read.

---

### 3.4 list_files

**Purpose**: Find files matching a glob pattern.

```json
{
  "name": "list_files",
  "description": "List files matching a glob pattern. Use to explore directory structure.",
  "parameters": {
    "pattern": {
      "type": "string",
      "description": "Glob pattern (e.g., '**/*.swift', 'src/*.ts')",
      "required": true
    },
    "path": {
      "type": "string",
      "description": "Base directory to search from",
      "required": false,
      "default": "."
    },
    "max_results": {
      "type": "integer",
      "description": "Maximum files to return",
      "required": false,
      "default": 100
    }
  },
  "returns": {
    "files": ["array of file paths"],
    "total_matches": "integer",
    "truncated": "boolean"
  }
}
```

---

### 3.5 search_files

**Purpose**: Search file contents with regex.

```json
{
  "name": "search_files",
  "description": "Search for text/regex pattern in files. Returns matching lines with context.",
  "parameters": {
    "pattern": {
      "type": "string",
      "description": "Regex pattern to search for",
      "required": true
    },
    "path": {
      "type": "string",
      "description": "Directory or file to search",
      "required": false,
      "default": "."
    },
    "file_pattern": {
      "type": "string",
      "description": "Glob to filter files (e.g., '*.swift')",
      "required": false
    },
    "context_lines": {
      "type": "integer",
      "description": "Lines of context before/after match",
      "required": false,
      "default": 2
    },
    "max_results": {
      "type": "integer",
      "description": "Maximum matches to return",
      "required": false,
      "default": 50
    }
  },
  "returns": {
    "matches": [
      {
        "file": "string",
        "line": "integer",
        "content": "string",
        "context_before": ["strings"],
        "context_after": ["strings"]
      }
    ],
    "total_matches": "integer",
    "truncated": "boolean"
  }
}
```

---

### 3.6 run_shell

**Purpose**: Execute shell commands.

```json
{
  "name": "run_shell",
  "description": "Execute a shell command. REQUIRES CONFIRMATION. Use for git, build tools, tests, etc.",
  "parameters": {
    "command": {
      "type": "string",
      "description": "Shell command to execute",
      "required": true
    },
    "working_dir": {
      "type": "string",
      "description": "Directory to run command in (CRITICAL: must be set for shell injection commands)",
      "required": false,
      "default": null
    },
    "timeout": {
      "type": "integer",
      "description": "Max execution time in seconds",
      "required": false,
      "default": 60
    }
  },
  "returns": {
    "exit_code": "integer",
    "stdout": "string",
    "stderr": "string"
  }
}
```

**Implementation Requirements**:
- **CRITICAL**: When invoked from shell injection (`!command`), MUST pass the current working directory explicitly
  - Shell injection handler MUST call: `FileManager.default.currentDirectoryPath`
  - Pass as `working_dir` parameter to ensure commands run in user's expected directory
  - Without this, commands run in the application's launch directory (incorrect behavior)

**Security**:
- ALWAYS requires confirmation (unless in allowed list)
- Sandboxed execution environment (if enabled)
- Timeout enforced
- Blocked commands rejected (if validation implemented)

**Test Requirement**:
```swift
// Test: Shell commands run in correct working directory
func testShellCommandWorkingDirectory() async throws {
    // Given: A known directory with a test file
    let testDir = "/tmp/test_shell_wd"
    try FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
    try "test content".write(toFile: "\(testDir)/test.txt", atomically: true, encoding: .utf8)

    // When: Running shell command with working_dir
    let result = try await runShellTool.execute(arguments: """
        {"command": "ls test.txt", "working_dir": "\(testDir)"}
        """)

    // Then: Command should find the file
    XCTAssertTrue(result.success)
    XCTAssertTrue(result.output?.contains("test.txt") ?? false)
}
```

---

## 4. External Tools

External tools extend functionality without recompiling. They are executables or scripts that follow a simple protocol.

### 4.1 External Tool Protocol

External tools are invoked as:
```bash
<tool-executable> <json-input>
```

They must:
1. Accept a single JSON argument with tool parameters
2. Output JSON to stdout
3. Exit 0 on success, non-zero on failure
4. Complete within configured timeout

**Example input**:
```json
{"query": "Swift async await tutorial", "max_results": 5}
```

**Example output**:
```json
{
  "success": true,
  "results": [
    {"title": "...", "url": "...", "snippet": "..."}
  ]
}
```

### 4.2 External Tool Definition

In config:
```json
{
  "name": "web_search",
  "type": "executable",
  "path": "~/.ybs/tools/web-search",
  "description": "Search the web for information. Returns titles, URLs, and snippets.",
  "parameters": {
    "query": {"type": "string", "required": true, "description": "Search query"},
    "max_results": {"type": "integer", "required": false, "default": 5}
  },
  "timeout_seconds": 30,
  "enabled": true
}
```

### 4.3 Recommended External Tools

| Tool | Purpose | Implementation Suggestion |
|------|---------|---------------------------|
| `web_search` | Search the web | Shell script calling SearXNG or DuckDuckGo API |
| `web_fetch` | Fetch URL content | Shell script using `curl` + `pandoc` for HTML→Markdown |
| `git_status` | Rich git info | Shell script wrapping git commands |
| `run_tests` | Project test runner | Shell script detecting test framework |

### 4.4 Built-in vs External: Recommendations

**Keep Built-in**:
- `read_file`, `write_file`, `edit_file` — Need atomic operations, security checks, tight integration
- `list_files`, `search_files` — Performance-critical, need native glob/regex
- `run_shell` — Security-critical sandbox integration

**Make External**:
- `web_search`, `web_fetch` — User may want different backends (SearXNG, Google, Brave)
- Project-specific tools — Test runners, linters, formatters vary by project
- Experimental tools — Easy to iterate without recompiling

---

## 5. Tool Discovery & Runtime Loading

### 5.1 Tool Registry

At startup, the agent builds a tool registry:

```swift
struct ToolRegistry {
    var builtinTools: [String: BuiltinTool]
    var externalTools: [String: ExternalToolConfig]

    func allTools() -> [ToolDefinition]
    func invoke(name: String, params: JSON) async throws -> ToolResult
}
```

### 5.2 Runtime Tool Loading

External tools can be added without restart:

1. **Config-based**: Add to `tools.external` array in config
2. **Directory-based** (IMPLEMENTED): Drop executable in configured tool paths, auto-discovered at startup
3. **Dynamic rescanning** (IMPLEMENTED): Use `/reload-tools` command during chat to rescan tool directories

**Tool Search Paths** (checked in order):
- `~/.config/ybs/tools`
- `~/.ybs/tools`
- `./tools` (current directory)

**Schema Discovery**: Tools must implement `--schema` flag to expose their interface:

```bash
$ ~/.config/ybs/tools/web_search --schema
{
  "name": "web_search",
  "description": "Search the web using SearXNG",
  "parameters": {
    "query": {
      "type": "string",
      "description": "Search query",
      "required": true
    },
    "max_results": {
      "type": "integer",
      "description": "Maximum results to return",
      "required": false
    }
  }
}
```

**Tool Invocation**: Tools receive JSON via stdin, return JSON via stdout:

```bash
$ echo '{"query": "Swift async"}' | ~/.config/ybs/tools/web_search
{
  "success": true,
  "result": "Found 10 results..."
}
```

**Configuration** (in `.ybs.json`):
```json
{
  "tools": {
    "search_paths": [
      "~/.config/ybs/tools",
      "~/.ybs/tools",
      "./tools"
    ]
  }
}
```

**Dynamic Rescanning**: Add tools without restarting the application:

```bash
# In one terminal: add a new tool
$ cat > ~/.config/ybs/tools/my_tool <<'EOF'
#!/bin/bash
if [ "$1" = "--schema" ]; then
  echo '{"name":"my_tool","description":"My custom tool","parameters":{}}'
  exit 0
fi
echo '{"success":true,"result":"Tool executed"}'
EOF
$ chmod +x ~/.config/ybs/tools/my_tool

# In test7 chat session:
You: /reload-tools
🔄 Rescanning for external tools...
✅ Tool reload complete!
   Built-in tools: 6
   External tools: 1
   Total: 7 tools available

External tools loaded:
  • my_tool: My custom tool
```

### 5.3 Tool Schema for LLM

Tools are presented to the LLM in OpenAI-compatible format:

```json
{
  "type": "function",
  "function": {
    "name": "read_file",
    "description": "Read the contents of a file...",
    "parameters": {
      "type": "object",
      "properties": {
        "path": {"type": "string", "description": "..."}
      },
      "required": ["path"]
    }
  }
}
```

---

## 6. Agent Loop

### 6.1 Core Loop Pseudocode

```swift
func agentLoop() async {
    var context = ConversationContext()

    while let userInput = readUserInput() {
        context.addUserMessage(userInput)

        var iterations = 0
        while iterations < config.agent.maxIterations {
            iterations += 1

            // 1. Send to LLM
            let response = try await llm.chat(
                messages: context.messages,
                tools: toolRegistry.allTools()
            )

            // 2. Check for tool call
            if let toolCall = response.toolCall {
                // Show user what we're about to do
                display.showToolCall(toolCall)

                // Get confirmation if required
                if safety.requiresConfirmation(toolCall) {
                    guard confirmWithUser(toolCall) else {
                        context.addToolResult(toolCall.id, "User cancelled")
                        continue
                    }
                }

                // Execute tool
                let result = try await toolRegistry.invoke(
                    name: toolCall.name,
                    params: toolCall.arguments
                )

                // Add result to context
                context.addToolResult(toolCall.id, result)
                display.showToolResult(result)

            } else {
                // 3. No tool call = final response
                display.showAssistantMessage(response.content)
                context.addAssistantMessage(response.content)
                break
            }

            // 4. Check for stuck/loop
            if context.detectLoop() {
                display.showWarning("Agent appears stuck, breaking loop")
                break
            }
        }

        // 5. Compact context if needed
        if context.tokenUsage > config.context.compactionThreshold {
            context.compact()
        }
    }
}
```

### 6.2 Message Types

```swift
enum Message {
    case system(String)
    case user(String)
    case assistant(String)
    case toolCall(id: String, name: String, arguments: JSON)
    case toolResult(id: String, content: String)
}
```

### 6.3 Meta Commands

The agent should support meta-commands that control the chat session itself rather than being sent to the LLM. Commands are prefixed with `/` and are handled before sending to the LLM.

**Required Commands**:

| Command | Purpose | Example |
|---------|---------|---------|
| `/help` | Show available commands and usage | `/help` |
| `/tools` | List available tools with descriptions | `/tools` |
| `/quit` or `/exit` | Exit the application | `/quit` |

**Command Handling**:

```swift
func handleUserInput(_ input: String) async {
    // Check for meta-commands first
    if input.hasPrefix("/") {
        handleMetaCommand(input)
        return  // Don't send to LLM
    }

    // Check for shell injection
    if input.hasPrefix("!") {
        await handleShellInjection(input)
        return  // Will send result to LLM, not the command itself
    }

    // Normal chat message - send to LLM
    await sendToLLM(input)
}
```

**Implementation**:

```swift
func handleMetaCommand(_ input: String) {
    let parts = input.dropFirst().split(separator: " ", maxSplits: 1)
    guard let command = parts.first?.lowercased() else { return }

    switch command {
    case "help":
        displayHelp()
    case "tools":
        displayTools()
    case "quit", "exit":
        displayGoodbye()
        exit(0)
    default:
        print("Unknown command: /\(command)")
        print("Type /help for available commands")
    }
}

func displayHelp() {
    print("""

    📖 Available Commands:
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    Meta Commands:
      /help                Show this help message
      /tools               List available tools
      /quit or /exit       Exit the application

    Shell Injection:
      !<command>           Run shell command and inject output into context

    Examples:
      /tools
      !ls -la
      !cat package.json

    Note: Shell commands run in sandbox (if enabled).

    """)
}

func displayTools() {
    let tools = toolRegistry.allTools()

    print("\n🔧 Available Tools:\n")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")

    for tool in tools.sorted(by: { $0.name < $1.name }) {
        print("  \(tool.name)")
        print("    \(tool.description)")
        print()
    }

    print("Total: \(tools.count) tools available\n")
}
```

**Display Format**:

```
You: /tools

🔧 Available Tools:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  edit_file
    Edit a file using search/replace or line-based operations

  list_files
    List files in a directory with optional filtering

  read_file
    Read contents of a file from the filesystem

  search_files
    Search for text or patterns across multiple files

  write_file
    Write content to a file, creating parent directories if needed

Total: 5 tools available
```

### 6.4 Shell Injection Commands

Shell injection allows users to run arbitrary shell commands and inject the output directly into the conversation context. This enables quick inspection of system state, file contents, or command output without requiring tool calls.

**Syntax**: `!<command> [args]`

**Examples**:
```
You: !ls -la
You: !cat README.md
You: !git status
You: !ps aux | grep node
You: !df -h
```

**Behavior**:

1. User input starts with `!`
2. Command is extracted (everything after `!`)
3. Command is executed via shell (respecting sandbox settings)
4. Output is captured (stdout + stderr)
5. Output is injected into context as a special message type
6. LLM receives context with output and can respond

**Implementation**:

```swift
func handleShellInjection(_ input: String) async {
    // Extract command (everything after '!')
    let command = String(input.dropFirst()).trimmingCharacters(in: .whitespaces)

    guard !command.isEmpty else {
        print("Error: No command specified")
        print("Usage: !<command>")
        return
    }

    // Show what we're running
    print("\n💻 Running: \(command)")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    do {
        // Execute via tool system (respects sandbox)
        let result = try await shellExecutor.run(
            command: command,
            captureOutput: true,
            timeout: config.safety.shellTimeoutSeconds
        )

        // Show output to user
        if !result.stdout.isEmpty {
            print(result.stdout)
        }
        if !result.stderr.isEmpty {
            print("stderr:", result.stderr)
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("Exit code: \(result.exitCode)\n")

        // Inject into conversation context
        let injectedMessage = """
        [Shell command output]
        Command: \(command)
        Exit code: \(result.exitCode)

        Output:
        \(result.stdout)
        \(result.stderr.isEmpty ? "" : "\nStderr:\n\(result.stderr)")
        """

        context.addMessage(Message(role: .user, content: injectedMessage))

        // Now let LLM respond to it
        await processWithTools()

    } catch {
        print("❌ Error executing command: \(error)\n")

        // Inject error into context
        let errorMessage = """
        [Shell command failed]
        Command: \(command)
        Error: \(error.localizedDescription)
        """

        context.addMessage(Message(role: .user, content: errorMessage))
        await processWithTools()
    }
}
```

**Security Considerations**:

1. **Sandbox Enforcement**: Shell injection MUST respect sandbox settings
   - If sandbox enabled: Commands run in sandbox
   - If sandbox disabled: Commands run with full permissions (dangerous)

2. **Timeout Protection**: All commands subject to timeout (default: 60s)

3. **Blocked Commands**: Commands in blocklist are rejected:
   ```swift
   let blockedPatterns = [
       "rm -rf /",
       "sudo",
       "chmod 777",
       // ... other dangerous patterns
   ]
   ```

4. **User Awareness**: Command and output are visible to user before LLM sees them

5. **Output Truncation**: Large outputs truncated to prevent context overflow:
   ```swift
   let maxOutputLength = config.context.maxToolOutputChars
   if output.count > maxOutputLength {
       output = String(output.prefix(maxOutputLength)) +
                "\n\n... (output truncated, \(output.count) total chars)"
   }
   ```

**Use Cases**:

```
Example 1: Quick file inspection
You: !cat package.json
[Output shown]
AI: I can see your project uses TypeScript 5.0 and has dependencies on...

Example 2: System diagnostics
You: !df -h
[Disk usage shown]
AI: You have 45GB free on your main drive. The /home partition is at 78% capacity...

Example 3: Git status
You: !git status
[Git status shown]
AI: You have 3 modified files and 2 untracked files. Would you like me to help commit them?

Example 4: Process inspection
You: !ps aux | grep node
[Process list shown]
AI: I see 2 Node.js processes running. The one on PID 1234 is using 450MB of memory...
```

**Alternative Syntax** (Optional):

Some systems use `$` prefix instead:
```
You: $ls -la
You: $cat file.txt
```

Or backticks (like shell substitution):
```
You: `ls -la`
You: `cat file.txt`
```

**Recommendation**: Use `!` as it:
- Is not a shell metacharacter (unlike `$` and `` ` ``)
- Visually distinctive
- Common in other tools (e.g., Jupyter `!command`)

---

### 6.5 Session Persistence

**Purpose**: Enable users to save and resume conversation sessions across application restarts without requiring a database. Sessions are stored as structured log files that can be replayed to restore conversation context.

**Design Philosophy**:
- **File-based**: No database required; uses simple JSON log files
- **Human-readable**: Sessions stored in readable format for inspection/debugging
- **Incremental**: Each message appended to session log as it occurs
- **Replay-based**: Loading a session replays the conversation to rebuild context
- **Configurable location**: Session directory specified in configuration

**Configuration**:

Add to configuration schema:
```json
{
  "session": {
    "storage_path": "~/.config/ybs/sessions",
    "auto_save": true,
    "max_sessions": 100,
    "retention_days": 30
  }
}
```

**Configuration Options**:
- `storage_path`: Directory where session logs are stored (default: `~/.config/ybs/sessions`)
- `auto_save`: Automatically save each message to session log (default: `true`)
- `max_sessions`: Maximum number of sessions to keep (oldest deleted first)
- `retention_days`: Delete sessions older than N days (0 = keep forever)

**Session Log Format**:

Each session is stored as a JSON Lines (JSONL) file where each line is a message:

```
~/.config/ybs/sessions/
├── session-20260118-143022.jsonl
├── session-20260118-150145.jsonl
└── session-20260118-163421.jsonl
```

File format (JSONL - one JSON object per line):
```json
{"timestamp":"2026-01-18T14:30:22Z","type":"session_start","config":{"provider":"anthropic","model":"claude-3-5-sonnet-20241022"}}
{"timestamp":"2026-01-18T14:30:25Z","type":"system","content":"You are a helpful AI coding assistant..."}
{"timestamp":"2026-01-18T14:30:30Z","type":"user","content":"Read the README file"}
{"timestamp":"2026-01-18T14:30:31Z","type":"tool_call","id":"call_123","name":"read_file","arguments":{"path":"README.md"}}
{"timestamp":"2026-01-18T14:30:31Z","type":"tool_result","id":"call_123","success":true,"output":"# My Project\n..."}
{"timestamp":"2026-01-18T14:30:33Z","type":"assistant","content":"I've read your README. The project is..."}
{"timestamp":"2026-01-18T14:31:00Z","type":"session_end","reason":"user_exit","message_count":6}
```

**Meta Commands for Session Management**:

Extend meta-commands (section 6.3) with session commands:

| Command | Purpose | Example |
|---------|---------|---------|
| `/sessions` | List available saved sessions | `/sessions` |
| `/load <session>` | Load a previous session by filename or number | `/load session-20260118-143022` |
| `/load <number>` | Load session by list number | `/load 3` |
| `/save [name]` | Manually save current session with optional name | `/save important-bugfix` |
| `/session` | Show current session info (messages, file) | `/session` |

**Session Loading Behavior**:

When loading a session:
1. **Clear current context**: Existing conversation cleared
2. **Replay messages**: All messages from log file replayed in order
3. **Skip tool execution**: Tool calls are not re-executed, results are loaded from log
4. **Restore state**: Conversation context restored to exact state at time of save
5. **Continue**: User can continue conversation from where it left off

**Implementation Pseudocode**:

```swift
class SessionManager {
    let storageURL: URL
    var currentSessionFile: URL?

    func startNewSession() -> URL {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let filename = "session-\(timestamp).jsonl"
        let fileURL = storageURL.appendingPathComponent(filename)

        // Write session start marker
        appendToSession(SessionEvent(
            timestamp: Date(),
            type: .sessionStart,
            config: currentConfig
        ))

        currentSessionFile = fileURL
        return fileURL
    }

    func appendToSession(_ event: SessionEvent) {
        guard let file = currentSessionFile else { return }
        guard config.session.autoSave else { return }

        let json = try JSONEncoder().encode(event)
        let line = String(data: json, encoding: .utf8)! + "\n"

        // Append to file (create if not exists)
        if let handle = FileHandle(forWritingAtPath: file.path) {
            handle.seekToEndOfFile()
            handle.write(line.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try line.write(to: file, atomically: true, encoding: .utf8)
        }
    }

    func loadSession(_ filename: String) throws -> ConversationContext {
        let fileURL = storageURL.appendingPathComponent(filename)
        let content = try String(contentsOf: fileURL)

        var context = ConversationContext()

        // Parse each line and replay
        for line in content.split(separator: "\n") {
            let event = try JSONDecoder().decode(SessionEvent.self, from: Data(line.utf8))

            switch event.type {
            case .system:
                context.addMessage(Message(role: .system, content: event.content))
            case .user:
                context.addMessage(Message(role: .user, content: event.content))
            case .assistant:
                context.addMessage(Message(role: .assistant, content: event.content))
            case .toolCall:
                // Add tool call (but don't execute)
                context.addMessage(Message(role: .assistant, toolCalls: [event.toolCall]))
            case .toolResult:
                // Add cached result
                context.addMessage(Message(role: .tool, content: event.output, toolCallId: event.id))
            case .sessionStart, .sessionEnd:
                // Metadata only, skip
                break
            }
        }

        return context
    }

    func listSessions() -> [SessionInfo] {
        let files = try FileManager.default.contentsOfDirectory(at: storageURL)
        return files
            .filter { $0.pathExtension == "jsonl" }
            .sorted { $0.lastPathComponent > $1.lastPathComponent }  // Newest first
            .map { url in
                let firstLine = try String(contentsOf: url).split(separator: "\n").first
                let event = try JSONDecoder().decode(SessionEvent.self, from: Data(firstLine!.utf8))
                return SessionInfo(
                    filename: url.lastPathComponent,
                    timestamp: event.timestamp,
                    config: event.config
                )
            }
    }

    func cleanupOldSessions() {
        guard config.session.retentionDays > 0 else { return }

        let cutoff = Date().addingTimeInterval(-Double(config.session.retentionDays) * 86400)
        let sessions = listSessions()

        for session in sessions where session.timestamp < cutoff {
            try? FileManager.default.removeItem(at: storageURL.appendingPathComponent(session.filename))
        }
    }
}
```

**User Experience**:

```
# Starting a new session
$ ybs
Welcome to YBS - AI Coding Assistant
Session: session-20260118-143022.jsonl

You: Read the README file
AI: [Uses read_file tool]
    I've read your README...

You: /save important-feature
✅ Session saved as: important-feature.jsonl

You: /quit

# Later, resuming the session
$ ybs
Welcome to YBS - AI Coding Assistant
Session: session-20260118-150200.jsonl

You: /sessions
Available sessions:
  1. session-20260118-143022.jsonl (5 minutes ago) - 12 messages
  2. important-feature.jsonl (10 minutes ago) - 6 messages
  3. session-20260118-120000.jsonl (2 hours ago) - 45 messages

You: /load 2
✅ Loaded session: important-feature.jsonl
   Restored 6 messages

You: Continue with the feature implementation
AI: [Continues from where you left off]
```

**Benefits**:
- ✅ **No database required**: Simple file-based storage
- ✅ **Human-readable**: Can inspect session files directly
- ✅ **Crash recovery**: Sessions auto-saved, can resume after crash
- ✅ **Debugging**: Full conversation history for troubleshooting
- ✅ **Sharing**: Can share session files with team members
- ✅ **Version control**: Can commit important sessions to git

**Security Considerations**:
- ⚠️ **Sensitive data**: Session logs may contain API keys, file contents, etc.
- ⚠️ **File permissions**: Ensure session directory is user-accessible only (chmod 700)
- ⚠️ **Cleanup**: Regular cleanup of old sessions prevents disk bloat
- ⚠️ **Exclude from version control**: Add `*.jsonl` to `.gitignore` for session logs

---

## 7. LLM Provider Abstraction

### 7.1 Provider Protocol

```swift
protocol LLMProvider {
    func chat(
        messages: [Message],
        tools: [ToolDefinition],
        options: ChatOptions
    ) async throws -> ChatResponse

    func countTokens(_ text: String) -> Int
}

struct ChatResponse {
    let content: String?
    let toolCall: ToolCall?
    let usage: TokenUsage
    let finishReason: FinishReason
}
```

### 7.2 Supported Providers

| Provider | Endpoint Format | Notes |
|----------|-----------------|-------|
| Ollama | `http://localhost:11434/api/chat` | Local, free |
| OpenAI | `https://api.openai.com/v1/chat/completions` | Requires API key |
| Anthropic | `https://api.anthropic.com/v1/messages` | Requires API key |
| Apple Foundation | Native Apple ML framework | Local, macOS 15+, no API key |
| OpenAI-compatible | Any URL | LocalAI, LM Studio, etc. |

### 7.3 Streaming

Responses should stream for better UX:

```swift
func chatStream(
    messages: [Message],
    tools: [ToolDefinition]
) -> AsyncThrowingStream<ChatChunk, Error>
```

### 7.4 Anthropic Provider Implementation

Anthropic's API differs significantly from OpenAI's format and requires a separate client implementation.

**Key Differences**:

| Aspect | OpenAI | Anthropic |
|--------|--------|-----------|
| Auth Header | `Authorization: Bearer <key>` | `x-api-key: <key>`, `anthropic-version: 2023-06-01` |
| System Message | In messages array | Separate `system` field |
| Request Format | `ChatCompletionRequest` | `MessagesRequest` |
| Response Format | `choices[0].message` | `content[0]` |
| Tool Format | OpenAI function calling | Anthropic tool use |
| Streaming | SSE with `data:` prefix | SSE with specific event types |

**Anthropic Request Structure**:

```swift
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
    var content: String
}

struct AnthropicTool: Codable {
    var name: String
    var description: String
    var input_schema: [String: Any]  // JSON Schema
}
```

**Anthropic Response Structure**:

```swift
struct AnthropicResponse: Codable {
    var id: String
    var type: String  // "message"
    var role: String  // "assistant"
    var content: [ContentBlock]
    var model: String
    var stop_reason: String?
    var usage: Usage
}

struct ContentBlock: Codable {
    var type: String  // "text" or "tool_use"
    var text: String?
    var id: String?
    var name: String?
    var input: [String: Any]?
}
```

**Authentication**:

```swift
var headers: [String: String] = [
    "Content-Type": "application/json",
    "x-api-key": apiKey,
    "anthropic-version": "2023-06-01"
]
```

**Implementation Requirements**:
1. Separate `AnthropicLLMClient` class
2. Transform messages to/from Anthropic format
3. Extract system message from conversation history
4. Convert OpenAI tool definitions to Anthropic format
5. Parse tool_use blocks from content array
6. Handle streaming with Anthropic's event format

### 7.5 Runtime Provider Switching

Users should be able to switch LLM providers during an active chat session without restarting the application.

**Chat Command**:

```
You: /provider <name> [model]

Examples:
  /provider ollama qwen2.5:14b
  /provider openai gpt-4
  /provider anthropic claude-3-5-sonnet-20241022
  /provider apple foundation
```

**Implementation**:

```swift
// Detect command in user input
func handleChatCommand(_ input: String) -> Bool {
    if input.hasPrefix("/provider ") {
        let parts = input.split(separator: " ")
        guard parts.count >= 2 else {
            print("Usage: /provider <name> [model]")
            return true
        }

        let providerName = String(parts[1])
        let modelName = parts.count > 2 ? String(parts[2]) : nil

        switchProvider(to: providerName, model: modelName)
        return true
    }
    return false
}

// Switch provider dynamically
func switchProvider(to providerName: String, model: String?) {
    // Update config
    config.llm.provider = providerName

    // Set default model if not specified
    if let model = model {
        config.llm.model = model
    } else {
        config.llm.model = defaultModel(for: providerName)
    }

    // Update endpoint
    config.llm.endpoint = defaultEndpoint(for: providerName)

    // Recreate LLM client with new config
    llmClient = createLLMClient(config: config.llm)

    logger.info("Switched to \(providerName) with model \(config.llm.model)")
}
```

**Other Chat Commands**:

```
/provider list              - Show available providers
/provider current           - Show current provider and model
/model <name>               - Change model (keep same provider)
/config                     - Show current configuration
/help                       - Show available commands
```

**Conversation Continuity**:
- Conversation history is preserved when switching providers
- Tool definitions remain available
- Context limits may differ between providers (warn user if needed)

---

## 8. Security Implementation

### 8.1 Path Sandboxing

```swift
struct PathSandbox {
    let allowedRoots: [URL]
    let blockedPaths: [URL]

    func validate(_ path: String) throws -> URL {
        let resolved = URL(fileURLWithPath: path).standardized

        // Check blocked first
        for blocked in blockedPaths {
            if resolved.path.hasPrefix(blocked.path) {
                throw SandboxError.blockedPath(path)
            }
        }

        // Check allowed
        for allowed in allowedRoots {
            if resolved.path.hasPrefix(allowed.path) {
                return resolved
            }
        }

        throw SandboxError.outsideSandbox(path)
    }
}
```

### 8.2 Shell Sandboxing (macOS)

Use `sandbox-exec` for shell commands:

```swift
func sandboxedShell(_ command: String) async throws -> ShellResult {
    let profile = """
    (version 1)
    (deny default)
    (allow file-read* (subpath "\(workingDirectory)"))
    (allow file-write* (subpath "\(workingDirectory)"))
    (allow process-fork)
    (allow process-exec)
    (deny network*)
    """

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/sandbox-exec")
    process.arguments = ["-p", profile, "/bin/sh", "-c", command]
    // ... execute with timeout
}
```

### 8.3 Confirmation Flow

```swift
func confirmWithUser(_ toolCall: ToolCall) -> Bool {
    print("⚠️  Tool requires confirmation:")
    print("   \(toolCall.name): \(toolCall.arguments)")
    print("   [y]es / [n]o / [a]lways allow this session: ", terminator: "")

    guard let input = readLine()?.lowercased() else { return false }

    switch input {
    case "y", "yes": return true
    case "a", "always":
        sessionAllowList.insert(toolCall.name)
        return true
    default: return false
    }
}
```

---

## 9. Project Structure

```
ybs/
├── Package.swift
├── Sources/
│   └── ybs/
│       ├── main.swift                 # Entry point, CLI parsing
│       ├── Config/
│       │   ├── Config.swift           # Configuration model
│       │   └── ConfigLoader.swift     # Multi-file config loading
│       ├── Agent/
│       │   ├── AgentLoop.swift        # Core agent loop
│       │   ├── ConversationContext.swift
│       │   └── LoopDetector.swift
│       ├── LLM/
│       │   ├── LLMProvider.swift      # Protocol
│       │   ├── OllamaProvider.swift
│       │   ├── OpenAIProvider.swift
│       │   └── AnthropicProvider.swift
│       ├── Tools/
│       │   ├── ToolRegistry.swift
│       │   ├── ToolProtocol.swift
│       │   ├── Builtin/
│       │   │   ├── ReadFileTool.swift
│       │   │   ├── WriteFileTool.swift
│       │   │   ├── EditFileTool.swift
│       │   │   ├── ListFilesTool.swift
│       │   │   ├── SearchFilesTool.swift
│       │   │   └── RunShellTool.swift
│       │   └── External/
│       │       └── ExternalToolRunner.swift
│       ├── Security/
│       │   ├── PathSandbox.swift
│       │   ├── ShellSandbox.swift
│       │   └── ConfirmationManager.swift
│       ├── UI/
│       │   ├── Display.swift          # Output formatting
│       │   ├── Input.swift            # User input handling
│       │   └── Colors.swift           # ANSI colors
│       └── Utilities/
│           ├── JSON.swift             # JSON helpers, repair
│           ├── Glob.swift             # Glob pattern matching
│           └── TokenCounter.swift
├── Tools/                             # External tool examples
│   ├── web-search/
│   │   ├── web-search                 # Executable
│   │   └── web-search.tool.json       # Sidecar definition
│   └── web-fetch/
│       ├── web-fetch
│       └── web-fetch.tool.json
└── Tests/
    └── ydsTests/
        ├── ToolTests/
        ├── SandboxTests/
        └── AgentLoopTests/
```

---

## 10. Dependencies

### 10.1 Swift Package Dependencies

```swift
// Package.swift
dependencies: [
    // CLI argument parsing
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),

    // Async HTTP client
    .package(url: "https://github.com/swift-server/async-http-client", from: "1.20.0"),

    // JSON handling (for repair/fuzzy parsing)
    // Consider: https://github.com/SwiftyJSON/SwiftyJSON or roll own
]
```

### 10.2 System Dependencies

- macOS: `sandbox-exec` (built-in) for shell sandboxing
- Optional: `ripgrep` (`rg`) for faster search (fallback to native)
- Optional: `tree-sitter` for code parsing (future repo map feature)

---

## 11. Future Considerations

### 11.1 MCP Support
Consider implementing Model Context Protocol for broader tool ecosystem compatibility.

### 11.2 Git Integration
Built-in git operations for auto-commit, status, diff viewing.

### 11.3 Repo Map
Tree-sitter based code structure extraction for better context.

### 11.4 Multi-file Editing Sessions
Track which files were read this session; allow edits without re-reading.

### 11.5 Project Detection
Auto-detect project type (Swift, Node, Python) and adjust default tools.

---

## 12. Testing Requirements

### 12.1 Mandatory Test Coverage

All implementations MUST include comprehensive testing:

- **Unit tests**: For each tool, model, and core component
- **Integration tests**: For agent loop, LLM clients, tool executor
- **End-to-end tests**: For complete user workflows

**Test Coverage Targets**:
- **Minimum**: 60% line coverage
- **Target**: 80% line coverage
- **Critical paths**: 100% coverage (tool execution, LLM communication, safety checks)

### 12.2 Test Structure

Tests must be organized following this structure:

```
Tests/
└── YBSTests/
    ├── ToolTests/           # Unit tests for each tool
    │   ├── ReadFileToolTests.swift
    │   ├── WriteFileToolTests.swift
    │   ├── EditFileToolTests.swift
    │   ├── ListFilesToolTests.swift
    │   ├── SearchFilesToolTests.swift
    │   └── RunShellToolTests.swift
    ├── LLMTests/            # Unit tests for LLM clients
    │   ├── LLMClientTests.swift
    │   ├── AnthropicLLMClientTests.swift
    │   └── LLMClientFactoryTests.swift
    ├── AgentTests/          # Integration tests for agent loop
    │   ├── AgentLoopTests.swift
    │   ├── ConversationContextTests.swift
    │   └── MetaCommandHandlerTests.swift
    ├── ConfigTests/         # Unit tests for configuration
    │   ├── ConfigLoaderTests.swift
    │   └── ConfigTests.swift
    ├── SessionTests/        # Unit tests for session management
    │   └── SessionManagerTests.swift
    └── E2ETests/            # End-to-end workflow tests
        └── WorkflowTests.swift
```

### 12.3 Test Requirements Per Component

**Tool Tests** (MANDATORY):
- Success cases for valid inputs
- Error cases for invalid inputs (missing files, bad paths)
- Edge cases (empty files, large files, special characters)
- Security validation (path traversal attempts blocked)

**LLM Client Tests** (MANDATORY):
- Message format conversion (especially Anthropic)
- API header construction
- Response parsing (success and error)
- Streaming functionality
- Timeout handling

**Agent Loop Tests** (MANDATORY):
- Full conversation flow with mock LLM
- Tool execution loop
- Meta-command handling
- Shell injection
- Provider switching
- Error recovery

**Configuration Tests** (MANDATORY):
- Config loading from various sources
- Validation and error messages
- Default value handling
- Override precedence

**Session Tests** (MANDATORY):
- Session creation and saving
- Session loading and replay
- Session listing
- Cleanup and retention

### 12.4 Testing Before Step Completion

**No implementation step is considered complete until**:

1. ✅ Tests are written for the implemented code
2. ✅ All tests pass (`swift test` succeeds)
3. ✅ Code coverage meets minimum threshold (60%)
4. ✅ Critical paths have 100% coverage

### 12.5 Test Execution

All tests must be runnable via standard Swift testing commands:

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter ToolTests

# Run with code coverage
swift test --enable-code-coverage

# View coverage report
xcrun llvm-cov report .build/debug/YBSPackageTests.xctest/Contents/MacOS/YBSPackageTests
```

### 12.6 Mock Objects

Tests should use mock implementations where appropriate:

```swift
// Mock LLM client for testing agent loop
class MockLLMClient: LLMClientProtocol {
    var responses: [Message] = []
    var currentIndex = 0

    func sendChatRequest(messages: [Message], tools: [Tool]?) async throws -> Message {
        defer { currentIndex += 1 }
        return responses[currentIndex]
    }

    func sendStreamingChatRequest(
        messages: [Message],
        tools: [Tool]?,
        onToken: @escaping (String) -> Void
    ) async throws -> Message {
        let response = responses[currentIndex]
        onToken(response.content)
        currentIndex += 1
        return response
    }
}
```

### 12.7 Test Data Management

- Use temporary directories for file operation tests
- Clean up test files after each test
- Use fixtures for complex test data
- Never depend on external services in tests

### 12.8 Continuous Integration

Tests should:
- Run automatically on commits
- Block merges if tests fail
- Report coverage metrics
- Be fast (< 30 seconds total)

---

## 13. Success Criteria

A minimal viable implementation should:

- [ ] Load configuration from multiple sources
- [ ] Connect to Ollama and complete a basic chat
- [ ] Execute all 6 built-in tools
- [ ] Enforce path sandboxing
- [ ] Require confirmation for write/shell operations
- [ ] Detect and break infinite loops
- [ ] Stream responses to terminal
- [ ] Load at least one external tool

---

*Specification Version: 1.0*
*Last Updated: 2026-01-16*
