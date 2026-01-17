# YBS Documentation

Welcome to the YBS documentation hub.

## What's in This Repository

This repository has two main components:

### 1. YBS Meta-Framework (specs/ + build-from-scratch/)
**A methodology that provides sufficient details for AI agents to build ANY system autonomously**

The YBS framework enables tool-using AI agents (like Claude) to build complete software systems (calculators, web apps, AI agents, databases, anything) from scratch to completion without human intervention.

**How it works:**
- **Specifications (specs/)** - Define WHAT to build
  - Technical specifications, architectural decisions, requirements
  - Can specify ANY type of system (web apps, CLI tools, AI agents, etc.)
- **Build Steps (build-from-scratch/)** - Define HOW to build it
  - Step-by-step instructions AI agents can execute autonomously
  - Each step: objectives, instructions, verification, traceability
- **AI Agent Execution** - Tool-using LLM reads steps and builds system
  - Uses tools: read files, write code, run commands, etc.
  - Follows specifications and steps
- **Output (builds/)** - Complete working system with full traceability

### 2. Bootstrap Implementation (specs/system/ + builds/test1/)
**Example: Using YBS to build a Swift-based LLM chat tool**

To test and validate the YBS framework, we're having Claude build a tool-using AI chat system for macOS (similar to Aider, but in Swift).

- **Specs (specs/system/)** - Complete specifications for the Swift chat tool
  - ybs-spec.md - Technical specification
  - ybs-decisions.md - Architectural decisions
  - ybs-lessons-learned.md - Implementation checklist
- **Build (builds/test1/)** - Work in progress using the YBS framework

**Key Insight**: The Swift chat tool is ONE example of what YBS can build. YBS is the framework, not the tool itself.

### Relationship: Specs ↔ Steps

**Critical**: Specs and steps must stay synchronized.

- Each step references which spec sections it implements
- When creating steps, reference specs/ sections
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

*[Planned]* Documentation for end-users running YBS.

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

**Project Phase**: Framework evolution + Bootstrap implementation starting

**YBS Framework (Meta-Framework):**
- ✅ Core methodology defined
- ✅ Documentation structure established
- ✅ Specification templates and patterns
- ✅ Build step framework (build-from-scratch/)
- ✅ Helper scripts and tooling
- 🔄 Refining through bootstrap validation

**Bootstrap Implementation (Swift Chat Tool):**
- ✅ Complete technical specification (100+ pages)
- ✅ 15 Architectural Decision Records
- ✅ Implementation checklist from industry research
- ✅ Build steps defined
- 🔄 Code implementation (using YBS framework)
- ❌ User documentation (future)

**What's next:**
- Continue building bootstrap using YBS framework
- Validate and refine framework based on experience
- Document patterns and best practices

## Key Concepts

### What is YBS?

**YBS is a methodology that provides sufficient specifications and details for an AI agent to build ANY system autonomously.**

It's a system of structured files (specs, steps, decisions, checklists) that enable tool-using AI agents like Claude to build complete software systems (calculators, web apps, AI agents, compilers, anything) from scratch to completion without human intervention.

**How It Works:**
1. **Specs define WHAT to build** - Technical specifications, architectural decisions, requirements
2. **Steps define HOW to build it** - Detailed instructions AI agents can follow autonomously
3. **AI agent executes steps** - Tool-using LLM (Claude, etc.) reads steps and builds the system
4. **System is built** - From initialization to completion, guided by the framework

**Current Project:** We're testing YBS by having Claude build a Swift-based LLM chat tool (the "bootstrap"). This validates that the framework provides sufficient detail for autonomous development. The bootstrap HAPPENS to be an AI agent, but YBS could just as easily guide building a calculator, web server, or anything else.

**Key Insight:** YBS is NOT the Swift chat tool. YBS is the FRAMEWORK (methodology + structured files) that enables building it autonomously.

### The Bootstrap Implementation

The first system being built WITH YBS is a command-line AI agent (reasoning + tool using LLM chat) that:
- Executes **locally** (all tools run on your machine)
- Supports **local or remote LLMs** (Ollama, OpenAI, Anthropic, etc.)
- Uses **hybrid tool architecture** (6 built-in + unlimited external tools)
- Implements **security by default** (sandboxed execution, confirmation for destructive ops)
- Maintains **simple, understandable core** (agent loop < 100 lines)

### Bootstrap Design Philosophy

The Swift chat tool (bootstrap) follows these principles:

1. **Local-first** - Your code stays on your machine
2. **Minimal dependencies** - Swift stdlib + 2-3 packages
3. **Extensible** - Add tools without recompiling
4. **Secure** - Sandboxed shell, path restrictions, user confirmation
5. **Simple** - Core logic should be human-readable

These principles are specific to the bootstrap. Systems built with YBS can follow different principles.

## Documentation Standards

When contributing to this documentation:

- **Use relative links** between docs (enables offline browsing)
- **Reference line numbers** for spec locations (e.g., "see ybs-spec.md:723-778")
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
