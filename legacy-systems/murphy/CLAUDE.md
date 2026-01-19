# CLAUDE.md - Murphy System

**Version**: 1.0.0
**Last Updated**: 2026-01-18

📍 **You are here**: YBS Repository > Legacy Systems > Murphy > AI Agent Guide
📚 **See also**: [Murphy README](README.md) | [YBS Framework](../../framework/README.md) | [Glossary](../../framework/docs/glossary.md)

**Status**: ⚠️ **To be extracted to separate repository** (`github.com/ScottYelich/murphy`)

---

This file provides guidance to Claude Code when working on the Murphy system.

## Murphy System Overview

**Murphy is a Swift-based AI chat tool (LLM coding assistant) for macOS with first-class YBS build system support.**

Named after Murphy's Law ("Anything that can go wrong, will go wrong"), Murphy helps developers handle what goes wrong during development.

**Location**: `legacy-systems/murphy/` (temporary - will move to standalone repo)

**Originally called**: "bootstrap" (renamed 2026-01-18 to avoid YBS framework name confusion)

---

## What Are You Doing? (Task Identification)

### → Working on Murphy Specifications (specs/)
You're defining or updating WHAT the Murphy system should do:
- **Read**: [specs/README.md](specs/README.md) for specs overview
- **Read**: [../../framework/methodology/writing-specs.md](../../framework/methodology/writing-specs.md) for how to write specs
- **Focus**: Technical requirements, architectural decisions, design principles
- **Goal**: Define the Murphy system clearly and completely

**Key files**:
- specs/technical/ybs-spec.md - Complete technical specification
- specs/architecture/ybs-decisions.md - Architectural Decision Records (ADRs)
- specs/general/ybs-lessons-learned.md - Implementation checklist

---

### → Working on Murphy Build Steps (steps/)
You're defining or updating HOW to build the Murphy system:
- **Read**: [steps/README.md](steps/README.md) for steps overview
- **Read**: [../../framework/methodology/writing-steps.md](../../framework/methodology/writing-steps.md) for how to write steps
- **Focus**: Step-by-step build instructions for AI agents
- **Goal**: Enable autonomous builds of the Murphy system

**Key files**:
- steps/ybs-step_000000000000.md - Step 0 (Build Configuration)
- steps/ybs-step_478a8c4b0cef.md - Step 1 (Project Skeleton)
- steps/ybs-step_c5404152680d.md - Step 2 (Configuration & Providers)
- steps/ybs-step_89b9e6233da5.md - Step 3 (Initial Implementation)

---

### → Executing a Murphy Build (builds/)
You're BUILDING the Murphy system using the steps:
- **Read**: [../../framework/methodology/executing-builds.md](../../framework/methodology/executing-builds.md) for execution guide
- **Navigate**: To builds/BUILDNAME/ (e.g., builds/test7/)
- **Execute**: Start with Step 0 (Build Configuration)
- **Follow**: The build-specific CLAUDE.md in the build directory

**Working directory**: builds/BUILDNAME/

**Each build has its own**:
- CLAUDE.md - Build-specific guide
- BUILD_CONFIG.json - Configuration values
- BUILD_STATUS.md - Current build status
- SESSION.md - Crash recovery (during builds)
- Source code and tests

---

## Murphy System Structure

```
murphy/
├── README.md                          # System overview (start here)
├── CLAUDE.md                          # This file - AI agent guide
│
├── specs/                             # System specifications
│   ├── README.md                      # Spec organization
│   ├── technical/                     # Technical specifications
│   │   └── ybs-spec.md                # Complete technical specification
│   ├── architecture/                  # Architectural decisions
│   │   └── ybs-decisions.md           # Architectural Decision Records
│   └── general/                       # General documentation
│       └── ybs-lessons-learned.md     # Implementation checklist
│
├── steps/                             # Build steps
│   ├── README.md                      # Steps overview
│   ├── ybs-step_000000000000.md       # Step 0: Build Configuration
│   ├── ybs-step_478a8c4b0cef.md       # Step 1: Project Skeleton
│   ├── ybs-step_c5404152680d.md       # Step 2: Configuration & Providers
│   └── ybs-step_89b9e6233da5.md       # Step 3: Initial Implementation
│
├── docs/                              # Murphy-specific documentation
│   ├── murphy-principles.md           # Design principles (was bootstrap-principles.md)
│   ├── tool-architecture.md           # Hybrid tool system
│   ├── security-model.md              # Security layers
│   └── configuration.md               # Configuration system
│
└── builds/                            # Build outputs
    ├── test6/                         # Test build 6
    └── test7/                         # Test build 7 (current active)
        ├── CLAUDE.md                  # Build-specific guide
        ├── BUILD_CONFIG.json          # Configuration
        ├── BUILD_STATUS.md            # Status
        ├── Package.swift              # Swift package
        └── Sources/                   # Source code
```

---

## Quick Start Guides

### Starting a New Build

1. **Read framework guide**: [../../framework/methodology/executing-builds.md](../../framework/methodology/executing-builds.md)
2. **Create build directory**: `mkdir -p builds/BUILDNAME`
3. **Navigate**: `cd builds/BUILDNAME`
4. **Start Step 0**: Follow [steps/ybs-step_000000000000.md](steps/ybs-step_000000000000.md)
5. **Check for SESSION.md**: Resume from crash if found
6. **Follow build CLAUDE.md**: Use the build-specific guide

### Modifying Specifications

1. **Read existing specs**: Start with [specs/technical/ybs-spec.md](specs/technical/ybs-spec.md)
2. **Read spec guide**: [../../framework/methodology/writing-specs.md](../../framework/methodology/writing-specs.md)
3. **Check decisions**: Review [specs/architecture/ybs-decisions.md](specs/architecture/ybs-decisions.md) for conflicts
4. **Update specs**: Make changes to spec files
5. **Add ADR**: If architectural, add to [specs/architecture/ybs-decisions.md](specs/architecture/ybs-decisions.md)
6. **Update steps**: Ensure steps reflect spec changes

### Modifying Build Steps

1. **Read existing steps**: Start with [steps/README.md](steps/README.md)
2. **Read step guide**: [../../framework/methodology/writing-steps.md](../../framework/methodology/writing-steps.md)
3. **Check specs**: Ensure changes align with [specs/technical/ybs-spec.md](specs/technical/ybs-spec.md)
4. **Update step files**: Modify step markdown files
5. **Test changes**: Execute steps to verify they work

---

## Murphy Design Principles

**See [docs/murphy-principles.md](docs/murphy-principles.md) for complete details.**

Key principles:
1. **Configuration-first** - Step 0 collects ALL questions upfront
2. **Autonomous execution** - After Step 0, no user prompts needed
3. **Hybrid tools** - Built-in + external tools
4. **Security by default** - Sandboxed execution
5. **Traceability** - Every implementation traces to specs
6. **YBS-friendly** - First-class support for YBS builds (but not YBS-only)
7. **Murphy's Law mindset** - Assume things will go wrong, help users handle it

---

## Important Rules for Murphy Work

1. **Check SESSION.md**: Always check for crash recovery in build directories
2. **Use scratch/**: All temporary files in repository root scratch/
3. **Respect boundaries**:
   - Specs = WHAT to build (reference only during builds)
   - Steps = HOW to build (instructions for AI agents)
   - Builds = WHERE builds happen (working directory)
4. **Follow steps in order**: Don't skip or combine steps during builds
5. **Verify before proceeding**: Every step must pass verification
6. **Document everything**: Completed steps get DONE files in build-history/
7. **Update status**: Keep BUILD_STATUS.md current in builds
8. **One agent per build**: Don't work on a build if another agent is active

---

## Common Tasks

### Task: Start a new Murphy build
→ Read: [../../framework/methodology/executing-builds.md](../../framework/methodology/executing-builds.md)
→ Then: Create builds/NEWBUILD/ and start Step 0

### Task: Understand Murphy architecture
→ Read: [specs/technical/ybs-spec.md](specs/technical/ybs-spec.md)
→ Read: [docs/murphy-principles.md](docs/murphy-principles.md)

### Task: Modify Murphy specifications
→ Read: [specs/README.md](specs/README.md)
→ Read: [../../framework/methodology/writing-specs.md](../../framework/methodology/writing-specs.md)

### Task: Add a new build step
→ Read: [steps/README.md](steps/README.md)
→ Read: [../../framework/methodology/writing-steps.md](../../framework/methodology/writing-steps.md)

### Task: Resume a crashed build
→ Check: builds/BUILDNAME/SESSION.md
→ Follow: The recovery instructions in SESSION.md

---

## Reference Documentation

### Murphy System (This System)
- **[README.md](README.md)** - System overview
- **[specs/technical/ybs-spec.md](specs/technical/ybs-spec.md)** - Complete technical specification
- **[specs/architecture/ybs-decisions.md](specs/architecture/ybs-decisions.md)** - Architectural decisions
- **[docs/murphy-principles.md](docs/murphy-principles.md)** - Design principles

### YBS Framework (Methodology)
- **[../../framework/README.md](../../framework/README.md)** - Framework overview
- **[../../framework/docs/glossary.md](../../framework/docs/glossary.md)** - Standard terminology
- **[../../framework/methodology/executing-builds.md](../../framework/methodology/executing-builds.md)** - How to execute builds

### Repository Root
- **[../../CLAUDE.md](../../CLAUDE.md)** - Repository-level AI agent guide
- **[../../README.md](../../README.md)** - Repository overview

---

## Murphy + YBS Integration

Murphy was built **using** YBS to validate the framework, and now serves as the **reference implementation** for how AI agents can work with YBS.

**Murphy's dual purpose**:
1. **General AI chat tool**: Works for any development task
2. **YBS reference agent**: Demonstrates first-class YBS build execution

**Future YBS-specific features** (after extraction to separate repo):
- `murphy build` - Execute YBS build from current directory
- `murphy step <N>` - Execute specific YBS step
- `murphy verify` - Run YBS verification for current step
- Native BUILD_CONFIG.json support
- Built-in understanding of YBS step format

**But**: YBS works with ANY AI agent. Murphy is ONE option (the recommended one).

---

## Murphy Build History

**Active builds**:
- test6: Test build 6 (2026-01-17)
- test7: Current active build (2026-01-18, Steps 0-44 in various states)

**Status**: Active development (test7 is current working build)

---

## Version History

- **1.0.0** (2026-01-18): Renamed from bootstrap to Murphy, prepared for extraction to separate repository
- **0.1.0** (2026-01-17): Initial version after repository restructure

---

## Notes for AI Agents

- This CLAUDE.md is for the SYSTEM level (Murphy as a whole)
- Each BUILD has its own CLAUDE.md (e.g., builds/test7/CLAUDE.md)
- Use the build-specific CLAUDE.md when working inside a build directory
- Use this CLAUDE.md when working on specs, steps, or creating new builds
- Murphy is being extracted to separate repository (github.com/ScottYelich/murphy)
- Originally called "bootstrap" - renamed 2026-01-18 for clarity
- Murphy demonstrates how AI agents can work with YBS, but is not YBS-only

---

**Last updated**: 2026-01-18 (renamed to Murphy, prepared for repository extraction)
