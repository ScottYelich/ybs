# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Repository Overview

This repository contains:

1. **YBS Specification** - Complete design for a local-first AI coding assistant
2. **Build Framework** - Generic step-by-step system builder for creating LLM coding assistants

**Note**: YBS itself is not yet implemented. The specs define WHAT to build, the framework provides HOW to build it.

## Repository Structure

```
ybs/
├── CLAUDE.md                          # This file - guidance for Claude Code
├── bin/                               # Centralized helper scripts
│   ├── list-specs.sh                 # List specifications by GUID
│   ├── deps.sh                       # Show dependency tree for specs
│   └── list-steps.sh                 # List build steps in order
├── builds/                            # OUTPUT: Working directory for builds (not source)
└── docs/
    ├── README.md                      # Documentation index and navigation hub
    ├── specs/
    │   ├── system/                    # System-wide specifications
    │   │   ├── ybs-spec.md            # YBS technical specification
    │   │   ├── ybs-decisions.md       # YBS architectural decisions
    │   │   └── ybs-lessons-learned.md # Implementation checklist
    │   ├── business/                  # Business specs per feature
    │   ├── functional/                # Functional specs per feature
    │   ├── technical/                 # Technical specs per feature
    │   └── testing/                   # Testing specs per feature
    ├── build-from-scratch/           # Generic build framework (step-by-step)
    └── usage/                         # End-user documentation (future)
```

## For Claude Code Agents

**What are you doing?**

→ **Editing YBS specs** (docs/specs/)
  - Read this file for YBS architecture overview
  - Reference system/ybs-spec.md, system/ybs-decisions.md, system/ybs-lessons-learned.md

→ **Executing build steps** (using build-from-scratch framework)
  - Read `docs/build-from-scratch/CLAUDE.md` instead
  - That file has detailed workflow for step execution

→ **Working in a specific build** (builds/SYSTEMNAME/)
  - Read `builds/SYSTEMNAME/CLAUDE.md` instead
  - Each build has its own guidance file

---

## YBS Specification Overview

### Core Documentation (docs/specs/system/)

Three foundational documents define YBS:

- **ybs-spec.md** - Complete technical specification (architecture, tools, config, security)
- **ybs-decisions.md** - Architectural Decision Records explaining design choices
- **ybs-lessons-learned.md** - Implementation checklist from industry research

## Key Architecture Principles

### Core Design Tenets
1. **Local-first**: All tool execution happens locally; LLM can be local or remote
2. **Minimal dependencies**: Use Swift standard library and Foundation where possible
3. **Extensible**: Tools can be added without recompiling
4. **Secure by default**: Sandboxed shell execution, confirmation for destructive operations
5. **Simple core**: Agent loop should be understandable in <100 lines

### Tool Architecture (Hybrid Approach)
- **Built-in tools** (6 core): `read_file`, `write_file`, `edit_file`, `list_files`, `search_files`, `run_shell`
  - Compiled into binary for security, performance, and tight integration
- **External tools**: Runtime-loaded executables following simple JSON protocol
  - Examples: `web_search`, `web_fetch`, project-specific test runners
  - Protocol: executable receives JSON via argv, outputs JSON to stdout

### Configuration System
Layered config resolution (later overrides earlier):
1. `/etc/ybs/config.json` (system-wide)
2. `~/.config/ybs/config.json` (user defaults)
3. `~/.ybs.json` (user home)
4. `./.ybs.json` (project-specific)
5. `--config <path>` (CLI override)

### Security Model
- **Path sandboxing**: All file operations restricted to allowed directories
- **Shell sandboxing**: macOS uses `sandbox-exec` with restrictive profile (deny-by-default)
- **Confirmation required**: `write_file`, `run_shell`, destructive operations need user approval
- **Session allow-list**: User can approve tool for current session only (not persisted)

### Edit Format
Uses SEARCH/REPLACE blocks (not whole-file rewrites or line-based edits):
- LLMs hallucinate line numbers, so no line-number-based edits
- Forces LLM to read file first to get exact content
- SEARCH text must be unique in file (catches hallucinations)
- Fuzzy matching handles minor whitespace differences

## Project Structure (When Implemented)

From ybs-spec.md:723-778:
```
ybs/
├── Package.swift
├── Sources/ybs/
│   ├── main.swift                 # Entry point, CLI parsing
│   ├── Config/                    # Configuration loading
│   ├── Agent/                     # Core agent loop
│   ├── LLM/                       # Provider abstraction
│   ├── Tools/                     # Built-in and external tools
│   ├── Security/                  # Sandboxing and permissions
│   └── UI/                        # Terminal display
├── Tools/                         # External tool examples
└── Tests/                         # Unit and integration tests
```

## Critical Implementation Checklist

When implementing YBS, refer to **docs/specs/system/ybs-lessons-learned.md** for comprehensive checklist covering:

### Context Management
- Token budget with auto-compaction at 95% capacity
- Truncate tool outputs to 10k chars max
- Repo map limited to ~1k tokens

### Tool Execution
- All tools have timeouts (30s default)
- Structured error returns (not raw exceptions)
- JSON repair/fuzzy parsing for malformed LLM output

### Agent Loop
- Max 25 iterations to prevent runaway loops
- Repetition detection (same tool call 3+ times = stuck)
- Graceful error recovery (don't crash, let LLM adapt)

### Safety (CRITICAL)
- Sandbox blocks access to `~/.ssh`, `~/.aws`, `~/.config`
- Blocked commands: `rm -rf /`, `sudo`, `chmod 777`
- Network isolation in sandbox by default
- Path traversal prevention

## Dependencies

**Required**:
- Foundation (built-in)
- swift-argument-parser (~1.3.0)
- AsyncHTTPClient (~1.20.0) or URLSession

**Optional**:
- ripgrep (external, for faster search with fallback to native)

## LLM Provider Support

Provider abstraction using OpenAI-compatible API format:
- **Ollama**: Local, free, default choice (`http://localhost:11434`)
- **OpenAI**: Cloud, requires API key
- **Anthropic**: Cloud, requires API key, needs format mapping
- **OpenAI-compatible**: LocalAI, LM Studio, etc.

## Design Decisions Reference

For detailed rationale behind any design choice, consult **docs/specs/system/ybs-decisions.md**. Key decisions:

- **D01**: Swift chosen for native macOS integration, fast startup, single binary
- **D04**: Hybrid tool architecture (built-in + external) for security and extensibility
- **D08**: SEARCH/REPLACE edit format to avoid line number hallucinations
- **D09**: macOS `sandbox-exec` for kernel-enforced filesystem/network isolation
- **D13**: No state persistence between sessions (stateless design)
- **D15**: Graceful degradation on errors (never crash)

## Working with This Repository

### Adding Features to Spec
When proposing changes to the specification:
1. Check if it contradicts existing architectural decisions
2. Update relevant sections in docs/specs/system/ybs-spec.md
3. Add new decision to docs/specs/system/ybs-decisions.md if architectural
4. Update docs/specs/system/ybs-lessons-learned.md checklist if it addresses a known pitfall

### Starting Implementation
When beginning to implement:
1. Create Swift Package with dependencies listed in docs/specs/system/ybs-spec.md
2. Follow project structure from docs/specs/system/ybs-spec.md
3. Use docs/specs/system/ybs-lessons-learned.md as implementation checklist
4. Refer to docs/specs/system/ybs-decisions.md when questioning "why this way?"

### Testing Strategy
Success criteria (docs/specs/system/ybs-spec.md):
- Load layered configuration
- Connect to Ollama and complete basic chat
- Execute all 6 built-in tools
- Enforce path sandboxing
- Require confirmation for destructive operations
- Detect and break infinite loops
- Stream responses
- Load external tools

## Important Notes

- **No code exists yet** - this is purely specification phase
- Default model: Ollama with qwen3:14b (local, free)
- Target: macOS 14+ (Linux support future)
- Design is deliberately simple: core agent loop should be <100 lines
- Stateless sessions: no persistence between runs (git is the state)
