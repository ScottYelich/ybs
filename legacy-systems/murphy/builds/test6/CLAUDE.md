# CLAUDE.md - test6

**Version**: 0.2.0

This file provides guidance to Claude Code when working on this project.

## Project Context

**System Name**: test6
**Language**: Swift
**Platform**: macOS only
**Purpose**: LLM-powered coding assistant
**Build Method**: Following step-by-step instructions from `../../steps/`

## Quick Start for Claude

### Build Commands
- **Build**: `swift build`
- **Run**: `swift run test6` or `.build/debug/test6`
- **Test**: `swift test`
- **Clean**: `swift package clean`

### Project Structure

```
test6/
├── Package.swift              # Swift Package Manager config
├── Sources/test6/            # Main executable source
├── Tests/test6Tests/         # Unit tests
├── BUILD_STATUS.md           # Current build status
├── ARCHITECTURE.md           # Architecture decisions
├── README.md                 # Project overview
├── CLAUDE.md                 # This file
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
- **Test location**: Tests/test6Tests/
- **Test framework**: XCTest (Swift built-in)

### Important Notes

- This workspace is independent of specs (use specs as reference only)
- All implementation happens in builds/test6/
- DO NOT modify anything in ../../specs/ or ../../steps/
- Each step must complete verification before proceeding
- Follow Swift conventions and Swift Package Manager structure

### Documentation Versioning

All documentation uses semantic versioning (major.minor.patch):
- **Current version**: 0.2.0
- **Increment rule**: ONLY minor version (0.1.0 → 0.2.0 → 0.3.0)
- **Major version**: LOCKED at 0.x.x (do NOT go to 1.0.0)

---

**Last updated**: 2026-01-17 14:36 UTC
