# test2

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

- Swift 5.9+
- macOS 14+
- Ollama (for local LLM, optional): https://ollama.ai

## Building

See `docs/BUILD.md` for detailed build instructions.

Quick start:
```bash
swift build
```

## Running

```bash
swift run test2
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
swift run test2 --help
```

## Development

- **Build status**: See BUILD_STATUS.md
- **Build history**: See docs/build-history/
- **Architecture**: See ARCHITECTURE.md
- **Claude guidance**: See CLAUDE.md

## Project Structure

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
├── CLAUDE.md                  # AI agent guidance
└── docs/
    ├── BUILD.md               # Build instructions
    ├── TESTING.md             # Testing guidelines
    ├── USAGE.md               # Usage documentation
    └── build-history/         # Completed step logs
```

## License

[TBD]

---

**Built with**: Step-by-step instructions from `../../steps/`
**Last updated**: 2026-01-17
