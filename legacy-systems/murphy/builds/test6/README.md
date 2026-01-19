# test6

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
- macOS 14.0 (Sonoma) or later
- Ollama (for local LLM, optional): https://ollama.ai

## Building

See `docs/BUILD.md` for detailed build instructions.

Quick start:
```bash
swift build
```

## Running

```bash
swift run test6
```

Or after building:
```bash
.build/debug/test6
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
swift run test6 --help
```

## Development

- **Build status**: See BUILD_STATUS.md
- **Build history**: See docs/build-history/
- **Architecture**: See ARCHITECTURE.md
- **Claude guidance**: See CLAUDE.md

## Project Structure

```
test6/
├── Package.swift              # Swift Package Manager configuration
├── Sources/
│   └── test6/                # Main executable source
│       └── main.swift
├── Tests/
│   └── test6Tests/           # Unit tests
├── docs/                     # Documentation
│   ├── BUILD.md
│   ├── TESTING.md
│   ├── USAGE.md
│   └── build-history/        # Build step logs
├── BUILD_STATUS.md           # Current build status
├── ARCHITECTURE.md           # Architecture decisions
├── README.md                 # This file
└── CLAUDE.md                 # AI agent guidance
```

## License

[TBD]

---

**Built with**: Step-by-step instructions from `../../steps/`
**Last updated**: 2026-01-17 14:36 UTC
