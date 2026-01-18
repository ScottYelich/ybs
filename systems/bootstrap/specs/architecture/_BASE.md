# Architecture BASE Specification: Bootstrap

**System**: Bootstrap (Swift AI Chat Tool)
**Version**: 1.0.0
**Last Updated**: 2026-01-17

## Architectural Principles

1. **Simplicity**: Start simple, add complexity only when needed
2. **Native**: Use macOS/SwiftUI native patterns
3. **Testability**: Design for unit and UI testing
4. **Performance**: Fast app launch, responsive UI
5. **Privacy**: All data local, no tracking

## System Architecture

```
┌─────────────────────────────────────────┐
│         SwiftUI Views (UI)              │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      View Models (Business Logic)       │
└──────┬──────────────────┬───────────────┘
       │                  │
       ↓                  ↓
┌──────────────┐   ┌──────────────┐
│   Services   │   │Configuration │
│              │   │   Manager    │
│- LLMService  │   └──────────────┘
│- Storage     │
│- Keychain    │
└──────────────┘
       │
       ↓
┌─────────────────────────────────────────┐
│     External (Anthropic API)            │
└─────────────────────────────────────────┘
```

## Technology Stack

| Layer | Technology | Justification |
|-------|------------|---------------|
| UI | SwiftUI | Native macOS, modern, reactive |
| Language | Swift | Native performance, type safety |
| Storage | FileManager + JSON | Simple, no database overhead |
| Secrets | Keychain | Secure, native macOS |
| Networking | URLSession | Native, reliable |
| Testing | XCTest | Native testing framework |

## Architectural Patterns

### MVVM (Model-View-ViewModel)

```swift
// Model
struct Message: Codable {
    let id: UUID
    let content: String
    let role: MessageRole
    let timestamp: Date
}

// ViewModel
@MainActor
class ConversationViewModel: ObservableObject {
    @Published var messages: [Message] = []

    private let llmService: LLMService

    func send(_ text: String) async {
        // Business logic here
    }
}

// View
struct ConversationView: View {
    @StateObject var viewModel: ConversationViewModel

    var body: some View {
        // UI here
    }
}
```

### Dependency Injection

```swift
// Protocol-based services
protocol LLMService {
    func send(_ message: String) async throws -> String
}

// Production implementation
class AnthropicService: LLMService {
    func send(_ message: String) async throws -> String {
        // API call
    }
}

// Mock for testing
class MockLLMService: LLMService {
    func send(_ message: String) async throws -> String {
        return "Mock response"
    }
}

// Inject into ViewModel
class ConversationViewModel {
    let llmService: LLMService

    init(llmService: LLMService) {
        self.llmService = llmService
    }
}
```

### Repository Pattern (Storage)

```swift
protocol ConversationRepository {
    func load() async throws -> [Conversation]
    func save(_ conversation: Conversation) async throws
    func delete(id: UUID) async throws
}

class FileConversationRepository: ConversationRepository {
    // Implementation using FileManager
}
```

## Key Architectural Decisions

### ADR-001: Use SwiftUI over AppKit

**Decision**: Use SwiftUI for all UI

**Rationale**:
- Modern, declarative syntax
- Automatic Dark Mode support
- Built-in accessibility
- Future-proof

**Trade-offs**:
- macOS 13+ only (acceptable)
- Some advanced features require workarounds

### ADR-002: JSON File Storage over Core Data

**Decision**: Use JSON files for conversation storage

**Rationale**:
- Simple data model
- Human-readable format
- No migration complexity
- Easy backup/export

**Trade-offs**:
- Not suitable for large datasets (acceptable for MVP)
- No built-in querying (acceptable for small data)

### ADR-003: Async/Await for API Calls

**Decision**: Use Swift async/await for all async operations

**Rationale**:
- Modern Swift concurrency
- Cleaner code than callbacks
- Better error handling
- Native cancellation support

## Quality Attributes

### Performance Targets

| Metric | Target |
|--------|--------|
| App Launch | < 500ms |
| Message Send | < 100ms (UI update) |
| First API Response | < 2s |
| UI Responsiveness | 60 FPS |

### Scalability Limits

- **Conversations**: 1,000 conversations (per user)
- **Messages per conversation**: 10,000 messages
- **Total storage**: < 100 MB

If exceeded, suggest archiving old conversations.

## Evolution Roadmap

**Phase 1** (Current - v1.0):
- Basic chat functionality
- Single conversation
- macOS only

**Phase 2** (v2.0):
- Multiple conversations
- Search functionality
- Conversation export

**Phase 3** (v3.0+):
- Plugins/extensions
- Custom prompts
- Team/sharing features

---

## Usage in Feature Specs

```markdown
## Architecture

**Extends**: $ref:architecture/_BASE.md#architectural-patterns

### Feature Architecture
[Feature-specific architecture diagram or description]

### Architectural Decisions
**ADR-XXX**: [New decision for this feature]
```
