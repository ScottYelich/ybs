# Bootstrap Implementation Principles

**Version**: 0.1.0
**Last Updated**: 2026-01-17

📍 **You are here**: YBS Framework > Documentation > Bootstrap Principles
**↑ Parent**: [Documentation Hub](README.md)
📚 **Related**: [tool-architecture.md](tool-architecture.md) | [security-model.md](security-model.md) | [configuration.md](configuration.md)

> **Canonical Reference**: This is the single source of truth for bootstrap implementation principles.
> All other documents should link here rather than duplicating this content.

---

## What is the Bootstrap?

The **bootstrap** is the first system being built WITH YBS to validate the framework. It's a Swift-based AI chat tool for macOS (similar to Aider, but local-first).

**Key Insight**: The bootstrap HAPPENS to be an AI agent, but YBS could just as easily guide building a calculator, web server, database, or anything else. The bootstrap is ONE example, not THE only thing YBS can build.

---

## Core Design Principles

These principles apply specifically to the Swift/macOS bootstrap implementation. Different systems built with YBS can follow different principles.

### 1. 🏠 Local-First

**Principle**: All tool execution happens locally on the user's machine.

**What this means**:
- File I/O runs on local filesystem
- Shell commands execute locally
- Code stays on user's machine
- LLM can be local (Ollama) or remote (OpenAI, Anthropic)

**Why**:
- Security: User controls their data
- Privacy: Code never leaves the machine
- Performance: No network latency for tool execution
- Offline-capable: Works without internet (with local LLM)

**Implementation**:
- Tools are implemented in Swift, run locally
- LLM API calls are the only network traffic
- Configuration and state stored locally

---

### 2. 🔧 Extensible

**Principle**: Users can add new tools without recompiling the agent.

**What this means**:
- Hybrid architecture: 6 built-in tools + unlimited external tools
- External tools follow simple JSON protocol
- Tools can be written in any language
- Agent discovers tools at runtime

**Why**:
- Flexibility: Adapt to any project or workflow
- Future-proof: New capabilities without agent updates
- Community: Users can share tools
- Experimentation: Try new tools without commitment

**Implementation**:
- External tools loaded from `~/.config/ybs/tools/` or `.ybs/tools/`
- Simple protocol: JSON in via argv, JSON out via stdout
- Agent validates tool output before acting on it

See: [tool-architecture.md](tool-architecture.md) for details

---

### 3. 🔒 Secure by Default

**Principle**: Safety mechanisms are enabled by default, not opt-in.

**What this means**:
- Shell execution is sandboxed (macOS `sandbox-exec`)
- Path restrictions block sensitive directories
- User confirmation required for destructive operations
- Command blocklist prevents dangerous operations
- Session allow-lists (not persisted)

**Why**:
- Safety: Prevent accidental damage
- Security: Limit attack surface if LLM is compromised
- Trust: Users can run agent confidently
- Compliance: Enterprise security requirements

**Implementation**:
- macOS: `sandbox-exec` with deny-by-default profile
- Blocks: `~/.ssh`, `~/.aws`, `~/.config`, network access
- Confirmation UI before: `write_file`, `run_shell`, `rm`, `chmod`
- Blocklist: `rm -rf /`, `sudo`, `chmod 777`, format commands

See: [security-model.md](security-model.md) for details

---

### 4. 🎯 Simple Core

**Principle**: The agent loop should be understandable in < 100 lines of code.

**What this means**:
- Core logic is readable and maintainable
- No complex state machines
- Straightforward control flow
- Well-commented and documented

**Why**:
- Maintainability: Easy to fix bugs
- Auditable: Security reviewers can understand it
- Teachable: Others can learn from the code
- Debuggable: Problems are easier to diagnose

**Implementation**:
- Agent loop: ~50-80 lines
- Pattern: read input → call LLM → execute tools → repeat
- No hidden magic or complex abstractions
- State is explicit (conversation history)

---

### 5. 🌐 Flexible LLM

**Principle**: LLM provider is configurable, not hardcoded.

**What this means**:
- Supports multiple providers: Ollama, OpenAI, Anthropic
- OpenAI-compatible API as baseline
- Provider-specific adapters for differences
- User chooses via configuration file

**Why**:
- Choice: Users pick what works for them
- Cost: Local LLMs are free
- Privacy: Local LLMs keep data private
- Reliability: Fallback if one provider is down

**Implementation**:
- Provider abstraction (protocol/interface)
- Default: Ollama at `http://localhost:11434`
- Configuration: JSON file specifies provider, model, endpoint, API key
- Streaming: SSE for real-time responses

See: [configuration.md](configuration.md) for details

---

### 6. ⚡ Minimal Overhead

**Principle**: Fast startup, low memory footprint, minimal dependencies.

**What this means**:
- Swift (compiled, not interpreted)
- Only 2-3 external dependencies
- Single binary distribution
- Sub-second startup time
- < 50MB memory usage typical

**Why**:
- Responsiveness: Users don't wait
- Resource-friendly: Works on older machines
- Distribution: Easy to install and run
- Maintenance: Fewer dependency conflicts

**Implementation**:
- Swift standard library + Foundation
- Dependencies: swift-argument-parser, AsyncHTTPClient
- Build: Single static binary
- No runtime dependencies beyond system libraries

---

## Framework vs Bootstrap

**Important distinction**:

| Aspect | YBS Framework | Bootstrap Implementation |
|--------|---------------|-------------------------|
| **What** | Methodology for autonomous building | Swift AI chat tool |
| **Scope** | Any system, any language | macOS only, Swift only |
| **Principles** | Traceability, autonomy, verification | Local-first, secure, extensible |
| **Output** | Structured files (specs + steps) | Working Swift application |
| **Audience** | Anyone building any system | Users of the chat tool |

The principles on this page are **bootstrap-specific**. YBS itself is language-agnostic and system-agnostic.

---

## Comparison to Similar Tools

### vs Aider
- **Similarity**: Both are AI coding assistants
- **Difference**: Bootstrap is local-first with sandboxing; Aider is Python-based

### vs Cursor
- **Similarity**: Both integrate AI into development
- **Difference**: Cursor is an IDE; bootstrap is CLI-first

### vs Claude Code
- **Similarity**: Both use Claude as the LLM
- **Difference**: Bootstrap is user-built system; Claude Code is Anthropic's product

The bootstrap demonstrates that YBS can guide building complex systems (AI agents) autonomously.

---

## References

- **Complete spec**: [../specs/ybs-spec.md](../specs/ybs-spec.md)
- **Architectural decisions**: [../specs/ybs-decisions.md](../specs/ybs-decisions.md)
- **Implementation checklist**: [../specs/ybs-lessons-learned.md](../specs/ybs-lessons-learned.md)
- **Tool architecture**: [tool-architecture.md](tool-architecture.md)
- **Security model**: [security-model.md](security-model.md)
- **Configuration**: [configuration.md](configuration.md)

---

**Version History**:
- 0.1.0 (2026-01-17): Initial canonical reference extracted from distributed documentation
