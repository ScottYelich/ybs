# Bootstrap Build Plan: Steps 4-30

**System**: Bootstrap (Swift AI Chat Tool)
**Version**: 1.0.0
**Last Updated**: 2026-01-17
**Status**: Steps 0-3 complete, Steps 4-30 planned

## Completed Steps (0-3)

✅ **Step 0**: Build Configuration (`ybs-step_000000000000`)
✅ **Step 1**: Project Skeleton (`ybs-step_478a8c4b0cef`)
✅ **Step 2**: Basic Configuration (`ybs-step_c5404152680d`)
✅ **Step 3**: Configuration Schema (`ybs-step_89b9e6233da5`)

**Current Build**: test6 (100% complete, ready for Step 4)

---

## Planning Philosophy

**Incremental Growth**: Each step adds a small piece, fully verified before moving on.

**Checkpoint System**: Can stop after any step, system remains working (with reduced features).

**LLM-Friendly**: Steps sized to fit in LLM context (~100-200 lines each).

**Dependency-Driven**: Clear prerequisites, no circular dependencies.

---

## Layer Overview

| Layer | Steps | Purpose | Status |
|-------|-------|---------|--------|
| **1. Foundation** | 4-7 | Base infrastructure | Planned |
| **2. Basic Tools** | 8-10 | Core file operations | Planned |
| **3. LLM Client** | 11-12 | Connect to AI | Planned |
| **4. Agent Core** | 13-15 | Agent loop + tool calling | Planned |
| **5. More Tools** | 16-19 | Expand capabilities | Planned |
| **6. Safety** | 20-22 | Security & sandboxing | Planned |
| **7. External Tools** | 23-24 | Plugin system | Planned |
| **8. Advanced Context** | 25-27 | Performance & scaling | Planned |
| **9. Polish** | 28-30 | UX improvements | Planned |

---

## Layer 1: Foundation (Steps 4-7)

**Purpose**: Establish base infrastructure that everything else depends on.

**Why First**: Config, models, errors, and CLI are used throughout the entire system.

### Step 4: Configuration Schema & File Loading

**Purpose**: Load and merge config files from multiple locations.

**Implements**:
- JSON config file parsing
- Layered resolution: /etc/ybs → ~/.config/ybs → ~/.ybs → ./.ybs → CLI flags
- Config validation

**Dependencies**:
- Step 3 (config schema defined)

**Deliverables**:
- `Sources/YBS/Configuration/ConfigLoader.swift`
- Config struct matching BUILD_CONFIG.json schema
- Tests for config loading and merging

**Verification**:
```bash
# Create test config files
echo '{"llm": {"provider": "ollama"}}' > test-config.json
swift run ybs --config test-config.json --dry-run
# Should print merged config
```

**Size**: ~150 lines

---

### Step 5: Core Data Models

**Purpose**: Define fundamental data structures used throughout the system.

**Implements**:
- `Message` - Chat message (role + content)
- `Tool` - Tool definition (name, description, parameters)
- `ToolCall` - Tool invocation (name, arguments, result)
- `LLMConfig` - LLM settings (provider, model, endpoint, etc.)
- `SafetyConfig` - Sandbox settings

**Dependencies**:
- None (pure data structures)

**Deliverables**:
- `Sources/YBS/Models/Message.swift`
- `Sources/YBS/Models/Tool.swift`
- `Sources/YBS/Models/ToolCall.swift`
- `Sources/YBS/Models/Configuration.swift`
- Tests for encoding/decoding

**Verification**:
```bash
swift test --filter MessageTests
# All model tests pass
```

**Size**: ~100 lines

---

### Step 6: Error Handling & Logging

**Purpose**: Consistent error types and logging throughout the system.

**Implements**:
- `YBSError` enum with all error categories
- `Logger` with levels (debug, info, warn, error)
- Structured error messages

**Dependencies**:
- None

**Deliverables**:
- `Sources/YBS/Core/YBSError.swift`
- `Sources/YBS/Core/Logger.swift`
- Tests for error creation and logging

**Verification**:
```bash
swift run ybs-demo-logger
# Logs at each level with colors
```

**Size**: ~100 lines

---

### Step 7: CLI Argument Parsing

**Purpose**: Parse command-line arguments and merge with config.

**Implements**:
- ArgumentParser integration
- Flags: --config, --model, --provider, --endpoint, --help, --version, --dry-run
- Merge CLI flags with loaded config (CLI overrides)

**Dependencies**:
- Step 4 (config loading)
- Step 6 (errors)

**Deliverables**:
- `Sources/YBS/CLI/ArgumentParser.swift`
- `Sources/YBS/main.swift` (entry point)
- Tests for argument parsing

**Verification**:
```bash
swift run ybs --version
# Prints: ybs version 0.1.0

swift run ybs --model claude-3.5 --dry-run
# Prints merged config with CLI overrides
```

**Size**: ~80 lines

---

## Layer 2: Basic Tools (Steps 8-10)

**Purpose**: Implement core file operations as tools.

**Why Second**: Provides basic capabilities the agent can use.

### Step 8: read_file Tool

**Purpose**: Read file contents with pagination.

**Implements**:
- Read file from path (relative to working directory)
- Optional offset/limit for large files
- Path validation (must be within allowed directories)
- Error handling (file not found, permission denied)

**Dependencies**:
- Step 5 (Tool model)
- Step 6 (errors)

**Deliverables**:
- `Sources/YBS/Tools/ReadFileTool.swift`
- Tool schema (name, description, parameters)
- Tests for reading various file types

**Verification**:
```bash
swift run ybs-test-tool read_file --path Package.swift
# Prints file contents with line numbers
```

**Size**: ~120 lines

---

### Step 9: list_files Tool

**Purpose**: List directory contents with filtering.

**Implements**:
- List files in directory (recursive option)
- Filter by pattern (glob-like)
- Exclude hidden files option
- Size/modification time metadata

**Dependencies**:
- Step 8 (similar pattern)

**Deliverables**:
- `Sources/YBS/Tools/ListFilesTool.swift`
- Tests for directory listing

**Verification**:
```bash
swift run ybs-test-tool list_files --path Sources --recursive
# Lists all source files
```

**Size**: ~80 lines

---

### Step 10: Tool Executor Framework

**Purpose**: Generic tool execution infrastructure.

**Implements**:
- Tool registry (map tool name → implementation)
- Execute tool by name with parameters
- Return tool result (success/error)
- Tool schema generation

**Dependencies**:
- Steps 8-9 (tools to register)

**Deliverables**:
- `Sources/YBS/Core/ToolExecutor.swift`
- Tool protocol
- Tests for tool execution

**Verification**:
```bash
swift run ybs-test-executor
# Registers read_file, executes it, prints result
```

**Size**: ~100 lines

---

## Layer 3: LLM Client (Steps 11-12)

**Purpose**: Connect to AI services.

**Why Third**: Need tools from Layer 2 to test with.

### Step 11: HTTP Client & OpenAI API Types

**Purpose**: HTTP communication with streaming support.

**Implements**:
- HTTP POST with async/await
- Streaming response handling (SSE - Server-Sent Events)
- OpenAI-compatible request/response types
- Timeout handling

**Dependencies**:
- Step 5 (Message model)
- Step 6 (errors)

**Deliverables**:
- `Sources/YBS/HTTP/HTTPClient.swift`
- `Sources/YBS/LLM/OpenAITypes.swift`
- Tests for HTTP requests

**Verification**:
```bash
# Set ANTHROPIC_API_KEY environment variable
swift run ybs-test-http
# Makes test request to Anthropic API, prints response
```

**Size**: ~150 lines

---

### Step 12: LLM Client

**Purpose**: Send messages to LLM, receive responses.

**Implements**:
- Send chat request with messages
- Receive streaming response
- Parse tool calls from response
- Handle errors (rate limits, timeouts, invalid responses)

**Dependencies**:
- Step 11 (HTTP client)

**Deliverables**:
- `Sources/YBS/LLM/LLMClient.swift`
- Tests for LLM communication

**Verification**:
```bash
swift run ybs-test-llm
# Sends "Hello" message, prints AI response
```

**Size**: ~120 lines

---

## Layer 4: Agent Core (Steps 13-15)

**Purpose**: The heart of the system - the agent loop.

**Why Fourth**: Has all prerequisites (tools, LLM client).

### Step 13: Basic Agent Loop (No Tools)

**Purpose**: Interactive chat without tool execution.

**Implements**:
- Read user input from terminal
- Send to LLM
- Print response
- Loop until user quits

**Dependencies**:
- Step 7 (CLI)
- Step 12 (LLM client)

**Deliverables**:
- `Sources/YBS/Agent/AgentLoop.swift`
- Basic REPL (Read-Eval-Print-Loop)

**Verification**:
```bash
swift run ybs
You: Hello
AI: Hello! How can I assist you today?
You: What is 2+2?
AI: 2+2 equals 4.
You: quit
```

**Size**: ~80 lines

---

### Step 14: Tool Calling Integration

**Purpose**: Agent executes tools requested by LLM.

**Implements**:
- Detect tool calls in LLM response
- Execute tool via ToolExecutor (Step 10)
- Add tool result to conversation
- Send updated conversation back to LLM

**Dependencies**:
- Step 10 (tool executor)
- Step 13 (agent loop)

**Deliverables**:
- Update `AgentLoop.swift` with tool handling
- Tool call detection and execution

**Verification**:
```bash
swift run ybs
You: Read the file Package.swift
AI: <calls read_file tool>
Tool: <file contents>
AI: The Package.swift file defines a Swift package with...
```

**Size**: ~100 lines

---

### Step 15: Conversation Context Management

**Purpose**: Maintain message history for multi-turn conversations.

**Implements**:
- Store message history (user + assistant + tool results)
- Add system prompt at start
- Prune old messages if approaching limit (simple: keep last N)

**Dependencies**:
- Step 14 (agent with tools)

**Deliverables**:
- `Sources/YBS/Agent/ConversationContext.swift`
- Message history management

**Verification**:
```bash
swift run ybs
You: My name is Scott
AI: Nice to meet you, Scott!
You: What's my name?
AI: Your name is Scott.
```

**Size**: ~60 lines

---

## Layer 5: More Tools (Steps 16-19)

**Purpose**: Expand agent capabilities.

**Why Fifth**: Agent loop works, can now add more tools.

### Step 16: write_file Tool

**Purpose**: Create or overwrite files.

**Implements**:
- Write content to file (create parent directories)
- Overwrite existing files
- Error handling (permission denied, disk full)

**Dependencies**:
- Step 8 (similar to read_file)

**Deliverables**:
- `Sources/YBS/Tools/WriteFileTool.swift`

**Verification**:
```bash
swift run ybs
You: Create a file called test.txt with "Hello World"
AI: <calls write_file>
Tool: Success
AI: I've created test.txt with the content "Hello World"
```

**Size**: ~100 lines

---

### Step 17: edit_file Tool (Search/Replace)

**Purpose**: Make targeted edits to files.

**Implements**:
- Search for exact text match
- Replace with new text
- Validate search text is unique
- Fuzzy matching for minor whitespace differences

**Dependencies**:
- Steps 8, 16 (read/write files)

**Deliverables**:
- `Sources/YBS/Tools/EditFileTool.swift`

**Verification**:
```bash
swift run ybs
You: In Package.swift, change 'version: "1.0.0"' to 'version: "1.0.1"'
AI: <calls edit_file>
Tool: Success (1 match, replaced)
AI: I've updated the version in Package.swift
```

**Size**: ~150 lines

---

### Step 18: search_files Tool (grep-like)

**Purpose**: Search for text across files.

**Implements**:
- Search for pattern (regex support)
- Recursive directory search
- Return file paths + line numbers + matched lines
- Limit results (don't return 10,000 matches)

**Dependencies**:
- Steps 8-9 (file operations)

**Deliverables**:
- `Sources/YBS/Tools/SearchFilesTool.swift`

**Verification**:
```bash
swift run ybs
You: Find all files that import Foundation
AI: <calls search_files with pattern="import Foundation">
Tool: Found 12 matches across 8 files
AI: I found 12 files that import Foundation...
```

**Size**: ~120 lines

---

### Step 19: run_shell Tool (Unsandboxed)

**Purpose**: Execute shell commands (without sandboxing yet).

**Implements**:
- Run command via Process
- Capture stdout and stderr
- Timeout after N seconds
- Return exit code + output

**Dependencies**:
- Step 10 (tool executor)

**Deliverables**:
- `Sources/YBS/Tools/RunShellTool.swift`

**Verification**:
```bash
swift run ybs
You: What files are in the current directory?
AI: <calls run_shell with command="ls -la">
Tool: <directory listing>
AI: The current directory contains...
```

**Size**: ~100 lines

**⚠️ Security Note**: Sandboxing added in Layer 6

---

## Layer 6: Safety (Steps 20-22)

**Purpose**: Secure the system.

**Why Sixth**: Now that tools work, lock them down.

### Step 20: Confirmation System

**Purpose**: Ask user before destructive operations.

**Implements**:
- Before executing tool, check if confirmation required
- Prompt user: "Execute write_file? [y/n/always]"
- Session allow-list (if user says "always", remember)
- Dry-run mode (--dry-run shows but doesn't execute)

**Dependencies**:
- Step 14 (tool calling)

**Deliverables**:
- `Sources/YBS/Safety/ConfirmationManager.swift`
- Integration with ToolExecutor

**Verification**:
```bash
swift run ybs
You: Create a file test.txt
AI: <calls write_file>
Confirm: Execute write_file on test.txt? [y/n/always] y
Tool: Success
AI: File created
```

**Size**: ~80 lines

---

### Step 21: Sandboxing (sandbox-exec)

**Purpose**: Run shell commands in macOS sandbox.

**Implements**:
- Wrap run_shell in sandbox-exec
- Define sandbox profile (allow read, block write to sensitive paths)
- Handle sandbox violations (exit code 1)

**Dependencies**:
- Step 19 (run_shell)

**Deliverables**:
- `Sources/YBS/Safety/Sandbox.swift`
- Sandbox profile file

**Verification**:
```bash
swift run ybs
You: Run 'cat ~/.ssh/id_rsa'
AI: <calls run_shell>
Sandbox: Operation not permitted
Tool: Error (sandbox violation)
AI: I cannot access that file due to security restrictions
```

**Size**: ~100 lines

---

### Step 22: Path Validation & Blocked Commands

**Purpose**: Additional safety checks.

**Implements**:
- Path validation (reject paths outside allowed directories)
- Blocked paths (~/.ssh, ~/.aws, ~/.config)
- Blocked commands (rm -rf /, sudo, chmod 777)
- Whitelist/blacklist checking

**Dependencies**:
- Steps 19-21 (shell and sandbox)

**Deliverables**:
- `Sources/YBS/Safety/PathValidator.swift`
- `Sources/YBS/Safety/CommandValidator.swift`

**Verification**:
```bash
swift run ybs
You: Delete all files with 'rm -rf /'
AI: <calls run_shell>
Validator: Blocked command detected
Tool: Error (blocked command)
AI: I cannot execute that command as it's blocked for safety
```

**Size**: ~80 lines

---

## Layer 7: External Tools (Steps 23-24)

**Purpose**: Plugin system for extensibility.

**Why Seventh**: Core tools work, now add extensibility.

### Step 23: External Tool Protocol

**Purpose**: Execute external binaries as tools.

**Implements**:
- Invoke external executable
- Pass parameters as JSON via stdin
- Read result as JSON from stdout
- Timeout handling
- Error handling (executable not found, invalid JSON)

**Dependencies**:
- Step 10 (tool executor)

**Deliverables**:
- `Sources/YBS/Tools/ExternalTool.swift`
- Protocol documentation

**Verification**:
```bash
# Create dummy tool
cat > ~/.ybs/tools/echo-tool << 'EOF'
#!/bin/bash
read json
echo "$json"
EOF
chmod +x ~/.ybs/tools/echo-tool

swift run ybs-test-external
# Executes echo-tool, verifies JSON I/O
```

**Size**: ~120 lines

---

### Step 24: External Tool Discovery & Loading

**Purpose**: Auto-discover and load external tools.

**Implements**:
- Scan ~/.ybs/tools/ directory
- Load tool schemas (tool --schema)
- Register in ToolExecutor
- Validate tool schemas

**Dependencies**:
- Step 23 (external tool protocol)

**Deliverables**:
- `Sources/YBS/Tools/ToolDiscovery.swift`
- Auto-loading at startup

**Verification**:
```bash
# Create web_search tool
cp web-search ~/.ybs/tools/

swift run ybs --list-tools
# Shows: read_file, write_file, edit_file, search_files, run_shell, web_search
```

**Size**: ~100 lines

---

## Layer 8: Advanced Context (Steps 25-27)

**Purpose**: Performance and scaling.

**Why Eighth**: Basic system works, now optimize.

### Step 25: Token Counting & Tracking

**Purpose**: Track context usage.

**Implements**:
- Count tokens in messages (tiktoken or approximation)
- Track total tokens used
- Warn when approaching limit
- Display token usage in UI

**Dependencies**:
- Step 15 (conversation context)

**Deliverables**:
- `Sources/YBS/Context/TokenCounter.swift`
- Integration with ConversationContext

**Verification**:
```bash
swift run ybs --show-token-usage
You: Hello
AI: Hi there!
[Tokens: 25/32000]
```

**Size**: ~100 lines

---

### Step 26: Context Compaction

**Purpose**: Prevent context overflow.

**Implements**:
- Monitor token count
- When approaching limit (95%), compact old messages
- Summarize old conversation (send to LLM: "Summarize these messages")
- Replace old messages with summary

**Dependencies**:
- Step 25 (token counting)

**Deliverables**:
- `Sources/YBS/Context/ContextCompactor.swift`

**Verification**:
```bash
swift run ybs
# Have a very long conversation (50+ turns)
# Observe auto-compaction when tokens approach limit
```

**Size**: ~150 lines

---

### Step 27: Repo Map Generation

**Purpose**: Provide codebase context to LLM.

**Implements**:
- Extract function/class signatures from source files
- Build tree-sitter-based parser (or regex fallback)
- Limit to ~1-5K tokens
- Include in system prompt

**Dependencies**:
- Steps 18, 25 (search files, token counting)

**Deliverables**:
- `Sources/YBS/Context/RepoMap.swift`
- Signature extraction

**Verification**:
```bash
swift run ybs --show-repo-map
# Displays function signatures from codebase
```

**Size**: ~200 lines

---

## Layer 9: Polish (Steps 28-30)

**Purpose**: UX improvements.

**Why Last**: Functionality complete, now make it nice.

### Step 28: Colored Output & UX

**Purpose**: Pretty terminal output.

**Implements**:
- ANSI color codes (user = blue, AI = green, tool = yellow)
- Progress spinner while waiting for LLM
- Formatted output (boxes, borders)
- Streaming output (print tokens as received)

**Dependencies**:
- Step 13 (agent loop)

**Deliverables**:
- `Sources/YBS/UI/ColorOutput.swift`
- `Sources/YBS/UI/ProgressIndicator.swift`

**Verification**:
```bash
swift run ybs
# See colored, pretty output
```

**Size**: ~80 lines

---

### Step 29: Error Recovery & Retry

**Purpose**: Handle transient failures.

**Implements**:
- Retry failed LLM requests with exponential backoff
- JSON repair for malformed tool calls (json-repair-like)
- Detect incomplete JSON (max_tokens cutoff)
- Re-prompt LLM: "Your JSON was invalid, try again"

**Dependencies**:
- Steps 11-12 (LLM client)

**Deliverables**:
- Retry logic in LLMClient
- JSON repair utility

**Verification**:
```bash
# Simulate network error (disconnect wifi briefly)
swift run ybs
You: Hello
# Observe automatic retry with backoff
```

**Size**: ~100 lines

---

### Step 30: Performance Optimization

**Purpose**: Make it fast.

**Implements**:
- Parallel tool execution (when LLM requests multiple tools)
- Cache repo maps (don't regenerate every request)
- Lazy loading (don't load all tools at startup)
- Connection pooling for HTTP

**Dependencies**:
- All previous steps

**Deliverables**:
- Optimizations throughout codebase
- Benchmarks

**Verification**:
```bash
# Benchmark tool execution time
swift run ybs-benchmark
# Before: 500ms, After: 200ms
```

**Size**: ~100 lines

---

## Execution Strategy

**Batch Approach**: Write and execute in batches

**Batch 1** (Foundation): Steps 4-7
- Write all 4 step documents
- Execute them in order
- Verify each works
- Commit after batch complete

**Batch 2** (Basic Tools): Steps 8-10
- Write step documents
- Execute and verify
- Commit

**Batch 3** (LLM + Agent): Steps 11-15
- Write step documents
- Execute and verify
- **Milestone**: Working AI chat!
- Commit

**Continue** in batches of 3-5 steps.

**Pause Points**: After Steps 7, 10, 15, 19, 22, 24, 27, 30

---

## Dependencies Graph Summary

```
Foundation (4-7)
    ├─> Basic Tools (8-10)
    │       └─> Agent Core (13-15)
    │               ├─> More Tools (16-19)
    │               │       └─> Safety (20-22)
    │               └─> Advanced Context (25-27)
    │                       └─> Polish (28-30)
    └─> LLM Client (11-12)
            └─> Agent Core (13-15)
                    └─> External Tools (23-24)
```

**Critical Path**: 4→5→6→7→11→12→13→14→15 (get to working agent)

---

## Next Actions

**Immediate**:
1. Write Step 4-7 documents (Foundation layer)
2. Execute Step 4 (config loading)
3. Execute Step 5 (data models)
4. Execute Step 6 (errors/logging)
5. Execute Step 7 (CLI parsing)
6. Verify foundation layer complete

**Then**:
7. Write Steps 8-10 (Basic Tools layer)
8. Continue in batches

---

## References

- **Process**: `framework/docs/step-planning-process.md`
- **Spec**: `systems/bootstrap/specs/technical/ybs-spec.md`
- **Decisions**: `systems/bootstrap/specs/architecture/ybs-decisions.md`
- **Template**: `framework/templates/step-template.md`
- **Completed Steps**: `systems/bootstrap/steps/ybs-step_*.md`
