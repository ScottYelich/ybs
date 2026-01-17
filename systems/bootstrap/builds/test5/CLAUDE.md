# CLAUDE.md - test5

**Version**: 0.2.0

This file provides guidance to Claude Code when working on this project.

## Project Context

**System Name**: test5
**Language**: Swift
**Platform**: macOS 14+
**Purpose**: LLM-powered coding assistant
**Build Method**: Following step-by-step instructions from `../../steps/`

## Quick Start for Claude

### Build Commands
- **Build**: `swift build` (debug) or `swift build -c release` (release)
- **Run**: `swift run test5` or `.build/debug/test5`
- **Test**: `swift test`
- **Clean**: `rm -rf .build`

## Working in This Directory

### Project Structure

```
test5/
├── Package.swift             # Swift Package Manager manifest
├── Sources/test5/            # Source code
│   └── main.swift            # Entry point
├── Tests/test5Tests/         # Unit tests
├── BUILD_STATUS.md           # Current build status (CHECK THIS FIRST)
├── BUILD_CONFIG.json         # Configuration values
├── ARCHITECTURE.md           # Architecture decisions
├── README.md                 # Project overview
├── CLAUDE.md                 # This file
└── docs/
    ├── BUILD.md              # Build instructions
    ├── TESTING.md            # Testing guidelines
    ├── USAGE.md              # Usage documentation
    └── build-history/        # Completed step documentation
```

### Development Workflow

1. **Check status**: Always read BUILD_STATUS.md first
2. **Read instructions**: Follow steps from `../../steps/steps/`
3. **Use todo lists**: Create TodoWrite for each step
4. **Write tests**: For code changes, write tests first or concurrently
5. **Verify**: Run tests and build before marking step complete
6. **Document**: Update build-history with DONE files

### Testing Requirements

- **Unit tests**: Test individual components in isolation
- **Integration tests**: Test components working together
- **All tests must pass**: Before marking any code step as complete
- **Test location**: Tests/test5Tests/

### Reference Documentation

Core specifications (DO NOT MODIFY):
- `../../specs/ybs-spec.md` - Technical specification
- `../../specs/ybs-decisions.md` - Architectural decisions
- `../../specs/ybs-lessons-learned.md` - Best practices

Build instructions (FOLLOW THESE):
- `../../steps/steps/ybs-step_<guid>.md` - Individual steps

### Important Notes

- This workspace is independent of specs (use specs as reference only)
- All implementation happens in builds/test5/
- DO NOT modify anything in docs/ (instructions)
- Each step must complete verification before proceeding
- Follow Swift conventions for this project

### Documentation Versioning

All documentation uses semantic versioning (major.minor.patch):
- **Current version**: 0.2.0
- **Increment rule**: ONLY minor version (0.1.0 → 0.2.0 → 0.3.0)
- **Major version**: LOCKED at 0.x.x (do NOT go to 1.0.0)

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
- Duration: [duration]
```

---

**Last updated**: 2026-01-17 07:41 UTC
