# Bootstrap System Build Steps

**Version**: 1.0.0
**Last Updated**: 2026-01-17

📍 **You are here**: Bootstrap System > Build Steps
**↑ Parent**: [Bootstrap System](../README.md)
📚 **Related**: [Specifications](../specs/) | [Documentation](../docs/)

---

## Overview

This directory contains the **build steps** for constructing the bootstrap system - a Swift-based AI chat tool for macOS.

Each step provides:
- **Clear objectives**: What will be accomplished
- **Detailed instructions**: How to execute the step
- **Verification criteria**: How to confirm success
- **Traceability**: Links to specifications implemented

**Autonomous execution**: After Step 0, all steps can be executed without user input by reading BUILD_CONFIG.json.

---

## Build Steps

### Step 0: Build Configuration (000000000000)

**File**: [ybs-step_000000000000.md](ybs-step_000000000000.md)
**Purpose**: Collect all configuration values upfront
**Duration**: ~5 minutes
**User interaction**: Required (answers configuration questions)

**What it does**:
1. Scans all build steps for CONFIG markers
2. Collects unique configuration values
3. Asks user all questions upfront (batched, max 4 at a time)
4. Generates BUILD_CONFIG.json for autonomous execution

**Outputs**:
- BUILD_CONFIG.json with all user choices
- Enables fully autonomous execution of Steps 1-N

**When to run**: Always first, before any other step

---

### Step 1: Initialize Build Workspace (478a8c4b0cef)

**File**: [ybs-step_478a8c4b0cef.md](ybs-step_478a8c4b0cef.md)
**Purpose**: Create build directory structure and initial documentation
**Duration**: ~2 minutes
**User interaction**: None (reads from BUILD_CONFIG.json)

**What it does**:
1. Reads system name from BUILD_CONFIG.json
2. Creates builds/SYSTEMNAME/ directory structure
3. Initializes BUILD_STATUS.md tracking file
4. Creates initial README.md and CLAUDE.md
5. Verifies structure

**Implements**:
- Infrastructure step - workspace setup

**Prerequisites**:
- Step 0 completed (BUILD_CONFIG.json exists)

**Outputs**:
- builds/SYSTEMNAME/ directory
- BUILD_STATUS.md
- README.md
- CLAUDE.md

---

### Step 2: Define Architecture & Choose Technology Stack (c5404152680d)

**File**: [ybs-step_c5404152680d.md](ybs-step_c5404152680d.md)
**Purpose**: Document architectural decisions and technology choices
**Duration**: ~3 minutes
**User interaction**: None (reads from BUILD_CONFIG.json)

**What it does**:
1. Reads language and platform choices from BUILD_CONFIG.json
2. Documents decisions in ARCHITECTURE.md
3. Updates BUILD_STATUS.md with architecture section
4. Verifies documentation complete

**Configurable values**:
- language: Programming language (Swift, Python, Go, Rust, TypeScript)
- platform: Target platform(s) (macOS only, Linux only, etc.)

**Implements**:
- ybs-decisions.md D01 (Swift as implementation language)
- Architecture foundation for subsequent steps

**Prerequisites**:
- Step 1 completed (workspace exists)

**Outputs**:
- ARCHITECTURE.md
- Updated BUILD_STATUS.md

---

### Step 3: Set Up Project Environment (89b9e6233da5)

**File**: [ybs-step_89b9e6233da5.md](ybs-step_89b9e6233da5.md)
**Purpose**: Initialize language-specific project structure and build tools
**Duration**: ~5 minutes
**User interaction**: None (reads from BUILD_CONFIG.json)

**What it does**:
1. Reads architecture decisions from ARCHITECTURE.md
2. Creates language-specific project structure (e.g., Swift Package Manager)
3. Initializes build tools and dependencies
4. Creates initial source files
5. Verifies build environment works
6. Creates comprehensive project documentation

**Configurable values**:
- Inherits language and platform from Step 2

**Implements**:
- Project structure foundation
- Build system initialization
- Documentation setup

**Prerequisites**:
- Step 2 completed (architecture defined)

**Outputs**:
- Language-specific project structure (Package.swift for Swift)
- Sources/ directory with initial code
- Tests/ directory
- docs/ directory (BUILD.md, TESTING.md, USAGE.md)
- Working build environment

**Verification**:
- Build completes successfully
- Initial program runs and prints welcome message

---

## Execution Flow

```
┌──────────────────────────────────────────────┐
│  Step 0: Build Configuration                 │
│  - User answers ALL questions upfront        │
│  - Generates BUILD_CONFIG.json               │
└─────────────┬────────────────────────────────┘
              │
              ↓
┌──────────────────────────────────────────────┐
│  Step 1: Initialize Build Workspace          │
│  - Reads: BUILD_CONFIG.json (system_name)    │
│  - Creates: builds/SYSTEMNAME/ structure     │
│  - Autonomous (no user input)                │
└─────────────┬────────────────────────────────┘
              │
              ↓
┌──────────────────────────────────────────────┐
│  Step 2: Define Architecture                 │
│  - Reads: BUILD_CONFIG.json (language,       │
│           platform)                           │
│  - Creates: ARCHITECTURE.md                  │
│  - Autonomous (no user input)                │
└─────────────┬────────────────────────────────┘
              │
              ↓
┌──────────────────────────────────────────────┐
│  Step 3: Set Up Project Environment          │
│  - Reads: ARCHITECTURE.md, BUILD_CONFIG.json │
│  - Creates: Project structure, build files   │
│  - Verifies: Build works                     │
│  - Autonomous (no user input)                │
└─────────────┬────────────────────────────────┘
              │
              ↓
         [Step 4+...]
      (Future steps TBD)
```

---

## Configuration-Driven Execution

### Step 0: Configuration Collection

**Purpose**: Collect ALL configuration upfront to enable autonomous execution.

**Process**:
1. Scans ALL step files (ybs-step_*.md)
2. Extracts CONFIG markers: `{{CONFIG:key|type|description|default}}`
3. Deduplicates by key (same key = one question)
4. Groups into batches (max 4 questions per AskUserQuestion call)
5. Asks user for all values
6. Validates responses against type constraints
7. Generates BUILD_CONFIG.json

**Example CONFIG marker**:
```markdown
{{CONFIG:language|choice[Swift,Python,Go]|Programming language|Swift}}
```

### Steps 1-N: Autonomous Execution

**Read from BUILD_CONFIG.json**:
```bash
LANGUAGE=$(jq -r '.values.language' BUILD_CONFIG.json)
PLATFORM=$(jq -r '.values.platform' BUILD_CONFIG.json)
```

**Never prompt user** - all values collected in Step 0.

---

## Step File Format

Each step file follows this structure:

1. **Title**: Step number and name
2. **Version**: Semantic versioning (0.1.0, 0.2.0, etc.)
3. **Overview**: Brief description
4. **Step Objectives**: Numbered list of goals
5. **Prerequisites**: Required prior steps or conditions
6. **Configurable Values**: CONFIG markers or "none"
7. **Traceability**: Links to specs/decisions implemented
8. **Instructions**: Detailed how-to (numbered sub-steps)
9. **Verification**: Checklist and commands to confirm success
10. **Documentation**: How to update BUILD_STATUS.md and create DONE file
11. **Success Criteria**: Final checklist before completion

See [framework/docs/step-format.md](../../../framework/docs/step-format.md) for complete format specification.

---

## Timing and Documentation

### Timing Requirements

All steps MUST track:
- **Start time**: Recorded at beginning of execution
- **End time**: Recorded after verification passes
- **Duration**: Calculated (end - start)

**Format**: ISO 8601 timestamps, human-readable duration

### Completion Documentation

Each completed step generates a DONE file:
```
builds/SYSTEMNAME/docs/build-history/ybs-step_<guid>-DONE.txt
```

**Contents**:
- Objectives accomplished
- Actions taken
- Verification results (including attempt count)
- Issues encountered and resolutions
- Files created/modified
- Timing summary (start, end, duration)

---

## Verification and Retry Policy

### Verification Requirements

Every step includes:
- **Checklist**: Specific criteria that must be met
- **Commands**: Executable verification steps
- **Expected output**: What success looks like

### Retry Policy

**Standard retry policy for all steps**:
1. **Attempt 1**: Execute and verify
2. **If fail**: Analyze error, fix, attempt 2
3. **If fail**: Analyze error, fix, attempt 3
4. **After 3 failures**: STOP and report to user

**Tracking**: Each attempt logged with timestamp and result

---

## Traceability

### Spec → Step → Code

Each step traces back to specifications:

```
Spec: ybs-spec.md Section 4.1 (Tool Interface)
  ↓ implements
Decision: D04 (Hybrid Tool Architecture)
  ↓ guides
Step: ybs-step_89b9e6233da5.md
  ↓ creates
Code: Sources/bootstrap/Tools/
```

### Step Traceability Markers

Steps document what they implement:
```markdown
## Traceability

**Implements**:
- ybs-spec.md Section 3.2 (Configuration Loading)
- ybs-spec.md Section 4.1 (Tool Interface)

**References**:
- D04 (Hybrid Tool Architecture)
- D08 (Edit Format)
```

---

## Status Tracking

### BUILD_STATUS.md

Central tracking file updated by each step:
- Current step and version
- Status (in_progress, completed, failed)
- Last updated timestamp
- Architecture decisions
- Build environment info
- Reference documentation links

### Completion History

Completed steps documented in:
```
builds/SYSTEMNAME/docs/build-history/
├── ybs-step_000000000000-DONE.txt
├── ybs-step_478a8c4b0cef-DONE.txt
├── ybs-step_c5404152680d-DONE.txt
└── ybs-step_89b9e6233da5-DONE.txt
```

---

## Using These Steps

### For AI Agents

**Workflow**:
1. **Check BUILD_STATUS.md**: See current step
2. **Read step file**: Get complete instructions
3. **Record start time**: Note when you begin
4. **Execute instructions**: Follow sequentially
5. **Verify completion**: Run verification checks (max 3 attempts)
6. **Record end time**: Note when verification passes
7. **Calculate duration**: End - start
8. **Document completion**: Create DONE file with timing
9. **Update BUILD_STATUS.md**: Mark step complete
10. **Report to user**: Summarize what was accomplished

**Key principles**:
- Follow steps in order (0, 1, 2, 3, ...)
- Never skip verification
- Always track timing (start, end, duration)
- Document everything in DONE files
- Read from BUILD_CONFIG.json (never prompt user in Steps 1-N)

### For System Designers

**Writing new steps**:
1. Use [framework/templates/step-template.md](../../../framework/templates/step-template.md)
2. Include CONFIG markers for configurable values
3. Link to specs/decisions (traceability)
4. Provide clear, executable instructions
5. Include verification commands with expected output
6. Specify timing requirements

### For Framework Contributors

**Validation**:
- Can steps be executed autonomously after Step 0?
- Are instructions clear and unambiguous?
- Do verification commands actually test success?
- Is traceability to specs maintained?
- Are timing requirements met?

---

## Step Development

### Creating New Steps

**Process**:
1. Start with [framework/templates/step-template.md](../../../framework/templates/step-template.md)
2. Generate GUID: 12-character hex (e.g., `a1b2c3d4e5f6`)
3. Name file: `ybs-step_<guid>.md`
4. Fill in all required sections
5. Test step execution
6. Verify autonomous execution works

### Updating Existing Steps

**When to update**:
- Instructions need clarification
- Verification criteria change
- New configuration values needed
- Bug fixes or improvements

**How to update**:
1. Read existing step file
2. Make necessary changes
3. Increment version (0.1.0 → 0.2.0)
4. Add entry to version history
5. Test that step still works
6. Update affected documentation

---

## Validation Results

**Proof of autonomous execution**:
- **test5 build**: 4/4 steps completed autonomously
- **Duration**: 15 minutes total (after Step 0)
- **User prompts**: 0 (after initial Step 0 configuration)
- **Success rate**: 100% (all verification passed on first attempt)
- **Artifacts**: Working Swift package, compilable, tests passing

---

## References

- **Specifications**: [../specs/](../specs/) - What these steps implement
- **Framework**: [../../../framework/README.md](../../../framework/README.md) - YBS methodology
- **Step Format**: [../../../framework/docs/step-format.md](../../../framework/docs/step-format.md) - Format specification
- **CONFIG Syntax**: [../../../framework/docs/config-markers.md](../../../framework/docs/config-markers.md) - Configuration markers
- **Step Template**: [../../../framework/templates/step-template.md](../../../framework/templates/step-template.md) - Template for new steps
- **Bootstrap System**: [../README.md](../README.md) - System overview
- **Glossary**: [../../../framework/docs/glossary.md](../../../framework/docs/glossary.md) - Terminology

---

## Quick Start

**New to building with YBS?**
1. Read: [ybs-step_000000000000.md](ybs-step_000000000000.md) - Understand Step 0
2. Review: Other step files - See the pattern
3. Execute: Start with Step 0, proceed sequentially

**Building bootstrap system?**
1. Read specifications in [../specs/](../specs/) first
2. Return here and execute Step 0
3. Follow steps autonomously (1 → 2 → 3 → ...)
4. Track timing and create DONE files
5. Verify each step before proceeding

**Writing new steps?**
1. Use framework step template
2. Study existing steps for patterns
3. Include CONFIG markers for configuration
4. Maintain traceability to specs
5. Provide clear verification criteria

---

**Version**: 1.0.0 (2026-01-17) - Initial steps README after v1.0.0 restructure
