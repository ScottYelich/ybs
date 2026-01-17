# Architecture Decisions: test2

**Version**: 0.1.0
**Decided**: 2026-01-17 05:30 UTC

## Technology Stack

### Programming Language
**Choice**: Swift

**Rationale**: Swift provides native macOS integration, fast startup time (~10ms), single binary distribution, and strong type safety. Since we're targeting macOS only, Swift is the optimal choice for leveraging platform-specific features like `sandbox-exec` for security sandboxing.

**Implications**:
- Project structure: Swift Package Manager layout (Sources/, Tests/, Package.swift)
- Build tool: Swift Package Manager (SPM)
- Package manager: Swift Package Manager
- Testing framework: XCTest (built-in)

### Target Platform(s)
**Choice**: macOS only

**Rationale**: Focusing on macOS allows us to leverage platform-specific features without worrying about cross-platform compatibility. This simplifies the implementation, especially for security features like sandboxing.

**Implications**:
- Sandboxing approach: Can use macOS `sandbox-exec` with kernel-enforced filesystem/network isolation
- Distribution: Single binary via Swift Package Manager, can distribute via Homebrew or direct download
- CI/CD: Only need to test on macOS (GitHub Actions macOS runners)
- Minimum version: macOS 14+ (for modern Swift features)

### LLM Provider Support
**Strategy**: Configurable via JSON configuration file

**Rationale**: LLM providers should be pluggable and user-configurable, not hardcoded architecture decisions. The configuration system (implemented in a later step) will allow users to choose Ollama, OpenAI, Anthropic, or any OpenAI-compatible provider.

**Implications**:
- API abstraction: Provider protocol/interface needed
- Configuration: JSON config with provider, model, endpoint, API key fields
- Dependencies: AsyncHTTPClient or URLSession for HTTP requests, Foundation for JSON parsing
- Default: Will default to Ollama (local, no API key) for development

## Implementation Notes

### Language-Specific Details

#### Swift
- **Build command**: `swift build`
- **Test command**: `swift test`
- **Run command**: `swift run test2`
- **Package file**: `Package.swift`
- **Dependencies management**: Swift Package Manager (dependencies declared in Package.swift)
- **Minimum Swift version**: 5.9+

### Platform-Specific Details

#### macOS
- **Sandboxing**: macOS `sandbox-exec` with restrictive deny-by-default profile
- **File paths**: Standard macOS paths (`~/`, `/tmp/`, etc.)
- **Shell execution**: `/bin/bash` or `/bin/zsh` with sandboxing
- **Configuration locations**:
  - `/etc/ybs/config.json` (system-wide)
  - `~/.config/ybs/config.json` (user)
  - `~/.ybs.json` (user shorthand)
  - `./.ybs.json` (project-specific)

### LLM Integration (Configurable)

- **HTTP client**: AsyncHTTPClient (async/await support) or URLSession (built-in)
- **API abstraction**: LLMProvider protocol for pluggable backends
- **Configuration**: JSON file with provider, model, endpoint, API key
- **Supported providers**: Ollama, OpenAI, Anthropic, any OpenAI-compatible API
- **Default**: Ollama at http://localhost:11434 (local, no key needed)

## Next Steps

Step 000003 will set up the Swift project structure with Package.swift, initial source files, and test scaffolding.

---

**Reference Documentation**:
- Language chosen: Swift (native macOS, type-safe, fast)
- Platform chosen: macOS 14+ (single platform, use platform features)
- Original spec reference: `../../specs/ybs-spec.md` (Swift-specific spec)
- Architectural decisions: `../../specs/ybs-decisions.md` (D01 explains Swift choice)
