# Architecture Decisions: test3

**Version**: 0.1.0
**Decided**: 2026-01-17 06:31 UTC

## Technology Stack

### Programming Language
**Choice**: Swift

**Rationale**: Swift provides native macOS integration, fast startup times (~10ms), produces single binary executables, and offers strong type safety. This makes it ideal for a macOS-first coding assistant that needs to respond quickly to user commands.

**Implications**:
- Project structure: Swift Package Manager layout with Sources/ and Tests/ directories
- Build tool: Swift Package Manager (swift build, swift test, swift run)
- Package manager: Swift Package Manager with Package.swift manifest
- Testing framework: XCTest (built-in)

### Target Platform(s)
**Choice**: macOS only

**Rationale**: Focusing on macOS allows us to leverage macOS-specific features like sandbox-exec for kernel-level security sandboxing, native file system APIs, and platform-specific optimizations. This simplifies development and enables the best possible user experience on macOS.

**Implications**:
- Sandboxing approach: Use macOS sandbox-exec with restrictive security profiles for kernel-enforced isolation
- Distribution: Single binary executable or .app bundle via Homebrew, direct download, or Mac App Store
- CI/CD: Test on macOS runners only (GitHub Actions macos-latest)
- Development: Requires macOS for building and testing

### LLM Provider Support
**Strategy**: Configurable via JSON configuration file

**Rationale**: LLM providers should be pluggable and user-configurable, not hardcoded architecture decisions. The configuration system (implemented in a later step) will allow users to choose Ollama, OpenAI, Anthropic, or any OpenAI-compatible provider.

**Implications**:
- API abstraction: Provider protocol/interface needed for pluggable backends
- Configuration: JSON config with provider, model, endpoint, API key fields
- Dependencies: HTTP client for REST APIs (AsyncHTTPClient or URLSession), JSON parsing (Codable)
- Default: Will default to Ollama (local, no API key) at http://localhost:11434 for development

## Implementation Notes

### Language-Specific Details

#### Swift
- **Build command**: `swift build` or `swift build -c release`
- **Test command**: `swift test`
- **Run command**: `swift run` or `.build/release/test3`
- **Package file**: Package.swift (Swift Package Manager manifest)
- **Dependencies**: Managed via Package.swift with semantic versioning
- **Compiler**: Swift 5.9+ required
- **macOS version**: macOS 14+ (Sonoma or later)

### Platform-Specific Details

#### macOS only
- **Sandboxing**: macOS sandbox-exec with deny-by-default security profile
  - Blocks access to ~/.ssh, ~/.aws, ~/.config by default
  - Network isolation configurable
  - File system access restricted to allowed paths
- **File paths**: Use Foundation FileManager for path handling
  - Respect macOS conventions (~/.config, ~/Library/Application Support)
  - Handle spaces in paths correctly
- **Shell execution**: Use Process API with sandbox-exec wrapper
  - Default shell: /bin/bash or /bin/zsh
  - Environment variable handling via Process.environment

### LLM Integration (Configurable)

- **HTTP client**: AsyncHTTPClient (async/await) or URLSession (built-in)
- **API abstraction**: LLMProvider protocol with implementations for each backend
  - OllamaProvider
  - OpenAIProvider
  - AnthropicProvider
  - GenericOpenAICompatibleProvider
- **Configuration**: JSON file at ~/.config/test3/config.json or ./.test3.json
  - Fields: provider (string), model (string), endpoint (URL), api_key (optional string)
- **Supported providers**: Ollama, OpenAI, Anthropic, any OpenAI-compatible API (LocalAI, LM Studio, etc.)
- **Default**: Ollama at http://localhost:11434 with qwen3:14b model (local, free, no API key needed)

## Next Steps

Step 000002 (ybs-step_89b9e6233da5) will set up the Swift project structure with Package.swift, initial directory layout, and build tools.

---

**Reference Documentation**:
- Language chosen: Swift (user preference)
- Platform chosen: macOS (user preference)
- Original spec reference: `../../docs/specs/system/ybs-spec.md` (Swift-specific, directly applicable)
- Architectural decisions: `../../docs/specs/system/ybs-decisions.md` (fully applicable for Swift/macOS)
