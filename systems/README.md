# Systems Directory

**Version**: 0.2.0
**Last Updated**: 2026-01-18

📍 **You are here**: YBS Repository > Systems
**↑ Parent**: [Repository Root](../README.md)
📚 **See also**: [Framework](../framework/README.md) | [CLAUDE.md](CLAUDE.md)

---

## What is This Directory?

**This directory contains definitions of all systems that can be built using the YBS framework.**

Each system is self-contained with:
- **Specifications** (WHAT to build)
- **Build steps** (HOW to build)
- **Documentation** (WHY and context)
- **Builds** (WHERE work happens - outputs and artifacts)

---

## System Structure

Each system follows this structure:

```
systems/SYSTEMNAME/
├── README.md                          # System overview
├── CLAUDE.md                          # AI agent guide for this system
│
├── specs/                             # Specifications (WHAT to build)
│   ├── technical/                     # Technical specifications
│   │   ├── _BASE.md                   # System-wide technical standards
│   │   └── SYSTEM-spec.md             # Complete technical spec
│   ├── architecture/                  # Architectural decisions
│   │   ├── _BASE.md                   # Architectural principles
│   │   └── SYSTEM-decisions.md        # ADRs
│   ├── general/                       # General documentation
│   │   └── SYSTEM-lessons-learned.md  # Implementation checklist
│   ├── business/_BASE.md              # Business context
│   ├── functional/_BASE.md            # UX patterns
│   ├── testing/_BASE.md               # Test standards
│   ├── security/_BASE.md              # Security model
│   └── operations/_BASE.md            # Deployment standards
│
├── steps/                             # Build steps (HOW to build)
│   ├── README.md                      # Steps overview
│   ├── STEPS_ORDER.txt                # Execution order
│   ├── SYSTEM-step_000000000000.md    # Step 0: Build Configuration
│   ├── SYSTEM-step_<guid1>.md         # Step 1
│   ├── SYSTEM-step_<guid2>.md         # Step 2
│   └── ...                            # More steps
│
├── docs/                              # System-specific documentation
│   ├── SYSTEM-principles.md           # Design principles
│   ├── tool-architecture.md           # Architecture details
│   └── ...                            # Other docs
│
└── builds/                            # Build workspaces (WHERE work happens)
    ├── test1/                         # First build
    ├── test2/                         # Second build
    └── testN/                         # Current build
        ├── BUILD_CONFIG.json          # Configuration
        ├── BUILD_STATUS.md            # Progress tracking
        ├── SESSION.md                 # Crash recovery
        ├── Package.swift              # (example - Swift project)
        ├── Sources/                   # Source code
        ├── Tests/                     # Test code
        └── build-history/             # Completed steps
```

---

## Current Systems

### bootstrap

**Location**: [systems/bootstrap/](bootstrap/)

**What**: Swift-based AI chat tool (LLM coding assistant) for macOS

**Purpose**: First validation that YBS framework provides sufficient detail for autonomous AI builds

**Status**: In progress
- ✅ Specifications complete (100+ pages)
- ✅ Build steps 0-3 documented
- ✅ test5 build active (Swift package created, compiles)
- 🔄 Core features being implemented

**Key Features** (when complete):
- Command-line AI coding assistant
- Local or remote LLMs (Ollama, OpenAI, Anthropic)
- 6 built-in tools + unlimited external tools
- Security by default (sandboxed execution)
- macOS native (Swift)

**See**: [systems/bootstrap/README.md](bootstrap/README.md) for complete details

---

## Adding a New System

### For Humans: Define a New System

**1. Create system directory**
```bash
mkdir -p systems/NEWSYSTEM
cd systems/NEWSYSTEM
```

**2. Create specifications** (`specs/`)
- Read: [../framework/methodology/writing-specs.md](../framework/methodology/writing-specs.md)
- Create: specs/technical/, specs/architecture/, specs/general/, etc.
- Write: What you want to build (requirements, architecture, decisions)

**3. Create build steps** (`steps/`)
- Read: [../framework/methodology/writing-steps.md](../framework/methodology/writing-steps.md)
- Create: steps/NEWSYSTEM-step_000000000000.md (Step 0)
- Write: How to build it (sequential instructions for AI agents)
- Create: steps/STEPS_ORDER.txt (execution order)

**4. Create documentation** (`docs/`)
- Create: README.md, CLAUDE.md
- Document: Principles, architecture, design decisions

**5. Test with AI agent**
- Navigate to: systems/NEWSYSTEM/
- Execute: Step 0 (Build Configuration)
- Continue: Through all steps autonomously

### For AI Agents: Build a System

**1. Read system guide**
```bash
cd systems/SYSTEMNAME/
cat CLAUDE.md
```

**2. Execute Step 0**
- Read: steps/SYSTEMNAME-step_000000000000.md
- Execute: Build Configuration step
- Generate: BUILD_CONFIG.json

**3. Continue autonomously**
- Follow: steps/STEPS_ORDER.txt
- Execute: Each step in order
- Verify: After each step
- Track: Progress in BUILD_STATUS.md

---

## System Independence

**Each system is self-contained:**

✅ **Specifications**: Everything needed to understand what to build
✅ **Build steps**: Complete instructions for how to build it
✅ **Documentation**: Context and decisions
✅ **Builds**: Outputs and artifacts stay inside system directory

**Benefits**:
- Clear separation of concerns
- Easy to add new systems
- No cross-system dependencies
- Supports parallel development

---

## Key Concepts

### Specs Define Reality

Specifications are the single source of truth. Code is derived from specs.

**Rule**: If it's not in the specs, it doesn't exist. If code exists without specs, it's a bug.

### Steps Enable Autonomy

Build steps provide sufficient detail for AI agents to build the system without human intervention (after Step 0).

**Step 0**: Collects all configuration upfront
**Steps 1-N**: Execute autonomously (no prompts)

### Builds Are Workspaces

Build directories (`builds/BUILDNAME/`) are where AI agents do their work.

**Multiple builds**: Parallel development of variants or iterations
**One agent per build**: Prevents conflicts

### Traceability Mandatory

Every implementation decision traces to specifications.

**Feature-level**: Steps reference specs they implement
**Code-level**: Source files include `// Implements: spec § X.Y` comments

---

## Tools

Helper scripts work with any system:

```bash
# List specifications for a system
../framework/tools/list-specs.sh SYSTEMNAME

# List build steps in order
../framework/tools/list-steps.sh SYSTEMNAME

# Show dependency tree
../framework/tools/deps.sh SYSTEMNAME

# Check code-to-spec traceability
../framework/tools/check-traceability.sh SYSTEMNAME BUILDNAME
```

---

## References

- **Framework**: [../framework/README.md](../framework/README.md)
- **Repository**: [../README.md](../README.md)
- **AI Agent Guide**: [CLAUDE.md](CLAUDE.md)
- **Bootstrap Example**: [bootstrap/README.md](bootstrap/README.md)

---

## Version History

- **0.2.0** (2026-01-18): Initial systems directory README

---

*Each system built with YBS validates and improves the framework.*
