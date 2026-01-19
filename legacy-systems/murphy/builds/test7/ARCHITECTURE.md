# Architecture Decisions: test7

**Version**: 0.1.0
**Decided**: 2026-01-18T02:05:39Z

## Technology Stack

### Programming Language
**Choice**: Swift

**Rationale**: Swift is the optimal choice for a macOS-focused AI coding assistant because:
- Native macOS integration with system APIs
- Excellent performance (compiled, not interpreted)
- Type safety reduces runtime errors
- Modern concurrency features (async/await)
- Strong package ecosystem via Swift Package Manager
- Direct access to macOS sandboxing APIs
- Fast compilation and startup times

**Implications**:
- Project structure: Swift Package Manager standard layout
- Build tool: Swift Package Manager (swift build)
- Package manager: SPM (Package.swift manifest)
- Testing framework: XCTest (built into Swift)
- Minimum version: Swift 5.9+ (for modern concurrency features)

### Target Platform(s)
**Choice**: macOS only

**Rationale**: Focusing on macOS exclusively allows:
- Leveraging platform-specific security features (sandbox-exec)
- Using native macOS APIs without cross-platform abstractions
- Simpler testing and deployment (single platform)
- Better integration with developer workflows on Mac
- Access to macOS-specific tools and utilities

**Implications**:
- Sandboxing approach: Use macOS sandbox-exec for shell command isolation
- Distribution: Binary executable for macOS 14+ (possibly via Homebrew)
- CI/CD: Test only on macOS runners
- File paths: macOS conventions (~/Library, etc.)
- Shell: Assume bash/zsh availability

### LLM Provider Support
**Strategy**: Configurable via JSON configuration file

**Rationale**: LLM providers should be pluggable and user-configurable, not hardcoded architecture decisions. The configuration system (implemented in a later step) will allow users to choose Ollama, OpenAI, Anthropic, or any OpenAI-compatible provider.

**Implications**:
- API abstraction: Provider protocol/interface needed (LLMProvider protocol)
- Configuration: JSON config with provider, model, endpoint, API key fields
- Dependencies: HTTP client (AsyncHTTPClient) for REST APIs, JSON parsing
- Default: Will default to Ollama (local, no API key) for development
- Multiple providers: Support switching between providers at runtime

## Implementation Notes

### Language-Specific Details

#### Swift
- **Build command**: `swift build`
- **Test command**: `swift test`
- **Run command**: `swift run bootstrap` (or executable name)
- **Package file**: `Package.swift`
- **Minimum Swift version**: 5.9
- **Minimum macOS version**: 14.0 (Sonoma)
- **Concurrency**: Modern Swift concurrency (async/await, actors)
- **Dependencies**:
  - swift-argument-parser (~1.3.0) for CLI parsing
  - AsyncHTTPClient (~1.20.0) for HTTP requests

### Platform-Specific Details

#### macOS only
- **Sandboxing**: Use `sandbox-exec` with custom profiles for shell command isolation
- **File paths**: Support standard macOS paths (~/, ~/Library/Application Support/)
- **Shell execution**: Assume bash/zsh, use Process API from Foundation
- **Configuration location**: ~/Library/Application Support/bootstrap/ for config files
- **Security**: Leverage macOS file permissions and sandbox restrictions

### LLM Integration (Configurable)

- **HTTP client**: AsyncHTTPClient (Swift package)
- **API abstraction**: LLMProvider protocol for pluggable backends
- **Configuration**: JSON file at ~/.config/bootstrap/config.json with:
  - provider (string: "ollama", "openai", "anthropic")
  - model (string: model name)
  - endpoint (string: API URL)
  - apiKey (string: optional, not needed for Ollama)
- **Supported providers**:
  - Ollama: http://localhost:11434 (default, local, no key)
  - OpenAI: https://api.openai.com/v1
  - Anthropic: https://api.anthropic.com/v1
  - Any OpenAI-compatible API
- **Default**: Ollama at http://localhost:11434 (local, no key needed)

## Next Steps

Step 3 (ybs-step_89b9e6233da5) will set up the Swift project structure with Swift Package Manager, create initial source files, and configure dependencies.

---

**Reference Documentation**:
- Language chosen: Swift (based on user preference and platform alignment)
- Original spec reference: `../../specs/ybs-spec.md` (Swift-focused specification)
- Architectural decisions: `../../specs/ybs-decisions.md` (Swift+macOS design choices)
- Implementation checklist: `../../specs/ybs-lessons-learned.md` (best practices)
