# test7

**Version**: 0.1.0
**Language**: Swift
**Platform**: macOS only

An LLM-powered coding assistant built from scratch using the YBS framework.

## Overview

This is an interactive command-line tool that provides AI-assisted coding through:
- Interactive chat interface
- Local tool execution (file operations, shell commands)
- Support for configurable LLM backends (Ollama, OpenAI, Anthropic, etc.)
- Conversation context management
- Security sandboxing

## Prerequisites

- Swift 5.9+
- macOS 14.0+ (Sonoma)
- Ollama (for local LLM, optional): https://ollama.ai

## Building

See `docs/BUILD.md` for detailed build instructions.

Quick start:
```bash
swift build
```

## Running

```bash
swift run test7
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
test7 --help
```

## Development

- **Build status**: See BUILD_STATUS.md
- **Build history**: See docs/build-history/
- **Architecture**: See ARCHITECTURE.md
- **Claude guidance**: See CLAUDE.md

## Project Structure

```
test7/
├── Package.swift           # Swift package manifest
├── Sources/
│   └── test7/             # Main executable source
│       └── main.swift
├── Tests/
│   └── test7Tests/        # Test suite
├── BUILD_CONFIG.json       # Configuration from Step 0
├── BUILD_STATUS.md         # Current build status
├── ARCHITECTURE.md         # Architecture decisions
├── README.md               # This file
├── CLAUDE.md               # Claude Code guidance
└── docs/
    ├── BUILD.md            # Build instructions
    ├── TESTING.md          # Testing guidelines
    ├── USAGE.md            # Usage documentation
    └── build-history/      # Completed step logs
```

## License

[TBD]

---

**Built with**: Step-by-step instructions from `../../steps/`
**Created**: 2026-01-18T02:04:16Z
**Build started**: 2026-01-18T02:03:07Z
**Last updated**: 2026-01-18T02:09:31Z
