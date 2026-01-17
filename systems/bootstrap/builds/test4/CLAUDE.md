# CLAUDE.md - test4

**Version**: 0.2.0

This file provides guidance to Claude Code when working on this project.

## Project Context

**System Name**: test4
**Language**: Swift
**Platform**: macOS 14+
**Purpose**: LLM-powered coding assistant
**Build Method**: Following step-by-step instructions from `../../docs/build-from-scratch/`

## Quick Start for Claude

### Build Commands
- **Build**: `swift build` (debug) or `swift build -c release` (release)
- **Run**: `swift run test4`
- **Test**: `swift test`
- **Clean**: `rm -rf .build/` (then rebuild)

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
test4/
├── BUILD_CONFIG.json         # Configuration from Step 0
├── BUILD_STATUS.md           # Current build status (CHECK THIS FIRST)
├── ARCHITECTURE.md           # Architecture decisions
├── README.md                 # Project overview
├── CLAUDE.md                # This file
├── Package.swift            # Swift Package Manager manifest
├── Sources/
│   └── test4/               # Source code
│       └── main.swift       # Entry point
├── Tests/
│   └── test4Tests/         # Unit tests
└── docs/
    ├── BUILD.md            # Build instructions
    ├── TESTING.md          # Testing guidelines
    ├── USAGE.md            # Usage documentation
    └── build-history/      # Completed step documentation
```

### Development Workflow

1. **Check status**: Always read BUILD_STATUS.md first
2. **Read instructions**: Follow steps from `../../docs/build-from-scratch/steps/`
3. **Use todo lists**: Create TodoWrite for each step
4. **Write tests**: For code changes, write tests first or concurrently
5. **Verify**: Run tests and build before marking step complete
6. **Document**: Update build-history with DONE files

### Testing Requirements

- **Unit tests**: Test individual components in isolation
- **Integration tests**: Test components working together
- **All tests must pass**: Before marking any code step as complete
- **Test location**: Tests/test4Tests/

### Reference Documentation

Core specifications (DO NOT MODIFY):
- `../../docs/specs/system/ybs-spec.md` - Technical specification
- `../../docs/specs/system/ybs-decisions.md` - Architectural decisions
- `../../docs/specs/system/ybs-lessons-learned.md` - Best practices

Build instructions (FOLLOW THESE):
- `../../docs/build-from-scratch/steps/ybs-step_<guid>.md` - Individual steps

### Important Notes

- This workspace is independent of specs (use specs as reference only)
- All implementation happens in builds/test4/
- DO NOT modify anything in docs/ (instructions)
- Each step must complete verification before proceeding
- Follow Swift language conventions for this project

## Build History Format

When documenting completed steps in `docs/build-history/ybs-step_<guid>-DONE.txt`:

```
STEP <guid>: [Title]
STARTED: [timestamp]
COMPLETED: [timestamp]
DURATION: [actual elapsed time]

OBJECTIVES:
- [objective 1]
- [objective 2]

ACTIONS TAKEN:
- [action 1]
- [action 2]

VERIFICATION RESULTS:
✓ [check 1]
✓ [check 2]

VERIFICATION ATTEMPTS: [1-3]

ISSUES ENCOUNTERED:
[none or list issues and resolutions]

FILES CREATED/MODIFIED:
- path/to/file1
- path/to/file2

NEXT STEP: ybs-step_<guid> ([Title])

TIMING SUMMARY:
- Start: [timestamp]
- End: [timestamp]
- Duration: [actual elapsed time]
```

---

**Build initialized**: 2026-01-16 22:32 UTC
**Last updated**: 2026-01-16 23:05 UTC
