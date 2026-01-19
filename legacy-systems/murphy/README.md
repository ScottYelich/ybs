# Murphy - AI Chat Tool with First-Class YBS Support

**Version**: 1.0.0
**Last Updated**: 2026-01-18

📍 **You are here**: YBS Repository > Legacy Systems > Murphy
**Status**: ⚠️ **To be extracted to separate repository**

---

## What is Murphy?

**Murphy is a Swift-based AI chat tool (LLM coding assistant) for macOS with first-class YBS build system support.**

Named after Murphy's Law ("Anything that can go wrong, will go wrong"), Murphy is your AI pair programmer that helps you handle what goes wrong during development.

---

## 🚨 Repository Status

**This directory will be moved to a separate repository**: `github.com/ScottYelich/murphy`

**Current location**: `legacy-systems/murphy/` (temporary, within YBS repo)

**Future location**: Standalone repository with YBS integration

**Why separate?**
- Murphy is a general-purpose AI chat tool (not YBS-specific)
- Can be used for any development tasks, not just YBS builds
- YBS framework works with any AI agent (Murphy is the reference implementation)
- **Option B Architecture**: YBS (framework) + Murphy (agent) = separate but tightly integrated

---

## Murphy + YBS: The Perfect Pair

**YBS Framework** provides:
- Specifications (what to build)
- Build steps (how to build)
- Configuration system
- Verification requirements

**Murphy** provides:
- AI execution engine (reads and executes YBS steps)
- Tool use (git, swift, npm, docker, etc.)
- Streaming responses (real-time feedback)
- Context management (handles large builds)
- Local execution (works with Ollama, no API costs)

**Together**:
```bash
# Install both
brew install ybs murphy

# Create system with YBS
cd my-system
ybs init

# Execute with Murphy
murphy build

# Murphy automatically:
# - Reads BUILD_CONFIG.json
# - Executes YBS steps sequentially
# - Verifies each step
# - Handles retries
# - Shows streaming progress
```

**But also separate**: Use YBS with Claude CLI, OpenAI assistants, or any AI agent. Use Murphy for non-YBS tasks.

---

## History: Originally Called "Bootstrap"

This project was originally named "bootstrap" because it was the **first system built WITH the YBS framework** to validate the methodology ("pulling yourself up by your bootstraps").

**Renamed to Murphy** (2026-01-18):
- **Reason**: Avoid naming confusion with YBS framework, reflect Murphy's Law theme
- **Git history**: Fully preserved via `git mv`
- **Purpose**: Clarified as general-purpose AI chat tool, not YBS-only

---

## Purpose

### Primary Goal: Reference AI Agent for YBS

Murphy serves as the reference implementation showing how AI agents can work with YBS:

- **Execute YBS builds**: Read specs, execute steps, verify results
- **Configuration-first**: Honors BUILD_CONFIG.json
- **Autonomous execution**: No prompts after Step 0
- **Demonstrates completeness**: AI agents can build complex systems end-to-end

### Secondary Goal: General-Purpose AI Chat Tool

Murphy is also a functional AI coding assistant for any task:

- Command-line interface
- Local or remote LLMs (Ollama, OpenAI, Anthropic)
- Hybrid tool architecture (built-in + external tools)
- Security by default (sandboxed execution)
- macOS native (Swift)

---

## System Structure

```
murphy/
├── README.md                          # This file
├── CLAUDE.md                          # Guide for AI agents working on Murphy
├── specs/                             # System specifications
│   ├── README.md                      # Spec organization
│   ├── technical/
│   │   └── ybs-spec.md                # Complete technical specification
│   ├── architecture/
│   │   └── ybs-decisions.md           # Architectural Decision Records (ADRs)
│   └── general/
│       └── ybs-lessons-learned.md     # Implementation checklist
├── steps/                             # Build steps
│   ├── README.md                      # Step overview
│   ├── ybs-step_000000000000.md       # Step 0: Build Configuration
│   ├── ybs-step_478a8c4b0cef.md       # Step 1: Initialize Build Workspace
│   └── ...                            # Steps 1-44
├── tools/                             # Helper scripts
│   ├── README.md                      # Tools documentation
│   └── searxng                        # SearXNG management script
├── docs/                              # Murphy-specific documentation
│   ├── murphy-principles.md           # Design principles (formerly bootstrap-principles.md)
│   ├── tool-architecture.md           # Hybrid tool system
│   ├── security-model.md              # Sandboxing and security
│   └── configuration.md               # Layered configuration system
└── builds/                            # Build outputs (transient workspaces)
    ├── test6/                         # Test build 6
    └── test7/                         # Test build 7 (current active)
```

---

## Quick Start

### For AI Agents: Build the Murphy System

1. **Read**: [CLAUDE.md](CLAUDE.md) - Complete AI agent guide for Murphy
2. **Start**: Execute [steps/ybs-step_000000000000.md](steps/ybs-step_000000000000.md) (Step 0: Configuration)
3. **Continue**: Follow steps autonomously until system is built

### For Humans: Understand Murphy

1. **Overview**: Read this file
2. **Design**: Read [docs/murphy-principles.md](docs/murphy-principles.md)
3. **Specs**: Read [specs/technical/ybs-spec.md](specs/technical/ybs-spec.md) - Complete technical specification
4. **Decisions**: Read [specs/architecture/ybs-decisions.md](specs/architecture/ybs-decisions.md) - Why designed this way

### For Contributors: Improve Murphy Specs/Steps

1. **Understand**: Read specs and steps thoroughly
2. **Identify gaps**: What's missing or ambiguous?
3. **Refine**: Update specs or steps to improve clarity
4. **Test**: Have AI agent attempt build with improvements

---

## Management Tools

Murphy includes helper scripts in `tools/` for managing dependencies and services.

### SearXNG Web Search Server

Murphy uses SearXNG for unlimited web searches. Manage it with:

```bash
# Start SearXNG (required for web_search tool to work)
./tools/searxng start

# Check status
./tools/searxng status

# Test search functionality
./tools/searxng test

# View logs
./tools/searxng logs

# Stop server
./tools/searxng stop

# Show all commands
./tools/searxng --help
```

**Details:**
- **URL**: http://127.0.0.1:38888
- **RAM**: ~30-50 MB
- **Limit**: Unlimited searches
- **Cost**: $0 (self-hosted)

**Installation**: Already configured in `~/.config/searxng/`

**See**: [tools/README.md](tools/README.md) for complete tools documentation

### External Tools Registration

Murphy auto-discovers external tools from these directories:
- `~/.config/ybs/tools` (system-wide, primary location)
- `~/.ybs/tools` (user-specific)
- `./tools` (project-specific)

**web_search Tool**:
- **Location**: `~/.config/ybs/tools/web_search`
- **Status**: ✅ Registered (auto-discovered at startup)
- **Protocol**: JSON input/output via stdin/stdout
- **Schema**: Supports `--schema` flag for discovery
- **Backend**: Queries SearXNG at http://127.0.0.1:38888

**How It Works**:
1. SearXNG server runs in background (managed by `./tools/searxng`)
2. Murphy discovers `web_search` tool at startup via `--schema` flag
3. LLM can call `web_search` tool during conversations
4. Tool queries SearXNG and returns results to LLM

**Testing External Tool**:
```bash
# Test tool directly
echo '{"query": "Swift programming", "max_results": 3}' | \
  ~/.config/ybs/tools/web_search | jq .

# Check tool schema
~/.config/ybs/tools/web_search --schema | jq .
```

**No manual registration required** - Murphy automatically discovers and loads all executable files in the tool search paths that implement the `--schema` flag.

---

## Murphy System Overview

### What It Does

A command-line AI coding assistant that:

- **Executes locally**: All tools run on your machine
- **Flexible LLM**: Local (Ollama) or remote (OpenAI, Anthropic)
- **Tool-based**: 6 built-in tools + unlimited external tools
- **Secure**: Sandboxed execution, confirmation for destructive ops
- **Simple core**: Agent loop < 100 lines
- **YBS-aware**: First-class support for executing YBS builds

### Technology Stack

- **Language**: Swift 5.9+
- **Platform**: macOS 14+
- **Package Manager**: Swift Package Manager (SPM)
- **Dependencies**:
  - swift-argument-parser (~1.3.0)
  - AsyncHTTPClient (~1.20.0)
- **LLM Providers**: Ollama (default), OpenAI, Anthropic

### Key Features

**Built-In Tools** (compiled):
- `read_file` - Read file contents
- `write_file` - Create/modify files
- `edit_file` - SEARCH/REPLACE edits
- `list_files` - Glob-based file discovery
- `search_files` - Content search (ripgrep or native)
- `run_shell` - Execute commands (sandboxed)

**External Tools** (runtime-loaded):
- Language-agnostic (any executable)
- JSON protocol (input via argv, output via stdout)
- Examples: web_search, web_fetch, project-specific tools

**YBS Integration** (future):
- `murphy build` - Execute YBS build from current directory
- `murphy step <N>` - Execute specific YBS step
- `murphy verify` - Run YBS verification for current step
- Native BUILD_CONFIG.json support
- Built-in understanding of YBS step format

**Configuration**:
- Layered config: System → User → Project → CLI
- Multiple file locations supported
- Provider-specific settings

**Security**:
- Path sandboxing (restricted file access)
- Shell sandboxing (sandbox-exec on macOS)
- Command blocklist (dangerous commands rejected)
- User confirmation (write_file, run_shell)
- Audit logging

---

## Design Principles

See [docs/murphy-principles.md](docs/murphy-principles.md) for complete principles. Summary:

1. **Local-First**: All tool execution happens locally
2. **Minimal Dependencies**: Swift stdlib + 2-3 packages
3. **Extensible**: Add tools without recompiling
4. **Secure by Default**: Sandboxed, confirmation required
5. **Simple Core**: Agent loop < 100 lines
6. **Provider-Agnostic**: Works with any LLM provider
7. **YBS-Friendly**: First-class support for YBS builds (but not YBS-only)

---

## Specifications

### Core Spec Documents

**[specs/technical/ybs-spec.md](specs/technical/ybs-spec.md)** - Complete technical specification (100+ pages)
- System architecture
- Tool definitions (built-in + external)
- Configuration schema
- Agent loop pseudocode
- LLM provider abstraction
- Security implementation
- Project structure

**[specs/architecture/ybs-decisions.md](specs/architecture/ybs-decisions.md)** - Architectural Decision Records (15 ADRs)
- D01: Swift chosen for native macOS integration
- D04: Hybrid tool architecture
- D08: SEARCH/REPLACE edit format
- D09: macOS sandbox-exec for shell isolation
- D13: Stateless sessions
- *(and 10 more)*

**[specs/general/ybs-lessons-learned.md](specs/general/ybs-lessons-learned.md)** - Implementation checklist
- Derived from Aider, Goose, OpenHands, Cursor
- Critical failure modes to prevent
- Recommended defaults
- Testing strategies

---

## Build Steps

Steps are in [steps/](steps/) directory:

- **Step 0**: Build Configuration (collect all settings upfront)
- **Step 1**: Initialize Build Workspace
- **Step 2**: Define Architecture
- **Step 3**: Set Up Project Environment
- *(44+ steps total)*

Each step includes:
- Objectives (what to accomplish)
- Instructions (how to do it)
- Verification (how to confirm success)
- Traceability (which specs it implements)

---

## Current Status

**Phase**: Active development using YBS framework

**Completed**:
- ✅ Complete technical specification (specs/)
- ✅ 15 Architectural Decision Records
- ✅ Implementation checklist from industry research
- ✅ Build steps (0-44 defined)
- ✅ Working builds: Swift package created, compiles successfully
- ✅ Core functionality implemented (test7 build)

**In Progress**:
- 🔄 Feature refinements
- 🔄 Testing suite expansion
- 🔄 YBS-specific integration features

**Future (After Extraction to Separate Repo)**:
- 🚀 Standalone repository setup
- 🚀 Homebrew formula
- 🚀 Published releases
- 🚀 User documentation website
- 🚀 YBS integration guide

---

## Builds

Builds are transient workspaces for building the system. Each build in `builds/BUILDNAME/` contains:
- Swift Package (Package.swift, Sources/, Tests/)
- BUILD_CONFIG.json (configuration from Step 0)
- BUILD_STATUS.md (current progress)
- build-history/ (completed steps documentation)

**Active builds**:
- test6, test7 (current development)

---

## Documentation

### Murphy-Specific Docs

- [docs/murphy-principles.md](docs/murphy-principles.md) - Design principles
- [docs/tool-architecture.md](docs/tool-architecture.md) - Hybrid tool system
- [docs/security-model.md](docs/security-model.md) - Security layers
- [docs/configuration.md](docs/configuration.md) - Config system

### YBS Framework Docs (for context)

- [../../framework/README.md](../../framework/README.md) - YBS framework overview
- [../../framework/docs/glossary.md](../../framework/docs/glossary.md) - Standard terminology

---

## Why "Murphy"?

**Murphy's Law**: "Anything that can go wrong, will go wrong"

The name reflects software development reality:
- Code breaks, bugs appear, builds fail
- Murphy is here to help you handle what goes wrong
- Pragmatic, honest, battle-tested approach
- Perfect for a developer's AI pair programmer

**Originally called "bootstrap"** (2026-01-16 to 2026-01-18):
- Built to validate YBS framework ("pulling yourself up by your bootstraps")
- Renamed to avoid confusion with YBS framework name
- History preserved in git

---

## Example Usage (When Complete)

```bash
# Start Murphy with Ollama (local)
$ murphy

# Or with OpenAI
$ murphy --provider openai --model gpt-4-turbo

# Execute YBS build
$ cd my-system
$ murphy build

# With project config
$ cd ~/myproject
$ murphy  # Reads ./.murphy.json for project-specific settings
```

---

## Contributing

To improve Murphy specs or steps:

1. **Test with AI agent**: Have Claude execute build steps
2. **Identify issues**: Ambiguities, gaps, errors
3. **Update specs**: Refine technical specification
4. **Update steps**: Improve build instructions
5. **Update ADRs**: Document architectural changes
6. **Retest**: Verify improvements work

---

## References

- **YBS Framework**: [../../framework/README.md](../../framework/README.md)
- **YBS Repository**: [../../README.md](../../README.md)
- **AI Agent Guide**: [CLAUDE.md](CLAUDE.md)
- **Glossary**: [../../framework/docs/glossary.md](../../framework/docs/glossary.md)
- **Future Repository**: github.com/ScottYelich/murphy (to be created)

---

## Version History

- **1.0.0** (2026-01-18): Renamed from bootstrap to Murphy, prepared for extraction to separate repo
- **0.1.0** (2026-01-17): Initial bootstrap system documentation after restructure

---

**Last updated**: 2026-01-18 (renamed to Murphy, prepared for repository extraction)
