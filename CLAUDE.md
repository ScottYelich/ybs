# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Repository Overview

**YBS = Meta-Framework**: A system for building systems that build systems.

This repository contains:

1. **YBS Meta-Framework** - Language-agnostic specifications for building AI agent systems
   - Generic build framework (step-by-step instructions in docs/build-from-scratch/)
   - Specification templates and patterns
   - Architecture for tool-based AI agents

2. **Bootstrap Implementation Specs** - First reference implementation (Swift/macOS)
   - Complete technical specification (docs/specs/system/)
   - Architectural decisions and implementation checklist
   - Used to validate the framework and demonstrate completeness

**Current Phase**: Framework evolution (Claude + Human refining specifications)
**Next Phase**: Bootstrap implementation (use YBS to build YBS in Swift)
**Note**: The Swift specs are ONE possible implementation, not THE only way

---

## How YBS Works

**YBS is a methodology that provides sufficient specifications and details for an AI agent to build ANY system autonomously.**

The framework uses structured files to guide AI agents (like Claude) through building complete systems - calculators, web apps, AI agents, databases, compilers, anything:

### 1. Specifications (`docs/specs/`)
Define WHAT to build:
- Technical specs, architectural decisions, requirements
- Example: `docs/specs/system/ybs-spec.md` defines the Swift chat tool
- Can specify ANY type of system (web apps, CLI tools, AI agents, databases, etc.)

### 2. Build Steps (`docs/build-from-scratch/`)
Define HOW to build it:
- Step-by-step instructions AI agents can execute autonomously
- Each step has: objectives, instructions, verification, traceability to specs
- Steps are language-agnostic and guide the AI agent through the build

### 3. AI Agent Execution (You, Claude!)
Tool-using LLM reads steps and executes them:
- Uses tools: read files, write code, run commands, search, edit, etc.
- Follows specifications and architectural decisions
- Builds system from scratch to completion
- Documents progress and maintains traceability

### 4. Output (`builds/SYSTEMNAME/`)
Complete working system:
- Fully functional code
- Build history and documentation
- Traceable to specs and steps
- Tests and verification

### Current Usage

**We're using YBS to build a Swift-based LLM chat tool (the "bootstrap").** This:
- Tests and validates that the YBS framework works
- Helps refine the methodology through practical use
- Demonstrates that an AI agent (Claude) can build a complete system from specs alone
- The bootstrap HAPPENS to be an AI agent, but YBS could just as easily build a calculator, web server, or anything else

**Key Point**: YBS can guide building ANY system - the methodology provides sufficient detail for autonomous development regardless of what's being built.

---

## Repository Structure

```
ybs/
├── CLAUDE.md                          # This file - guidance for Claude Code
├── SESSION.md                         # [TRANSIENT] Active session scratchpad (crash recovery)
├── SESSION.md.template                # Template for creating SESSION.md
├── scratch/                           # [TRANSIENT] Session work files directory
├── LICENSE                            # MIT License
├── bin/                               # Centralized helper scripts
│   ├── list-specs.sh                 # List specifications by GUID
│   ├── deps.sh                       # Show dependency tree for specs
│   ├── list-steps.sh                 # List build steps in order
│   └── list-changelogs.sh            # List session changelogs
├── builds/                            # OUTPUT: Systems built with YBS
│   └── test1/                        # Example experimental build
└── docs/
    ├── README.md                      # Documentation index and navigation hub
    ├── changelogs/                    # Session-based change tracking
    │   ├── README.md                  # Changelog system documentation
    │   └── YYYY-MM-DD_<guid>.md      # Individual session changelogs
    ├── specs/
    │   ├── system/                    # Bootstrap implementation specs (Swift/macOS)
    │   │   ├── ybs-spec.md            # Complete technical specification
    │   │   ├── ybs-decisions.md       # Architectural decisions
    │   │   └── ybs-lessons-learned.md # Implementation checklist
    │   ├── business/                  # Business specs per feature (future)
    │   ├── functional/                # Functional specs per feature (future)
    │   ├── technical/                 # Technical specs per feature (future)
    │   └── testing/                   # Testing specs per feature (future)
    ├── build-from-scratch/           # Generic build framework (language-agnostic)
    └── usage/                         # End-user documentation (future)
```

## For Claude Code Agents

**What are you doing? Identify your task:**

### → **Working on the YBS Framework Itself** (docs/)
You're helping evolve the meta-framework:
- Read this file for overview
- You're defining specifications and patterns
- Focus on language-agnostic concepts
- Goal: Make the framework better for building ANY system

**Key files:**
- docs/README.md - Framework documentation
- docs/build-from-scratch/ - Step framework
- ANALYSIS.md - Framework improvements

---

### → **Editing Bootstrap Specifications** (docs/specs/system/)
You're working on the Swift chat tool specs:
- Reference ybs-spec.md, ybs-decisions.md, ybs-lessons-learned.md
- These are Swift/macOS specific (one example system)
- You're defining WHAT the bootstrap will be

**Remember:** These specs are for the bootstrap, not YBS itself.

---

### → **Executing Build Steps** (using build-from-scratch framework)
You're building a system using YBS:
- **Read `docs/build-from-scratch/CLAUDE.md`** for detailed workflow
- Follow steps in order, maintain traceability
- Use specifications as reference
- Document your work

**This is YBS in action!** You're the AI agent building a system autonomously.

---

### → **Working in a Specific Build** (builds/SYSTEMNAME/)
You're in an active build workspace:
- Read `builds/SYSTEMNAME/CLAUDE.md` for system-specific guidance
- Check `BUILD_STATUS.md` for current status
- Each build has its own context and requirements

---

## 🚨 CRITICAL: Session File Crash-Recovery System

**Claude crashes frequently. You MUST maintain a session scratchpad for crash recovery.**

### Mandatory Session File Protocol

**ALWAYS follow this protocol at the start of ANY session:**

1. **Check for SESSION.md** - If it exists, a previous session crashed:
   ```bash
   ls -la SESSION.md 2>/dev/null
   ```
   - **If found**: Read it, understand the context, resume from where it left off
   - **If not found**: Create a new SESSION.md using the template file

2. **Update SESSION.md regularly** - After EVERY significant action:
   - After reading files
   - After making edits
   - After running commands
   - Before starting complex operations
   - Update the todo list status

3. **Clean up on completion** - When session ends successfully:
   - **If working on a build step**: Move SESSION.md → `builds/SYSTEMNAME/step-result_GUID.md`
   - **If NOT working on a step**: Delete SESSION.md
   - Never leave SESSION.md if session completed normally

### SESSION.md Template

**Use the template file**: Copy `SESSION.md.template` to create your SESSION.md

```bash
# At start of session (if no SESSION.md exists):
cp SESSION.md.template SESSION.md
# Then edit SESSION.md with current session details
```

**Template contents** (see SESSION.md.template for full template):
- Session ID (timestamp + 12-hex GUID)
- Context (what you're working on)
- Action Plan (high-level steps)
- Current Todo List (specific tasks)
- Progress Log (timestamped actions)
- Files Modified (track all changes)
- Next Steps (recovery instructions)
- Notes (important context/decisions)

### Why This Matters

Claude Code crashes frequently due to:
- Token limits
- Network timeouts
- Unexpected errors
- Context overflows

Without SESSION.md:
- ❌ Human must explain context again
- ❌ Work is lost or duplicated
- ❌ No clear recovery path

With SESSION.md:
- ✅ Next Claude session resumes instantly
- ✅ No work is lost
- ✅ Clear state of what's done/pending
- ✅ Human doesn't need to re-explain

### Examples

**Good - Start of session:**
```
1. Check for SESSION.md
2. If found, read it and resume
3. If not found, create it with current task
4. Update it after each major action
```

**Good - During work:**
```
1. Read file → Update SESSION.md progress
2. Edit file → Update SESSION.md progress
3. Run command → Update SESSION.md progress
4. Before complex operation → Update SESSION.md with "about to do X"
```

**Good - End of session:**
```
1. Mark all todos as completed in SESSION.md
2. Update status to "completing"
3. If working on build step: Move to builds/SYSTEMNAME/step-result_GUID.md
4. If not on build step: Delete SESSION.md
```

### Repository Structure Update

```
ybs/
├── SESSION.md                         # [TRANSIENT] Active session scratchpad
├── CLAUDE.md                          # This file
├── LICENSE                            # MIT License
├── bin/                               # Centralized helper scripts
└── ...
```

**SESSION.md is transient** - It should only exist during active work, never in commits.

---

## 🗂️ CRITICAL: Session Work Files Directory

**Use `scratch/` directory for all session working files. Clean up when done.**

### Mandatory Work Files Protocol

**ALWAYS follow this protocol for temporary/working files:**

1. **Use scratch/ directory** - ALL temporary session files go here:
   ```bash
   mkdir -p scratch
   ```

   **What goes in scratch/**:
   - Analysis documents (like ANALYSIS.md)
   - Working drafts and notes
   - Temporary data files
   - Session artifacts
   - Any file that's NOT part of the deliverable

2. **Never commit scratch/** - Already in .gitignore
   - scratch/ should NEVER appear in git commits
   - These are transient working files only
   - If a file needs to be permanent, move it out of scratch/

3. **Clean up when done** - After EVERY successful step/session:
   ```bash
   # When step/session completes successfully:
   rm -rf scratch/*
   # Or delete specific files:
   rm scratch/analysis.md scratch/draft.txt
   ```

   **When to clean up:**
   - ✅ After completing a build step
   - ✅ After finishing a session successfully
   - ✅ Before committing final work
   - ✅ When working files are no longer needed

   **When NOT to clean up:**
   - ❌ If session crashes (leave for next session)
   - ❌ If step is blocked/incomplete
   - ❌ If files needed for debugging

### Directory Structure

```
ybs/
├── SESSION.md              # Current session status (root level)
├── SESSION.md.template     # Template file (committed)
└── scratch/                # All temporary work files (NEVER committed)
    ├── analysis.md         # Example: working analysis
    ├── draft-spec.md       # Example: draft before final
    ├── notes.txt           # Example: session notes
    └── data.json           # Example: temporary data
```

### Why This Matters

**Without scratch/ directory:**
- ❌ Working files clutter repository root
- ❌ Risk of accidentally committing analysis/draft files
- ❌ Unclear which files are deliverables vs working files
- ❌ Repository gets messy over time

**With scratch/ directory:**
- ✅ Clean repository root (only deliverables)
- ✅ .gitignore prevents accidental commits
- ✅ Clear separation: deliverables vs working files
- ✅ Easy cleanup (rm -rf scratch/*)
- ✅ Consistent pattern across all sessions

### Examples

**Good - Using scratch/:**
```bash
# Start analysis
mkdir -p scratch
echo "Analysis findings..." > scratch/analysis.md

# Do work, create final deliverables in proper locations
echo "Final content" > docs/new-document.md

# Clean up when done
rm -rf scratch/*
git add docs/new-document.md
git commit -m "Add new document"
```

**Bad - Cluttering root:**
```bash
# DON'T DO THIS
echo "Analysis..." > ANALYSIS.md  # Wrong - clutters root
echo "Draft..." > DRAFT.md        # Wrong - risk of committing
# Later: accidentally commit these files
git add ANALYSIS.md  # Oops!
```

---

## Bootstrap Implementation Overview (Swift/macOS)

### Core Documentation (docs/specs/system/)

Three foundational documents define the bootstrap implementation:

- **ybs-spec.md** - Complete technical specification (Swift/macOS architecture, tools, config, security)
- **ybs-decisions.md** - Architectural Decision Records explaining design choices for Swift implementation
- **ybs-lessons-learned.md** - Implementation checklist from industry research (applicable to any language)

## Key Architecture Principles (Framework-Level)

### Core Design Tenets (for systems built with YBS)
1. **Local-first**: All tool execution happens locally; LLM can be local or remote
2. **Minimal dependencies**: Use language standard library where possible
3. **Extensible**: Tools can be added without recompiling
4. **Secure by default**: Sandboxed shell execution, confirmation for destructive operations
5. **Simple core**: Agent loop should be understandable in <100 lines

### Tool Architecture (Hybrid Approach)
- **Built-in tools** (core set): File I/O, file discovery, shell execution
  - Compiled into agent binary for security, performance, and tight integration
  - Bootstrap uses 6: `read_file`, `write_file`, `edit_file`, `list_files`, `search_files`, `run_shell`
- **External tools**: Runtime-loaded executables following simple JSON protocol
  - Examples: `web_search`, `web_fetch`, project-specific test runners
  - Protocol: executable receives JSON via argv, outputs JSON to stdout
  - Language-agnostic (any language that can handle JSON I/O)

### Configuration System (Bootstrap Implementation)
Layered config resolution (later overrides earlier):
1. `/etc/ybs/config.json` (system-wide)
2. `~/.config/ybs/config.json` (user defaults)
3. `~/.ybs.json` (user home)
4. `./.ybs.json` (project-specific)
5. `--config <path>` (CLI override)

Other implementations may use different paths or formats.

### Security Model (Bootstrap Implementation)
- **Path sandboxing**: All file operations restricted to allowed directories
- **Shell sandboxing**: macOS uses `sandbox-exec` with restrictive profile (deny-by-default)
- **Confirmation required**: `write_file`, `run_shell`, destructive operations need user approval
- **Session allow-list**: User can approve tool for current session only (not persisted)

Other implementations should follow similar principles but may use different mechanisms (e.g., seccomp on Linux, process isolation, etc.).

### Edit Format
Uses SEARCH/REPLACE blocks (not whole-file rewrites or line-based edits):
- LLMs hallucinate line numbers, so no line-number-based edits
- Forces LLM to read file first to get exact content
- SEARCH text must be unique in file (catches hallucinations)
- Fuzzy matching handles minor whitespace differences

## Bootstrap Implementation Structure (When Built)

From ybs-spec.md (Swift/macOS specific):
```
builds/ybs-swift/
├── Package.swift                  # Swift package definition
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

This is the Swift implementation. Implementations in other languages will have different structures.

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
- Stateless sessions: no persistence between runs (tools access filesystem, git, databases as needed)
