# test4

**Version**: 0.1.0
**Language**: Swift
**Platform**: macOS 14+

An LLM-powered coding assistant built from scratch.

## Overview

This is an interactive command-line tool that provides AI-assisted coding through:
- Interactive chat interface
- Local tool execution (file operations, shell commands)
- Support for configurable LLM backends (Ollama, OpenAI, Anthropic, etc.)
- Conversation context management
- Security sandboxing

## Prerequisites

- Swift 5.9+ (part of Xcode 15+ or Swift toolchain)
- macOS 14+ (Sonoma or later)
- Ollama (for local LLM, optional): https://ollama.ai

## Building

See `docs/BUILD.md` for detailed build instructions.

Quick start:
```bash
swift build
```

## Running

```bash
swift run test4
```

## Testing

See `docs/TESTING.md` for testing guidelines.

```bash
swift test
```

## Usage

See `docs/USAGE.md` for detailed usage instructions.

Basic usage:
```bash
swift run test4 --help
```

## Development

- **Build status**: See BUILD_STATUS.md
- **Build history**: See docs/build-history/
- **Architecture**: See ARCHITECTURE.md
- **Claude guidance**: See CLAUDE.md

## Project Structure

```
test4/
├── Package.swift              # Swift Package Manager manifest
├── Sources/
│   └── test4/
│       └── main.swift         # Entry point
├── Tests/
│   └── test4Tests/           # Unit tests
├── BUILD_STATUS.md           # Current build status
├── ARCHITECTURE.md           # Architecture decisions
└── docs/
    ├── BUILD.md             # Build instructions
    ├── TESTING.md           # Testing guidelines
    ├── USAGE.md             # Usage documentation
    └── build-history/       # Completed build steps
```

## License

[TBD]

---

**Built with**: Step-by-step instructions from `../../docs/build-from-scratch/`

---

**Created**: 2026-01-16 23:01 UTC
**Build started**: 2026-01-16 22:32 UTC
