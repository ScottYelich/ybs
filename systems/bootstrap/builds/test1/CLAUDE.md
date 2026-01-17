# CLAUDE.md - test1

**Version**: 0.2.0

This file provides guidance to Claude Code when working on this project.

## Project Context

**System Name**: test1
**Language**: Swift
**Platform**: macOS only
**Purpose**: LLM-powered coding assistant
**Build Method**: Following step-by-step instructions from `../../steps/`

## Quick Start for Claude

### Build Commands
- **Build**: `swift build`
- **Run**: `swift run test1`
- **Test**: `swift test`
- **Clean**: `swift package clean`

### Project Structure

```
test1/
├── Sources/
│   └── test1/
│       └── main.swift
├── Tests/
│   └── test1Tests/
├── Package.swift
├── BUILD_STATUS.md
├── ARCHITECTURE.md
├── README.md
├── CLAUDE.md (this file)
└── docs/
    ├── BUILD.md
    ├── TESTING.md
    ├── USAGE.md
    └── build-history/
```

### Development Workflow

1. **Check status**: Always read BUILD_STATUS.md first
2. **Read instructions**: Follow steps from `../../steps/`
3. **Use todo lists**: Create TodoWrite for each step
4. **Write tests**: For code changes, write tests first or concurrently
5. **Verify**: Run tests and build before marking step complete
6. **Document**: Update build-history with DONE files

### Testing Requirements

- **Unit tests**: Test individual components in isolation
- **Integration tests**: Test components working together
- **All tests must pass**: Before marking any code step as complete
- **Test location**: Tests/test1Tests/

### Important Notes

- This workspace is independent of specs (use specs as reference only)
- All implementation happens in builds/test1/
- DO NOT modify anything in docs/ (instructions)
- Each step must complete verification before proceeding
- Follow Swift conventions for this project

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
test1/
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
2. **Read instructions**: Read the step file from `../../steps/step_NNNNNN.md`
3. **Execute**: Follow instructions exactly
4. **Verify**: Run verification checks
5. **Document**: Create build-history entry
6. **Update status**: Update BUILD_STATUS.md
7. **Report**: Inform user of completion

### Reference Documentation

Core specifications (DO NOT MODIFY):
- `../../specs/ybs-spec.md` - Technical specification
- `../../specs/ybs-decisions.md` - Architectural decisions
- `../../specs/ybs-lessons-learned.md` - Best practices

Build instructions (FOLLOW THESE):
- `../../steps/step_NNNNNN.md` - Individual steps

### Important Notes

- This workspace is INDEPENDENT of the specs
- The specs are REFERENCE ONLY
- All implementation happens HERE in builds/test1/
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

**Build initialized**: 2026-01-16 18:48:00
