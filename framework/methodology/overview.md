# YBS Overview

**Version**: 1.0.0
**Last Updated**: 2026-01-17

📍 **You are here**: YBS Framework > Methodology > Overview
**↑ Parent**: [Framework](../README.md)
📚 **Related**: [Writing Specs](writing-specs.md) | [Writing Steps](writing-steps.md) | [Executing Builds](executing-builds.md)

---

## What is YBS?

**YBS (Yelich Build System) is a methodology for enabling AI agents to build complete software systems autonomously.**

The framework provides structured files (specifications, build steps, and patterns) that guide tool-using AI agents like Claude Code through building ANY type of system - from simple calculators to complex distributed applications.

---

## Core Concept

**Provide sufficient detail for autonomous development.**

YBS defines:
- **WHAT to build** → Specifications
- **HOW to build it** → Step-by-step instructions
- **WHY decisions were made** → Architectural decision records
- **HOW to verify** → Testing and validation criteria

With these in place, AI agents can build systems from scratch to completion without human intervention (after initial configuration).

---

## The Three Layers

YBS has a three-layer architecture:

### A. Framework (`framework/`)

**The YBS methodology itself** - reusable across ANY system:
- How to write specs, steps, execute builds
- Templates and patterns
- Tools and documentation
- **Language-agnostic** - works for Swift, Python, Go, Rust, anything

### B. Systems (`systems/SYSTEMNAME/`)

**Definitions of specific systems to build** - self-contained:
- Specifications (WHAT to build)
- Build steps (HOW to build)
- Documentation (WHY decisions made)
- **Examples**: bootstrap (Swift AI tool), calculator, web-app

### C. Builds (`systems/SYSTEMNAME/builds/BUILDNAME/`)

**Active build workspaces** - where AI agents work:
- Build outputs and artifacts
- SESSION.md for crash recovery
- BUILD_STATUS.md tracking progress
- **One build per AI agent** - enables parallel work

---

## How YBS Works

### Phase 1: Define System (Human)

**System designer creates**:
1. **Specifications** (`systems/SYSTEMNAME/specs/`)
   - Technical specs: Architecture, components, APIs
   - Decision records: Why choices were made
   - Functional specs: Features, workflows, behavior

2. **Build Steps** (`systems/SYSTEMNAME/steps/`)
   - Step 0: Build Configuration (collects all settings)
   - Steps 1-N: Implementation steps (detailed instructions)
   - STEPS_ORDER.txt: Defines execution order
   - Each step: objectives → instructions → verification

### Phase 2: Execute Build (AI Agent)

**AI agent reads steps and builds system**:
1. **Step 0**: Collect all configuration upfront
   - User answers questions once
   - Generates BUILD_CONFIG.json
   - Enables fully autonomous execution

2. **Steps 1-N**: Build autonomously
   - Read BUILD_CONFIG.json for settings
   - Follow detailed instructions
   - Use tools: read files, write code, run commands
   - Verify completion after each step
   - Track progress in BUILD_STATUS.md

3. **Crash Recovery**: Resume from interruptions
   - SESSION.md tracks current state
   - AI agent resumes from where it left off
   - No work lost

### Phase 3: Result

**Complete working system**:
- Compiled/running code
- Tests passing
- Documentation generated
- Full traceability from specs to implementation

---

## Key Principles

### 1. Configuration-First

**Step 0 collects ALL questions upfront**

Traditional approach (interrupts frequently):
```
Agent: What's the system name?
User: myapp
Agent: [builds something]
Agent: What port should I use?
User: 8080
Agent: [builds more]
Agent: What database?
User: PostgreSQL
```

YBS approach (questions once, builds autonomously):
```
Agent: [Runs Step 0]
  - What's the system name? myapp
  - What port? 8080
  - What database? PostgreSQL
  - What features? [authentication, logging, metrics]
Agent: [Saves BUILD_CONFIG.json]
Agent: [Builds entire system without interruption]
```

**Benefits**:
- No interruptions during build
- Consistent configuration across all steps
- Easy to rebuild with different config
- Parallel builds with different configs

### 2. Autonomous Execution

**AI agents work continuously without interruption**

After Step 0:
- No user prompts needed
- Agent proceeds through steps automatically
- Only stops for critical errors (3x retry limit exceeded)
- Can run overnight, over weekends

**Enables**:
- Multiple AI agents working in parallel (different systems or builds)
- Long-running builds (compile large projects)
- Unattended operation

### 3. Traceability

**Every implementation traces to specifications**

```
Code → Step → Spec → Decision
```

Example:
- `Config.swift` implements authentication
- Built in Step 5: "Implement Configuration System"
- Implements spec Section 4.2: "Configuration Loading"
- Based on Decision D07: "Layered Configuration"

**Benefits**:
- Audit trail from requirement to code
- Changes to specs trigger review of affected steps
- Understand WHY code exists
- Compliance and documentation

### 4. Verification-Driven

**Every step has explicit verification criteria**

Not vague:
```
❌ "Make sure it works"
```

Explicit and automated:
```
✅ This step is complete when:
   - [ ] Package.swift exists at expected path
   - [ ] `swift build` completes without errors
   - [ ] Tests pass: `swift test` returns 0
   - [ ] Binary runs: `./myapp --version` outputs version
```

**Retry Policy**:
- If verification fails → analyze error and fix
- Maximum 3 attempts
- After 3 failures → STOP and report to user

**Benefits**:
- Agent knows when step is truly complete
- Prevents proceeding with broken state
- Automated validation

### 5. Language-Agnostic

**Framework works for ANY programming language or system type**

YBS can build:
- **CLI tools**: Swift, Rust, Go, Python
- **Web apps**: React, Vue, Rails, Django
- **Mobile apps**: SwiftUI, Kotlin, React Native
- **Databases**: PostgreSQL extensions, Redis modules
- **Compilers**: Parser, AST, code generation
- **AI agents**: Tool-using LLM assistants
- **Anything else**: Framework adapts to target

Not tied to specific technology - steps and specs adapt.

---

## File Organization

### Systems Directory Structure

```
systems/SYSTEMNAME/
├── README.md                     # System overview
├── CLAUDE.md                     # AI agent guide for this system
│
├── specs/                        # Specifications (WHAT to build)
│   ├── README.md
│   ├── system-spec.md            # Technical specification
│   ├── decisions.md              # Architectural decisions (ADRs)
│   └── lessons-learned.md        # Implementation insights
│
├── steps/                        # Build steps (HOW to build)
│   ├── README.md
│   ├── STEPS_ORDER.txt           # Execution order
│   ├── ybs-step_000000000000.md  # Step 0: Build Configuration
│   ├── ybs-step_<guid>.md        # Step 1
│   ├── ybs-step_<guid>.md        # Step 2
│   └── ...                       # More steps
│
├── docs/                         # System-specific docs
│   ├── architecture.md
│   ├── security.md
│   └── configuration.md
│
└── builds/                       # Build outputs
    ├── build1/
    ├── build2/
    └── test5/                    # Current build
        ├── SESSION.md            # Crash recovery state
        ├── BUILD_CONFIG.json     # Configuration values
        ├── BUILD_STATUS.md       # Progress tracking
        └── [source code]         # Actual build output
```

### Naming Conventions

**Step files**: `ybs-step_<12-hex-guid>.md`
- Example: `ybs-step_478a8c4b0cef.md`
- GUID enables flexible ordering (insert, branch, loop)
- Order defined in `STEPS_ORDER.txt`, not filename

**Build directories**: Descriptive names
- Examples: `build1`, `test5`, `production`, `experiment-auth`
- Each build is independent
- Can have multiple active builds with different configs

---

## Configuration System

### CONFIG Markers

Steps use `{{CONFIG:...}}` markers for configurable values:

```markdown
### Create Package Manifest

Create `Package.swift`:

```swift
let package = Package(
    name: "{{CONFIG:system_name|string|Name of the system|myapp}}",
    platforms: [
        .macOS(.v{{CONFIG:min_os_version|choice[13,14,15]|Minimum macOS version|14}})
    ]
)
```
```

### Step 0: Build Configuration

Step 0 extracts all CONFIG markers from all steps and asks user:
1. Scan all steps for `{{CONFIG:...}}` markers
2. Present questions to user
3. Save answers to BUILD_CONFIG.json
4. Subsequent steps read from config

### BUILD_CONFIG.json Example

```json
{
  "system_name": "bootstrap",
  "min_os_version": "14",
  "language": "Swift",
  "enable_tests": true,
  "max_threads": 4,
  "primary_color": "#007AFF"
}
```

**Benefits**:
- Questions asked once (Step 0)
- No interruptions during build
- Easy to rebuild with different settings
- Multiple builds with different configs

---

## Step Anatomy

Every step has:

### 1. Header
```markdown
# Step NNNNNN: Descriptive Title

**Version**: 0.1.0
```

### 2. Overview
What this step accomplishes and why (1-2 paragraphs)

### 3. Step Objectives
Numbered list of specific goals

### 4. Prerequisites
What must exist before starting

### 5. Configurable Values
All `{{CONFIG:...}}` markers used

### 6. Traceability
Which specs implemented, ADRs referenced

### 7. Instructions
Detailed sub-steps with code snippets

### 8. Verification
Explicit success criteria with commands

### 9. Version History
Track changes to step file

**See**: [writing-steps.md](writing-steps.md) for complete guide

---

## Verification

### Explicit Checks

Every step ends with verification section:

```markdown
## Verification

**This step is complete when**:
- [ ] Package.swift exists at expected path
- [ ] Dependencies resolved: `swift package resolve` succeeds
- [ ] Project compiles: `swift build` succeeds
- [ ] Tests pass: `swift test` returns 0

**Verification Commands**:
```bash
test -f Package.swift && echo "✓ File exists" || echo "✗ Missing"
swift package resolve && echo "✓ Resolved" || echo "✗ Failed"
swift build && echo "✓ Compiled" || echo "✗ Failed"
swift test && echo "✓ Tests pass" || echo "✗ Tests fail"
```

**Expected Output**:
```
✓ File exists
Fetching dependencies...
✓ Resolved
Building for debugging...
✓ Compiled
Test Suite 'All tests' passed
✓ Tests pass
```

**Retry Policy**:
- If verification fails, analyze error and fix
- Maximum 3 attempts allowed
- After 3 failures, STOP and report to user
```

---

## Crash Recovery

### SESSION.md Protocol

**Problem**: Claude Code crashes frequently, losing context.

**Solution**: SESSION.md tracks current state.

### Location

- **Building system**: `systems/SYSTEMNAME/builds/BUILDNAME/SESSION.md`
- **Framework work**: `./SESSION.md` (repo root)
- **System definition**: `systems/SYSTEMNAME/SESSION.md`

### Protocol

1. **Session start**: Check for SESSION.md
   - If found → read and resume
   - If not found → create new

2. **During work**: Update SESSION.md after every significant action
   - After reading files
   - After making edits
   - After running commands
   - Before complex operations

3. **Session end**: Clean up
   - If successful → delete SESSION.md
   - If incomplete → leave for next session

### Template

```markdown
# Build Session

**System**: bootstrap
**Build**: test5
**Current Step**: Step 3 (ybs-step_89b9e6233da5)
**Started**: 2026-01-17 14:30 UTC
**Last Updated**: 2026-01-17 15:45 UTC

## Current State

Working on: Setting up Swift project environment

## Progress

- [x] Step 0: Build Configuration
- [x] Step 1: Initialize Build Workspace
- [x] Step 2: Define Architecture
- [IN PROGRESS] Step 3: Set Up Project Environment
  - [x] Created Package.swift
  - [x] Created directory structure
  - [IN PROGRESS] Resolving dependencies
- [ ] Step 4: Not started

## Next Actions

1. Run `swift package resolve` to fetch dependencies
2. Verify compilation with `swift build`
3. Move to Step 4

## Notes

- Using swift-argument-parser 1.3.0
- macOS 14+ target platform
```

**Benefits**:
- Next Claude session resumes instantly
- No work lost on crash
- Clear state of what's done/pending
- Human can understand progress

---

## Parallel Execution

### Supported Parallelization

✅ **Multiple systems** - Different AI agents building different systems:
```
Agent 1 → systems/bootstrap/builds/build1/
Agent 2 → systems/calculator/builds/build1/
```

✅ **Multiple builds** - Different AI agents building different variants:
```
Agent 1 → systems/bootstrap/builds/test5/
Agent 2 → systems/bootstrap/builds/test6/
```

### Not Supported

❌ **Multiple agents on same build**:
```
Agent 1 → systems/bootstrap/builds/test5/  ⚠️
Agent 2 → systems/bootstrap/builds/test5/  ⚠️ CONFLICT
```

**Reason**: Compilation locks, file conflicts, state confusion

**Rule**: One AI agent per build directory

---

## Best Practices

### For System Designers

1. **Start with specs** - Define WHAT before HOW
2. **Use CONFIG markers** - Enable different configurations
3. **Write explicit verification** - Automate where possible
4. **Maintain traceability** - Every step links to specs
5. **Test with AI agents** - Ensure autonomous execution works
6. **Document decisions** - WHY is as important as WHAT

### For AI Agents

1. **Check SESSION.md first** - Resume if crashed
2. **Start with Step 0** - Always collect config first
3. **Read BUILD_CONFIG.json** - Use configured values
4. **Verify before proceeding** - Don't skip checks
5. **Update SESSION.md frequently** - Track state for crash recovery
6. **Follow steps exactly** - Don't improvise or skip
7. **Respect retry limits** - Stop after 3 failures

### For Framework Contributors

1. **Use it first** - Build systems to find gaps
2. **Document patterns** - Capture what works
3. **Improve templates** - Make them clearer
4. **Add examples** - More system types
5. **Test thoroughly** - Different languages, platforms

---

## Common Patterns

### Pattern 1: Incremental Development

Build system in layers:
- Step 1-5: Foundation (project setup, dependencies)
- Step 6-10: Core (main functionality)
- Step 11-15: Features (additional capabilities)
- Step 16-20: Polish (tests, docs, optimization)

### Pattern 2: Verify Early, Verify Often

Every step verifies:
- Files exist
- Code compiles
- Tests pass
- Commands succeed

Don't defer verification to the end.

### Pattern 3: Configuration Over Code

Prefer CONFIG markers over hardcoded values:
- System names
- Technology choices
- Feature flags
- Numeric parameters

### Pattern 4: Traceability Chain

Maintain clear chain:
```
Requirement → Spec → Decision → Step → Code
```

Always know WHY code exists.

---

## Troubleshooting

### Build Fails to Start

**Check**:
- Step 0 completed? BUILD_CONFIG.json exists?
- Prerequisites met? (language installed, tools available)
- Working directory correct? (systems/SYSTEMNAME/builds/BUILDNAME/)

### Verification Always Fails

**Check**:
- Retry limit? (max 3 attempts)
- Error messages? (read them carefully)
- Prerequisites? (previous steps completed?)
- System requirements? (correct OS, versions)

### Agent Gets Stuck

**Check**:
- SESSION.md? (should be updated frequently)
- Ambiguous instructions? (step needs clarification)
- Missing information? (step lacks detail)

### Different Build Results

**Check**:
- BUILD_CONFIG.json? (should be consistent)
- Step versions? (might have changed)
- External dependencies? (version pinning)

---

## Terminology

See [glossary.md](../docs/glossary.md) for complete terminology reference.

**Key Terms**:
- **Framework**: YBS methodology (layer A)
- **System**: Thing being built (layer B)
- **Build**: Active workspace (layer C)
- **Step**: Single unit of work
- **Spec**: What to build
- **CONFIG**: Configurable value
- **Verification**: Success criteria
- **Traceability**: Link from code to spec

---

## Examples

### Real System: Bootstrap

**What**: Swift-based AI chat tool (LLM coding assistant)

**Location**: `systems/bootstrap/`

**Structure**:
- `specs/` - Technical specs, decisions, lessons
- `steps/` - Step 0-3 complete, more planned
- `builds/test5/` - Current active build
- `docs/` - Architecture, security, configuration

**Purpose**: Validate YBS framework through real-world use

**Learn from**: Complete example of YBS methodology in action

---

## Next Steps

### Learn More

- [Writing Specifications](writing-specs.md) - How to define systems
- [Writing Build Steps](writing-steps.md) - How to guide AI agents
- [Executing Builds](executing-builds.md) - How AI agents build systems

### Try It

1. Read bootstrap example: `systems/bootstrap/`
2. Try building bootstrap: Follow steps in `systems/bootstrap/steps/`
3. Create your own system: Use templates in `framework/templates/`

---

## References

- **Framework**: [../README.md](../README.md)
- **Repository**: [../../README.md](../../README.md)
- **Glossary**: [../docs/glossary.md](../docs/glossary.md)
- **Bootstrap**: [../../systems/bootstrap/README.md](../../systems/bootstrap/README.md)

---

## Version History

- **1.0.0** (2026-01-17): Comprehensive YBS overview after restructure
