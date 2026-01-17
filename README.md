# YBS (Yelich Build System)

> A methodology that enables AI agents to build ANY system autonomously
>
> **Status**: Framework evolution + Bootstrap implementation in progress
> **Version**: 1.0.0
> **Last Updated**: 2026-01-17

📍 **Navigation**: [Framework](framework/README.md) | [Bootstrap](systems/bootstrap/README.md) | [Glossary](framework/docs/glossary.md)

---

## 🚀 Quick Start (Choose Your Path)

**→ Build something with YBS** (AI agents)
- **Read**: [CLAUDE.md](CLAUDE.md) - AI agent guide for this repository
- **Learn**: [framework/methodology/executing-builds.md](framework/methodology/executing-builds.md)
- **Start**: Navigate to systems/SYSTEMNAME/ and execute Step 0
- **Example**: See [systems/bootstrap/builds/test5/](systems/bootstrap/builds/test5/) - working example

**→ Understand the YBS framework** (humans)
- **Read**: [framework/README.md](framework/README.md) - Framework overview
- **Learn**: [framework/docs/glossary.md](framework/docs/glossary.md) - Key terminology
- **Explore**: [systems/bootstrap/](systems/bootstrap/) - Complete example system

**→ See a working example**
- **Browse**: [systems/bootstrap/builds/test5/](systems/bootstrap/builds/test5/) - Latest build
- **Status**: [systems/bootstrap/builds/test5/BUILD_STATUS.md](systems/bootstrap/builds/test5/BUILD_STATUS.md)
- **Code**: [systems/bootstrap/builds/test5/Package.swift](systems/bootstrap/builds/test5/Package.swift)

**→ Work on YBS framework itself** (contributors)
- **AI agents**: [CLAUDE.md](CLAUDE.md) - Complete AI agent guide
- **Humans**: Read [framework/README.md](framework/README.md) before proposing changes
- **Review**: [systems/bootstrap/specs/ybs-decisions.md](systems/bootstrap/specs/ybs-decisions.md) - Architectural decisions

---

## What is This Repository?

**This repository contains the YBS framework and systems built with it.**

### Three-Layer Architecture

**A. Framework** (`framework/`) - The YBS methodology itself
- How to write specs, steps, and execute builds
- Templates and patterns (reusable across all systems)
- Tools and documentation
- **Language-agnostic, system-agnostic**

**B. Systems** (`systems/`) - Definitions of specific systems to build
- Each system has: specs (WHAT) + steps (HOW) + docs
- Self-contained (everything needed to build that system)
- **Examples**: bootstrap (Swift AI tool), calculator, web-app, etc.

**C. Builds** (`systems/SYSTEMNAME/builds/`) - Active build workspaces
- Build outputs and artifacts (compiled code, etc.)
- SESSION.md for crash recovery
- BUILD_STATUS.md for progress tracking
- **Location**: Inside each system (B + C together)

---

## Repository Structure

```
ybs/
├── README.md                          # This file
├── CLAUDE.md                          # AI agent guide
├── LICENSE
├── SESSION.md.template                # Session tracking template
├── scratch/                           # Temporary working files
│
├── framework/                         # "A" - YBS Framework
│   ├── README.md                      # Framework overview
│   ├── methodology/                   # How YBS works
│   ├── templates/                     # Reusable templates
│   ├── docs/                          # Framework docs
│   ├── tools/                         # Helper scripts
│   └── changelogs/                    # Framework changes
│
└── systems/                           # Collection of system definitions
    │
    └── bootstrap/                     # "B" - Bootstrap system
        ├── README.md                  # Bootstrap overview
        ├── CLAUDE.md                  # AI agent guide for bootstrap
        ├── specs/                     # Specifications (WHAT to build)
        ├── steps/                     # Build steps (HOW to build)
        ├── docs/                      # Bootstrap-specific documentation
        └── builds/                    # "C" - Build outputs
            ├── test1/
            ├── test2/
            ├── test3/
            ├── test4/
            └── test5/                 # Current build (active)
```

---

## What is YBS?

**YBS is a methodology that provides sufficient specifications and details for AI agents to build ANY system autonomously.**

### How It Works

1. **Define System** - Write specs (technical, business, functional, testing)
2. **Create Steps** - Write step-by-step build instructions
3. **Execute** - AI agent reads steps and builds the system
4. **Result** - Complete working system with full traceability

### What Can Be Built

- **Anything that can be specified**: Calculators, web apps, CLI tools, AI agents, compilers, databases, servers, etc.
- **Language-agnostic**: Python, Swift, Rust, Go, TypeScript, C++, Java, etc.
- **Platform-agnostic**: Web, desktop, mobile, embedded, cloud, etc.

### Key Principles

- **📋 Configuration-First**: Step 0 collects all questions upfront → enables autonomous execution
- **🎯 Traceable**: Every implementation decision traces to specs
- **🔀 Language-Agnostic**: Framework works for ANY programming language
- **🌐 System-Agnostic**: Can guide building ANY type of software
- **✅ Verifiable**: Each step has explicit verification criteria
- **🔄 Self-Refining**: Framework improves through real-world use

---

## Bootstrap Example

**The bootstrap system demonstrates YBS in action.**

**What**: Swift-based AI chat tool (LLM coding assistant) for macOS

**Why**: First test case to validate YBS framework provides sufficient detail

**Status**: In progress (Steps 0-3 complete, test5 build working)

**Location**: [systems/bootstrap/](systems/bootstrap/)

### Bootstrap Features (When Complete)

- Command-line AI coding assistant
- Local or remote LLMs (Ollama, OpenAI, Anthropic)
- 6 built-in tools + unlimited external tools
- Security by default (sandboxed execution)
- macOS native (Swift)

### Bootstrap Principles

- **🏠 Local-First**: All tool execution on user's machine
- **🔧 Extensible**: External tool protocol for custom tools
- **🔒 Secure by Default**: Sandboxing and confirmations
- **🎯 Simple Core**: Agent loop < 100 lines
- **⚡ Minimal Dependencies**: Swift stdlib + 2-3 packages

**See [systems/bootstrap/docs/bootstrap-principles.md](systems/bootstrap/docs/bootstrap-principles.md) for complete details.**

---

## Current Status

### Framework (A)
- ✅ Methodology documented
- ✅ Generic build framework
- ✅ Templates and patterns
- ✅ Helper scripts and tools
- 🔄 Refining through bootstrap validation

### Bootstrap System (B)
- ✅ Complete technical specification (100+ pages)
- ✅ 15 Architectural Decision Records
- ✅ Implementation checklist
- ✅ Build steps (0-3)
- 🔄 Code implementation in progress

### Bootstrap Builds (C)
- ✅ test5: Swift package created, compiles successfully
- ✅ BUILD_CONFIG.json generated (Step 0)
- ✅ BUILD_STATUS.md tracking progress
- 🔄 Core features being implemented

---

## Documentation

### Framework Documentation

- **[framework/README.md](framework/README.md)** - Framework overview
- **[framework/methodology/](framework/methodology/)** - How YBS works
  - [executing-builds.md](framework/methodology/executing-builds.md) - AI agent guide
  - [writing-specs.md](framework/methodology/writing-specs.md) - How to write specs
  - [writing-steps.md](framework/methodology/writing-steps.md) - How to write steps
- **[framework/docs/glossary.md](framework/docs/glossary.md)** - Standard terminology (50+ terms)
- **[framework/templates/](framework/templates/)** - Reusable templates

### Bootstrap Documentation

- **[systems/bootstrap/README.md](systems/bootstrap/README.md)** - Bootstrap overview
- **[systems/bootstrap/CLAUDE.md](systems/bootstrap/CLAUDE.md)** - AI agent guide for bootstrap
- **[systems/bootstrap/specs/](systems/bootstrap/specs/)** - Complete specifications
  - [ybs-spec.md](systems/bootstrap/specs/ybs-spec.md) - Technical specification
  - [ybs-decisions.md](systems/bootstrap/specs/ybs-decisions.md) - Architectural decisions
  - [ybs-lessons-learned.md](systems/bootstrap/specs/ybs-lessons-learned.md) - Implementation checklist
- **[systems/bootstrap/docs/](systems/bootstrap/docs/)** - Bootstrap-specific docs
  - [bootstrap-principles.md](systems/bootstrap/docs/bootstrap-principles.md) - Design principles
  - [tool-architecture.md](systems/bootstrap/docs/tool-architecture.md) - Hybrid tool system
  - [security-model.md](systems/bootstrap/docs/security-model.md) - Security layers
  - [configuration.md](systems/bootstrap/docs/configuration.md) - Configuration system

---

## Getting Started

### For AI Agents: Build a System

1. Read [CLAUDE.md](CLAUDE.md) - Repository guide
2. Navigate to systems/SYSTEMNAME/
3. Read systems/SYSTEMNAME/CLAUDE.md
4. Execute Step 0 (Build Configuration)
5. Continue autonomously through all steps

### For Humans: Understand YBS

1. Read [framework/README.md](framework/README.md) - Framework overview
2. Read [systems/bootstrap/README.md](systems/bootstrap/README.md) - Example system
3. Browse [systems/bootstrap/specs/](systems/bootstrap/specs/) - Complete specifications
4. Review [systems/bootstrap/builds/test5/](systems/bootstrap/builds/test5/) - Working build

### For Contributors: Improve Framework

1. Read [framework/README.md](framework/README.md)
2. Read [framework/docs/glossary.md](framework/docs/glossary.md)
3. Test framework by building diverse system types
4. Document patterns and best practices
5. Refine templates and tools

---

## Key Concepts

### Configuration-First (Step 0)

Step 0 collects ALL configuration upfront:
- Generates BUILD_CONFIG.json with all settings
- Subsequent steps read from config (no user prompts)
- **Enables fully autonomous execution after Step 0**

### Autonomous Execution

AI agents work continuously without interruption:
- After Step 0, no user prompts needed
- Agent proceeds through steps automatically
- Only stops for critical errors or 3x verification failures

### Traceability

Every implementation decision traces to specifications:
- Steps reference specs they implement
- Specs reference decisions (ADRs)
- Clear audit trail from requirement to code

### Parallel Builds

Multiple agents can work simultaneously:
- ✅ Different systems: systems/bootstrap/ + systems/calculator/
- ✅ Different builds: systems/bootstrap/builds/test5/ + test6/
- ❌ Same build: One agent per build (prevents conflicts)

---

## Tools

Helper scripts in `framework/tools/`:

```bash
framework/tools/list-specs.sh        # List specifications
framework/tools/list-steps.sh        # List build steps in order
framework/tools/deps.sh              # Show dependency tree
framework/tools/list-changelogs.sh   # List session changelogs
```

---

## Restructure Note

**This repository was restructured on 2026-01-17** to clearly separate:

- **A**: Framework (methodology) - Reusable across all systems
- **B**: System definitions (specs + steps) - Self-contained per system
- **C**: Build outputs (inside B) - Active workspaces

**Benefits**:
- Clear separation of concerns
- Easy to add new systems
- Supports parallel builds
- Self-contained system definitions

**See**: `scratch/restructure-plan.md` for complete documentation

---

## Contributing

### Improve Framework

- Test framework by building diverse systems
- Refine methodology documentation
- Improve templates and patterns
- Enhance helper tools

### Improve Bootstrap

- Review specs for completeness
- Refine build steps for clarity
- Test autonomous execution
- Document patterns discovered

### Add New Systems

- Create systems/NEWSYSTEM/
- Write specs (WHAT to build)
- Write steps (HOW to build)
- Test with AI agent

---

## License

MIT License - See [LICENSE](LICENSE)

---

## Version History

- **1.0.0** (2026-01-17): Major restructure - separated framework, systems, and builds
- **0.2.0** (2026-01-17): Documentation improvements, canonical docs, Quick Start
- **0.1.0** (2026-01-16): Initial version

---

## References

- **Framework**: [framework/README.md](framework/README.md)
- **AI Agent Guide**: [CLAUDE.md](CLAUDE.md)
- **Bootstrap**: [systems/bootstrap/README.md](systems/bootstrap/README.md)
- **Glossary**: [framework/docs/glossary.md](framework/docs/glossary.md)

