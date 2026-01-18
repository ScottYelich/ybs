# CLAUDE.md

**Version**: 1.0.0
**Last Updated**: 2026-01-17

📍 **You are here**: YBS Repository > AI Agent Guide
📚 **See also**: [README.md](README.md) | [Framework](framework/README.md) | [Glossary](framework/docs/glossary.md)

---

This file provides guidance to Claude Code when working in this repository.

## Repository Overview

**This repository contains the YBS (Yelich Build System) framework and systems built with it.**

### Three-Layer Architecture

**A. Framework** (`framework/`) - The YBS methodology itself
- How to write specs, steps, and execute builds
- Templates and patterns (reusable)
- Tools and documentation
- **Applies to**: ANY system being built

**B. Systems** (`systems/`) - Definitions of specific systems to build
- Each system: specs + steps + docs
- Self-contained (everything needed to build that system)
- **Examples**: bootstrap (Swift AI tool), calculator, web-app, etc.

**C. Builds** (`systems/SYSTEMNAME/builds/`) - Active build workspaces
- Build outputs and artifacts
- SESSION.md for crash recovery (per build)
- BUILD_STATUS.md tracking progress
- **Location**: INSIDE each system definition (B + C together)

---

## New Structure (After Restructure)

```
ybs/
├── CLAUDE.md                          # This file - AI agent guide
├── README.md                          # Repository overview
├── SESSION.md.template                # Template for session tracking
├── scratch/                           # [TRANSIENT] Working files
├── LICENSE
│
├── framework/                         # "A" - YBS Framework
│   ├── README.md                      # Framework overview
│   ├── methodology/                   # How YBS works
│   │   ├── overview.md                # What is YBS
│   │   ├── writing-specs.md           # How to write specs
│   │   ├── writing-steps.md           # How to write steps
│   │   └── executing-builds.md        # How to execute (AI agents)
│   ├── templates/                     # Reusable templates
│   │   ├── spec-template.md
│   │   ├── step-template.md
│   │   ├── adr-template.md
│   │   └── build-config-template.json
│   ├── docs/                          # Framework docs
│   │   ├── glossary.md                # Standard terminology
│   │   ├── step-format.md             # Step file format
│   │   └── config-markers.md          # CONFIG syntax
│   ├── tools/                         # Helper scripts
│   │   ├── list-specs.sh
│   │   ├── list-steps.sh
│   │   ├── deps.sh
│   │   └── list-changelogs.sh
│   └── changelogs/                    # Framework changes
│
└── systems/                           # Collection of system definitions
    │
    └── bootstrap/                     # "B" - Bootstrap system (Swift AI tool)
        ├── README.md                  # Bootstrap overview
        ├── CLAUDE.md                  # Guide for working on bootstrap
        │
        ├── specs/                     # Bootstrap specifications
        │   ├── README.md
        │   ├── ybs-spec.md            # Technical specification
        │   ├── ybs-decisions.md       # Architectural decisions
        │   └── ybs-lessons-learned.md # Implementation checklist
        │
        ├── steps/                     # Bootstrap build steps
        │   ├── README.md
        │   ├── ybs-step_000000000000.md  # Step 0
        │   ├── ybs-step_478a8c4b0cef.md  # Step 1
        │   ├── ybs-step_c5404152680d.md  # Step 2
        │   └── ybs-step_89b9e6233da5.md  # Step 3
        │
        ├── docs/                      # Bootstrap-specific docs
        │   ├── bootstrap-principles.md
        │   ├── tool-architecture.md
        │   ├── security-model.md
        │   └── configuration.md
        │
        └── builds/                    # "C" - Build outputs
            ├── test1/
            ├── test2/
            ├── test3/
            ├── test4/
            └── test5/                 # Current build
                ├── SESSION.md         # Per-build session
                ├── BUILD_CONFIG.json
                ├── BUILD_STATUS.md
                ├── Package.swift
                └── Sources/
```

---

## What Are You Doing? (Task Identification)

### → Working on YBS Framework Itself (framework/)
You're improving the methodology:
- **Read**: [framework/README.md](framework/README.md) for overview
- **Focus**: Language-agnostic concepts, templates, tools
- **Goal**: Make framework better for building ANY system

**Key files**:
- framework/methodology/ - How YBS works
- framework/templates/ - Reusable patterns
- framework/tools/ - Helper scripts

---

### → Defining a New System (systems/NEWSYSTEM/)
You're creating specs and steps for a new system:
- **Read**: [framework/methodology/writing-specs.md](framework/methodology/writing-specs.md)
- **Read**: [framework/methodology/writing-steps.md](framework/methodology/writing-steps.md)
- **Create**: systems/NEWSYSTEM/specs/ and systems/NEWSYSTEM/steps/
- **Goal**: Define WHAT to build and HOW to build it

**Remember**: System definitions are self-contained (specs + steps + docs).

---

### → Executing Build Steps (Building a System)
You're building a system using YBS:
- **Read**: [framework/methodology/executing-builds.md](framework/methodology/executing-builds.md)
- **Navigate**: To systems/SYSTEMNAME/
- **Execute**: Start with Step 0 (Build Configuration)
- **Continue**: Follow steps autonomously

**Working directory**: systems/SYSTEMNAME/builds/BUILDNAME/

---

### → Working on Bootstrap System (systems/bootstrap/)
You're working on the Swift AI chat tool:
- **Read**: [systems/bootstrap/README.md](systems/bootstrap/README.md) for overview
- **Read**: [systems/bootstrap/CLAUDE.md](systems/bootstrap/CLAUDE.md) for AI agent guide
- **Specs**: systems/bootstrap/specs/ (WHAT to build)
- **Steps**: systems/bootstrap/steps/ (HOW to build)
- **Builds**: systems/bootstrap/builds/test5/ (WHERE you work)

**Remember**: Bootstrap is ONE example system, not YBS itself.

---

## 🚨 CRITICAL: Session File Crash-Recovery System

**Claude crashes frequently. Maintain session tracking for crash recovery.**

### Mandatory Session File Protocol

**ALWAYS follow this at the start of ANY session:**

1. **Check for SESSION.md** in your working directory
   - **If found**: Read it, resume from where it left off
   - **If not found**: Create new SESSION.md using template

2. **Update SESSION.md regularly** after every significant action:
   - After reading files
   - After making edits
   - After running commands
   - Before complex operations

3. **Clean up on completion**:
   - **If working on build step**: Move SESSION.md → build-history/
   - **If NOT on build step**: Delete SESSION.md
   - Never leave SESSION.md if session completed normally

### SESSION.md Location

**IMPORTANT**: SESSION.md location depends on what you're working on:

- **Building a system**: `systems/SYSTEMNAME/builds/BUILDNAME/SESSION.md`
- **Framework work**: `./SESSION.md` (repository root)
- **System definition**: `systems/SYSTEMNAME/SESSION.md`

**One SESSION.md per build** - enables parallel agents on different builds.

### Template

Use `SESSION.md.template` from repository root as starting point.

**Why This Matters**:
- ✅ Next Claude session resumes instantly
- ✅ No work is lost
- ✅ Clear state of what's done/pending
- ✅ Human doesn't need to re-explain

---

## 🗂️ CRITICAL: Session Work Files Directory

**Use `scratch/` for ALL temporary working files.**

### Mandatory Work Files Protocol

1. **Use scratch/ directory** for all temporary files:
   ```bash
   mkdir -p scratch
   ```
   - Analysis documents
   - Working drafts
   - Temporary data
   - Any file NOT part of deliverable

2. **Never commit scratch/** - Already in .gitignore

3. **Clean up when done**:
   ```bash
   ls -la scratch/           # Review first
   rm -r scratch/            # Remove directory (no wildcards!)
   ```

**When to clean**: After completing step/session successfully

---

## Parallel Execution Support

**Supported Parallelization**:
- ✅ Multiple systems: systems/bootstrap/ + systems/calculator/ (different agents)
- ✅ Multiple builds: systems/bootstrap/builds/test5/ + test6/ (different agents)

**Not Supported**:
- ❌ Multiple agents on same build (two agents both on test5/)

**Reason**: Compilation locks, file conflicts, state confusion. One agent per build.

**See**: scratch/parallelization-analysis.md for complete analysis.

---

## Key Framework Concepts

### 1. Configuration-First (Step 0)

**Step 0 collects ALL questions upfront**:
- Generates BUILD_CONFIG.json
- Subsequent steps read from config (no prompts)
- Enables fully autonomous execution

### 2. Autonomous Execution

**AI agents work continuously without interruption**:
- After Step 0, no user prompts needed
- Agent proceeds through steps automatically
- Only stops for critical errors or 3x verification failures

### 3. Traceability

**Every implementation traces to specifications**:
- Steps reference specs they implement
- Specs reference decisions (ADRs)
- Clear audit trail from requirement to code

### 4. Verification-Driven

**Every step has explicit verification criteria**:
- Automated checks where possible
- Tests must pass before proceeding
- Retry limit (3 attempts) prevents infinite loops

---

## Quick Navigation

### For AI Agents Building Systems

1. **Learn YBS**: [framework/methodology/executing-builds.md](framework/methodology/executing-builds.md)
2. **Choose system**: Navigate to systems/SYSTEMNAME/
3. **Read system guide**: systems/SYSTEMNAME/CLAUDE.md
4. **Execute**: Start with Step 0 in systems/SYSTEMNAME/steps/

### For System Designers

1. **Learn YBS**: [framework/README.md](framework/README.md)
2. **Learn specs**: [framework/methodology/writing-specs.md](framework/methodology/writing-specs.md)
3. **Learn steps**: [framework/methodology/writing-steps.md](framework/methodology/writing-steps.md)
4. **Create system**: systems/NEWSYSTEM/ with specs/ and steps/

### For Framework Contributors

1. **Read**: [framework/README.md](framework/README.md)
2. **Read**: [framework/docs/glossary.md](framework/docs/glossary.md)
3. **Improve**: Methodology, templates, tools
4. **Test**: Build diverse system types

---

## Bootstrap Example

**The bootstrap system demonstrates YBS in action:**

- **Location**: systems/bootstrap/
- **What**: Swift-based AI chat tool for macOS
- **Purpose**: Validate YBS framework through real-world use
- **Status**: In progress (Steps 0-3 complete, test5 build active)

**To work on bootstrap**: Read [systems/bootstrap/CLAUDE.md](systems/bootstrap/CLAUDE.md)

---

## Important Rules

1. **Check SESSION.md**: Always check for crash recovery
2. **Use scratch/**: All temporary files go there
3. **One agent per build**: Don't work on build if another agent is active
4. **Follow steps in order**: Don't skip or combine steps
5. **Verify before proceeding**: Every step must pass verification
6. **Document everything**: Completed steps get DONE files
7. **Update status**: Keep BUILD_STATUS.md current
8. **Clean up**: Remove scratch/ and SESSION.md when done

## 🚨 CRITICAL: Feature Addition Protocol

**When ANY new feature is requested - MUST follow this process:**

1. **SCAN existing specs/steps** for duplicates
   - If duplicate found: DENY or ASK for clarification
   - If similar found: ASK how it differs
2. **UPDATE SPECS FIRST** (never implement without spec)
   - Add to system specs with requirements + test requirements
3. **UPDATE/CREATE STEP** (add implementation instructions)
4. **IMPLEMENT** with mandatory test coverage:
   - ✅ Tests written BEFORE/DURING implementation
   - ✅ Minimum 60% line coverage (REQUIRED)
   - ✅ Target 80% line coverage (RECOMMENDED)
   - ✅ 100% coverage for critical paths
5. **VERIFY** all tests pass + coverage met

**NO EXCEPTIONS** - See: [framework/methodology/feature-addition-protocol.md](framework/methodology/feature-addition-protocol.md)

**Remember**: Specs first, implementation second. No step complete without tests.

---

## Tools

Helper scripts in `framework/tools/`:

```bash
framework/tools/list-specs.sh        # List specifications
framework/tools/list-steps.sh        # List build steps
framework/tools/deps.sh              # Show dependencies
framework/tools/list-changelogs.sh   # List changelogs
```

---

## Restructure Note

**This repository was restructured on 2026-01-17** to separate:
- **A**: Framework (methodology)
- **B**: System definitions (specs + steps)
- **C**: Build outputs (inside B)

**Benefits**:
- Clear separation of concerns
- Supports multiple systems easily
- Enables parallel builds
- Self-contained system definitions

**See**: scratch/restructure-plan.md for complete restructure documentation

---

## Version History

- **1.0.0** (2026-01-17): Major restructure - separated framework, systems, and builds
- **0.2.0** (2026-01-17): Documentation improvements, canonical docs, Quick Start
- **0.1.0** (2026-01-16): Initial version

---

## References

- **Framework**: [framework/README.md](framework/README.md)
- **Repository**: [README.md](README.md)
- **Glossary**: [framework/docs/glossary.md](framework/docs/glossary.md)
- **Bootstrap**: [systems/bootstrap/README.md](systems/bootstrap/README.md)

