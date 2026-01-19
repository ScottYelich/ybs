# CLAUDE.md - test7 Build

**Version**: 0.2.0

This file provides guidance to Claude Code when working in this build workspace.

## Project Context

**System Name**: test7
**Language**: Swift
**Platform**: macOS only
**Purpose**: LLM-based coding assistant
**Build Method**: Following step-by-step instructions from `../../steps/`
**Build Started**: 2026-01-18T02:03:07Z

## Configuration

This build uses the following configuration (from BUILD_CONFIG.json):
- **Language**: Swift
- **Platform**: macOS only
- **UI Color**: Enabled

## Quick Start for Claude

### Build Commands
- **Build**: `swift build`
- **Run**: `swift run test7`
- **Test**: `swift test`
- **Clean**: `swift package clean`

### Project Structure

```
test7/
├── Sources/test7/          # Main executable source
├── Tests/test7Tests/       # Test suite
├── Package.swift           # Swift package manifest
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

## Documentation Versioning

All documentation uses semantic versioning (major.minor.patch):
- **Current version**: 0.2.0
- **Increment rule**: ONLY minor version (0.1.0 → 0.2.0 → 0.3.0)
- **Major version**: LOCKED at 0.x.x (do NOT go to 1.0.0)
- **Patch version**: Typo fixes only

## Current Build Status

Always check `BUILD_STATUS.md` before starting work. It contains:
- Current step GUID
- Current status
- Any issues or blockers
- Next action required

## Working in This Directory

### File Organization

```
test7/
├── BUILD_CONFIG.json        # Configuration from Step 0
├── BUILD_STATUS.md           # Current build status (CHECK THIS FIRST)
├── README.md                 # Project overview
├── CLAUDE.md                 # This file
├── SESSION.md                # Crash recovery tracking
├── docs/
│   └── build-history/       # Completed step documentation
├── Package.swift            # (created in later step)
├── Sources/                 # (created in later step)
└── Tests/                   # (created in later step)
```

### Workflow

1. **Check session**: Read SESSION.md for crash recovery
2. **Check status**: Read BUILD_STATUS.md to see current step
3. **Read instructions**: Read the step file from `../../steps/ybs-step_<guid>.md`
4. **Execute**: Follow instructions exactly
5. **Verify**: Run verification checks
6. **Document**: Create build-history entry
7. **Update status**: Update BUILD_STATUS.md
8. **Continue**: Proceed automatically to next step

### Reference Documentation

Core specifications (DO NOT MODIFY):
- `../../specs/ybs-spec.md` - Technical specification
- `../../specs/ybs-decisions.md` - Architectural decisions
- `../../specs/ybs-lessons-learned.md` - Best practices

Build instructions (FOLLOW THESE):
- `../../steps/ybs-step_<guid>.md` - Individual steps
- `../../steps/STEPS_ORDER.txt` - Step execution order

### Important Notes

- This workspace is INDEPENDENT of the specs
- The specs are REFERENCE ONLY
- All implementation happens HERE in builds/test7/
- DO NOT modify anything in specs/ or steps/
- Each step must complete verification before proceeding
- Proceed automatically to next step after successful completion

## Build History Format

When documenting completed steps in `docs/build-history/ybs-step_<guid>-DONE.txt`:

```
STEP <guid>: [Title]
STARTED: [timestamp]
COMPLETED: [timestamp]
DURATION: [duration]

OBJECTIVES:
- [objective 1]
- [objective 2]

ACTIONS TAKEN:
- [action 1]
- [action 2]

VERIFICATION RESULTS:
✓ [check 1]
✓ [check 2]

VERIFICATION ATTEMPTS: [count]

ISSUES ENCOUNTERED:
[none or list issues and resolutions]

FILES CREATED/MODIFIED:
- path/to/file1
- path/to/file2

NEXT STEP: ybs-step_<guid> ([title])
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
- **Test location**: Tests/test7Tests/

## Autonomous Execution

This build follows the YBS autonomous execution model:
- After Step 0, NO user prompts needed
- Proceed automatically from step to step
- Only stop for critical errors or 3x verification failures
- Update SESSION.md regularly for crash recovery

## Important Notes

- This workspace is independent of specs (use specs as reference only)
- All implementation happens in builds/test7/
- DO NOT modify anything in ../../specs/ or ../../steps/
- Each step must complete verification before proceeding
- Follow Swift conventions for this project

---

**Build initialized**: 2026-01-18T02:03:07Z
**Last updated**: 2026-01-18T02:09:31Z
