# YBS (Yelich Derp System)

> A local-first, extensible AI coding assistant specification + build framework
>
> **Status**: Specification complete, framework ready

## What is This Repository?

This repository contains:

1. **YBS Specification** - Complete design for a local-first AI coding assistant
   - Technical spec, architectural decisions, implementation checklist

2. **Build Framework** - Step-by-step system builder
   - Generic instructions for building ANY LLM coding assistant
   - Can be used to implement YBS or create a different system

3. **builds/** - Output directory for active builds (like .build/ or dist/)

## What is YBS?

YBS (the specification) defines a command-line tool providing an interactive chat interface for AI-assisted coding. It maintains conversation context, executes tools locally, and supports both local and remote LLM backends.

### Key Features (Planned)

- **🏠 Local-first**: All tool execution happens locally; your code stays on your machine
- **🔧 Extensible**: Add new tools without recompiling (external tool protocol)
- **🔒 Secure by default**: Sandboxed shell execution, path restrictions, user confirmation for destructive ops
- **🎯 Simple core**: Agent loop designed to be understandable in < 100 lines
- **🌐 Flexible LLM**: Works with Ollama (local), OpenAI, Anthropic, or any OpenAI-compatible API
- **⚡ Fast**: Native Swift binary, ~10ms startup time

### Design Philosophy

1. **Local tool execution** - Security and control
2. **Minimal dependencies** - Swift stdlib + 2-3 packages
3. **Hybrid tool architecture** - 6 built-in tools + unlimited external tools
4. **Stateless sessions** - Git is your state; no hidden databases
5. **Graceful degradation** - Errors don't crash; LLM can adapt

## Current Status

**What's complete**:
- ✅ YBS specification (100+ pages technical spec)
- ✅ 15 architectural decision records with rationale
- ✅ Implementation checklist from industry research
- ✅ Build framework (step-by-step instructions)

**What's NOT in this repo**:
- ❌ YBS implementation (specs define WHAT, not code)
- ❌ Pre-built binaries

**How to use this**:
- Read specs to understand YBS design
- Use build framework to implement YBS (or create your own system)
- builds/ directory is where framework outputs go

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

## Architecture Overview

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

### Built-in Tools (6)
- `read_file` - Read file contents with line limits
- `write_file` - Create/overwrite files (requires confirmation)
- `edit_file` - Search/replace edits (no line number hallucinations)
- `list_files` - Glob pattern file discovery
- `search_files` - Regex content search
- `run_shell` - Sandboxed command execution (requires confirmation)

### External Tools (Unlimited)
Simple protocol: executable receives JSON via argv, outputs JSON to stdout
- Examples: `web-search`, `web-fetch`, project-specific test runners

## Implementation Details

### Language & Platform
- **Language**: Swift 5.9+
- **Platform**: macOS 14+ (Linux support planned)
- **Dependencies**: swift-argument-parser, AsyncHTTPClient (or URLSession)

### Security Model
- **Sandboxing**: macOS `sandbox-exec` (deny-by-default profile)
- **Path restrictions**: Block `~/.ssh`, `~/.aws`, `~/.config`
- **Command blocklist**: `rm -rf /`, `sudo`, `chmod 777`, etc.
- **User confirmation**: All destructive operations require approval

### Configuration
Layered resolution (later overrides earlier):
```
/etc/ybs/config.json          # System defaults
~/.config/ybs/config.json     # User defaults
~/.ybs.json                   # User home
./.ybs.json                   # Project-specific
--config <path>               # CLI override
```

## Design Inspiration

YBS design informed by analysis of:
- [Aider](https://aider.chat) - Edit format, repo maps
- [Goose](https://github.com/block/goose) - MCP integration, architecture
- [OpenHands](https://github.com/All-Hands-AI/OpenHands) - Loop detection
- [Cursor](https://cursor.sh) - Context management
- [Claude Code](https://claude.ai/code) - Tool design patterns

See [docs/specs/system/ybs-lessons-learned.md](docs/specs/system/ybs-lessons-learned.md) for detailed analysis.

## FAQ

**Q: Why Swift instead of Python/Rust/Go?**
- Native macOS integration, single binary distribution, fast startup, type safety
- See [docs/specs/system/ybs-decisions.md](docs/specs/system/ybs-decisions.md) D01 for full rationale

**Q: Can I use it with ChatGPT/Claude/local models?**
- Yes! Supports OpenAI, Anthropic, Ollama, or any OpenAI-compatible API

**Q: Is my code sent to the cloud?**
- Only if you use a cloud LLM (OpenAI, Anthropic)
- Tool execution is always local
- Default config uses Ollama (fully local)

**Q: When will it be ready?**
- Specification complete, implementation not started
- No timeline set (this is a personal/learning project)

**Q: How is this different from Claude Code?**
- YBS is local-first with simpler core (< 100 line agent loop)
- Designed for transparency and extensibility
- Hybrid tool architecture (built-in + external)
- No cloud dependency requirement (Ollama default)

## Contributing

Currently in specification phase. Once implementation begins:
1. Check [docs/README.md](docs/README.md) for documentation structure
2. Review [docs/specs/system/ybs-decisions.md](docs/specs/system/ybs-decisions.md) before proposing changes
3. Ensure changes align with design principles
4. Add tests for all new functionality

## Project Structure (Planned)

```
ybs/
├── README.md                          # This file
├── CLAUDE.md                          # Guidance for Claude Code
├── builds/                            # OUTPUT: Build workspace (not source)
└── docs/                              # All documentation
    ├── README.md                      # Documentation index
    ├── specs/                         # YBS specifications
    │   ├── system/                    # System-wide specs
    │   ├── business/                  # Business specs per feature
    │   ├── functional/                # Functional specs per feature
    │   ├── technical/                 # Technical specs per feature
    │   └── testing/                   # Testing specs per feature
    ├── build-from-scratch/           # Build framework (step-by-step)
    └── usage/                         # User documentation (future)
```

When YBS is implemented, add:
```
├── Package.swift                      # Swift package definition
├── Sources/ybs/                       # Implementation
├── Tools/                             # External tool examples
└── Tests/                             # Test suite
```

## License

*[To be determined]*

---

**Name etymology**: "YBS" = Yelich Build System, a framework for building LLM-based coding assistants.

**Last updated**: 2026-01-16
