# Step 000001: Initialize Build Workspace

**Version**: 0.2.0

## Overview

This step initializes the build workspace for creating an LLM-based coding assistant system.

## What We're Building

An LLM-powered chat agent that assists with coding tasks. The system will:
- Provide an interactive chat interface for developers
- Execute tools locally (read files, write files, run commands, etc.)
- Work with both local and remote LLM backends
- Maintain conversation context
- Implement security sandboxing for safe code execution

This is a command-line tool designed to be:
- **Local-first**: All tool execution happens on your machine
- **Extensible**: Tools can be added without recompiling
- **Secure**: Sandboxed execution with user confirmation for destructive operations
- **Simple**: Core agent loop designed to be understandable

## Step Objectives

1. Read system name from BUILD_CONFIG.json
2. Create the `builds/` directory structure
3. Create the system-specific workspace
4. Initialize BUILD_STATUS.md
5. Create initial documentation files
6. Verify the structure

## Prerequisites

- BUILD_CONFIG.json must exist (Step 0 completed)
- system_name must be defined in config

## Configurable Values

**This step uses the following configuration values:**

- `{{CONFIG:system_name|string|Name of the system being built|myapp}}` - Used for directory name and all documentation

**Note**: This value is read from BUILD_CONFIG.json (collected in Step 0).

## Traceability

**Implements**: Infrastructure step - workspace initialization

**References**:
- Framework design: build isolation in separate directories
- Configuration-driven execution

## Instructions

### 1. Read System Name from Config

Read the system name from BUILD_CONFIG.json:

**Command**:
```bash
jq -r '.system_name' builds/BUILD_CONFIG.json
```

**Note**: BUILD_CONFIG.json is in the top-level builds/ directory initially, then will be moved to builds/{{CONFIG:system_name}}/ by this step.

Store the value. Let's call it `SYSTEM_NAME`.

### 2. Create Directory Structure

Create the following directory structure:

```
builds/
└── SYSTEM_NAME/
    ├── BUILD_STATUS.md
    ├── README.md
    ├── CLAUDE.md
    └── docs/
        └── build-history/
            └── .gitkeep
```

**Commands to execute**:
```bash
mkdir -p builds/SYSTEM_NAME/docs/build-history
touch builds/SYSTEM_NAME/docs/build-history/.gitkeep
```

Replace `SYSTEM_NAME` with the actual name chosen.

### 3. Create BUILD_STATUS.md

Create `builds/SYSTEM_NAME/BUILD_STATUS.md` with the following content:

```markdown
# Build Status: SYSTEM_NAME

**Version**: 0.1.0
**System Name**: SYSTEM_NAME
**Current Step**: step_000000
**Step Version**: 0.1.0
**Status**: in_progress
**Last Updated**: [current timestamp]

## Current Step Details
- **Title**: Initialize Build Workspace
- **Status**: in_progress
- **Issues**: none

## Next Action
Complete step 000000 initialization and verification.

## Progress Summary
- Steps completed: 0
- Current step: 0 (initialization)
- Overall status: Just started

## Build Information
- **Created**: [current timestamp]
- **Purpose**: LLM-based coding assistant
- **Language**: Swift (planned)
- **Target Platform**: macOS 14+ (primary)

## Reference Documentation
- Specification: `../../docs/specs/system/ybs-spec.md`
- Decisions: `../../docs/specs/system/ybs-decisions.md`
- Checklist: `../../docs/specs/system/ybs-lessons-learned.md`
```

Replace `SYSTEM_NAME` and `[current timestamp]` with actual values.

### 4. Create README.md

Create `builds/SYSTEM_NAME/README.md` with:

```markdown
# SYSTEM_NAME

**Version**: 0.1.0

An LLM-powered coding assistant built from scratch.

## Overview

This is an interactive command-line tool that provides AI-assisted coding through:
- Interactive chat interface
- Local tool execution (file operations, shell commands)
- Support for local and remote LLM backends
- Conversation context management
- Security sandboxing

## Build Status

See `BUILD_STATUS.md` for current build progress.

## Build History

See `docs/build-history/` for completed build steps and verification results.

## Reference Specifications

This implementation is based on specifications in:
- `../../docs/specs/system/ybs-spec.md` - Complete technical specification
- `../../docs/specs/system/ybs-decisions.md` - Architectural decisions
- `../../docs/specs/system/ybs-lessons-learned.md` - Implementation best practices

## Getting Started

This project is being built step-by-step following instructions in `../../docs/build-from-scratch/`.

**Current step**: See BUILD_STATUS.md

---

**Created**: [current timestamp]
**Build started**: [current timestamp]
```

Replace `SYSTEM_NAME` and timestamps.

### 5. Create CLAUDE.md

Create `builds/SYSTEM_NAME/CLAUDE.md` with:

```markdown
# CLAUDE.md - SYSTEM_NAME

**Version**: 0.1.0

This file provides guidance to Claude Code when working in this build workspace.

## Build Context

**System Name**: SYSTEM_NAME
**System Version**: 0.1.0
**Purpose**: LLM-based coding assistant
**Build Method**: Following step-by-step instructions from `../../docs/build-from-scratch/`

## Documentation Versioning

All documentation uses semantic versioning (major.minor.patch):
- **Starting version**: 0.1.0
- **Increment rule**: ONLY minor version (0.1.0 → 0.2.0 → 0.3.0)
- **Major version**: LOCKED at 0.x.x (do NOT go to 1.0.0)
- **Patch version**: Typo fixes only
- **Status file version**: This document version is 0.1.0

## Current Build Status

Always check `BUILD_STATUS.md` before starting work. It contains:
- Current step number
- Current status
- Any issues or blockers
- Next action required

## Working in This Directory

### File Organization

```
SYSTEM_NAME/
├── BUILD_STATUS.md           # Current build status (CHECK THIS FIRST)
├── README.md                 # Project overview
├── CLAUDE.md                # This file
├── docs/
│   └── build-history/       # Completed step documentation
├── Package.swift            # (created in later step)
├── Sources/                 # (created in later step)
└── Tests/                   # (created in later step)
```

### Workflow

1. **Check status**: Read BUILD_STATUS.md to see current step
2. **Read instructions**: Read the step file from `../../docs/build-from-scratch/step_NNNNNN.md`
3. **Execute**: Follow instructions exactly
4. **Verify**: Run verification checks
5. **Document**: Create build-history entry
6. **Update status**: Update BUILD_STATUS.md
7. **Report**: Inform user of completion

### Reference Documentation

Core specifications (DO NOT MODIFY):
- `../../docs/specs/system/ybs-spec.md` - Technical specification
- `../../docs/specs/system/ybs-decisions.md` - Architectural decisions
- `../../docs/specs/system/ybs-lessons-learned.md` - Best practices

Build instructions (FOLLOW THESE):
- `../../docs/build-from-scratch/step_NNNNNN.md` - Individual steps

### Important Notes

- This workspace is INDEPENDENT of the specs
- The specs are REFERENCE ONLY
- All implementation happens HERE in builds/SYSTEM_NAME/
- DO NOT modify anything in docs/
- Each step must complete verification before proceeding

## Build History Format

When documenting completed steps in `docs/build-history/step_NNNNNN-DONE.txt`:

```
STEP NNNNNN: [Title]
COMPLETED: [timestamp]

OBJECTIVES:
- [objective 1]
- [objective 2]

ACTIONS TAKEN:
- [action 1]
- [action 2]

VERIFICATION RESULTS:
✓ [check 1]
✓ [check 2]

ISSUES ENCOUNTERED:
[none or list issues and resolutions]

FILES CREATED/MODIFIED:
- path/to/file1
- path/to/file2

NEXT STEP: step_NNNNNN
```

---

**Build initialized**: [current timestamp]
```

Replace `SYSTEM_NAME` and timestamps.

### 6. Verify Structure

Run verification checks to ensure everything is created correctly.

**Verification Commands**:
```bash
# Check directory structure
ls -la builds/SYSTEM_NAME/
ls -la builds/SYSTEM_NAME/docs/
ls -la builds/SYSTEM_NAME/docs/build-history/

# Verify files exist
test -f builds/SYSTEM_NAME/BUILD_STATUS.md && echo "✓ BUILD_STATUS.md exists"
test -f builds/SYSTEM_NAME/README.md && echo "✓ README.md exists"
test -f builds/SYSTEM_NAME/CLAUDE.md && echo "✓ CLAUDE.md exists"
test -d builds/SYSTEM_NAME/docs/build-history && echo "✓ build-history directory exists"

# Show BUILD_STATUS.md content
echo "=== BUILD_STATUS.md ==="
cat builds/SYSTEM_NAME/BUILD_STATUS.md
```

Replace `SYSTEM_NAME` with actual name.

### 7. Document Completion

Create `builds/SYSTEM_NAME/docs/build-history/step_000000-DONE.txt`:

```
STEP 000000: Initialize Build Workspace
COMPLETED: [timestamp]

OBJECTIVES:
- Ask user for system name
- Create builds/ directory structure
- Initialize BUILD_STATUS.md tracking file
- Create initial documentation (README.md, CLAUDE.md)
- Create build-history directory
- Verify structure

ACTIONS TAKEN:
- Asked user for system name (response: SYSTEM_NAME)
- Created builds/SYSTEM_NAME/ directory
- Created builds/SYSTEM_NAME/docs/build-history/ directory
- Created BUILD_STATUS.md with initial status
- Created README.md with project overview
- Created CLAUDE.md with build guidance
- Created .gitkeep in build-history/

VERIFICATION RESULTS:
✓ builds/SYSTEM_NAME/ directory exists
✓ BUILD_STATUS.md exists and contains correct content
✓ README.md exists
✓ CLAUDE.md exists
✓ docs/build-history/ directory exists
✓ All file contents verified

ISSUES ENCOUNTERED:
None

FILES CREATED:
- builds/SYSTEM_NAME/BUILD_STATUS.md
- builds/SYSTEM_NAME/README.md
- builds/SYSTEM_NAME/CLAUDE.md
- builds/SYSTEM_NAME/docs/build-history/.gitkeep

NEXT STEP: step_000001 (TBD - will implement Swift package setup)

BUILD WORKSPACE READY: Yes
```

Replace `SYSTEM_NAME` and `[timestamp]` with actual values.

### 8. Update BUILD_STATUS.md

Update `builds/SYSTEM_NAME/BUILD_STATUS.md` to mark step complete:

Change the status section to:
```markdown
**Version**: 0.1.0
**Current Step**: step_000000
**Step Version**: 0.1.0
**Status**: completed
**Last Updated**: [current timestamp]

## Current Step Details
- **Title**: Initialize Build Workspace
- **Status**: completed
- **Issues**: none

## Next Action
Ready to proceed to step_000001 (Swift package initialization).
```

### 9. Report to User

Output a summary message:

```
✓ Step 000000 complete: Build workspace initialized

System Name: SYSTEM_NAME
Location: builds/SYSTEM_NAME/

Created:
  ✓ Directory structure
  ✓ BUILD_STATUS.md (tracking file)
  ✓ README.md (project overview)
  ✓ CLAUDE.md (build guidance)
  ✓ docs/build-history/ (completion tracking)

Verification: All checks passed
Documentation: step_000000-DONE.txt created

Status: ✓ READY FOR STEP 1

Next step: step_000001 (Swift package initialization)
```

## Verification Checklist

Before marking this step complete, verify:

- [ ] User was asked for system name
- [ ] `builds/SYSTEM_NAME/` directory created
- [ ] `builds/SYSTEM_NAME/BUILD_STATUS.md` exists with correct content
- [ ] `builds/SYSTEM_NAME/README.md` exists
- [ ] `builds/SYSTEM_NAME/CLAUDE.md` exists
- [ ] `builds/SYSTEM_NAME/docs/build-history/` directory exists
- [ ] `step_000000-DONE.txt` created in build-history/
- [ ] BUILD_STATUS.md updated to "completed"
- [ ] All files contain correct system name (no template placeholders)
- [ ] User received completion summary

## Success Criteria

This step is successful when:
1. All files and directories exist
2. All files contain actual values (no placeholders)
3. BUILD_STATUS.md shows step as completed
4. Documentation file exists in build-history/
5. Structure verified with no errors

---

## Version History

### 0.1.0 (2026-01-16)
- Initial version
- Workspace initialization step
- Includes versioning requirements for all generated documents

---

**Step completed?** Proceed to `step_000001.md`
