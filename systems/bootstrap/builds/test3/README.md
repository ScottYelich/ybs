# test3

**Version**: 0.1.0
**Language**: Swift
**Platform**: macOS only

An LLM-powered coding assistant built from scratch.

## Overview

This is an interactive command-line tool that provides AI-assisted coding through:
- Interactive chat interface
- Local tool execution (file operations, shell commands)
- Support for configurable LLM backends (Ollama, OpenAI, Anthropic, etc.)
- Conversation context management
- Security sandboxing

## Prerequisites

- Swift 5.9 or later
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
swift run test3
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
swift run test3 --help
```

## Development

- **Build status**: See BUILD_STATUS.md
- **Build history**: See docs/build-history/
- **Architecture**: See ARCHITECTURE.md
- **Claude guidance**: See CLAUDE.md

## Project Structure

```
test3/
├── Package.swift              # Swift Package Manager manifest
├── Sources/
│   └── test3/                 # Main source code
│       └── main.swift         # Entry point
├── Tests/
│   └── test3Tests/            # Unit tests
├── BUILD_STATUS.md            # Current build status
├── ARCHITECTURE.md            # Architecture decisions
├── CLAUDE.md                  # Claude guidance
└── docs/
    ├── BUILD.md               # Build instructions
    ├── TESTING.md             # Testing guide
    ├── USAGE.md               # Usage documentation
    └── build-history/         # Completed steps
```

## License

[TBD]

---

**Built with**: Step-by-step instructions from `../../docs/build-from-scratch/`
**Last updated**: 2026-01-17 06:32 UTC
