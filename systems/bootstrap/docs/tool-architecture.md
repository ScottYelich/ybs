# Tool Architecture

**Version**: 0.1.0
**Last Updated**: 2026-01-17

📍 **You are here**: YBS Framework > Documentation > Tool Architecture
**↑ Parent**: [Documentation Hub](README.md)
📚 **Related**: [bootstrap-principles.md](bootstrap-principles.md) | [security-model.md](security-model.md)

> **Canonical Reference**: This is the single source of truth for YBS tool architecture.
> All other documents should link here rather than duplicating this content.

---

## Overview

Systems built with YBS typically use a **hybrid tool architecture** combining built-in tools (compiled into the agent binary) with external tools (runtime-loaded executables).

This approach balances security, performance, and extensibility.

---

## Built-In Tools

**Purpose**: Core operations requiring security, performance, or tight integration

**Characteristics**:
- Compiled directly into the agent binary
- Subject to security sandbox restrictions
- Fast execution (no process spawn overhead)
- Can access agent's internal state
- Updated only with new agent releases

**Typical Built-In Tools**:
- `read_file` - Read file contents
- `write_file` - Write/create files (requires user confirmation)
- `edit_file` - Apply SEARCH/REPLACE edits
- `list_files` - File discovery (glob patterns)
- `search_files` - Content search (grep/ripgrep)
- `run_shell` - Execute shell commands (sandboxed, requires confirmation)

**Example**: The bootstrap implementation (Swift/macOS) uses exactly 6 built-in tools as listed above.

---

## External Tools

**Purpose**: Project-specific or extensible functionality without recompiling

**Characteristics**:
- Language-agnostic executables
- Simple JSON protocol (in via argv, out via stdout)
- Can be added by users without modifying agent
- Isolated processes (own memory space)
- Can be versioned independently

**Protocol**:
```bash
# Tool receives JSON input via command-line argument
$ external-tool '{"action": "search", "query": "example"}'

# Tool outputs JSON to stdout
{"status": "success", "results": [...]}
```

**Example External Tools**:
- `web_search` - Search the web
- `web_fetch` - Fetch URL contents
- `language_server` - IDE-like code intelligence
- `test_runner` - Project-specific test execution
- `linter` - Code quality checks

---

## Why Hybrid?

**Built-in advantages**:
- ✅ Security: Sandboxed together with agent
- ✅ Performance: No process spawn overhead
- ✅ Reliability: Core functionality always available
- ✅ Integration: Access to agent context

**External advantages**:
- ✅ Extensibility: Add tools without recompiling
- ✅ Flexibility: Any language, any framework
- ✅ Isolation: Crash doesn't affect agent
- ✅ Upgradability: Update tools independently

**Trade-offs**:
- ⚖️ Built-in tools increase binary size
- ⚖️ External tools have process spawn overhead
- ⚖️ JSON protocol adds serialization cost
- ⚖️ Need to balance what's built-in vs external

---

## Design Guidelines

### When to Make a Tool Built-In

✅ **Yes, make it built-in if**:
- Security-sensitive (file I/O, shell execution)
- Used in nearly every session
- Requires access to agent's internal state
- Performance-critical (called frequently)
- Core to the agent's mission

❌ **No, make it external if**:
- Project-specific or domain-specific
- Optional feature (not everyone needs it)
- Frequently updated independently
- Complex dependencies (Python packages, etc.)
- Language/framework-specific

### External Tool Best Practices

1. **Keep protocol simple**: JSON in, JSON out
2. **Fail gracefully**: Return structured errors
3. **Add timeouts**: Don't hang indefinitely
4. **Document clearly**: Help text via `--help`
5. **Version explicitly**: Include version in output
6. **Make idempotent**: Same input → same output

---

## Implementation Examples

### Bootstrap Implementation (Swift/macOS)

**Built-in tools**: 6 core tools compiled into Swift binary
**External tools**: Loaded from `~/.config/ybs/tools/` or project `.ybs/tools/`
**Discovery**: Agent scans tool directories at startup
**Execution**: Agent spawns process, passes JSON via argv, reads stdout

### Other Implementations

Python-based implementation might:
- Use same 6 core built-in tools
- Implement external tools as Python scripts
- Use different discovery mechanism
- Follow same JSON protocol

The hybrid pattern is framework-level guidance, not a strict requirement.

---

## Security Considerations

**Built-in tools**:
- Run in agent's sandbox
- Subject to path restrictions
- Require user confirmation for destructive operations
- Can be disabled via configuration

**External tools**:
- Run in separate processes
- Inherit sandbox restrictions (if enforced at process level)
- Should validate inputs (don't trust LLM output blindly)
- Should limit resource usage (memory, CPU, network)

---

## References

- **Bootstrap spec**: [../specs/ybs-spec.md](../specs/ybs-spec.md) Section 3 (Tools)
- **Architectural decision**: [../specs/ybs-decisions.md](../specs/ybs-decisions.md) D04 (Hybrid Tool Architecture)
- **Security model**: [security-model.md](security-model.md)

---

**Version History**:
- 0.1.0 (2026-01-17): Initial canonical reference extracted from distributed documentation
