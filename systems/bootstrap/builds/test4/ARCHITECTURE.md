# Architecture Decisions: test4

**Version**: 0.1.0
**Decided**: 2026-01-16 23:03 UTC

## Technology Stack

### Programming Language
**Choice**: Swift

**Rationale**: Swift provides excellent macOS integration with native performance, modern language features, and strong type safety. As a compiled language, it produces fast single-binary executables with minimal dependencies. Swift's concurrency model (async/await) makes it ideal for handling LLM streaming responses.

**Implications**:
- Project structure: Swift Package Manager (SPM) standard layout with Sources/ and Tests/
- Build tool: Swift Package Manager (swift build, swift test, swift run)
- Package manager: SPM with Package.swift manifest
- Testing framework: XCTest (built into Swift)
- Binary distribution: Single compiled executable, no runtime required
- Development: Xcode or command-line swift tools

### Target Platform(s)
**Choice**: macOS only

**Rationale**: macOS provides robust sandboxing via sandbox-exec, native Swift support, and straightforward filesystem security. Focusing on a single platform allows for tight integration and leveraging platform-specific features.

**Implications**:
- Sandboxing approach: macOS sandbox-exec with restrictive profiles (deny-by-default)
- Distribution: macOS binary (.app bundle or single executable)
- CI/CD: Test on macOS only (can use GitHub Actions with macos-latest)
- Filesystem: Standard POSIX paths with macOS-specific locations (~/.config/, /etc/)
- Minimum version: macOS 14+ for modern Swift features

### LLM Provider Support
**Strategy**: Configurable via JSON configuration file

**Rationale**: LLM providers should be pluggable and user-configurable, not hardcoded architecture decisions. The configuration system (implemented in a later step) will allow users to choose Ollama, OpenAI, Anthropic, or any OpenAI-compatible provider.

**Implications**:
- API abstraction: Provider protocol/interface needed for different backends
- Configuration: JSON config with provider, model, endpoint, API key fields
- Dependencies: HTTP client for REST APIs (AsyncHTTPClient or URLSession), JSON parsing (Codable)
- Default: Will default to Ollama (local, no API key) for development at http://localhost:11434
- Streaming: Support for Server-Sent Events (SSE) or streaming JSON responses

## Implementation Notes

### Language-Specific Details

#### Swift
- **Build command**: `swift build` (debug) or `swift build -c release` (optimized)
- **Test command**: `swift test`
- **Run command**: `swift run ybs` (or executable name)
- **Package file**: `Package.swift` (SPM manifest)
- **Directory structure**:
  ```
  test4/
  ├── Package.swift
  ├── Sources/
  │   └── ybs/
  │       ├── main.swift
  │       ├── Config/
  │       ├── Agent/
  │       ├── LLM/
  │       ├── Tools/
  │       ├── Security/
  │       └── UI/
  └── Tests/
      └── ybsTests/
  ```
- **Dependencies**: Managed in Package.swift via SPM
  - swift-argument-parser (~1.3.0) for CLI parsing
  - AsyncHTTPClient (~1.20.0) or URLSession for HTTP
  - No external runtime dependencies

### Platform-Specific Details

#### macOS only
- **Sandboxing**: macOS sandbox-exec with custom .sb profiles
  - Deny-by-default policy
  - Whitelist specific directories for file access
  - Block network by default (allow via config)
  - Block sensitive paths (~/.ssh, ~/.aws, ~/.config)
- **File paths**:
  - Config: ~/.config/ybs/config.json, ~/.ybs.json, .ybs.json
  - System config: /etc/ybs/config.json
  - Use FileManager for cross-platform path handling
- **Shell execution**:
  - Use Process API with sandbox-exec wrapper
  - Pass sandbox profile as argument
  - Capture stdout/stderr separately

### LLM Integration (Configurable)

- **HTTP client**: AsyncHTTPClient for async/streaming support, or URLSession (built-in)
- **API abstraction**:
  - LLMProvider protocol with methods: chat(messages) -> AsyncStream<String>
  - Implementations: OllamaProvider, OpenAIProvider, AnthropicProvider
- **Configuration**: JSON file with:
  ```json
  {
    "llm": {
      "provider": "ollama",
      "model": "qwen2.5:14b",
      "endpoint": "http://localhost:11434",
      "api_key": null
    }
  }
  ```
- **Supported providers**:
  - Ollama (local, no key, default)
  - OpenAI (cloud, requires key)
  - Anthropic (cloud, requires key, needs format mapping)
  - Any OpenAI-compatible API
- **Default**: Ollama at http://localhost:11434 (local, no key needed)
- **Streaming**: Use AsyncStream<String> for token streaming

## Next Steps

Step 3 (ybs-step_89b9e6233da5) will set up the Swift project structure with Package.swift, initial directories, and build tools.

---

**Reference Documentation**:
- Language chosen: Swift (based on user preference in Step 0)
- Original spec reference: `../../specs/ybs-spec.md` (Swift-specific reference implementation)
- Architectural decisions: `../../specs/ybs-decisions.md` (reference documentation)
- Bootstrap implementation: This build follows YBS framework for creating an LLM coding assistant
