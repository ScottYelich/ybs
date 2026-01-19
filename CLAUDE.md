# CLAUDE.md

**Version**: 1.0.1
**Last Updated**: 2026-01-18

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

**B. Examples** (`examples/`) - Reference example systems
- Each example: specs + steps + docs
- Self-contained (everything needed to build that system)
- **Examples**: 01-hello-world, 02-calculator, 03-rest-api

**C. Builds** (`examples/EXAMPLENAME/builds/`) - Active build workspaces
- Build outputs and artifacts
- SESSION.md for crash recovery (per build)
- BUILD_STATUS.md tracking progress
- **Location**: INSIDE each system definition (B + C together)

---

## Repository Structure

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
└── examples/                          # Collection of reference examples
    │
    ├── 01-hello-world/                # Simple example
    │   ├── README.md                  # Example overview
    │   ├── specs/                     # Specifications
    │   ├── steps/                     # Build steps
    │   ├── docs/                      # Documentation
    │   └── builds/                    # Build workspaces
    │       └── demo/                  # Example build
    │
    ├── 02-calculator/                 # Multi-module example
    │   ├── README.md
    │   ├── specs/
    │   ├── steps/
    │   ├── docs/
    │   └── builds/demo/
    │
    └── 03-rest-api/                   # Multi-tier example
        ├── README.md
        ├── specs/
        ├── steps/
        ├── docs/
        └── builds/demo/
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

### → Defining a New System (External Repository)
You're creating specs and steps for a new system:
- **Read**: [framework/methodology/writing-specs.md](framework/methodology/writing-specs.md)
- **Read**: [framework/methodology/writing-steps.md](framework/methodology/writing-steps.md)
- **Read**: [docs/external-systems.md](docs/external-systems.md) for external system setup
- **Create**: External directory with specs/, steps/, builds/
- **Goal**: Define WHAT to build and HOW to build it

**Remember**: Systems are typically created as external repositories, not in examples/.

---

### → Executing Build Steps (Building a System)
You're building a system using YBS:
- **Read**: [framework/methodology/executing-builds.md](framework/methodology/executing-builds.md)
- **Study**: Examples in examples/ directory for reference
- **Execute**: Start with Step 0 (Build Configuration) in your system
- **Continue**: Follow steps autonomously

**Working directory**: YOUR_SYSTEM/builds/BUILDNAME/ (in external repo or examples/)

---

### → Studying Example Systems (examples/)
You're studying reference implementations:
- **Read**: [examples/README.md](examples/README.md) for overview
- **Examples**: 01-hello-world, 02-calculator, 03-rest-api
- **Purpose**: Learn YBS patterns and practices
- **Location**: examples/EXAMPLENAME/

**Remember**: Examples are for reference only. Build your own systems externally.

**Note**: Murphy (former bootstrap system) was extracted to a separate repository.

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

- **Building a system**: `YOUR_SYSTEM/builds/BUILDNAME/SESSION.md` (in external repo)
- **Framework work**: `./SESSION.md` (repository root)
- **Studying examples**: `./SESSION.md` (repository root)

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
- ✅ Multiple systems: YOUR_SYSTEM_A/ + YOUR_SYSTEM_B/ (different agents, external repos)
- ✅ Multiple builds: YOUR_SYSTEM/builds/build1/ + build2/ (different agents)

**Not Supported**:
- ❌ Multiple agents on same build (two agents both on test5/)

**Reason**: Compilation locks, file conflicts, state confusion. One agent per build.

**See**: Repository structure supports parallel work on different builds.

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
2. **Study examples**: Navigate to examples/ for reference
3. **Set up your system**: See [docs/external-systems.md](docs/external-systems.md)
4. **Execute**: Start with Step 0 in your external system

### For System Designers

1. **Learn YBS**: [framework/README.md](framework/README.md)
2. **Learn specs**: [framework/methodology/writing-specs.md](framework/methodology/writing-specs.md)
3. **Learn steps**: [framework/methodology/writing-steps.md](framework/methodology/writing-steps.md)
4. **Create system**: External repository with specs/, steps/, and builds/

### For Framework Contributors

1. **Read**: [framework/README.md](framework/README.md)
2. **Read**: [framework/docs/glossary.md](framework/docs/glossary.md)
3. **Improve**: Methodology, templates, tools
4. **Test**: Build diverse system types

---

## Example Systems

**Three reference examples demonstrate YBS in action:**

- **01-hello-world**: Simple Python script (5 steps) - Learn basics
- **02-calculator**: CLI calculator (10 steps) - Multi-module, testing
- **03-rest-api**: Todo REST API (20 steps) - Multi-tier, persistence

**To study examples**: Read [examples/README.md](examples/README.md)

**Note**: Murphy (Swift AI tool) was extracted to a separate repository

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
9. **Traceability comments**: ALL source files must have `// Implements:` comments linking to specs

## 🚨 CRITICAL: Feature Addition Protocol

**When ANY new feature is requested - MUST follow this process:**

1. **SCAN existing specs/steps** for duplicates
   - If duplicate found: DENY or ASK for clarification
   - If similar found: ASK how it differs
2. **UPDATE SPECS FIRST** (never implement without spec)
   - Add to system specs with requirements + test requirements
3. **UPDATE/CREATE STEP** (add implementation instructions)
4. **IMPLEMENT** with mandatory test coverage and traceability:
   - ✅ Tests written BEFORE/DURING implementation
   - ✅ Minimum 60% line coverage (REQUIRED)
   - ✅ Target 80% line coverage (RECOMMENDED)
   - ✅ 100% coverage for critical paths
   - ✅ Traceability comments in ALL source files (REQUIRED)
5. **VERIFY** all tests pass + coverage met + traceability ≥80%

**NO EXCEPTIONS** - See: [framework/methodology/feature-addition-protocol.md](framework/methodology/feature-addition-protocol.md)

**Remember**: Specs first, implementation second. No step complete without tests.

---

## Tools

Helper scripts in `framework/tools/`:

```bash
framework/tools/list-specs.sh             # List specifications
framework/tools/list-steps.sh             # List build steps
framework/tools/deps.sh                   # Show dependencies
framework/tools/list-changelogs.sh        # List changelogs
framework/tools/check-traceability.sh     # Verify code-to-spec traceability
```

**Traceability Checking**:
```bash
# Verify all source files have traceability comments
./framework/tools/check-traceability.sh YOUR_SYSTEM BUILD_NAME

# Required thresholds:
# ✅ PASS: ≥80% files traced
# ⚠️ WARN: 60-79% files traced
# ✗ FAIL: <60% files traced
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

**See**: git log for complete restructure history

---

## Version History

- **1.0.1** (2026-01-18): Updated for Murphy extraction and systems → examples restructure
- **1.0.0** (2026-01-17): Major restructure - separated framework, systems, and builds
- **0.2.0** (2026-01-17): Documentation improvements, canonical docs, Quick Start
- **0.1.0** (2026-01-16): Initial version

---

## References

- **Framework**: [framework/README.md](framework/README.md)
- **Repository**: [README.md](README.md)
- **Glossary**: [framework/docs/glossary.md](framework/docs/glossary.md)
- **Examples**: [examples/README.md](examples/README.md)
- **External Systems**: [docs/external-systems.md](docs/external-systems.md)

