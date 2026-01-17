# YBS (Yelich Build System)

> A methodology that provides sufficient details for AI agents to build ANY system autonomously
>
> **Status**: Framework evolution + Bootstrap implementation in progress

## What is This Repository?

This repository contains:

1. **YBS Meta-Framework** - Methodology for autonomous system development by AI agents
   - Structured files (specs, steps, decisions, checklists) with sufficient detail for autonomous builds
   - Generic build framework (step-by-step instructions)
   - Specification templates and patterns
   - Language-agnostic, system-agnostic

2. **YBS Bootstrap Implementation** - First test case using the framework
   - Swift-based AI chat tool for macOS (specs/system/)
   - Technical spec, architectural decisions, implementation checklist
   - Used to validate and refine the framework
   - The bootstrap HAPPENS to be an AI agent, but YBS could build anything

3. **builds/** - Output directory for systems built with YBS

## What is YBS?

**YBS is a methodology that provides sufficient specifications and details for an AI agent to build ANY system autonomously.**

It uses structured files (specs, steps, decisions, checklists) to guide tool-using AI agents (like Claude) through building complete systems from scratch to completion without human intervention.

**What can be built:**
- Calculators, web apps, CLI tools, libraries
- AI agents, compilers, databases, servers
- Anything that can be specified
- Language-agnostic (Python, Swift, Rust, Go, TypeScript, etc.)

**How it works:**
- **Specs** define WHAT to build (requirements, architecture, decisions)
- **Steps** define HOW to build it (detailed instructions for AI agents)
- **AI agent** (Claude, etc.) executes steps using tools (read, write, run commands)
- **System** gets built autonomously with full traceability

**The Bootstrap**: We're testing YBS by having Claude build a Swift-based LLM chat tool. This validates that the framework provides sufficient detail for autonomous development.

### Example: The Bootstrap Implementation

The first system being built WITH YBS is a command-line AI chat tool (Swift/macOS) that:
- Executes tools locally (file I/O, shell commands, external tools)
- Reasons using LLMs (local or remote: Ollama, OpenAI, Anthropic, etc.)
- Maintains conversation context
- Uses minimal dependencies
- Supports extensible tool architectures

This is ONE example of what YBS can build - we could just as easily use YBS to build a calculator, web server, or anything else.

### YBS Framework Principles

The YBS methodology itself follows these principles:

- **📋 Sufficiently detailed**: Specs and steps provide enough detail for autonomous development
- **🎯 Traceable**: Every implementation decision traces back to specs
- **🔀 Language-agnostic**: Can guide building systems in any language
- **🌐 System-agnostic**: Can guide building any type of software
- **📦 Modular**: Specs, steps, decisions, and checklists are separate concerns
- **✅ Verifiable**: Each step includes verification criteria

### Bootstrap Implementation Principles

The Swift chat tool (bootstrap) follows THESE principles (specific to that system):

- **🏠 Local-first**: All tool execution happens locally; code stays on user's machine
- **🔧 Extensible**: Add new tools without recompiling (external tool protocol)
- **🔒 Secure by default**: Sandboxed shell execution, path restrictions, user confirmation for destructive ops
- **🎯 Simple core**: Agent loop designed to be understandable in < 100 lines
- **🌐 Flexible LLM**: Works with local (Ollama) or remote (OpenAI, Anthropic) providers
- **⚡ Minimal overhead**: Fast startup, low memory footprint

Different systems built with YBS can follow different principles.

### Design Philosophy

1. **Local tool execution** - Security and control
2. **Minimal dependencies** - Use language standard library where possible
3. **Hybrid tool architecture** - Core built-in tools + unlimited external tools
4. **Stateless sessions** - State via filesystem (tools can access git, sqlite, etc. as needed)
5. **Graceful degradation** - Errors don't crash; LLM can adapt

## Current Status

**Framework (Language-Agnostic)**:
- ✅ Generic build framework (step-by-step system builder)
- ✅ Specification templates and patterns
- ✅ Architecture documentation
- ✅ Session-based changelog system
- ✅ Helper scripts (bin/)

**Bootstrap Implementation (Swift/macOS)**:
- ✅ Complete technical specification (100+ pages)
- ✅ 15 architectural decision records with rationale
- ✅ Implementation checklist from industry research
- ❌ Code implementation (in progress via build framework)
- ❌ Pre-built binaries

**How to use this**:
- **To understand the framework**: Read docs/build-from-scratch/
- **To see a complete spec example**: Read docs/specs/system/ (Swift implementation)
- **To build your own system**: Use the framework with any language
- **To contribute**: Help build the bootstrap implementation

## Documentation

All project documentation lives in [`docs/`](docs/):

- **[docs/README.md](docs/README.md)** - Documentation index and navigation hub
- **[docs/specs/](docs/specs/)** - Specifications organized by type:
  - **[system/](docs/specs/system/)** - System-wide specifications
    - [ybs-spec.md](docs/specs/system/ybs-spec.md) - Complete technical specification
    - [ybs-decisions.md](docs/specs/system/ybs-decisions.md) - Architectural Decision Records
    - [ybs-lessons-learned.md](docs/specs/system/ybs-lessons-learned.md) - Implementation checklist
  - **business/**, **functional/**, **technical/**, **testing/** - Feature specs by category
- **[docs/build-from-scratch/](docs/build-from-scratch/)** - Developer implementation guides (planned)
- **[docs/usage/](docs/usage/)** - End-user documentation (planned)

## Quick Links

### For Developers Implementing YBS
1. Read [docs/specs/system/ybs-spec.md](docs/specs/system/ybs-spec.md) for technical specification
2. Reference [docs/specs/system/ybs-decisions.md](docs/specs/system/ybs-decisions.md) for architectural rationale
3. Use [docs/specs/system/ybs-lessons-learned.md](docs/specs/system/ybs-lessons-learned.md) as validation checklist

### For Claude Code Instances
- **[CLAUDE.md](CLAUDE.md)** - Guidance for working in this repository

### For Contributors
- Start with [docs/README.md](docs/README.md) to understand documentation structure
- Review [docs/specs/system/ybs-decisions.md](docs/specs/system/ybs-decisions.md) before proposing changes
- Check if your idea conflicts with existing architectural decisions

## Architecture Overview (Bootstrap Implementation)

This shows the architecture of the Swift/macOS bootstrap implementation. Other implementations may vary.

```
┌─────────────────────────────┐
│   User (Terminal)           │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│   YBS Agent (Swift CLI)     │
│   - Tool execution          │
│   - Context management      │
│   - Sandboxing              │
│   - Confirmation UI         │
└──────────┬──────────────────┘
           │ HTTP/JSON
           ▼
┌─────────────────────────────┐
│   LLM Provider              │
│   - Ollama (local)          │
│   - OpenAI (cloud)          │
│   - Anthropic (cloud)       │
└─────────────────────────────┘
```

### Core Tool Architecture

Systems built with YBS typically include:

**Built-in Tools** (compiled into agent):
- File I/O (read, write, edit)
- File discovery (list, search)
- Shell execution (sandboxed)

**External Tools** (runtime-loaded):
- Simple protocol: JSON in via argv, JSON out via stdout
- Examples: web-search, web-fetch, language-specific tooling

### Bootstrap Implementation Details

The Swift/macOS bootstrap implementation uses:

**Language & Platform**:
- Swift 5.9+, macOS 14+ (Linux support planned)
- Dependencies: swift-argument-parser, AsyncHTTPClient

**Security Model**:
- Sandboxing via macOS `sandbox-exec` (deny-by-default)
- Path restrictions: Block `~/.ssh`, `~/.aws`, `~/.config`
- Command blocklist: `rm -rf /`, `sudo`, `chmod 777`, etc.
- User confirmation for all destructive operations

**Configuration** (layered resolution):
```
/etc/ybs/config.json          # System defaults
~/.config/ybs/config.json     # User defaults
~/.ybs.json                   # User home
./.ybs.json                   # Project-specific
--config <path>               # CLI override
```

Other implementations may use different approaches (Python, Rust, Go, etc.).

## Design Inspiration

The bootstrap implementation (Swift/macOS) was informed by analysis of:
- [Aider](https://aider.chat) - Edit format, repo maps
- [Goose](https://github.com/block/goose) - MCP integration, architecture
- [OpenHands](https://github.com/All-Hands-AI/OpenHands) - Loop detection
- [Cursor](https://cursor.sh) - Context management
- [Claude Code](https://claude.ai/code) - Tool design patterns

These insights are codified in [docs/specs/system/ybs-lessons-learned.md](docs/specs/system/ybs-lessons-learned.md) and can be applied to implementations in any language.

## FAQ

**Q: What exactly is YBS?**
- YBS is a METHODOLOGY (not a tool) for providing sufficient details so AI agents can build systems autonomously
- Uses structured files: specs (WHAT to build), steps (HOW to build it), decisions, checklists
- Can guide building ANY system: calculators, web apps, AI agents, databases, anything
- Language-agnostic and system-agnostic

**Q: What is the "bootstrap" implementation?**
- The first system we're building WITH YBS to test and validate the framework
- It's a Swift-based AI chat tool (similar to Aider, but local-first)
- The bootstrap HAPPENS to be an AI agent, but YBS could just as easily build a calculator
- This validates that YBS provides sufficient detail for autonomous development

**Q: Can I use YBS to build something other than AI agents?**
- **YES!** That's the whole point
- YBS can guide building: web servers, calculators, compilers, databases, CLI tools, libraries, anything
- The bootstrap is an AI agent only because we're testing the framework with a complex example
- Use YBS to build whatever you want in whatever language you want

**Q: Why Swift for the bootstrap?**
- Native macOS integration, single binary distribution, fast startup, type safety
- See [docs/specs/system/ybs-decisions.md](docs/specs/system/ybs-decisions.md) D01 for full rationale
- This choice is specific to the bootstrap, not required for YBS or other systems built with YBS

**Q: When will the bootstrap be ready?**
- Specifications complete, code implementation in progress via YBS framework
- No timeline set (this is a learning/validation project)
- The goal is to validate YBS works, not ship a product

**Q: How is this different from Claude Code/Aider/Cursor?**
- YBS is a METHODOLOGY, those are TOOLS
- YBS guides AI agents to build systems; those tools are the systems themselves
- YBS is for creating new systems from scratch; those tools are for working with existing codebases
- You could use YBS to build something like Aider/Cursor (that's essentially what the bootstrap is)

## Contributing

Currently in specification phase. Once implementation begins:
1. Check [docs/README.md](docs/README.md) for documentation structure
2. Review [docs/specs/system/ybs-decisions.md](docs/specs/system/ybs-decisions.md) before proposing changes
3. Ensure changes align with design principles
4. Add tests for all new functionality

## Project Structure

**Current (Framework + Specifications)**:
```
ybs/
├── README.md                          # This file
├── CLAUDE.md                          # Guidance for Claude Code
├── LICENSE                            # MIT License
├── bin/                               # Helper scripts
│   ├── list-specs.sh                 # List specifications by GUID
│   ├── deps.sh                       # Show dependency tree
│   ├── list-steps.sh                 # List build steps
│   └── list-changelogs.sh            # List session changelogs
├── builds/                            # OUTPUT: Systems built with YBS
│   └── test1/                        # Example build (experimental)
└── docs/                              # All documentation
    ├── README.md                      # Documentation index
    ├── changelogs/                    # Session-based change tracking
    ├── specs/                         # Specifications
    │   ├── system/                    # Bootstrap (Swift) implementation specs
    │   ├── business/                  # Business specs per feature
    │   ├── functional/                # Functional specs per feature
    │   ├── technical/                 # Technical specs per feature
    │   └── testing/                   # Testing specs per feature
    ├── build-from-scratch/           # Generic build framework
    └── usage/                         # User documentation (planned)
```

**When bootstrap implementation is built** (in builds/ybs-swift/):
```
builds/ybs-swift/
├── Package.swift                      # Swift package definition
├── Sources/ybs/                       # Implementation code
├── Tools/                             # External tool examples
└── Tests/                             # Test suite
```

## Current Journey

**Phase 1 (Current)**: Framework Evolution
- Claude (Sonnet 4.5) + Human refining the YBS methodology
- Documenting patterns, architecture, and best practices
- Testing the framework by building the bootstrap

**Phase 2 (In Progress)**: Bootstrap Implementation
- Using YBS to have Claude build a Swift-based AI chat tool
- Following the build-from-scratch framework step-by-step
- Goal: Validate YBS provides sufficient detail for autonomous development
- Refine the methodology based on what works and what doesn't

**Phase 3 (Future)**: Validation & Iteration
- Complete the bootstrap implementation
- Use what we learned to improve YBS
- Apply YBS to build other systems (calculators, web apps, etc.)
- Iterate and refine the methodology

The bootstrap being an AI chat tool is intentionally complex - if YBS can guide building that autonomously, it can guide building anything.

---

## License

MIT License - See [LICENSE](LICENSE) file for details

---

**Name etymology**: "YBS" = Yelich Build System, a meta-framework for building systems that build systems.

**Last updated**: 2026-01-16
