# Claude Chat Example

**Example Level**: 4 (Complex)
**Language**: Swift
**Purpose**: Production-quality CLI tool demonstrating full YBS capabilities

---

## Overview

This example builds a feature-rich AI chat CLI tool with Claude API integration.

**Why this example?**
- ✅ Framework stress test (validates YBS at scale)
- ✅ Production-quality patterns (error handling, configuration, testing)
- ✅ Advanced YBS features (change management, feature protocol)
- ✅ Real tool (actually usable for AI chat)

**Note**: This is a complex example with 44+ steps. Start with simpler examples ([01-hello-world](../01-hello-world/), [02-calculator](../02-calculator/)) before studying this one.

---

## Features

### Core Functionality
- **Claude API integration**: Streaming and non-streaming responses
- **Message history**: Conversation persistence and retrieval
- **Context management**: Token counting, context window optimization
- **Multiple models**: Support for Sonnet, Opus, Haiku

### Advanced Features
- **Readline support**: Line editing, history, SSH detection
- **Configuration system**: User preferences, API keys, defaults
- **Error handling**: Comprehensive error recovery and user feedback
- **Streaming responses**: Real-time token display
- **Web search**: Integration with search capabilities (optional)
- **Cost estimation**: Track token usage and costs

### Development Features
- **Comprehensive tests**: Unit, integration, and system tests
- **Change management**: Systematic feature addition workflow
- **Traceability**: Complete code → spec traceability
- **Documentation**: Architecture, security, usage guides

---

## Structure

```
04-claude-chat/
├── README.md                          # This file
├── specs/                             # What to build
│   ├── technical/
│   │   └── ybs-spec.md                # Technical specification
│   ├── architecture/
│   │   └── ybs-decisions.md           # Architectural decisions (ADRs)
│   ├── general/
│   │   └── ybs-lessons-learned.md     # Implementation checklist
│   └── testing/
│       └── TESTING-REQUIREMENTS.md    # Test requirements
├── steps/                             # How to build (44+ steps)
│   ├── ybs-step_000000000000.md       # Step 0: Build config
│   ├── ybs-step_478a8c4b0cef.md       # Step 1: Project structure
│   ├── ybs-step_c5404152680d.md       # Step 2: Core CLI
│   ├── ...                            # Steps 3-42: Feature development
│   ├── ybs-step_c940e69...md          # Step 43: Context management
│   └── ybs-step_aea2359...md          # Step 44: Readline support
├── docs/                              # Documentation
│   ├── tool-architecture.md
│   ├── security-model.md
│   ├── configuration.md
│   └── usage-guide.md
└── builds/
    └── demo/                          # Example build (future)
```

---

## Example Usage

```bash
# Interactive chat
./claude-chat
> Hello! How are you?
I'm doing well, thank you for asking! ...

# Single query
./claude-chat "What is the capital of France?"

# With specific model
./claude-chat --model opus "Explain quantum computing"

# Streaming disabled
./claude-chat --no-stream "Quick response please"

# List available models
./claude-chat --list-models
```

---

## Development History

### Original Name: Bootstrap

This example was originally called "murphy" because it was the first system built with YBS - it "bootstrapped" the methodology.

**Renamed to Claude Chat** (2026-01-18):
- Reason: Avoid naming confusion with YBS framework
- Tool output name changed: ybs → claude-chat
- All git history and traceability preserved

### Timeline

- **2026-01-16**: Initial murphy system created
- **Steps 0-3**: Core CLI structure, API integration
- **Steps 4-42**: Feature development (history, context, configuration)
- **Step 43**: Context statistics and dynamic management
- **Step 44**: Readline support with SSH detection
- **2026-01-18**: Renamed to claude-chat

---

## Status

🚧 **Placeholder - Content to be migrated**

This example directory is a placeholder in the YBS v2.0.0 restructure. The complete implementation currently exists in `legacy-systems/murphy/` and will be migrated here in a future update.

**Current location**: `legacy-systems/murphy/`

---

## Learning Path

**Before studying this example:**

1. ✅ Complete [01-hello-world](../01-hello-world/) - Learn YBS basics
2. ✅ Complete [02-calculator](../02-calculator/) - Learn multi-module patterns
3. ✅ Review [03-rest-api](../03-rest-api/) - Learn multi-tier architecture
4. ✅ Read [YBS Methodology](../../framework/methodology/overview.md)

**Then dive into this example to learn:**
- Production-quality code organization
- Advanced error handling patterns
- Configuration management strategies
- Change management workflow
- Feature addition protocol
- Comprehensive testing approaches

---

## Key Concepts Demonstrated

### 1. Change Management
See: [../../framework/methodology/change-management.md](../../framework/methodology/change-management.md)

Systematic process for adding features:
- Scan for duplicates
- Update specs first
- Create/update steps
- Implement with tests
- Verify coverage and traceability

### 2. Feature Addition Protocol
See: [../../framework/methodology/feature-addition-protocol.md](../../framework/methodology/feature-addition-protocol.md)

Mandatory requirements:
- Tests written before/during implementation
- Minimum 60% line coverage (required)
- Target 80% line coverage (recommended)
- 100% coverage for critical paths
- Traceability comments in all source files

### 3. Traceability
Every source file contains `// Implements:` comments linking to specifications:

```swift
// Implements: ybs-spec.md § 3.2 Message History
// - Store conversation messages in CoreData
// - Retrieve history by conversation ID
class MessageStore {
    // ...
}
```

Verified with: `./framework/tools/check-traceability.sh murphy test5`

---

## References

- **Examples Overview**: [../README.md](../README.md)
- **Current Implementation**: [../../legacy-systems/murphy/](../../legacy-systems/murphy/)
- **Tool Architecture**: [../../legacy-systems/murphy/docs/tool-architecture.md](../../legacy-systems/murphy/docs/tool-architecture.md)
- **Security Model**: [../../legacy-systems/murphy/docs/security-model.md](../../legacy-systems/murphy/docs/security-model.md)
