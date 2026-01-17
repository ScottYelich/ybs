# YBS: Architectural Decisions Record

> Key decisions with rationale. Reference this when implementing or questioning "why did we do it this way?"
>
> **YBS** = Yelich Build System

---

## Decision Index

| ID | Decision | Choice |
|----|----------|--------|
| D01 | Implementation Language | Swift |
| D02 | LLM Location | Remote (with local option) |
| D03 | API Abstraction | OpenAI-compatible |
| D04 | Tool Architecture | Built-in core + External plugins |
| D05 | External Tool Protocol | Executable + JSON stdin/stdout |
| D06 | Configuration Format | JSON |
| D07 | Config Resolution | Layered (system → user → project → CLI) |
| D08 | Edit Format | Search/Replace blocks |
| D09 | Shell Sandboxing | macOS sandbox-exec |
| D10 | Confirmation Model | Per-tool, with session allow-list |
| D11 | Context Management | Token-based with auto-compaction |
| D12 | Streaming | Required for responses |
| D13 | State Persistence | None (stateless sessions) |
| D14 | Dependencies | Minimal (Foundation + ArgumentParser + HTTP) |
| D15 | Error Handling | Graceful degradation, no fatal crashes |

---

## D01: Implementation Language

**Decision**: Swift

**Alternatives Considered**:
- Python (ecosystem, but slow startup, messy distribution)
- Rust (performance, but steeper learning curve)
- Go (simple, but less natural for macOS)
- TypeScript (Claude Code uses it, but Node dependency)

**Rationale**:
1. Native macOS integration (Process, FileManager, sandbox-exec)
2. Single binary distribution (no runtime dependencies)
3. Fast startup (~10ms vs Python's ~200ms)
4. Type safety catches tool schema errors at compile time
5. User is comfortable with Swift
6. Async/await maps cleanly to agent loop

**Trade-offs**:
- Fewer existing examples to copy from
- No LangChain equivalent (but we don't need it)
- Smaller LLM/AI ecosystem

---

## D02: LLM Location

**Decision**: LLM can be local OR remote; agent always runs locally

**Rationale**:
```
┌─────────────────────────────┐
│     LOCAL (your machine)    │
│  ┌───────────────────────┐  │
│  │   Agent (Swift CLI)   │  │
│  │   - Tool execution    │  │
│  │   - Context mgmt      │  │
│  │   - User I/O          │  │
│  └───────────┬───────────┘  │
└──────────────┼──────────────┘
               │ HTTP/JSON
               ▼
    ┌─────────────────────┐
    │   LLM (anywhere)    │
    │   - Ollama local    │
    │   - OpenAI cloud    │
    │   - Anthropic cloud │
    └─────────────────────┘
```

1. **Tool execution MUST be local** — security, filesystem access, shell
2. **LLM is just HTTP** — no reason to restrict to local
3. **User choice** — local for privacy/cost, remote for capability
4. **Same code path** — provider abstraction makes this transparent

**Default**: Ollama (local) for zero-cost experimentation

---

## D03: API Abstraction

**Decision**: OpenAI-compatible chat completions API as the abstraction

**Rationale**:
1. De facto standard — Ollama, LM Studio, LocalAI, vLLM all support it
2. Well-documented, stable schema
3. Tool/function calling has standard format
4. Easy to add new providers
5. Anthropic adapter is straightforward (different but mappable)

**Schema** (simplified):
```json
{
  "model": "qwen3:14b",
  "messages": [...],
  "tools": [...],
  "stream": true
}
```

**Provider-specific handling**:
- Ollama: Native OpenAI-compat at `/api/chat`
- OpenAI: Direct
- Anthropic: Map messages format, tool format slightly different

---

## D04: Tool Architecture

**Decision**: Hybrid — built-in core tools + runtime-loaded external tools

**Built-in Tools** (6):
| Tool | Why Built-in |
|------|--------------|
| `read_file` | Security (path validation), performance |
| `write_file` | Security (atomic writes, confirmation) |
| `edit_file` | Tight integration with read tracking |
| `list_files` | Performance (native glob) |
| `search_files` | Performance (native regex) |
| `run_shell` | Security (sandbox integration) |

**External Tools**:
| Tool | Why External |
|------|--------------|
| `web_search` | User picks backend (SearXNG, DDG, Google) |
| `web_fetch` | Implementation varies (curl, headless browser) |
| Custom | Project-specific (test runners, linters) |

**Rationale**:
1. Core tools need security integration that's hard to do externally
2. Core tools need performance (no exec overhead)
3. External tools allow customization without recompiling
4. External tools can be written in any language
5. Clear separation of concerns

---

## D05: External Tool Protocol

**Decision**: Executable that reads JSON from argv, writes JSON to stdout

**Format**:
```bash
# Invocation
./web-search '{"query": "swift async", "max_results": 5}'

# Output (stdout)
{"success": true, "results": [...]}

# Errors (exit code != 0, stderr for message)
```

**Alternatives Considered**:
- Stdin for input → More complex, buffering issues
- MCP protocol → Heavier, requires persistent connection
- Shared library/FFI → Language-specific, complex
- HTTP server → Overhead, port management

**Rationale**:
1. **Universal** — Any language can implement (bash, Python, Swift, Go)
2. **Simple** — No protocol negotiation, no state
3. **Debuggable** — Run tool manually to test
4. **Isolated** — Each invocation is independent
5. **Timeout-friendly** — Just kill the process

**Schema Discovery**:
Sidecar file `<tool-name>.tool.json`:
```json
{
  "name": "web_search",
  "description": "Search the web",
  "parameters": {
    "query": {"type": "string", "required": true}
  }
}
```

---

## D06: Configuration Format

**Decision**: JSON

**Alternatives Considered**:
- YAML — More readable, but parsing complexity, whitespace issues
- TOML — Good for simple configs, but nested structures awkward
- Swift code — Type-safe, but requires recompilation

**Rationale**:
1. Native to Swift (JSONDecoder)
2. LLMs understand JSON well (for debugging/generation)
3. Strict format = fewer ambiguities
4. Comments not needed (use separate documentation)
5. Matches tool I/O format (consistency)

---

## D07: Configuration Resolution

**Decision**: Layered config with overrides

```
Priority (highest to lowest):
1. --config <path>       CLI explicit
2. ./.yds.json           Project-local
3. ~/.yds.json           User home
4. ~/.config/yds/config.json  XDG user
5. /etc/yds/config.json       System
```

**Merge Strategy**: Deep merge, later values override earlier

**Rationale**:
1. System admins can set org-wide defaults
2. Users customize their preferences
3. Projects can override for specific needs (different model, tools)
4. CLI has final say for one-off changes
5. Follows Unix conventions (XDG, /etc)

---

## D08: Edit Format

**Decision**: Search/Replace blocks (not whole-file, not unified diff)

**Format**:
```
<<<<<<< SEARCH
exact text to find
=======
replacement text
>>>>>>> REPLACE
```

**Alternatives Considered**:
- Whole file → Wasteful, slow, expensive
- Unified diff → Better for strong models, but line numbers hallucinate
- Line-based edits → Line numbers are unreliable

**Rationale**:
1. **No line numbers** — LLMs hallucinate line numbers constantly
2. **Exact match required** — Forces LLM to read file first
3. **Auditable** — User sees exactly what changes
4. **Robust** — Fuzzy matching handles minor whitespace differences
5. **Works with all models** — Simpler format = fewer format errors

**Validation**:
- SEARCH text must be unique in file (or use replace_all flag)
- Reject if not found or ambiguous
- This catches hallucinated content

---

## D09: Shell Sandboxing

**Decision**: macOS `sandbox-exec` with restrictive profile

**Profile** (default):
```scheme
(version 1)
(deny default)
(allow file-read* (subpath "/working/directory"))
(allow file-write* (subpath "/working/directory"))
(allow process-fork)
(allow process-exec)
(deny network*)
```

**Alternatives Considered**:
- Docker container → Heavy, requires Docker running
- No sandbox → Dangerous
- Firejail → Linux only
- Custom chroot → Complex, incomplete

**Rationale**:
1. Built into macOS (no dependencies)
2. Kernel-enforced (can't bypass from userspace)
3. Fine-grained control (per-path, per-syscall)
4. Lightweight (no container overhead)

**Linux Future**: Use `bubblewrap` or `firejail` with similar restrictions

**Escape Hatch**: `--no-sandbox` flag for trusted environments (CI, etc.)

---

## D10: Confirmation Model

**Decision**: Per-tool confirmation with session allow-list

**Tools Requiring Confirmation**:
- `write_file` — Always
- `run_shell` — Always (unless command in safe-list)
- `delete_file` — Always
- `edit_file` — If file not read this session

**User Options**:
```
⚠️  run_shell: git push origin main
[y]es / [n]o / [a]lways this session: a
```

**Session Allow-list**:
- User types 'a' → tool added to session allow-list
- Persists until CLI exits
- NOT persisted to disk (security)

**Rationale**:
1. Destructive operations need human approval
2. Session allow-list reduces friction for repeated ops
3. Not persisted = fresh start each session (security)
4. Per-tool granularity (not blanket "trust all")

---

## D11: Context Management

**Decision**: Token-based tracking with auto-compaction at 95%

**Components**:
| Component | Budget |
|-----------|--------|
| System prompt | ~500 tokens (fixed) |
| Repo map | ~1,024 tokens (configurable) |
| Conversation | Remainder |
| Tool results | Truncated to 10k chars |

**Compaction Strategy**:
1. At 95% capacity, trigger compaction
2. Summarize older messages (keep last N turns verbatim)
3. Preserve: system prompt, recent context, current task
4. Discard: old tool results, superseded information

**Rationale**:
1. Token-based (not message count) is accurate
2. 95% threshold leaves room for response
3. Summarization preserves essential context
4. Truncation prevents single tool result from blowing budget

**Alternative Considered**: Sliding window (drop oldest) — loses important early context

---

## D12: Streaming

**Decision**: Required for all LLM responses

**Implementation**:
```swift
for try await chunk in llm.chatStream(messages, tools) {
    switch chunk {
    case .text(let delta):
        print(delta, terminator: "")
        fflush(stdout)
    case .toolCall(let partial):
        // Buffer until complete
    case .done(let response):
        // Final processing
    }
}
```

**Rationale**:
1. **UX** — User sees progress immediately
2. **Perceived speed** — Feels faster even if same total time
3. **Early abort** — User can Ctrl+C if going wrong direction
4. **Memory** — Don't buffer entire response

**Non-streaming Fallback**: For providers that don't support it, simulate with single chunk

---

## D13: State Persistence

**Decision**: No state persistence between sessions (stateless)

**What's NOT Persisted**:
- Conversation history
- Session allow-list
- Tool results
- In-progress edits

**What IS Persisted** (via config/filesystem):
- Configuration files
- Actual file edits (they're real files)
- Git history (if auto-commit enabled)

**Rationale**:
1. **Simplicity** — No database, no state files
2. **Security** — Fresh session = fresh permissions
3. **Reproducibility** — Same input = same behavior
4. **Git is the state** — File changes are tracked there

**Future Consideration**: Optional session save/restore for long tasks

---

## D14: Dependencies

**Decision**: Minimal dependencies

**Required**:
| Dependency | Purpose |
|------------|---------|
| Foundation | File I/O, Process, JSON |
| swift-argument-parser | CLI argument parsing |
| AsyncHTTPClient | HTTP requests (or URLSession) |

**Optional**:
| Dependency | Purpose |
|------------|---------|
| ripgrep (rg) | Faster file search (fallback to native) |

**Explicitly NOT Using**:
- LangChain/LlamaIndex equivalents — Overkill, we need simple loop
- Heavy ML frameworks — LLM is external
- Database — Stateless design

**Rationale**:
1. Fewer dependencies = fewer vulnerabilities
2. Faster compile times
3. Easier to understand
4. Single binary distribution

---

## D15: Error Handling

**Decision**: Graceful degradation, never crash

**Categories**:

| Error Type | Handling |
|------------|----------|
| LLM API error | Retry with backoff, then inform user |
| Tool execution error | Return error to LLM, let it adapt |
| JSON parse error | Attempt repair, retry, then inform user |
| File not found | Return error to LLM (not a crash) |
| Permission denied | Return error to LLM |
| Infinite loop detected | Break loop, inform user |
| Config error | Use defaults, warn user |

**Implementation**:
```swift
// Tools return Result, not throw
func invoke() async -> ToolResult {
    // On error:
    return ToolResult(
        success: false,
        error: "File not found: \(path)"
    )
    // LLM sees this and can adjust
}
```

**Rationale**:
1. Errors are often recoverable by LLM
2. User stays in control (not dumped to shell)
3. Context preserved (can continue conversation)
4. Graceful restart after transient failures

---

## Open Questions (To Decide During Implementation)

| Question | Options | Leaning |
|----------|---------|---------|
| Token counting | Estimate (chars/4) vs. tiktoken-equivalent | Estimate first, accuracy later |
| Repo map generation | Manual specification vs. auto-detect | Auto-detect with override |
| Color output | Always / Never / Auto-detect | Auto-detect (isatty) |
| History file | None / Optional .history | None for v1 |
| Plugin sandboxing | Trust external tools / Sandbox them too | Trust for v1, sandbox later |

---

*Decisions Version: 1.0*
*Last Updated: 2026-01-16*
