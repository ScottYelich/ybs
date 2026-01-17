# test1

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

- Swift: 5.9+
- macOS: 14+ (Sonoma)
- Swift Package Manager (included with Swift)
- Ollama (for local LLM, optional): https://ollama.ai

## Building

See `docs/BUILD.md` for detailed build instructions.

Quick start:
```bash
swift build
```

## Running

```bash
swift run test1
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
test1 --help
```

## Development

- **Build status**: See BUILD_STATUS.md
- **Build history**: See docs/build-history/
- **Architecture**: See ARCHITECTURE.md
- **Claude guidance**: See CLAUDE.md

## Project Structure

```
test1/
├── Sources/
│   └── test1/
│       └── main.swift
├── Tests/
│   └── test1Tests/
├── Package.swift
├── BUILD_STATUS.md
├── ARCHITECTURE.md
├── README.md (this file)
├── CLAUDE.md
└── docs/
    ├── BUILD.md
    ├── TESTING.md
    ├── USAGE.md
    └── build-history/
```

## License

[TBD]

---

**Built with**: Step-by-step instructions from `../../steps/`
**Last updated**: 2026-01-16 19:20:00
