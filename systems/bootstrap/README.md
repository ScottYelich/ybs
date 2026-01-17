# Bootstrap System

**Version**: 1.0.0
**Last Updated**: 2026-01-17

📍 **You are here**: YBS Framework > Systems > Bootstrap
**↑ Parent**: [Systems Directory](../) | [Framework](../../framework/README.md)

---

## What is Bootstrap?

**Bootstrap is a Swift-based AI chat tool (LLM coding assistant) for macOS.** It's the first system being built WITH the YBS framework to validate and refine the methodology.

**Important**: Bootstrap is ONE example of what YBS can build. The YBS framework can guide building ANY type of system - calculators, web apps, databases, compilers, AI agents, anything.

---

## Purpose

### Primary Goal: Validate YBS Framework

Bootstrap serves as a real-world test case:

- **Tests methodology**: Does YBS provide sufficient detail for autonomous builds?
- **Refines framework**: Identifies gaps, ambiguities, and improvements needed
- **Demonstrates completeness**: Proves AI agents can build complex systems end-to-end

### Secondary Goal: Useful Tool

If successful, bootstrap becomes a functional AI coding assistant:

- Command-line interface
- Local or remote LLMs (Ollama, OpenAI, Anthropic)
- Hybrid tool architecture (built-in + external tools)
- Security by default (sandboxed execution)
- macOS native (Swift)

---

## System Structure

```
bootstrap/
├── README.md                          # This file
├── CLAUDE.md                          # Guide for AI agents working on bootstrap
├── specs/                             # System specifications
│   ├── README.md                      # Spec organization
│   ├── ybs-spec.md                    # Complete technical specification
│   ├── ybs-decisions.md               # Architectural Decision Records (ADRs)
│   └── ybs-lessons-learned.md         # Implementation checklist
├── steps/                             # Build steps
│   ├── README.md                      # Step overview
│   ├── ybs-step_000000000000.md       # Step 0: Build Configuration
│   ├── ybs-step_478a8c4b0cef.md       # Step 1: Initialize Build Workspace
│   ├── ybs-step_c5404152680d.md       # Step 2: Define Architecture
│   └── ybs-step_89b9e6233da5.md       # Step 3: Set Up Project Environment
├── docs/                              # Bootstrap-specific documentation
│   ├── bootstrap-principles.md        # Design principles for bootstrap
│   ├── tool-architecture.md           # Hybrid tool system
│   ├── security-model.md              # Sandboxing and security
│   └── configuration.md               # Layered configuration system
└── builds/                            # Build outputs
    ├── test1/                         # First experimental build
    ├── test2/                         # ...
    ├── test3/                         # ...
    ├── test4/                         # ...
    └── test5/                         # Latest build (currently working)
```

---

## Quick Start

### For AI Agents: Build the Bootstrap System

1. **Read**: [CLAUDE.md](CLAUDE.md) - Complete AI agent guide for bootstrap
2. **Start**: Execute [steps/ybs-step_000000000000.md](steps/ybs-step_000000000000.md) (Step 0: Configuration)
3. **Continue**: Follow steps autonomously until system is built

### For Humans: Understand the Bootstrap

1. **Overview**: Read this file
2. **Design**: Read [docs/bootstrap-principles.md](docs/bootstrap-principles.md)
3. **Specs**: Read [specs/ybs-spec.md](specs/ybs-spec.md) - Complete technical specification
4. **Decisions**: Read [specs/ybs-decisions.md](specs/ybs-decisions.md) - Why designed this way

### For Contributors: Improve Bootstrap Specs/Steps

1. **Understand**: Read specs and steps thoroughly
2. **Identify gaps**: What's missing or ambiguous?
3. **Refine**: Update specs or steps to improve clarity
4. **Test**: Have AI agent attempt build with improvements

---

## Bootstrap System Overview

### What It Does

A command-line AI coding assistant that:

- **Executes locally**: All tools run on your machine
- **Flexible LLM**: Local (Ollama) or remote (OpenAI, Anthropic)
- **Tool-based**: 6 built-in tools + unlimited external tools
- **Secure**: Sandboxed execution, confirmation for destructive ops
- **Simple core**: Agent loop < 100 lines

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

See [docs/bootstrap-principles.md](docs/bootstrap-principles.md) for complete principles. Summary:

1. **Local-First**: All tool execution happens locally
2. **Minimal Dependencies**: Swift stdlib + 2-3 packages
3. **Extensible**: Add tools without recompiling
4. **Secure by Default**: Sandboxed, confirmation required
5. **Simple Core**: Agent loop < 100 lines
6. **Provider-Agnostic**: Works with any LLM provider

---

## Specifications

### Core Spec Documents

**[specs/ybs-spec.md](specs/ybs-spec.md)** - Complete technical specification (100+ pages)
- System architecture
- Tool definitions (built-in + external)
- Configuration schema
- Agent loop pseudocode
- LLM provider abstraction
- Security implementation
- Project structure

**[specs/ybs-decisions.md](specs/ybs-decisions.md)** - Architectural Decision Records (15 ADRs)
- D01: Swift chosen for native macOS integration
- D04: Hybrid tool architecture
- D08: SEARCH/REPLACE edit format
- D09: macOS sandbox-exec for shell isolation
- D13: Stateless sessions
- *(and 10 more)*

**[specs/ybs-lessons-learned.md](specs/ybs-lessons-learned.md)** - Implementation checklist
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
- *(More steps to be added)*

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
- ✅ Initial build steps (0-3)
- ✅ test5 build: Swift package created, compiles successfully

**In Progress**:
- 🔄 Additional build steps (implementing features)
- 🔄 Core agent loop
- 🔄 Built-in tools
- 🔄 LLM provider integration

**Future**:
- ❌ External tool system
- ❌ Security implementation
- ❌ Configuration system
- ❌ Testing suite
- ❌ User documentation

---

## Builds

Multiple builds exist for experimentation:

- **test1-test4**: Early experimental builds
- **test5**: Current active build (most recent)

Each build in `builds/BUILDNAME/` contains:
- Swift Package (Package.swift, Sources/, Tests/)
- BUILD_CONFIG.json (configuration from Step 0)
- BUILD_STATUS.md (current progress)
- build-history/ (completed steps documentation)

---

## Documentation

### Bootstrap-Specific Docs

- [docs/bootstrap-principles.md](docs/bootstrap-principles.md) - Design principles
- [docs/tool-architecture.md](docs/tool-architecture.md) - Hybrid tool system
- [docs/security-model.md](docs/security-model.md) - Security layers
- [docs/configuration.md](docs/configuration.md) - Config system

### Framework Docs

- [../../framework/README.md](../../framework/README.md) - YBS framework overview
- [../../framework/docs/glossary.md](../../framework/docs/glossary.md) - Standard terminology

---

## Why "Bootstrap"?

**Bootstrap = The first system built WITH YBS to validate the framework itself.**

The name reflects its purpose:
- "Pulling yourself up by your bootstraps"
- Using YBS to build a tool that could eventually build systems (including itself)
- First reference implementation demonstrating YBS completeness

**Not called "YBS Tool"** because:
- YBS is the FRAMEWORK (methodology)
- Bootstrap is ONE system built WITH the framework
- Avoids confusion between framework and implementation

---

## Example Usage (When Complete)

```bash
# Start bootstrap with Ollama (local)
$ bootstrap

# Or with OpenAI
$ bootstrap --provider openai --model gpt-4-turbo

# With project config
$ cd ~/myproject
$ bootstrap  # Reads ./.ybs.json for project-specific settings
```

---

## Contributing

To improve bootstrap specs or steps:

1. **Test with AI agent**: Have Claude execute build steps
2. **Identify issues**: Ambiguities, gaps, errors
3. **Update specs**: Refine technical specification
4. **Update steps**: Improve build instructions
5. **Update ADRs**: Document architectural changes
6. **Retest**: Verify improvements work

---

## References

- **Framework**: [../../framework/README.md](../../framework/README.md)
- **YBS Overview**: [../../README.md](../../README.md)
- **AI Agent Guide**: [CLAUDE.md](CLAUDE.md)
- **Glossary**: [../../framework/docs/glossary.md](../../framework/docs/glossary.md)

---

## Version History

- **1.0.0** (2026-01-17): Initial bootstrap system documentation after restructure

