# CLAUDE.md - Bootstrap System

**Version**: 1.0.0
**Last Updated**: 2026-01-17

📍 **You are here**: YBS Repository > Systems > Bootstrap > AI Agent Guide
📚 **See also**: [Bootstrap README](README.md) | [Framework](../../framework/README.md) | [Glossary](../../framework/docs/glossary.md)

---

This file provides guidance to Claude Code when working on the Bootstrap system.

## Bootstrap System Overview

**Bootstrap is a Swift-based AI chat tool (LLM coding assistant) for macOS.** It's the first system being built WITH the YBS framework to validate and refine the methodology.

**Location**: `systems/bootstrap/`

---

## What Are You Doing? (Task Identification)

### → Working on Bootstrap Specifications (specs/)
You're defining or updating WHAT the bootstrap system should do:
- **Read**: [specs/README.md](specs/README.md) for specs overview
- **Read**: [../../framework/methodology/writing-specs.md](../../framework/methodology/writing-specs.md) for how to write specs
- **Focus**: Technical requirements, architectural decisions, design principles
- **Goal**: Define the bootstrap system clearly and completely

**Key files**:
- specs/ybs-spec.md - Complete technical specification
- specs/ybs-decisions.md - Architectural Decision Records (ADRs)
- specs/ybs-lessons-learned.md - Implementation checklist

---

### → Working on Bootstrap Build Steps (steps/)
You're defining or updating HOW to build the bootstrap system:
- **Read**: [steps/README.md](steps/README.md) for steps overview
- **Read**: [../../framework/methodology/writing-steps.md](../../framework/methodology/writing-steps.md) for how to write steps
- **Focus**: Step-by-step build instructions for AI agents
- **Goal**: Enable autonomous builds of the bootstrap system

**Key files**:
- steps/ybs-step_000000000000.md - Step 0 (Build Configuration)
- steps/ybs-step_478a8c4b0cef.md - Step 1 (Project Skeleton)
- steps/ybs-step_c5404152680d.md - Step 2 (Configuration & Providers)
- steps/ybs-step_89b9e6233da5.md - Step 3 (Initial Implementation)

---

### → Executing a Bootstrap Build (builds/)
You're BUILDING the bootstrap system using the steps:
- **Read**: [../../framework/methodology/executing-builds.md](../../framework/methodology/executing-builds.md) for execution guide
- **Navigate**: To builds/BUILDNAME/ (e.g., builds/test5/)
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

## Bootstrap System Structure

```
bootstrap/
├── README.md                          # System overview (start here)
├── CLAUDE.md                          # This file - AI agent guide
│
├── specs/                             # System specifications
│   ├── README.md                      # Spec organization
│   ├── ybs-spec.md                    # Complete technical specification
│   ├── ybs-decisions.md               # Architectural Decision Records
│   └── ybs-lessons-learned.md         # Implementation checklist
│
├── steps/                             # Build steps
│   ├── README.md                      # Steps overview
│   ├── ybs-step_000000000000.md       # Step 0: Build Configuration
│   ├── ybs-step_478a8c4b0cef.md       # Step 1: Project Skeleton
│   ├── ybs-step_c5404152680d.md       # Step 2: Configuration & Providers
│   └── ybs-step_89b9e6233da5.md       # Step 3: Initial Implementation
│
├── docs/                              # Bootstrap-specific documentation
│   ├── bootstrap-principles.md        # Design principles
│   ├── tool-architecture.md           # Hybrid tool system
│   ├── security-model.md              # Security layers
│   └── configuration.md               # Configuration system
│
└── builds/                            # Build outputs
    ├── test1/                         # First test build
    ├── test2/                         # Second test build
    ├── test3/                         # Third test build
    ├── test4/                         # Fourth test build
    └── test5/                         # Current active build
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

1. **Read existing specs**: Start with [specs/ybs-spec.md](specs/ybs-spec.md)
2. **Read spec guide**: [../../framework/methodology/writing-specs.md](../../framework/methodology/writing-specs.md)
3. **Check decisions**: Review [specs/ybs-decisions.md](specs/ybs-decisions.md) for conflicts
4. **Update specs**: Make changes to spec files
5. **Add ADR**: If architectural, add to [specs/ybs-decisions.md](specs/ybs-decisions.md)
6. **Update steps**: Ensure steps reflect spec changes

### Modifying Build Steps

1. **Read existing steps**: Start with [steps/README.md](steps/README.md)
2. **Read step guide**: [../../framework/methodology/writing-steps.md](../../framework/methodology/writing-steps.md)
3. **Check specs**: Ensure changes align with [specs/ybs-spec.md](specs/ybs-spec.md)
4. **Update step files**: Modify step markdown files
5. **Test changes**: Execute steps to verify they work

---

## Bootstrap Design Principles

**See [docs/bootstrap-principles.md](docs/bootstrap-principles.md) for complete details.**

Key principles:
1. **Configuration-first** - Step 0 collects ALL questions upfront
2. **Autonomous execution** - After Step 0, no user prompts needed
3. **Hybrid tools** - Built-in + external tools
4. **Security by default** - Sandboxed execution
5. **Traceability** - Every implementation traces to specs

---

## Important Rules for Bootstrap Work

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

### Task: Start a new bootstrap build
→ Read: [../../framework/methodology/executing-builds.md](../../framework/methodology/executing-builds.md)
→ Then: Create builds/NEWBUILD/ and start Step 0

### Task: Understand bootstrap architecture
→ Read: [specs/ybs-spec.md](specs/ybs-spec.md)
→ Read: [docs/bootstrap-principles.md](docs/bootstrap-principles.md)

### Task: Modify bootstrap specifications
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

### Bootstrap System (This System)
- **[README.md](README.md)** - System overview
- **[specs/ybs-spec.md](specs/ybs-spec.md)** - Complete technical specification
- **[specs/ybs-decisions.md](specs/ybs-decisions.md)** - Architectural decisions
- **[docs/bootstrap-principles.md](docs/bootstrap-principles.md)** - Design principles

### YBS Framework (Methodology)
- **[../../framework/README.md](../../framework/README.md)** - Framework overview
- **[../../framework/docs/glossary.md](../../framework/docs/glossary.md)** - Standard terminology
- **[../../framework/methodology/executing-builds.md](../../framework/methodology/executing-builds.md)** - How to execute builds

### Repository Root
- **[../../CLAUDE.md](../../CLAUDE.md)** - Repository-level AI agent guide
- **[../../README.md](../../README.md)** - Repository overview

---

## Bootstrap Build History

**Active builds**:
- test1: First test build (2026-01-16, Step 0 complete)
- test2: Second test build (2026-01-16, Step 0 complete)
- test3: Third test build (2026-01-16, Step 0 complete)
- test4: Fourth test build (2026-01-16, Step 0 complete)
- test5: Current active build (2026-01-16, Step 0 complete, Step 1-3 in progress)

**Status**: In progress (Steps 0-3 defined, test5 is active build)

---

## Version History

- **1.0.0** (2026-01-17): Initial version after repository restructure

---

## Notes for AI Agents

- This CLAUDE.md is for the SYSTEM level (bootstrap as a whole)
- Each BUILD has its own CLAUDE.md (e.g., builds/test5/CLAUDE.md)
- Use the build-specific CLAUDE.md when working inside a build directory
- Use this CLAUDE.md when working on specs, steps, or creating new builds
- Bootstrap is ONE example system - YBS can build ANY type of system

---

**Last updated**: 2026-01-17 (after repository restructure)
