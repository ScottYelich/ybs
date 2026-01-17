# CLAUDE.md - test3

**Version**: 0.2.0

This file provides guidance to Claude Code when working on this project.

## Project Context

**System Name**: test3
**Language**: Swift
**Platform**: macOS only
**Purpose**: LLM-powered coding assistant
**Build Method**: Following step-by-step instructions from `../../steps/`

## Documentation Versioning

All documentation uses semantic versioning (major.minor.patch):
- **Starting version**: 0.1.0
- **Increment rule**: ONLY minor version (0.1.0 → 0.2.0 → 0.3.0)
- **Major version**: LOCKED at 0.x.x (do NOT go to 1.0.0)
- **Patch version**: Typo fixes only
- **Status file version**: This document version is 0.2.0

## Quick Start for Claude

### Build Commands
- **Build**: `swift build` or `swift build -c release`
- **Run**: `swift run test3` or `.build/debug/test3`
- **Test**: `swift test`
- **Clean**: `swift package clean`

### Project Structure

```
test3/
├── Package.swift              # Swift Package Manager manifest
├── Sources/
│   └── test3/                 # Main source code
│       └── main.swift         # Entry point
├── Tests/
│   └── test3Tests/            # Unit tests
├── BUILD_STATUS.md            # Current build status
├── BUILD_CONFIG.json          # Configuration values
├── ARCHITECTURE.md            # Architecture decisions
├── README.md                  # Project overview
├── CLAUDE.md                  # This file
└── docs/
    ├── BUILD.md               # Build instructions
    ├── TESTING.md             # Testing guide
    ├── USAGE.md               # Usage documentation
    └── build-history/         # Completed step documentation
```

### Development Workflow

1. **Check status**: Always read BUILD_STATUS.md first
2. **Read instructions**: Follow steps from `../../steps/steps/`
3. **Use todo lists**: Create TodoWrite for each step
4. **Write tests**: For code changes, write tests first or concurrently
5. **Verify**: Run tests and build before marking step complete
6. **Document**: Update build-history with DONE files

### Testing Requirements

- **Unit tests**: Test individual components in isolation using XCTest
- **Integration tests**: Test components working together
- **All tests must pass**: Before marking any code step as complete
- **Test location**: Tests/test3Tests/

### Important Notes

- This workspace is independent of specs (use specs as reference only)
- All implementation happens in builds/test3/
- DO NOT modify anything in ../../docs/ (instructions)
- Each step must complete verification before proceeding
- Follow Swift conventions for this project (naming, formatting, etc.)

### Swift-Specific Guidelines

- **Naming**: Use camelCase for variables/functions, PascalCase for types
- **Formatting**: Follow Swift API Design Guidelines
- **Error handling**: Use Swift's Result type or throw errors appropriately
- **Async**: Use async/await for asynchronous operations
- **Dependencies**: Manage via Package.swift with semantic versioning

---

**Build initialized**: 2026-01-17 06:28 UTC
**Last updated**: 2026-01-17 06:32 UTC
