# YDS Documentation

Welcome to the YDS documentation hub.

## What's in This Repository

This repository has two main components:

### 1. YBS Specification (specs/)
**WHAT to build** - Complete design for a local-first AI coding assistant

- System-wide technical specifications
- Feature specifications by category (business, functional, technical, testing)
- Architectural decisions
- Implementation checklist

### 2. Build Framework (build-from-scratch/)
**HOW to build it** - Generic step-by-step instructions

- Can implement YBS specification
- Can create a different system entirely
- Outputs go to `../builds/SYSTEMNAME/`

### Relationship: Specs ↔ Steps

**Critical**: Specs and steps must stay synchronized.

- Each step references which spec sections it implements
- When creating steps, reference specs/system/ sections
- When updating specs, update affected steps
- All spec functionality needs corresponding steps
- See [build-from-scratch/CLAUDE.md](build-from-scratch/CLAUDE.md#step-to-spec-traceability) for details

---

## Documentation Organization

### 📋 Specifications (`specs/`)

Organized by type with traceability across perspectives:

#### System-Wide (`specs/system/`)
Core design documents that define what YBS is and how it should be built:

- **[ybs-spec.md](specs/system/ybs-spec.md)** - Complete technical specification
  - System architecture and design principles
  - Tool definitions (built-in and external)
  - Configuration schema and file resolution
  - Agent loop pseudocode
  - LLM provider abstraction
  - Security implementation details
  - Project structure and dependencies

- **[ybs-decisions.md](specs/system/ybs-decisions.md)** - Architectural Decision Records (ADRs)
  - 15 key architectural decisions with rationale
  - Alternatives considered for each decision
  - Trade-offs and implications
  - Reference when questioning "why did we do it this way?"

- **[ybs-lessons-learned.md](specs/system/ybs-lessons-learned.md)** - Implementation checklist
  - Comprehensive checklist derived from Aider, Goose, OpenHands, Cursor, and other AI coding agents
  - Critical failure modes to prevent
  - Recommended defaults for all settings
  - Testing strategies
  - Use as a validation checklist during implementation

#### Feature Specifications
Each feature gets a 12-hex GUID with specs across multiple categories:
- **business/** - Business value, user stories, success metrics
- **functional/** - Features, workflows, behavior specifications
- **technical/** - Implementation details, APIs, dependencies
- **testing/** - Test plans, test cases, acceptance criteria
- **security/**, **operations/**, **architecture/** - Additional perspectives as needed

See [specs/README.md](specs/README.md) for complete overview.

### 🔨 Build Framework (`build-from-scratch/`)

Step-by-step instructions for building LLM coding assistant systems.

**Structure:**
- Sequential step files (step_000000.md, step_000001.md, etc.)
- Each step has objectives, instructions, and verification
- CLAUDE.md for AI agents executing steps
- README.md for human developers

**Output:** Builds go to `../builds/SYSTEMNAME/` (working directory, not source)

### 📖 User Documentation (`usage/`)

*[Planned]* Documentation for end-users running YDS.

**Proposed structure:**
- Installation instructions
- Quick start guide
- Configuration reference
- CLI commands
- Built-in and external tools
- Troubleshooting guide

## Navigation by Task

### 🏗️ Implement YBS (using the build framework)

1. Read [ybs-spec.md](specs/system/ybs-spec.md) - understand WHAT to build
2. Read [ybs-decisions.md](specs/system/ybs-decisions.md) - understand WHY designed this way
3. Use [build-from-scratch/](build-from-scratch/) - follow HOW to build it
4. Check [ybs-lessons-learned.md](specs/system/ybs-lessons-learned.md) - validation checklist

### 🧪 Understand YBS architecture

Read in order:
1. [ybs-spec.md](specs/system/ybs-spec.md) sections 1-2 (Overview, Configuration)
2. [ybs-decisions.md](specs/system/ybs-decisions.md) D01-D15 (all decisions)
3. [ybs-spec.md](specs/system/ybs-spec.md) sections 6-7 (Agent Loop, LLM Providers)

### 🔧 Modify YBS specification

Before making changes:
1. Review [ybs-decisions.md](specs/system/ybs-decisions.md) - check for conflicts
2. Update [ybs-spec.md](specs/system/ybs-spec.md) - modify the spec
3. Add ADR to [ybs-decisions.md](specs/system/ybs-decisions.md) if architectural
4. Update [ybs-lessons-learned.md](specs/system/ybs-lessons-learned.md) if relevant

### 🤖 Claude Code: Execute build steps

→ Read [build-from-scratch/CLAUDE.md](build-from-scratch/CLAUDE.md) for workflow

### 👤 Use a built system

→ Check `../builds/SYSTEMNAME/README.md` for that specific build

## Current Status

**Project Phase**: Specification complete, implementation not started

**What exists:**
- ✅ Complete technical specification
- ✅ Architectural Decision Records
- ✅ Implementation checklist from industry research
- ✅ Documentation structure

**What's next:**
- 🔄 Create build-from-scratch guides
- 🔄 Begin Swift implementation
- 🔄 Create user documentation as features are built

## Key Concepts

### What is YDS?

YDS is a command-line AI coding assistant that:
- Executes **locally** (all tools run on your machine)
- Supports **local or remote LLMs** (Ollama, OpenAI, Anthropic, etc.)
- Uses **hybrid tool architecture** (6 built-in + unlimited external tools)
- Implements **security by default** (sandboxed execution, confirmation for destructive ops)
- Maintains **simple, understandable core** (agent loop < 100 lines)

### Design Philosophy

1. **Local-first** - Your code stays on your machine
2. **Minimal dependencies** - Swift stdlib + 2-3 packages
3. **Extensible** - Add tools without recompiling
4. **Secure** - Sandboxed shell, path restrictions, user confirmation
5. **Simple** - Core logic should be human-readable

## Documentation Standards

When contributing to this documentation:

- **Use relative links** between docs (enables offline browsing)
- **Reference line numbers** for spec locations (e.g., "see yds-spec.md:723-778")
- **Update index** (this file) when adding new documents
- **Keep examples concrete** with actual code snippets
- **Explain the "why"** not just the "what"

## Resources

### Related Projects Studied
- [Aider](https://aider.chat) - Search/replace edit format inspiration
- [Goose](https://github.com/block/goose) - MCP integration patterns
- [OpenHands](https://github.com/All-Hands-AI/OpenHands) - Loop detection strategies
- [Cursor](https://cursor.sh) - Context management insights

### Key Technologies
- **Swift** - Implementation language (macOS 14+)
- **Ollama** - Default local LLM backend
- **sandbox-exec** - macOS sandboxing (Linux: bubblewrap/firejail)
- **OpenAI API** - Provider abstraction baseline

---

**Last updated**: 2026-01-16
**Documentation version**: 1.0
**Status**: Pre-implementation (specification phase)
