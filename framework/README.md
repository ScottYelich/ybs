# YBS Framework

**Yelich Build System: Specification-Driven Development (SDD) for Autonomous AI Agents**

**Version**: 0.2.2
**Last Updated**: 2026-01-18

📍 **You are here**: YBS Framework
**↑ Parent**: [Repository Root](../README.md)
🔗 **GitHub**: [github.com/ScottYelich/ybs](https://github.com/ScottYelich/ybs)

---

## What is This?

**This directory contains the YBS framework**—the methodology, templates, and tools for building software systems autonomously with AI agents.

The framework provides:
- **Methodology**: How to write specs, create build steps, and execute builds
- **Templates**: Reusable patterns for specifications, steps, and decisions
- **Tools**: Helper scripts for traceability, dependencies, and verification
- **Reference docs**: Glossary, file formats, configuration syntax

**For the complete YBS value proposition, comparisons to other tools, and why this matters, see** [Repository Root](../README.md).

---

## Three-Layer Architecture

YBS organizes work into three distinct layers:

### A. Framework (`framework/`) - THIS Directory

**The methodology itself**—language-agnostic, system-agnostic, reusable across all systems.

**Contains**:
- **methodology/**: Complete guides for writing specs, steps, and executing builds
- **templates/**: Reusable patterns (specs, steps, ADRs, configs)
- **tools/**: Helper scripts (list-specs, check-traceability, deps, etc.)
- **docs/**: Reference documentation (glossary, file formats)

**Purpose**: Define HOW to use YBS to build ANY system

**Applies to**: All systems built with YBS

**See**: [methodology/overview.md](methodology/overview.md) for complete methodology

---

### B. Systems (`../systems/`) - System Definitions

**Definitions of specific systems to build**—each system is self-contained.

**Each system contains**:
- **specs/**: Specifications (WHAT to build)
  - technical/, architecture/, business/, functional/, etc.
  - Complete requirements, architecture decisions, test criteria
- **steps/**: Build steps (HOW to build it)
  - Step 0 (Build Configuration)
  - Steps 1-N (sequential implementation instructions)
  - STEPS_ORDER.txt (execution order)
- **docs/**: System-specific documentation
- **builds/**: Build workspaces (see layer C)

**Purpose**: Define WHAT to build and HOW to build it (for one specific system)

**Example**: `../systems/bootstrap/` - Swift AI chat tool

**See**: [../systems/README.md](../systems/README.md) for systems overview

---

### C. Builds (`../systems/SYSTEMNAME/builds/`) - Build Workspaces

**Active build directories where AI agents do their work**—outputs and artifacts.

**Each build contains**:
- **BUILD_CONFIG.json**: Configuration from Step 0 (enables zero-interaction rebuilds)
- **BUILD_STATUS.md**: Progress tracking (which steps complete/in-progress/failed)
- **SESSION.md**: Crash recovery (enables resumption after interruption)
- **Source code**: Compiled application code
- **Tests**: Test code and test results
- **Artifacts**: Build outputs (binaries, packages, etc.)

**Purpose**: WHERE the actual building happens

**Location**: Inside each system directory (B + C together keep systems self-contained)

**Example**: `../systems/bootstrap/builds/test5/` - Current bootstrap build

---

## Why Three Layers?

**Separation of concerns**:
- **Framework (A)** evolves independently of specific systems
- **Systems (B)** are self-contained and don't depend on each other
- **Builds (C)** can run in parallel without conflicts

**Reusability**:
- One framework supports unlimited systems
- One system definition supports unlimited builds
- Templates and tools work across all systems

**Scalability**:
- Add new systems without changing framework
- Run multiple builds of same system concurrently
- Multiple teams can work on different systems simultaneously

---

## What the Framework Provides

### Core Methodology

- **[overview.md](methodology/overview.md)** - Complete YBS methodology
- **[writing-specs.md](methodology/writing-specs.md)** - How to write specifications
- **[writing-steps.md](methodology/writing-steps.md)** - How to create build steps
- **[executing-builds.md](methodology/executing-builds.md)** - How AI agents execute builds
- **[feature-addition-protocol.md](methodology/feature-addition-protocol.md)** - Process for adding features
- **[change-management.md](methodology/change-management.md)** - How to handle bugs, enhancements, and modifications

### Templates

Reusable patterns in `templates/`:
- **spec-template.md** - Specification template
- **step-template.md** - Build step template
- **adr-template.md** - Architecture decision record template
- **build-config-template.json** - BUILD_CONFIG.json template

### Tools

Helper scripts in `tools/`:
- **list-specs.sh** - List specifications for a system
- **list-steps.sh** - List build steps in execution order
- **deps.sh** - Show dependency tree
- **check-traceability.sh** - Verify code-to-spec traceability

### Reference Documentation

Technical references in `docs/`:
- **glossary.md** - Standard terminology (50+ terms)
- **step-format.md** - Step file format specification
- **config-markers.md** - CONFIG marker syntax

### For AI Agents

- **[CLAUDE.md](CLAUDE.md)** - Guidance for AI agents working on framework itself
- **[../CLAUDE.md](../CLAUDE.md)** - Repository-level guidance for AI agents

---

## Getting Started

### 🎯 I Want to Build Something with YBS

**Step 1**: Read [methodology/overview.md](methodology/overview.md) - Understand how YBS works

**Step 2**: Read [methodology/writing-specs.md](methodology/writing-specs.md) - Learn to write specifications

**Step 3**: Read [methodology/writing-steps.md](methodology/writing-steps.md) - Learn to create build steps

**Step 4**: Study `../systems/bootstrap/` - See complete real-world example

**Step 5**: Create your system in `../systems/YOUR_SYSTEM/` with specs, steps, and docs

---

### 🤖 I'm an AI Agent Building a System

**Step 1**: Read [methodology/executing-builds.md](methodology/executing-builds.md) - Your complete execution guide

**Step 2**: Navigate to `../systems/SYSTEMNAME/`

**Step 3**: Read `../systems/SYSTEMNAME/CLAUDE.md` - System-specific guidance

**Step 4**: Execute Step 0 (Build Configuration) in `../systems/SYSTEMNAME/builds/BUILDNAME/`

**Step 5**: Continue autonomously through Steps 1-N

---

### 🛠️ I Want to Improve the Framework

**Step 1**: Read [CLAUDE.md](CLAUDE.md) - Framework contributor guide

**Step 2**: Understand what needs improvement (methodology, templates, tools, docs)

**Step 3**: Make changes while maintaining language-agnostic, system-agnostic design

**Step 4**: Test changes with real systems (e.g., bootstrap)

**Step 5**: Submit improvements

---

## Framework Structure

```
framework/
├── README.md                          # This file - Framework landing page
├── CLAUDE.md                          # AI agent guidance for framework work
│
├── methodology/                       # Complete YBS methodology
│   ├── overview.md                    # How YBS works (comprehensive)
│   ├── writing-specs.md               # Specification authoring
│   ├── writing-steps.md               # Build step authoring
│   ├── executing-builds.md            # AI agent execution guide
│   └── feature-addition-protocol.md   # Feature addition process
│
├── templates/                         # Reusable templates
│   ├── spec-template.md               # Specification template
│   ├── step-template.md               # Build step template
│   ├── adr-template.md                # Architecture decision record
│   └── build-config-template.json     # BUILD_CONFIG.json template
│
├── docs/                              # Reference documentation
│   ├── glossary.md                    # Standard terminology (50+ terms)
│   ├── step-format.md                 # Step file format spec
│   └── config-markers.md              # CONFIG marker syntax
│
└── tools/                             # Helper scripts
    ├── README.md                      # Tools documentation
    ├── list-specs.sh                  # List specifications
    ├── list-steps.sh                  # List build steps
    ├── deps.sh                        # Dependency analysis
    └── check-traceability.sh          # Traceability verification
```

---

## Design Philosophy

### Specs as Source of Truth

**Specifications are the single source of truth. Code is derived from specs, not the other way around.**

In YBS:
- **Specs define reality**: What exists in specs is what should be built
- **Code implements specs**: Every function, class, and feature traces to a spec
- **Specs must stay current**: When requirements change, specs are updated FIRST, then code
- **No spec = No code**: Unspecified features are technical debt

This inverts traditional development where code becomes the documentation. In YBS, documentation (specs) drives the code.

**Why this matters**:
- AI agents can regenerate code from specs at any time
- Specs remain accurate because they drive implementation
- System understanding doesn't decay over time
- Rebuilding in new languages/platforms is trivial

**Rule**: If it's not in the specs, it doesn't exist. If code exists without specs, it's a bug.

---

### Sufficiency Over Completeness

Provide **just enough** detail for autonomous execution—not too much (overwhelming), not too little (ambiguous).

Specs and steps should be:
- Specific enough that AI agents don't get stuck
- General enough to allow implementation flexibility
- Focused on outcomes, not implementation details

---

### Configuration-First Always

Collect ALL decisions upfront in Step 0. Zero user prompts during Steps 1-N.

**Step 0 logic**:
1. Check if BUILD_CONFIG.json exists
2. If yes: Read config, skip questions, proceed to Step 1
3. If no: Ask questions, create BUILD_CONFIG.json, mark Step 0 complete

**Benefits**:
- First build: Questions asked once, config saved
- Subsequent builds: Config read, zero questions
- Machine-updatable: Scripts can modify config for automated regeneration

---

### Traceability by Default

Every implementation decision traces to specifications. Every line of code references its requirement.

**Two-level traceability**:

**Feature-level**:
- Build steps reference specs they implement
- Specs reference architectural decisions (ADRs)
- Clear audit trail from requirement to implementation

**Code-level**:
- Source files include `// Implements: spec § X.Y` comments
- Automated verification with `check-traceability.sh`
- Detects unspecified features automatically
- Minimum 80% of files must have traceability comments

---

### Verification-Driven Development

Explicit, automated verification criteria for every step. No vague "make sure it works."

**Each step must have**:
- Clear success criteria
- Automated checks where possible
- Tests that must pass
- Compilation that must succeed
- Specific outputs that must exist

**Verification policy**:
- Agent attempts verification
- If fails: Retry up to 3 times
- If still failing after 3 attempts: Stop and report error
- Only proceed to next step after verification passes

---

### Language-Agnostic by Design

Framework works for ANY programming language, platform, or domain. No assumptions.

**What this means**:
- Methodology docs don't assume Swift, Python, JavaScript, etc.
- Templates work for any language
- Tools work for any system structure
- Examples show multiple languages when helpful

**Examples of language-agnostic systems**:
- Swift command-line tools (bootstrap)
- Python web applications
- Rust embedded systems
- Go microservices
- JavaScript/TypeScript frontend apps
- C++ desktop applications

---

## Key Framework Concepts

### Step 0: Build Configuration

**ALWAYS execute Step 0 first**—collects all configuration upfront or reads from BUILD_CONFIG.json.

**Purpose**: Enable autonomous execution (Steps 1-N) and zero-interaction rebuilds

**How it works**:
1. Check if BUILD_CONFIG.json exists in build directory
2. **If exists**: Read config file, skip questions, proceed to Step 1
3. **If not exists**:
   - Scan all steps for {{CONFIG:...}} markers
   - Ask user questions
   - Save answers to BUILD_CONFIG.json
   - Mark Step 0 complete

**Result**: Steps 1-N can execute autonomously without user prompts

---

### Autonomous Execution

AI agents work continuously without interruption after Step 0.

**Rules**:
- After Step 0 complete, no user prompts needed
- Agent proceeds through steps automatically
- Only stops for critical errors or 3x verification failures
- Can run overnight, over weekends, for hours/days

**Why this works**:
- Step 0 collected all decisions upfront
- Steps reference BUILD_CONFIG.json for configuration
- Specs provide complete requirements
- Verification criteria are explicit

---

### Crash Recovery with SESSION.md

AI agents can crash and resume exactly where they left off.

**Protocol**:
1. **At session start**: Check for SESSION.md in build directory
2. **If found**: Read it, resume from last known state
3. **During work**: Update SESSION.md after every significant action
4. **On completion**: Move SESSION.md to build-history/

**SESSION.md contains**:
- Current step number
- What was completed
- What's in progress
- What's pending
- Recent actions taken

---

### Parallel Builds

Multiple AI agents can work simultaneously on different systems or different builds.

**Supported**:
- ✅ Multiple systems: One agent on bootstrap, another on calculator
- ✅ Multiple builds: One agent on test5, another on test6

**Not supported**:
- ❌ Same build: Two agents both working on test5 (causes file conflicts)

**Why**: Each build directory is an independent workspace. One agent per workspace prevents conflicts.

---

## Using the Framework

### Creating a New System

**1. Create system directory**:
```bash
mkdir -p systems/NEWSYSTEM/{specs,steps,docs,builds}
cd systems/NEWSYSTEM
```

**2. Write specifications** (`specs/`):
- Use templates from `framework/templates/`
- Define WHAT to build (requirements, architecture, tests)
- See `framework/methodology/writing-specs.md`

**3. Create build steps** (`steps/`):
- Start with Step 0 (Build Configuration)
- Add Steps 1-N for implementation
- Use templates from `framework/templates/`
- See `framework/methodology/writing-steps.md`

**4. Add documentation** (`docs/`):
- README.md (system overview)
- CLAUDE.md (AI agent guidance)
- System-specific principles, architecture, design

**5. Test with AI agent**:
- Have AI agent execute Step 0
- Verify agent can proceed autonomously
- Refine steps where agent gets stuck

---

### Improving the Framework

**When to improve**:
- Methodology docs are unclear or incomplete
- Templates don't cover common patterns
- Tools are missing or buggy
- AI agents get stuck on something not covered

**How to improve**:
1. Identify specific gap or issue
2. Research: How do existing systems handle this?
3. Generalize: Extract language-agnostic pattern
4. Document: Update methodology docs
5. Create templates: If pattern is reusable
6. Build tools: If automation would help
7. Test: Validate with real systems (bootstrap)

**See**: [CLAUDE.md](CLAUDE.md) for complete framework contributor guide

---

## Tools

Helper scripts in `framework/tools/`:

```bash
# List specifications for a system
framework/tools/list-specs.sh SYSTEMNAME

# List build steps in execution order
framework/tools/list-steps.sh SYSTEMNAME

# Show dependency tree
framework/tools/deps.sh SYSTEMNAME

# Verify code-to-spec traceability
framework/tools/check-traceability.sh SYSTEMNAME BUILDNAME
```

**Thresholds**:
- ✅ **PASS**: ≥80% files have traceability comments
- ⚠️ **WARN**: 60-79% files traced
- ✗ **FAIL**: <60% files traced

---

## Version History

- **0.2.2** (2026-01-18): Restructured to focus on A/B/C architecture, removed duplicate content, clarified framework role
- **0.2.1** (2026-01-18): Positioned YBS as SDD, added comparison to other SDD tools, BUILD_CONFIG.json reading documentation
- **0.2.0** (2026-01-18): Comprehensive framework documentation improvements (specs as source of truth, traceability)
- **0.1.0** (2026-01-17): Initial framework documentation after restructure

---

## References

### For YBS Value Proposition

**See [Repository Root](../README.md)** for:
- What YBS is and why it matters
- Comparison to other SDD tools (GitHub Spec Kit, AWS Kiro, Tessl)
- YBS unique advantages
- Why this is the future of software development
- Complete feature list and capabilities

### For Framework Details

- **[methodology/overview.md](methodology/overview.md)** - Complete technical methodology
- **[../systems/bootstrap/](../systems/bootstrap/)** - Real-world example system
- **[docs/glossary.md](docs/glossary.md)** - Standard terminology

### For AI Agents

- **[CLAUDE.md](CLAUDE.md)** - Framework work guidance
- **[../CLAUDE.md](../CLAUDE.md)** - Repository work guidance
- **[methodology/executing-builds.md](methodology/executing-builds.md)** - Build execution guide

---

## Contact & Community

**Repository**: [github.com/ScottYelich/ybs](https://github.com/ScottYelich/ybs)
**Issues**: [github.com/ScottYelich/ybs/issues](https://github.com/ScottYelich/ybs/issues)

---

*Build software autonomously with AI agents using YBS.*
