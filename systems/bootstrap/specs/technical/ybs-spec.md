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
    "working_directory": {
      "type": "string",
      "description": "Directory to run command in",
      "required": false,
      "default": "."
    },
    "timeout_seconds": {
      "type": "integer",
      "description": "Max execution time",
      "required": false,
      "default": 30
    }
  },
  "returns": {
    "exit_code": "integer",
    "stdout": "string",
    "stderr": "string",
    "timed_out": "boolean"
  }
}
```

**Security**:
- ALWAYS requires confirmation (unless in allowed list)
- Sandboxed execution environment
- Timeout enforced
- Blocked commands rejected

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

1. **Config-based**: Add to `tools.external` array in config, send SIGHUP to reload
2. **Directory-based**: Drop executable in `~/.ybs/tools/`, auto-discovered if it has a `.tool.json` sidecar file

**Sidecar file example** (`web-search.tool.json`):
```json
{
  "name": "web_search",
  "description": "Search the web using SearXNG",
  "parameters": {
    "query": {"type": "string", "required": true}
  }
}
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

## 12. Success Criteria

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
