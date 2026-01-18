# YBS Framework

**Yelich Build System: Enabling AI Agents to Build Complete Software Systems Autonomously**

**Version**: 2.0.0
**Last Updated**: 2026-01-18

📍 **You are here**: YBS Framework
**↑ Parent**: [Repository Root](../README.md)
🔗 **GitHub**: [github.com/ScottYelich/ybs](https://github.com/ScottYelich/ybs)

---

## What is YBS?

**YBS is a revolutionary methodology that enables AI agents to build complete, production-ready software systems from scratch—autonomously.**

Imagine describing a software system you want, then watching an AI agent build it end-to-end: writing specifications, making architectural decisions, implementing code, writing tests, and verifying everything works. No human intervention required after initial configuration.

**That's the power of YBS.**

---

## The Vision

Traditional software development requires constant human oversight—clarifying requirements, making decisions, resolving ambiguities. AI agents get stuck without this guidance.

**YBS changes the game** by providing AI agents with everything they need upfront:

- **WHAT to build** (comprehensive specifications)
- **HOW to build it** (step-by-step instructions)
- **WHY decisions were made** (architectural decision records)
- **HOW to verify** (automated testing and validation)

With YBS, AI agents transform from assistants into **autonomous builders**.

---

## Unprecedented Capabilities

### 🚀 Fully Autonomous Builds

**Configuration-first design** collects all decisions upfront in Step 0, then agents execute Steps 1-N continuously without interruption. No more "What should I do here?" prompts mid-build.

**Real-world impact**: Build complex systems overnight while you sleep.

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
- Step 0: Collect all configuration
- Steps 1-N: Implement each component
- Each step includes verification criteria

### 3. **Execute Build** (AI Agent)

Point an AI agent at your steps:
```bash
# Agent reads Step 0, asks all questions upfront
# Then builds autonomously through Steps 1-N
# Verifies each step before proceeding
# Results in complete, working system
```

### 4. **Get Production-Ready Software**

The AI agent delivers:
- ✅ Compiled, running code
- ✅ Comprehensive test suite (passing)
- ✅ Complete documentation
- ✅ Full traceability from requirement to implementation

---

## Proven in Production

**Bootstrap System**: A Swift-based AI chat tool for macOS, built entirely using YBS methodology.

- 60+ build steps
- Comprehensive specifications
- Full test coverage
- Production-ready code
- Built autonomously by Claude Code

**See**: `systems/bootstrap/` for complete example.

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

## What YBS Provides

### Core Methodology

- **[overview.md](methodology/overview.md)** - Complete YBS methodology (for humans and AI)
- **[writing-specs.md](methodology/writing-specs.md)** - How to write specifications
- **[writing-steps.md](methodology/writing-steps.md)** - How to create build steps
- **[executing-builds.md](methodology/executing-builds.md)** - How AI agents execute builds
- **[feature-addition-protocol.md](methodology/feature-addition-protocol.md)** - Process for adding features

### Templates & Tools

- **Templates**: Reusable patterns for specs, steps, and ADRs
- **Tools**: Helper scripts for traceability, dependency analysis, step ordering
- **Reference Docs**: Glossary, file formats, configuration syntax

### For AI Agents

- **[CLAUDE.md](CLAUDE.md)** - Complete guidance for AI agents working on YBS framework itself
- **[../CLAUDE.md](../CLAUDE.md)** - Repository-level guidance for AI agents

---

## Getting Started

### 🎯 I Want to Build Something with YBS

**Step 1**: Read [methodology/overview.md](methodology/overview.md) - Understand how YBS works
**Step 2**: Read [methodology/writing-specs.md](methodology/writing-specs.md) - Learn to write specifications
**Step 3**: Read [methodology/writing-steps.md](methodology/writing-steps.md) - Learn to create build steps
**Step 4**: Study `systems/bootstrap/` - See complete real-world example
**Step 5**: Create your system in `systems/YOUR_SYSTEM/` - Build something amazing

### 🤖 I'm an AI Agent

**Read**: [methodology/executing-builds.md](methodology/executing-builds.md) - Your complete execution guide

Then navigate to `systems/SYSTEMNAME/steps/` and start with Step 0.

### 🛠️ I Want to Improve YBS Framework

**Read**: [CLAUDE.md](CLAUDE.md) - Framework contributor guide

Then contribute methodology improvements, templates, tools, or examples.

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
│   ├── spec-template.md
│   ├── step-template.md
│   ├── adr-template.md
│   └── build-config-template.json
│
├── docs/                              # Reference documentation
│   ├── glossary.md                    # Standard terminology
│   ├── step-format.md                 # Step file format spec
│   └── config-markers.md              # CONFIG marker syntax
│
└── tools/                             # Helper scripts
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

## Version History

- **2.0.0** (2026-01-18): Transformed README into human-focused landing page extolling YBS capabilities
- **1.1.0** (2026-01-18): Enhanced traceability documentation, added Feature Addition Protocol reference
- **1.0.0** (2026-01-17): Initial framework documentation after restructure

---

## References

**For Humans**:
- [methodology/overview.md](methodology/overview.md) - Complete technical details
- [Repository Root](../README.md) - Overall repository guide
- [systems/bootstrap/](../systems/bootstrap/) - Real-world example

**For AI Agents**:
- [CLAUDE.md](CLAUDE.md) - Framework work guidance
- [../CLAUDE.md](../CLAUDE.md) - Repository work guidance
- [methodology/executing-builds.md](methodology/executing-builds.md) - Build execution guide

---

## Contact & Community

**Repository**: [github.com/ScottYelich/ybs](https://github.com/ScottYelich/ybs)
**Issues**: [github.com/ScottYelich/ybs/issues](https://github.com/ScottYelich/ybs/issues)

**YBS is open source. Star the repo. Build something amazing. Share your results.**

---

*The future of software development is autonomous. Welcome to YBS.*
