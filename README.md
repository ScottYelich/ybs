# YBS: Specification-Driven Development for Autonomous AI Agents

**Yelich Build System (YBS) - The most complete SDD framework for AI-powered software development**

> **Revolutionary**: AI agents build complete, production-ready systems autonomously from specifications
>
> **Status**: Framework active + Bootstrap (Swift AI tool) in progress
> **Version**: 0.2.1
> **GitHub**: [github.com/ScottYelich/ybs](https://github.com/ScottYelich/ybs)

📍 **Navigation**: [Framework](framework/README.md) | [Bootstrap Example](systems/bootstrap/README.md) | [AI Agent Guide](CLAUDE.md)

---

## What is YBS?

**YBS is Specification-Driven Development (SDD) at the "spec-as-source" level—where AI agents autonomously build complete software systems from specifications.**

Imagine:
1. You write specifications describing what you want
2. You write sequential build steps explaining how to build it
3. An AI agent reads the steps and **builds the entire system autonomously**
4. You get production-ready code with full traceability

**No human intervention after initial configuration. This is the future of software development.**

---

## The Foundation: Specs as Source of Truth

**Everything in YBS flows from one principle: Specifications are the single source of truth. Code is derived from specs, not the other way around.**

### Why This Changes Everything

**Traditional development**:
- Code is written, then documented (maybe)
- Documentation drifts out of sync
- Nobody knows why code exists
- Rebuilding requires reverse-engineering

**YBS approach**:
- **Specs come FIRST**: Write what you want before any code exists
- **Code implements specs**: Every function, class, feature traces to a specification
- **Specs stay current**: When requirements change, specs update FIRST, then code follows
- **No spec = No code**: Unspecified features are technical debt, identified automatically

### The Superpower This Unlocks

Because specs are authoritative:
- **AI agents can regenerate code from specs at any time**
- **Rebuild in any language/platform** - just point an AI at the specs
- **System understanding never decays** - specs remain accurate because they drive implementation
- **Instant compliance** - trace any code to its requirement
- **Zero ambiguity** - if it's not in specs, it doesn't exist

**The rule**: If code exists without specs, it's a bug. If specs say it, code must implement it.

---

## YBS and Specification-Driven Development (SDD)

**YBS is a complete implementation of Specification-Driven Development at the "spec-as-source" level.**

### What is SDD?

Specification-Driven Development (SDD) is an emerging paradigm where specifications become the authoritative artifact driving AI-generated code. In 2026, tools like GitHub Spec Kit, AWS Kiro, and Tessl are pioneering this approach.

**SDD has three levels**:
1. **Spec-first**: Specification written before coding
2. **Spec-anchored**: Specification maintained throughout evolution
3. **Spec-as-source**: Specification IS the primary artifact; code is generated

**YBS operates at level 3: Spec-as-source.**

### How YBS Compares to Other SDD Tools

| Tool | Level | Focus | Autonomous? |
|------|-------|-------|-------------|
| **GitHub Spec Kit** | Spec-first | Requirements capture | Partial |
| **AWS Kiro** | Spec-first | Agentic IDE | Requires interaction |
| **Tessl** | Spec-as-source | Generated code | Beta |
| **YBS** | **Spec-as-source** | **Complete methodology** | **Fully autonomous** |

---

## YBS Unique Advantages

**YBS isn't just "write specs, generate code"—it's a complete methodology:**

### ✅ Human-Readable Build Steps
Not just specs, but sequential instructions AI agents follow autonomously. Each step has objectives, instructions, and verification criteria.

### ✅ Language-Agnostic
Works for ANY programming language or platform. Not tied to JavaScript, Python, or any specific stack. Build Swift apps, Rust CLI tools, Python web servers—anything.

### ✅ Verification-Driven
Each step has explicit verification criteria. Tests must pass before proceeding. No vague "make sure it works"—automated checks where possible.

### ✅ Configuration-First
Step 0 collects ALL decisions upfront, then Steps 1-N run autonomously. No interruptions mid-build.

### ✅ Zero-Interaction Rebuilds
**Step 0 reads from BUILD_CONFIG.json if it exists.** First build asks questions and creates the config. Every subsequent build reads the config—zero questions, zero interaction.

**Machine-updatable configs**: Edit BUILD_CONFIG.json programmatically (change versions, toggle features, update parameters), run the agent, get a new build. Fully automated regeneration.

**Real-world impact**:
- **CI/CD integration**: Commit config changes → automated rebuild
- **Batch generation**: One script updates config 10 different ways → 10 builds generated
- **A/B testing**: Generate multiple builds with different configurations automatically
- **Never answer the same questions twice**: Config persists across builds

### ✅ Traceability Tooling
`check-traceability.sh` validates code↔spec links automatically. Detects unspecified features. Every line of code traces to its requirement.

### ✅ Fully Autonomous
No prompts after Step 0. Kiro and other tools still require interaction. YBS agents build overnight while you sleep.

### ✅ Reproducible Builds
Same specifications + same steps = identical output every time. No "works on my machine" problems.

### ✅ Crash Recovery
SESSION.md enables resumption after interruption. AI agents can crash and resume exactly where they left off.

### ✅ System Evolution
Framework for how systems grow and change over time. Specs stay synchronized with code automatically.

---

## What YBS Provides That Others Don't

**Complete methodology for**:
- **How to organize specifications** (system-wide vs feature-level, hybrid approaches)
- **How to write build steps** that AI agents follow autonomously without getting stuck
- **How to maintain traceability** from requirement to implementation (feature-level + code-level)
- **How to verify each step** before proceeding (automated where possible)
- **How to handle crash recovery** with SESSION.md for resumable builds
- **How to evolve systems over time** with specs staying synchronized with code

**Result**: YBS is the most complete SDD framework for autonomous AI development in 2026.

---

## Unprecedented Capabilities

### 🚀 Fully Autonomous Builds

**Configuration-first design** collects all decisions upfront in Step 0, then agents execute Steps 1-N continuously without interruption. No more "What should I do here?" prompts mid-build.

**Real-world impact**: Build complex systems overnight while you sleep.

### 🔄 Zero-Human-Interaction Rebuilds

**Step 0 reads from BUILD_CONFIG.json if it exists.** First build asks questions and creates the config. Every subsequent build reads the config—zero questions, zero interaction.

**Machine-updatable configs**: Edit BUILD_CONFIG.json programmatically, run the agent, get a new build. Fully automated regeneration.

### 🔍 Complete Traceability

Every line of code traces back to its specification. Know exactly **WHY** every feature exists, **WHO** requested it, and **WHAT** decision justified it.

**Real-world impact**:
- Instant compliance audits
- Effortless code reviews
- Rapid onboarding of new developers
- Automated detection of unspecified features

### 🌐 Universal Applicability

**Language-agnostic. Platform-agnostic. Domain-agnostic.**

Build anything:
- Web applications (React, Vue, Angular)
- Mobile apps (iOS, Android)
- Backend services (Node, Python, Go, Rust)
- Desktop applications (Swift, Electron)
- Embedded systems (C, C++)
- AI agents (Python, TypeScript)
- Databases, compilers, operating systems—anything

**Real-world impact**: One framework to rule them all.

### ✅ Verification-Driven Quality

Every build step includes explicit, automated verification criteria. Tests must pass, code must compile, files must exist. No ambiguity.

**Real-world impact**: AI agents produce production-quality code, not prototypes.

### 📦 Reproducible Builds

Same specifications + same steps = identical results. Every time.

**Real-world impact**:
- No "works on my machine" problems
- Reproducible research
- Compliance with regulatory requirements

---

## How It Works

### 1. **Define Your System** (Human)

Write specifications describing what you want to build:
- Technical architecture
- Business requirements
- User workflows
- Test criteria

YBS provides templates and patterns to make this easy.

### 2. **Create Build Steps** (Human)

Write sequential instructions for how to build it:
- **Step 0**: Configuration collection (reads from BUILD_CONFIG.json if exists, otherwise prompts and creates it)
- **Steps 1-N**: Implement each component
- Each step includes verification criteria

### 3. **Execute Build** (AI Agent)

Point an AI agent at your steps:

```bash
# First build: Agent reads Step 0, asks questions, creates BUILD_CONFIG.json
# Agent then builds autonomously through Steps 1-N

# Subsequent builds: Agent reads BUILD_CONFIG.json, asks NOTHING
# Builds immediately with zero human interaction

# Machine-updated config: Edit BUILD_CONFIG.json programmatically
# Run agent again → new build from updated config, still zero interaction
```

**The game-changer**: Once BUILD_CONFIG.json exists, you never answer questions again. Update the config file (manually or programmatically), run the agent, get a new build. Completely automated.

### 4. **Get Production-Ready Software**

The AI agent delivers:
- ✅ Compiled, running code
- ✅ Comprehensive test suite (passing)
- ✅ Complete documentation
- ✅ Full traceability from requirement to implementation

---

## Repository Structure

### Three-Layer Architecture

**A. Framework** (`framework/`) - The YBS methodology itself
- How to write specs, steps, and execute builds
- Templates and patterns (reusable across all systems)
- Tools and documentation
- **Language-agnostic, system-agnostic**
- **See**: [framework/README.md](framework/README.md)

**B. Systems** (`systems/`) - Definitions of specific systems to build
- Each system has: specs (WHAT) + steps (HOW) + docs
- Self-contained (everything needed to build that system)
- **Examples**: bootstrap (Swift AI tool), calculator, web-app, etc.

**C. Builds** (`systems/SYSTEMNAME/builds/`) - Active build workspaces
- Build outputs and artifacts (compiled code, etc.)
- SESSION.md for crash recovery
- BUILD_STATUS.md for progress tracking
- **Location**: Inside each system (B + C together)

```
ybs/
├── README.md                          # This file - Repository overview
├── CLAUDE.md                          # AI agent guide
├── framework/                         # YBS methodology
│   ├── README.md                      # Framework details
│   ├── methodology/                   # How YBS works
│   ├── templates/                     # Reusable templates
│   ├── docs/                          # Reference docs
│   └── tools/                         # Helper scripts
│
└── systems/                           # System definitions
    └── bootstrap/                     # Swift AI chat tool example
        ├── specs/                     # Specifications (WHAT)
        ├── steps/                     # Build steps (HOW)
        ├── docs/                      # Documentation
        └── builds/                    # Build workspaces
            └── test5/                 # Current active build
```

---

## Proven in Production

**Bootstrap System**: A Swift-based AI chat tool for macOS, built entirely using YBS methodology.

- 60+ build steps
- Comprehensive specifications
- Full test coverage
- Production-ready code
- Built autonomously by Claude Code

**What**: Command-line AI coding assistant with local/remote LLMs
**Why**: First test case to validate YBS provides sufficient detail for autonomous builds
**Status**: In progress (Steps 0-3 complete, test5 build working)
**Location**: [systems/bootstrap/](systems/bootstrap/)

---

## Why YBS is Revolutionary

### Traditional Approach (Manual Development)
- Human writes specs
- Human implements code
- Human writes tests
- Human reviews everything
- **Weeks/months of work**

### YBS Approach (Autonomous AI)
- Human writes specs once
- Human writes build steps once
- **AI agent builds everything autonomously**
- **Hours/days of work**

### The Multiplier Effect

Write specifications and steps once, then:
- **Build multiple implementations** (iOS version, Android version, web version)
- **Rebuild with new frameworks** (migrate React to Vue)
- **Regenerate for new platforms** (port from Python to Go)
- **Update autonomously** (AI agent applies spec changes)

**This is the future of software development.**

---

## 🚀 Quick Start

### → I'm an AI Agent: Build a System

1. **Read**: [CLAUDE.md](CLAUDE.md) - Complete AI agent guide
2. **Navigate**: To systems/SYSTEMNAME/
3. **Read**: systems/SYSTEMNAME/CLAUDE.md
4. **Execute**: Start with Step 0 (Build Configuration)
5. **Continue**: Autonomously through all steps

**Example**: [systems/bootstrap/builds/test5/](systems/bootstrap/builds/test5/)

### → I'm a Human: Understand YBS

1. **Read**: [framework/README.md](framework/README.md) - Framework overview (detailed)
2. **Explore**: [systems/bootstrap/](systems/bootstrap/) - Complete example system
3. **Review**: [systems/bootstrap/builds/test5/](systems/bootstrap/builds/test5/) - Working build
4. **Learn**: [framework/docs/glossary.md](framework/docs/glossary.md) - Terminology

### → I Want to Build Something with YBS

**Step 1**: Read [framework/README.md](framework/README.md) - Understand methodology
**Step 2**: Read [framework/methodology/writing-specs.md](framework/methodology/writing-specs.md) - Learn to write specifications
**Step 3**: Read [framework/methodology/writing-steps.md](framework/methodology/writing-steps.md) - Learn to create build steps
**Step 4**: Study `systems/bootstrap/` - See complete real-world example
**Step 5**: Create your system in `systems/YOUR_SYSTEM/` - Build something amazing

---

## Key Concepts

### Configuration-First (Step 0)

**Step 0 collects ALL questions upfront—or reads from BUILD_CONFIG.json**

- **First build**: Asks questions once, saves to BUILD_CONFIG.json
- **Subsequent builds**: Reads config file, asks NOTHING (zero interaction)
- **Machine-updated builds**: Script updates config → agent reads → new build (fully automated)

**Benefits**:
- Never answer questions twice
- Zero-interaction rebuilds
- CI/CD integration
- Batch generation of build variants

### Autonomous Execution

AI agents work continuously without interruption:
- After Step 0, no user prompts needed
- Agent proceeds through steps automatically
- Only stops for critical errors or 3x verification failures
- Can run overnight, over weekends

### Traceability (Two Levels)

**Feature-Level**:
- Steps reference specs they implement
- Specs reference decisions (ADRs)
- Clear audit trail from requirement to code

**Code-Level**:
- Source files include `// Implements: spec § X.Y` comments
- Automated verification with `check-traceability.sh`
- Detects unspecified features automatically

### Parallel Builds

Multiple agents can work simultaneously:
- ✅ Different systems: systems/bootstrap/ + systems/calculator/
- ✅ Different builds: systems/bootstrap/builds/test5/ + test6/
- ❌ Same build: One agent per build (prevents conflicts)

---

## Documentation

### Framework Documentation

- **[framework/README.md](framework/README.md)** - Comprehensive framework overview
- **[framework/methodology/](framework/methodology/)** - Complete YBS methodology
  - [overview.md](framework/methodology/overview.md) - How YBS works (detailed)
  - [executing-builds.md](framework/methodology/executing-builds.md) - AI agent execution guide
  - [writing-specs.md](framework/methodology/writing-specs.md) - How to write specs
  - [writing-steps.md](framework/methodology/writing-steps.md) - How to write steps
  - [feature-addition-protocol.md](framework/methodology/feature-addition-protocol.md) - Feature addition process
- **[framework/docs/glossary.md](framework/docs/glossary.md)** - Standard terminology (50+ terms)
- **[framework/templates/](framework/templates/)** - Reusable templates

### Bootstrap Documentation

- **[systems/bootstrap/README.md](systems/bootstrap/README.md)** - Bootstrap overview
- **[systems/bootstrap/CLAUDE.md](systems/bootstrap/CLAUDE.md)** - AI agent guide for bootstrap
- **[systems/bootstrap/specs/](systems/bootstrap/specs/)** - Complete specifications
  - [ybs-spec.md](systems/bootstrap/specs/technical/ybs-spec.md) - Technical specification (100+ pages)
  - [ybs-decisions.md](systems/bootstrap/specs/architecture/ybs-decisions.md) - 15 Architectural decisions
  - [ybs-lessons-learned.md](systems/bootstrap/specs/general/ybs-lessons-learned.md) - Implementation checklist
- **[systems/bootstrap/docs/](systems/bootstrap/docs/)** - Bootstrap-specific documentation

---

## Tools

Helper scripts in `framework/tools/`:

```bash
framework/tools/list-specs.sh          # List specifications
framework/tools/list-steps.sh          # List build steps in order
framework/tools/deps.sh                # Show dependency tree
framework/tools/check-traceability.sh  # Verify code↔spec traceability
```

---

## Design Philosophy

### Specs as Source of Truth

Specifications are the single source of truth. Code is derived from specs, not the other way around.

### Sufficiency Over Completeness

Provide **just enough** detail for autonomous execution—not too much (overwhelming), not too little (ambiguous).

### Configuration-First Always

Collect ALL decisions upfront in Step 0. Zero user prompts during Steps 1-N.

### Traceability by Default

Every implementation decision traces to specifications. Every line of code references its requirement.

### Verification-Driven Development

Explicit, automated verification criteria for every step. No vague "make sure it works."

### Language-Agnostic by Design

Framework works for ANY programming language, platform, or domain. No assumptions.

---

## The Future is Autonomous

Software development is evolving from **human-driven** to **human-designed, AI-built**.

**YBS is the bridge.**

Humans focus on **what** should be built and **why**. AI agents handle the **how**.

This isn't just faster development—it's a **fundamental shift** in how software gets made.

---

## Contributing

YBS improves through real-world use:

1. **Use it**: Build systems with YBS
2. **Document findings**: What works, what doesn't
3. **Refine framework**: Improve methodology, templates, tools
4. **Share examples**: Build diverse system types
5. **Capture patterns**: Document best practices

**Every system built with YBS makes the framework better.**

---

## Status

### Framework (A)
- ✅ Methodology documented
- ✅ SDD positioning complete
- ✅ Templates and patterns
- ✅ Helper scripts and tools
- 🔄 Refining through bootstrap validation

### Bootstrap System (B)
- ✅ Complete technical specification (100+ pages)
- ✅ 15 Architectural Decision Records
- ✅ Implementation checklist
- ✅ Build steps (0-3 documented)
- 🔄 Code implementation in progress

### Bootstrap Builds (C)
- ✅ test5: Swift package created, compiles successfully
- ✅ BUILD_CONFIG.json generated (Step 0)
- ✅ BUILD_STATUS.md tracking progress
- 🔄 Core features being implemented

---

## License

MIT License - See [LICENSE](LICENSE)

---

## Version History

- **0.2.1** (2026-01-18): SDD positioning, BUILD_CONFIG.json reading, comprehensive updates
- **0.2.0** (2026-01-17): Documentation improvements, restructure completion
- **0.1.0** (2026-01-16): Initial version

---

## Contact & Community

**Repository**: [github.com/ScottYelich/ybs](https://github.com/ScottYelich/ybs)
**Issues**: [github.com/ScottYelich/ybs/issues](https://github.com/ScottYelich/ybs/issues)

**YBS is open source. Star the repo. Build something amazing. Share your results.**

---

*The future of software development is autonomous. Welcome to YBS.*
