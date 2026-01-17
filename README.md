# YBS (Yelich Build System)

> A meta-framework for building systems that build systems
>
> **Status**: Specifications complete, bootstrap implementation in progress

## What is This Repository?

This repository contains:

1. **YBS Meta-Framework** - Language-agnostic specifications for building system-building systems
   - Generic build framework (step-by-step instructions)
   - Specification templates and patterns
   - Architecture for tool-based AI agents

2. **YBS Bootstrap Implementation** - First reference implementation using the framework
   - Swift-based AI agent for macOS (specs/system/)
   - Technical spec, architectural decisions, implementation checklist
   - Used to validate and dogfood the framework

3. **builds/** - Output directory for systems built with YBS

## What is YBS?

**YBS is a meta-framework**: A system for building systems that build systems.

It provides language-agnostic specifications and step-by-step build instructions for creating AI agents that:
- Execute tools locally (file I/O, shell commands, external tools)
- Reason using LLMs (local or remote)
- Maintain conversation context
- Require minimal dependencies
- Support extensible tool architectures

**The Bootstrap**: We're using YBS to build the first YBS implementation (Swift/macOS), which will then be used to build other systems.

### What YBS Builds

Systems built with YBS are AI agents that:
- Chat with users to understand intent
- Use tools to accomplish tasks (read files, edit code, run commands)
- Maintain context across operations
- Work with any LLM backend (Ollama, OpenAI, Anthropic, etc.)

The first system we're building is a Swift-based coding assistant for macOS.

### Framework Principles

Systems built with YBS follow these principles:

- **🏠 Local-first**: All tool execution happens locally; code stays on user's machine
- **🔧 Extensible**: Add new tools without recompiling (external tool protocol)
- **🔒 Secure by default**: Sandboxed shell execution, path restrictions, user confirmation for destructive ops
- **🎯 Simple core**: Agent loop designed to be understandable in < 100 lines
- **🌐 Flexible LLM**: Works with local (Ollama) or remote (OpenAI, Anthropic) providers
- **⚡ Minimal overhead**: Fast startup, low memory footprint

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

**Q: What is the "bootstrap" implementation?**
- YBS is a meta-framework for building systems that build systems
- We're using YBS to build the first YBS implementation (Swift/macOS)
- This first implementation will then be used to build other systems
- It's recursive: YBS builds YBS

**Q: Can I use a different language?**
- Yes! The framework is language-agnostic
- The Swift implementation is just the first example
- You can build implementations in Python, Rust, Go, TypeScript, etc.
- The specifications are concepts, not code

**Q: Why Swift for the bootstrap?**
- Native macOS integration, single binary distribution, fast startup, type safety
- See [docs/specs/system/ybs-decisions.md](docs/specs/system/ybs-decisions.md) D01 for full rationale
- This choice is specific to the bootstrap, not required by YBS

**Q: Can systems built with YBS use ChatGPT/Claude/local models?**
- Yes! The framework supports any LLM backend
- OpenAI, Anthropic, Ollama, or any OpenAI-compatible API
- Local-first: tool execution is always local, only LLM calls go to cloud (if using cloud LLM)

**Q: When will the bootstrap be ready?**
- Specifications complete, code implementation in progress via build framework
- No timeline set (this is a learning/validation project)
- Other implementations can start now using the framework

**Q: How is this different from Claude Code/Aider/Cursor?**
- YBS is a meta-framework, not a single tool
- Designed for building custom AI agent systems
- Local-first by default (tool execution always local)
- Extensible architecture (external tool protocol)
- Language-agnostic specifications

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
- Claude (Sonnet 4.5) + Human evolving the YBS specifications
- Documenting patterns, architecture, and best practices
- Building the meta-framework iteratively

**Phase 2 (Next)**: Bootstrap Implementation
- Use the YBS method to build a YBS implementation (Swift/macOS)
- Follow the build-from-scratch framework step-by-step
- Goal: Working local implementation (even if imperfect!)

**Phase 3 (Future)**: Self-Hosting
- Use the Swift YBS to build other systems
- Test with local LLMs (Ollama, etc.)
- Iterate and improve based on real usage

It's okay if the local LLM implementation isn't as capable as Claude. The goal is to reach the point where we can try, learn, and iterate.

---

## License

MIT License - See [LICENSE](LICENSE) file for details

---

**Name etymology**: "YBS" = Yelich Build System, a meta-framework for building systems that build systems.

**Last updated**: 2026-01-16
