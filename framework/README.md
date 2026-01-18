# YBS Framework

**Version**: 1.1.0
**Last Updated**: 2026-01-18

📍 **You are here**: YBS Framework
**↑ Parent**: [Repository Root](../README.md)

---

## What is YBS?

**YBS (Yelich Build System) is a methodology for enabling AI agents to build complete software systems autonomously.**

The framework provides structured files (specifications, build steps, templates, and patterns) that guide tool-using AI agents like Claude through building ANY type of system - from simple calculators to complex distributed applications.

### Core Concept

**Provide sufficient detail for autonomous development.**

YBS defines:
- **WHAT to build** (specifications)
- **HOW to build it** (step-by-step instructions)
- **WHY decisions were made** (architectural decision records)
- **HOW to verify** (testing and validation criteria)

With these in place, AI agents can build systems from scratch to completion without human intervention (after initial configuration).

---

## Framework Structure

```
framework/
├── README.md                          # This file - Framework overview
├── methodology/                       # How YBS works
│   ├── overview.md                    # What is YBS, how it works
│   ├── writing-specs.md               # How to write specifications
│   ├── writing-steps.md               # How to write build steps
│   └── executing-builds.md            # How to execute builds
├── templates/                         # Reusable templates
│   ├── spec-template.md               # Template for specifications
│   ├── step-template.md               # Template for build steps
│   ├── adr-template.md                # Template for ADRs
│   └── build-config-template.json     # Template for BUILD_CONFIG
├── docs/                              # Framework reference docs
│   ├── glossary.md                    # Standard terminology
│   ├── step-format.md                 # Step file format specification
│   └── config-markers.md              # CONFIG marker syntax
├── tools/                             # Helper scripts
│   ├── list-specs.sh                  # List specifications for a system
│   ├── list-steps.sh                  # List build steps in order
│   ├── deps.sh                        # Show dependency tree
│   └── check-traceability.sh          # Verify code-to-spec traceability
└── changelogs/                        # Historical (no longer maintained)
```

---

## How YBS Works

### 1. Define System (Specifications)

Create specifications that define WHAT to build:

- **Technical specs**: Architecture, components, APIs, data models
- **Business specs**: Features, user stories, success metrics
- **Functional specs**: Workflows, behavior, edge cases
- **Testing specs**: Test plans, acceptance criteria
- **Decision records**: WHY choices were made

**Location**: `systems/SYSTEMNAME/specs/`

### 2. Create Build Steps

Write step-by-step instructions for HOW to build it:

- Sequential steps (Step 0, Step 1, Step 2, ...)
- Each step has: objectives, instructions, verification, traceability
- Steps reference specifications they implement
- Config markers for user-settable values

**Location**: `systems/SYSTEMNAME/steps/`

### 3. Execute Build

AI agent reads steps and builds the system:

- Step 0 collects all configuration upfront (enables autonomous execution)
- Steps 1-N execute autonomously
- Agent uses tools: read files, write code, run commands
- Verification after each step
- Build history tracked

**Location**: `systems/SYSTEMNAME/builds/BUILDNAME/`

### 4. Result

Complete working system:

- Compiled/running code
- Tests passing
- Documentation generated
- Full traceability from specs to implementation

---

## Key Principles

### 1. Configuration-First

**Step 0 collects ALL questions upfront**

- Generates BUILD_CONFIG.json with all settings
- Subsequent steps read from config (no user prompts)
- Enables fully autonomous execution

### 2. Autonomous Execution

**AI agents work continuously without interruption**

- After Step 0, no user prompts needed
- Agent proceeds through steps automatically
- Only stops for critical errors or verification failures

### 3. Traceability

**Every implementation decision traces to its specification**

**Feature-Level Traceability**:
- Steps reference specs they implement
- Specs reference decisions (ADRs)
- Clear audit trail from requirement to code

**Code-Level Traceability**:
- Source files include `// Implements: spec § X.Y` comments
- Automated checking with check-traceability.sh tool
- Detects unspecified features automatically
- Enables rapid code review

See: [Feature Addition Protocol](methodology/feature-addition-protocol.md)

### 4. Verification-Driven

**Every step has explicit verification criteria**

- Automated checks where possible
- Tests must pass before proceeding
- Retry limit (3 attempts) prevents infinite loops

### 5. Language-Agnostic

**Framework works for ANY programming language or system type**

- Not tied to specific technology
- Can build: web apps, CLI tools, databases, AI agents, anything
- Steps adapt to target language/platform

---

## Getting Started

### For System Designers

Want to define a new system that AI agents can build?

1. Read: [methodology/writing-specs.md](methodology/writing-specs.md) - How to write specifications
2. Read: [methodology/writing-steps.md](methodology/writing-steps.md) - How to create build steps
3. Create: `systems/YOUR_SYSTEM/specs/` - Write your specifications
4. Create: `systems/YOUR_SYSTEM/steps/` - Write your build steps
5. Test: Have an AI agent execute your steps

### For AI Agents

Want to build a system using YBS?

1. Read: [methodology/executing-builds.md](methodology/executing-builds.md) - Complete execution guide
2. Navigate: To `systems/SYSTEMNAME/` for the system you're building
3. Execute: Start with Step 0 (Build Configuration)
4. Continue: Follow steps autonomously until completion

### For Framework Contributors

Want to improve the YBS framework itself?

1. Read: [../CLAUDE.md](../CLAUDE.md) - Repository guide for AI agents
2. Read: [docs/glossary.md](docs/glossary.md) - Standard terminology
3. Contribute: Framework improvements, templates, tools
4. Test: Use framework to build diverse system types

---

## Documentation

### Methodology

- [overview.md](methodology/overview.md) - What is YBS, how it works
- [writing-specs.md](methodology/writing-specs.md) - How to write specifications
- [writing-steps.md](methodology/writing-steps.md) - How to write build steps
- [executing-builds.md](methodology/executing-builds.md) - How to execute builds (AI agents)
- [feature-addition-protocol.md](methodology/feature-addition-protocol.md) - Process for adding new features

### Reference

- [docs/glossary.md](docs/glossary.md) - Standard terminology
- [docs/step-format.md](docs/step-format.md) - Step file format specification
- [docs/config-markers.md](docs/config-markers.md) - CONFIG marker syntax

### Templates

- [templates/spec-template.md](templates/spec-template.md) - Specification template
- [templates/step-template.md](templates/step-template.md) - Build step template
- [templates/adr-template.md](templates/adr-template.md) - Architectural decision record template
- [templates/build-config-template.json](templates/build-config-template.json) - BUILD_CONFIG template

---

## Examples

### Systems Built with YBS

See `systems/` directory for examples:

- **systems/bootstrap/** - Swift-based AI chat tool (LLM coding assistant)
  - Complete specs, steps, and builds
  - Demonstrates framework for complex AI system
  - macOS native application

*(More systems can be added as examples)*

---

## Design Philosophy

### Sufficiency

**Provide sufficient detail for autonomous execution.**

Not too much (overwhelming), not too little (ambiguous). Just enough for an AI agent to build the system without getting stuck.

### Modularity

**Each system is self-contained.**

Everything needed to build a system lives in `systems/SYSTEMNAME/`:
- Specs define what to build
- Steps define how to build it
- Builds contain the output
- No global state or dependencies between systems

### Adaptability

**Framework works for any system type.**

YBS doesn't assume:
- Programming language
- Platform (web, desktop, mobile, embedded)
- Architecture (monolith, microservices, serverless)
- Domain (AI agents, databases, compilers, games)

Steps and specs adapt to the system being built.

### Verifiability

**Every step can be verified.**

Automated verification where possible:
- Compilation success
- Tests passing
- File existence
- Command execution

This enables autonomous execution with confidence.

---

## Framework Evolution

**Current Status**: Framework is actively evolving through real-world use.

**Validation Method**: Building actual systems with AI agents (starting with bootstrap)

**Improvement Cycle**:
1. AI agent attempts to build system using YBS
2. Identify gaps, ambiguities, or inefficiencies
3. Refine framework, specs, or steps
4. Try again with improved framework
5. Repeat until high-quality autonomous builds

---

## Tools

Helper scripts in `framework/tools/`:

- **list-specs.sh** - List specifications by GUID
- **list-steps.sh** - List build steps in execution order
- **deps.sh** - Show dependency tree for specs
- **check-traceability.sh** - Verify code-to-spec traceability
- **list-changelogs.sh** - List session changelogs (historical)

---

## Contributing

To improve the YBS framework:

1. **Use it**: Build systems with YBS and document what works/doesn't
2. **Refine templates**: Improve spec and step templates
3. **Add examples**: Build diverse system types to test framework
4. **Improve tools**: Enhance helper scripts and automation
5. **Document patterns**: Capture best practices

---

## Version History

- **1.1.0** (2026-01-18): Enhanced traceability documentation, added Feature Addition Protocol reference, clarified tool locations
- **1.0.0** (2026-01-17): Initial framework documentation after restructure

---

## References

- [Repository Root](../README.md) - Overall repository guide
- [CLAUDE.md](../CLAUDE.md) - AI agent guidance for working in this repo
- [systems/](../systems/) - System definitions (specs + steps + builds)

