# Architecture Decisions: test6

**Version**: 0.1.0
**Decided**: 2026-01-17 14:34 UTC

## Technology Stack

### Programming Language
**Choice**: Swift

**Rationale**: Swift is the native language for macOS development, providing excellent performance, type safety, and seamless integration with the macOS ecosystem. The language's modern concurrency features (async/await) are ideal for handling LLM API calls and tool execution.

**Implications**:
- Project structure: Swift Package Manager (SPM) standard layout
- Build tool: Swift Package Manager (swift build)
- Package manager: Swift Package Manager
- Testing framework: XCTest (built-in)
- Fast compilation and native performance
- Strong type system prevents many runtime errors
- Modern concurrency with async/await for API calls

### Target Platform(s)
**Choice**: macOS only

**Rationale**: Focusing on a single platform allows for optimal use of platform-specific features and simplifies development, testing, and deployment. macOS is the primary development platform for Swift and provides excellent sandboxing capabilities.

**Implications**:
- Sandboxing approach: macOS App Sandbox or custom sandbox via processes
- Distribution: Single binary executable via swift build -c release
- CI/CD: Test on macOS only (GitHub Actions with macOS runner)
- Can leverage macOS-specific APIs and features
- Simpler deployment and distribution model

### LLM Provider Support
**Strategy**: Configurable via JSON configuration file

**Rationale**: LLM providers should be pluggable and user-configurable, not hardcoded architecture decisions. The configuration system (implemented in a later step) will allow users to choose Ollama, OpenAI, Anthropic, or any OpenAI-compatible provider.

**Implications**:
- API abstraction: Provider protocol/interface needed
- Configuration: JSON config with provider, model, endpoint, API key fields
- Dependencies: AsyncHTTPClient for REST APIs, Foundation for JSON parsing
- Default: Will default to Ollama (local, no API key) for development

## Implementation Notes

### Language-Specific Details

#### Swift
- **Build command**: `swift build`
- **Test command**: `swift test`
- **Run command**: `swift run test6` or `.build/debug/test6`
- **Package file**: Package.swift
- **Minimum version**: Swift 5.9
- **Minimum macOS**: macOS 14.0 (Sonoma)

### Platform-Specific Details

#### macOS only
- **Sandboxing**: Process-based sandboxing for tool execution
- **File paths**: Use FileManager and URL for path handling
- **Shell execution**: Process and Pipe for command execution
- **Security**: Leverage macOS security features

### LLM Integration (Configurable)

- **HTTP client**: AsyncHTTPClient (swift-server/async-http-client)
- **API abstraction**: Provider protocol for pluggable backends
- **Configuration**: JSON file with provider, model, endpoint, API key
- **Supported providers**: Ollama, OpenAI, Anthropic, any OpenAI-compatible API
- **Default**: Ollama at http://localhost:11434 (local, no key needed)

## Next Steps

Step 89b9e6233da5 (step 000002) will set up the Swift project structure with Package.swift and initial source files.

---

**Reference Documentation**:
- Language chosen: Swift (based on user preference and macOS target)
- Original spec reference: `../../specs/ybs-spec.md`
- Architectural decisions: `../../specs/ybs-decisions.md`
