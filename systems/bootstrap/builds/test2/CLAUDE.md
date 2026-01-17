# CLAUDE.md - test2

**Version**: 0.2.0

This file provides guidance to Claude Code when working on this project.

## Project Context

**System Name**: test2
**Language**: Swift
**Platform**: macOS 14+
**Purpose**: LLM-powered coding assistant
**Build Method**: Following step-by-step instructions from `../../docs/build-from-scratch/`

## Quick Start for Claude

### Build Commands
- **Build**: `swift build`
- **Run**: `swift run test2`
- **Test**: `swift test`
- **Clean**: `rm -rf .build`

### Project Structure

```
test2/
├── Package.swift              # Swift package definition
├── Sources/
│   └── test2/
│       └── main.swift         # Entry point
├── Tests/
│   └── test2Tests/            # Unit tests
├── BUILD_STATUS.md            # Current build status
├── ARCHITECTURE.md            # Architecture decisions
├── README.md                  # Project overview
├── CLAUDE.md                  # This file
└── docs/
    ├── BUILD.md               # Build instructions
    ├── TESTING.md             # Testing guidelines
    ├── USAGE.md               # Usage documentation
    └── build-history/         # Completed step logs
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
- **Test location**: Tests/test2Tests/

### Important Notes

- This workspace is independent of specs (use specs as reference only)
- All implementation happens in builds/test2/
- DO NOT modify anything in docs/ (instructions)
- Each step must complete verification before proceeding
- Follow Swift conventions for this project

### Documentation Versioning

All documentation uses semantic versioning (major.minor.patch):
- **Current version**: 0.2.0
- **Increment rule**: ONLY minor version (0.1.0 → 0.2.0 → 0.3.0)
- **Major version**: LOCKED at 0.x.x (do NOT go to 1.0.0)

---

**Last updated**: 2026-01-17
