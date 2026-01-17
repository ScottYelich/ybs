# Architecture Decisions: test1

**Version**: 0.1.0
**Decided**: 2026-01-16 19:05:00

## Technology Stack

### Programming Language
**Choice**: Swift

**Rationale**: Swift provides native macOS integration, fast startup times (~10ms vs Python's ~200ms), and produces a single binary with no runtime dependencies. The type system catches errors at compile time, and Foundation/AppKit provide excellent file system and process management capabilities. For a macOS-focused coding assistant, Swift is the optimal choice.

**Implications**:
- Project structure: Swift Package Manager layout (Sources/, Tests/, Package.swift)
- Build tool: Swift Package Manager (swift build)
- Package manager: SPM with swift-argument-parser, AsyncHTTPClient dependencies
- Testing framework: XCTest (built-in)
- Single binary distribution - no runtime needed

### Target Platform(s)
**Choice**: macOS only

**Rationale**: Focusing on macOS allows us to leverage platform-specific features like `sandbox-exec` for secure shell execution, native file system APIs, and macOS-specific security mechanisms. This simplifies development and allows for the best possible macOS experience without cross-platform compromises.

**Implications**:
- Sandboxing approach: Use macOS `sandbox-exec` with restrictive profiles
- Distribution: Single macOS binary, potentially via Homebrew
- CI/CD: Only need to test on macOS (GitHub Actions macOS runners)
- Can use macOS-specific APIs without fallbacks

### Initial LLM Provider(s)
**Choice**: Ollama only

**Rationale**: Starting with Ollama keeps the system completely local and free. No API keys required, no costs, and better privacy. Ollama is perfect for development and allows users to run the coding assistant without any cloud dependencies. The architecture can be extended later to support OpenAI/Anthropic if needed.

**Implications**:
- API abstraction needed: Minimal - single provider initially
- Configuration: Only need Ollama endpoint (default: http://localhost:11434)
- Dependencies: AsyncHTTPClient for HTTP requests, no auth required
- User setup: Must have Ollama installed and running locally

## Implementation Notes

### Language-Specific Details

#### Swift
- **Build command**: `swift build`
- **Test command**: `swift test`
- **Run command**: `swift run test1`
- **Package file**: `Package.swift`
- **Minimum version**: Swift 5.9+, macOS 14+
- **Key dependencies**:
  - swift-argument-parser (~1.3.0) for CLI
  - async-http-client (~1.20.0) for HTTP to Ollama

### Platform-Specific Details

#### macOS only
- **Sandboxing**: Use `sandbox-exec` with deny-by-default profile
  - Allow file read/write in project directory only
  - Block access to ~/.ssh, ~/.aws, ~/.config
  - Deny network access from sandboxed commands
- **File paths**: Use Foundation's FileManager for path handling
- **Shell execution**: Process with sandboxed environment via sandbox-exec

### LLM Integration

#### Ollama only
- **HTTP client**: AsyncHTTPClient from Swift Server Working Group
- **API format**: OpenAI-compatible endpoint at /api/chat
- **Streaming**: SSE support via AsyncHTTPClient streaming
- **Default endpoint**: http://localhost:11434
- **No authentication**: Ollama runs locally without auth
- **Error handling**: Check if Ollama is running, provide helpful error messages

## Next Steps

Step 000002 will set up the Swift project structure with Package.swift, initial source files, and verify the build environment works.

---

**Reference Documentation**:
- Language chosen: Swift (user preference + macOS native)
- Original spec reference: `../../docs/specs/system/ybs-spec.md` (matches Swift-specific design)
- Architectural decisions: `../../docs/specs/system/ybs-decisions.md` (aligns with D01 - Swift choice)
