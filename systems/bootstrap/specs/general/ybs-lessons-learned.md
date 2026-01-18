# YBS: Lessons Learned & Implementation Checklist

> A comprehensive checklist derived from Aider, Goose, Open Interpreter, Cursor, OpenHands, and other open-source AI coding agents. Use this to verify your YBS implementation covers known pitfalls.
>
> **YBS** = Yelich Build System

---

## 1. Context Window Management

### 1.1 Context Budget
- [ ] **Token budget defined**: Set explicit max tokens for context (e.g., 95% of model limit)
- [ ] **Auto-compaction implemented**: When approaching limit, summarize/compact conversation history
- [ ] **Per-component budgets**: Allocate separate budgets for system prompt, repo map, conversation, tool results
- [ ] **Token counting active**: Track actual token usage, not just message count

### 1.2 Repository Context
- [ ] **Repo map uses signatures only**: Extract function/class signatures, not full implementations
- [ ] **Repo map budget ~1-5k tokens**: Don't exceed; use tree-sitter for intelligent extraction
- [ ] **Dynamic repo map**: Adjust included files based on current task relevance
- [ ] **Lazy loading**: Only load file contents when explicitly needed, not upfront

### 1.3 Context Quality
- [ ] **No context poisoning**: Validate tool outputs before adding to context; strip hallucinated content
- [ ] **Important info at edges**: Place critical instructions at START or END of context, never middle
- [ ] **Recency bias handled**: Recent messages weighted appropriately; old context summarized
- [ ] **Session isolation**: New task = new session; don't carry stale context across unrelated tasks

---

## 2. Tool Calling & Reliability

### 2.1 Tool Design
- [ ] **Minimal tool count**: Fewer tools = less confusion; aim for <10 core tools
- [ ] **Non-overlapping purposes**: Each tool has ONE clear job; no ambiguous "could use A or B" situations
- [ ] **Clear tool descriptions**: Descriptions say WHEN to use, not just what it does
- [ ] **Explicit "don't use" guidance**: Tell LLM when NOT to call tools (e.g., "don't call for greetings")

### 2.2 Tool Schema
- [ ] **Required vs optional params clear**: Mark required params; provide defaults for optional
- [ ] **Enum constraints where possible**: Limit string params to known values when applicable
- [ ] **Examples in descriptions**: Show example valid inputs in tool/param descriptions
- [ ] **Return type documented**: LLM knows what to expect back

### 2.3 JSON Parsing Robustness
- [ ] **Handle unescaped characters**: Newlines, tabs, control chars in string values
- [ ] **Handle single quotes**: LLMs output Python-style quotes; convert to double
- [ ] **Handle conversational wrapping**: Strip "Sure, here's the JSON:" prefixes
- [ ] **Handle truncation**: Detect incomplete JSON from max_tokens cutoff
- [ ] **JSON repair library**: Use a repair/fuzzy parser as fallback (e.g., json-repair)
- [ ] **Retry on parse failure**: Re-prompt with "Your JSON was malformed, try again" + specific error

### 2.4 Tool Execution
- [ ] **Timeout on all tools**: No tool runs forever; set reasonable timeouts (e.g., 30s default, 5min max)
- [ ] **Capture stdout AND stderr**: Return both to LLM for debugging
- [ ] **Truncate large outputs**: Don't return 100k lines; truncate with "[truncated, showing first/last N lines]"
- [ ] **Structured error returns**: Return `{success: false, error: "message"}` not raw exceptions

---

## 3. Edit Formats & File Operations

### 3.1 Edit Format Selection
- [ ] **NOT using whole-file by default**: Whole-file rewrites waste tokens and increase latency
- [ ] **SEARCH/REPLACE blocks preferred**: Explicit old→new blocks are reliable and auditable
- [ ] **Unified diff for capable models**: GPT-4+ class models perform better with udiff (3x less lazy)
- [ ] **Format matches model capability**: Weaker models get simpler formats; strong models get efficient ones

### 3.2 Edit Format Robustness
- [ ] **Fuzzy matching for SEARCH blocks**: Handle minor whitespace differences in "old" text
- [ ] **Unique match validation**: Reject edits where SEARCH text matches multiple locations
- [ ] **Line number avoidance**: Don't require LLM to specify line numbers (they hallucinate them)
- [ ] **Atomic file writes**: Write to temp file, then rename; don't corrupt on crash

### 3.3 Architect/Editor Split (Optional)
- [ ] **Consider two-phase for complex edits**: Phase 1 = plan changes, Phase 2 = format as edits
- [ ] **Reduces cognitive load**: LLM focuses on ONE task per phase (reasoning OR formatting)
- [ ] **Can use different models**: Expensive model for planning, cheap model for edit formatting

---

## 4. Agent Loop & Control Flow

### 4.1 Loop Limits
- [ ] **Max iterations set**: Hard limit (e.g., 25 turns) prevents runaway agents
- [ ] **Repetition detection**: Detect if last N tool calls are identical; break loop
- [ ] **Cost/token limit**: Stop if accumulated cost exceeds threshold
- [ ] **User interrupt respected**: Ctrl+C or similar immediately halts execution

### 4.2 Loop State Management
- [ ] **Explicit state tracking in code**: Don't rely on LLM to remember what it did; track in your agent
- [ ] **Progress indicators**: Show user what step agent is on (e.g., "Step 3/10: Running tests")
- [ ] **Checkpointing for long tasks**: Save state periodically; allow resume after crash
- [ ] **Clear termination signals**: Define explicit "I'm done" detection (not just absence of tool calls)

### 4.3 Error Recovery
- [ ] **Graceful error states**: Don't throw fatal exceptions; transition to error state
- [ ] **Recovery from error state**: New user message can restart from error state
- [ ] **Error context preserved**: When erroring, keep enough context to explain what went wrong
- [ ] **Retry with backoff**: Transient errors (rate limits, network) retry with exponential backoff

### 4.4 Stuck Detection
- [ ] **"Trying same thing repeatedly" detection**: 3+ identical actions = stuck
- [ ] **Offer escape hatch**: When stuck, prompt user or switch to chat-only mode
- [ ] **Log full trajectory**: On stuck/failure, dump full action history for debugging

---

## 5. Safety & Security

### 5.1 Sandboxing (CRITICAL)
- [ ] **Execution sandbox exists**: All code/shell execution in isolated environment
- [ ] **Filesystem isolation**: Agent can only access designated directories
- [ ] **Network isolation**: Agent cannot make arbitrary outbound connections (or allowlist only)
- [ ] **Ephemeral environments**: Sandbox state destroyed after each session/task
- [ ] **No host system access**: Cannot access Docker socket, SSH keys, cloud creds outside sandbox

### 5.2 Sandboxing Technology
- [ ] **Appropriate isolation level chosen**:
  - Firecracker/microVM for zero-trust (strongest)
  - gVisor for syscall filtering (strong)
  - Docker + seccomp + AppArmor for moderate trust
  - Landlock + seccomp for lightweight Linux sandboxing
- [ ] **Sandbox tested**: Verified that `rm -rf /`, network exfil, etc. are blocked

### 5.3 Permission System
- [ ] **Least privilege default**: Start with read-only; require explicit grant for writes
- [ ] **Per-tool permissions**: Each tool has its own permission scope (not blanket "allow all")
- [ ] **Dangerous operations require confirmation**: Delete, overwrite, git push, external sends → user approval
- [ ] **Permission scoping by path**: Write access to `./src` doesn't mean write access to `~/.ssh`

### 5.4 Input Validation
- [ ] **External data is untrusted**: Jira tickets, GitHub issues, web content → treat as prompt injection vectors
- [ ] **Command injection prevention**: Shell commands properly escaped/quoted
- [ ] **Path traversal prevention**: Reject `../` attempts to escape allowed directories
- [ ] **No secrets in prompts**: Don't include API keys, passwords in system prompts

---

## 6. User Experience

### 6.1 Transparency
- [ ] **Show tool calls before execution**: User sees what agent is about to do
- [ ] **Show tool results**: User sees outputs (possibly truncated)
- [ ] **Explain reasoning**: Agent explains why it's taking an action (optional, but helpful)
- [ ] **Show token/cost usage**: User knows how much context is used, approximate cost

### 6.2 Control
- [ ] **Confirmation for destructive ops**: User must approve before irreversible actions
- [ ] **Ability to cancel mid-operation**: User can stop agent at any point
- [ ] **Ability to undo**: Git integration for easy rollback of changes
- [ ] **Ability to modify and retry**: User can edit the failed attempt and retry

### 6.3 Feedback Loops
- [ ] **Run tests after changes**: Offer to run linter/tests and show results to LLM
- [ ] **Iterative refinement**: If tests fail, LLM can see output and try to fix
- [ ] **Lint/format integration**: Auto-format code or warn about lint errors

---

## 7. LLM API Integration

### 7.1 Provider Abstraction
- [ ] **OpenAI-compatible API as baseline**: Easy to swap between providers
- [ ] **Model-specific quirks handled**: Different models need different prompts/formats
- [ ] **Streaming supported**: Stream responses for better UX; don't wait for full completion
- [ ] **Fallback models configured**: If primary model fails, try backup

### 7.2 API Robustness
- [ ] **Rate limit handling**: Detect 429s, implement backoff
- [ ] **Timeout handling**: API calls have timeouts; don't hang forever
- [ ] **Partial response handling**: If stream cuts off, detect and handle gracefully
- [ ] **Cost tracking**: Log token usage per request for billing awareness

### 7.3 Local LLM Considerations
- [ ] **Lower reliability expected**: Local models fail tool calling more often; plan for it
- [ ] **Quantization tradeoffs understood**: Q4 saves RAM but may reduce tool-call accuracy
- [ ] **Ollama/LM Studio compatible**: Standard local inference servers supported
- [ ] **Model-specific tool call formats**: Some models use different tool call syntax

---

## 8. Git Integration

### 8.1 Safety
- [ ] **Auto-commit changes**: Each LLM edit gets a commit (easy rollback)
- [ ] **Descriptive commit messages**: Commits explain what changed and why
- [ ] **Never force push without confirmation**: Protect against history destruction
- [ ] **Branch awareness**: Know what branch agent is on; warn about main/master

### 8.2 Context
- [ ] **Git status informs agent**: Agent knows about uncommitted changes
- [ ] **Git diff available**: Agent can see what's changed
- [ ] **Git log for style**: Agent can see recent commit message style

---

## 9. Web Capabilities (Optional)

### 9.1 Web Search
- [ ] **Self-hosted option (SearXNG)**: No API key dependencies
- [ ] **Rate limiting**: Don't hammer search engines
- [ ] **Result summarization**: Don't dump 10 pages of results; summarize relevant parts

### 9.2 Web Fetch
- [ ] **HTML to markdown conversion**: Clean extraction of content
- [ ] **JavaScript rendering (optional)**: Headless browser for dynamic sites
- [ ] **Content length limits**: Don't fetch 100MB files
- [ ] **Domain allowlisting (optional)**: Restrict to known-safe domains

---

## 10. Architecture & Code Quality

### 10.1 Simplicity
- [ ] **Core loop is simple**: Main agent loop understandable in <50 lines
- [ ] **Tools are independent**: Each tool is a pure function; no hidden dependencies
- [ ] **Configuration not code**: Model selection, API keys, limits are config, not hardcoded

### 10.2 Extensibility
- [ ] **Easy to add new tools**: Adding a tool = define function + schema
- [ ] **Protocol-based integration (MCP)**: Consider MCP for interoperability
- [ ] **Plugin architecture (optional)**: Allow third-party tool extensions

### 10.3 Testing (MANDATORY)

**All implementations MUST include comprehensive testing. No step is complete without tests.**

- ✅ **Unit tests for tools** (REQUIRED): Each tool MUST be tested independently
  - Test success cases (valid inputs)
  - Test error cases (invalid inputs, missing files)
  - Test edge cases (empty files, large files, special characters)
  - Test security (path traversal blocked)
  - Minimum 30 test cases total across all tools

- ✅ **Unit tests for LLM clients** (REQUIRED): Each LLM client MUST be tested
  - Test message format conversion (especially Anthropic)
  - Test API header construction
  - Test response parsing (success and error)
  - Test streaming functionality
  - Mock HTTP responses for testing

- ✅ **Integration tests for agent loop** (REQUIRED): Full agent loop MUST be tested
  - Test complete conversation flow with mock LLM
  - Test tool execution loop (multi-turn)
  - Test meta-command handling
  - Test shell injection
  - Test provider switching
  - Test error recovery

- ✅ **Configuration tests** (REQUIRED): Configuration system MUST be tested
  - Test config loading from various sources
  - Test validation and error messages
  - Test default value handling
  - Test override precedence

- ✅ **Session tests** (REQUIRED): Session management MUST be tested
  - Test session creation and saving
  - Test session loading and replay
  - Test session listing
  - Test cleanup and retention

- ✅ **Sandbox tests** (REQUIRED): Sandbox MUST be verified
  - Verify sandbox blocks dangerous operations (rm -rf /, etc.)
  - Verify blocked commands are rejected
  - Verify timeouts are enforced
  - Test path restrictions

- ⚠️ **Replay tests** (OPTIONAL): Record and replay LLM interactions
  - Useful for regression testing
  - Can implement after core tests are complete

**Test Coverage Requirements**:
- **Minimum**: 60% line coverage (REQUIRED for completion)
- **Target**: 80% line coverage (RECOMMENDED)
- **Critical paths**: 100% coverage (tool execution, LLM communication, safety)

**Verification**:
- All tests MUST pass before marking step complete
- Run: `swift test` must succeed
- Run: `swift test --enable-code-coverage` to verify coverage
- No step is complete until tests are written and passing

---

## Quick Reference: Critical Failures to Prevent

| Failure Mode | Prevention |
|--------------|------------|
| Context overflow | Auto-compaction at 95% |
| Infinite loop | Max iterations + repetition detection |
| JSON parse error | Repair library + retry logic |
| Sandbox escape | Network isolation + filesystem restrictions |
| Prompt injection | Treat external data as untrusted |
| Data loss | Git auto-commit + confirmation for destructive ops |
| Cost explosion | Token/cost limits + user visibility |
| Hung process | Timeouts on all external calls |

---

## Quick Reference: Recommended Defaults

| Setting | Recommended Default |
|---------|---------------------|
| Max iterations | 25 |
| Tool timeout | 30 seconds |
| Max tool output | 10,000 characters |
| Repo map budget | 1,024 tokens |
| Context compaction trigger | 95% of window |
| Retry attempts | 3 with exponential backoff |
| Confirmation required | delete, overwrite, git push, external network |

---

## Sources

- [Aider Documentation](https://aider.chat/docs/)
- [Aider Edit Formats](https://aider.chat/docs/more/edit-formats.html)
- [Aider Unified Diffs](https://aider.chat/docs/unified-diffs.html)
- [Aider Repository Map](https://aider.chat/docs/repomap.html)
- [Goose Architecture](https://block.github.io/goose/docs/goose-architecture/)
- [Goose MCP Deep Dive](https://skywork.ai/skypage/en/Goose-with-MCP-Servers-A-Deep-Dive-for-AI-Engineers/)
- [Block's Goose Deployment](https://www.lennysnewsletter.com/p/blocks-custom-ai-agent-goose)
- [JetBrains Context Management Research](https://blog.jetbrains.com/research/2025/12/efficient-context-management/)
- [Anthropic Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [LangChain Context Engineering](https://www.blog.langchain.com/context-engineering-for-agents/)
- [NVIDIA Agentic AI Security](https://developer.nvidia.com/blog/how-code-execution-drives-key-risks-in-agentic-ai-systems/)
- [AI Sandboxing Guide](https://www.luiscardoso.dev/blog/sandboxes-for-ai)
- [CodeAnt Shell Sandboxing](https://www.codeant.ai/blogs/agentic-rag-shell-sandboxing)
- [AI Agent Loop Prevention](https://www.fixbrokenaiapps.com/blog/ai-agents-infinite-loops)
- [OpenHands Loop Recovery PR](https://github.com/All-Hands-AI/OpenHands/pull/5500)
- [Stytch Agent Permissions](https://stytch.com/blog/handling-ai-agent-permissions/)
- [Docker Tool Calling Evaluation](https://www.docker.com/blog/local-llm-tool-calling-a-practical-evaluation/)
- [JSON Reliability for Local LLMs](https://www.arsturn.com/blog/json-response-reliability-fixing-broken-output-from-local-llms)
- [Goose JSON Parsing Issue](https://github.com/block/goose/issues/2892)
- [Build Coding Agent Tutorial](https://www.siddharthbharath.com/build-a-coding-agent-python-tutorial/)
- [Martin Fowler Pydantic-AI Agent](https://martinfowler.com/articles/build-own-coding-agent.html)
- [Repository Intelligence Graph Paper](https://arxiv.org/html/2601.10112)
- [Code Maps for LLMs](https://origo.prose.sh/code-maps)

---

*Last updated: 2026-01-16*
