# Architecture Decisions: test5

**Version**: 0.1.0
**Decided**: 2026-01-17 07:39 UTC

## Technology Stack

### Programming Language
**Choice**: Swift

**Rationale**: Swift provides native macOS integration with excellent performance characteristics. It offers type safety, modern language features, fast compilation and startup times, and produces single-binary executables. The language is well-suited for system tools and has strong standard library support for file I/O, process execution, and concurrency.

**Implications**:
- Project structure: Swift Package Manager (SPM) with Sources/ and Tests/ directories
- Build tool: Swift Package Manager (swift build, swift run, swift test)
- Package manager: SPM with Package.swift manifest
- Testing framework: XCTest (built-in)
- Single binary output: Easy distribution and deployment
- Memory safety: Automatic reference counting (ARC) with strong type system
- Concurrency: Native async/await support for LLM API calls

### Target Platform(s)
**Choice**: macOS only

**Rationale**: Focusing on macOS allows use of native sandboxing features (sandbox-exec) and simplified development without cross-platform complexity. This aligns with the bootstrap implementation specifications and enables kernel-enforced security boundaries.

**Implications**:
- Sandboxing approach: macOS sandbox-exec with restrictive profiles (deny-by-default)
- Distribution: Single binary for macOS 14+ (.pkg installer or direct binary)
- CI/CD: Test on macOS only (GitHub Actions macOS runners)
- File paths: Use Foundation's URL/Path APIs (cross-platform compatible if needed later)
- Shell execution: Use Process API with sandbox-exec wrapper

### LLM Provider Support
**Strategy**: Configurable via JSON configuration file

**Rationale**: LLM providers should be pluggable and user-configurable, not hardcoded architecture decisions. The configuration system (implemented in a later step) will allow users to choose Ollama, OpenAI, Anthropic, or any OpenAI-compatible provider. This provides flexibility without architectural lock-in.

**Implications**:
- API abstraction: Provider protocol/interface for different backends
- Configuration: JSON config with provider, model, endpoint, API key fields
- Dependencies: AsyncHTTPClient for REST API calls, Foundation for JSON parsing
- Default: Ollama (local, no API key) at http://localhost:11434 for development
- Provider implementations: OpenAI-compatible format as base, with adapters for specific providers

## Implementation Notes

### Language-Specific Details

#### Swift
- **Build command**: `swift build` (debug) or `swift build -c release` (optimized)
- **Test command**: `swift test`
- **Run command**: `swift run test5` (development) or `.build/release/test5` (production)
- **Package file**: Package.swift (SPM manifest)
- **Dependencies**: swift-argument-parser (~1.3.0), AsyncHTTPClient (~1.20.0)
- **Target**: macOS 14+ (aligned with native APIs and sandbox features)

### Platform-Specific Details

#### macOS only
- **Sandboxing**: sandbox-exec with custom .sb profile (deny-by-default, allow specific paths)
- **File paths**: Use FileManager and URL APIs from Foundation
- **Shell execution**: Process API wrapped with sandbox-exec for security
- **Configuration location**: `~/.config/test5/config.json` (XDG-style) or `~/.test5.json`
- **System integration**: Can integrate with Finder, Spotlight, Quick Look if needed later

### LLM Integration (Configurable)

- **HTTP client**: AsyncHTTPClient for async/await streaming support
- **API abstraction**: LLMProvider protocol with concrete implementations
- **Configuration**: JSON file with structure: `{"provider": "ollama", "model": "qwen2.5-coder:14b", "endpoint": "http://localhost:11434", "api_key": null}`
- **Supported providers**:
  - Ollama (local, OpenAI-compatible API)
  - OpenAI (cloud, requires API key)
  - Anthropic (cloud, requires API key, needs format adapter)
  - Any OpenAI-compatible endpoint
- **Default**: Ollama at http://localhost:11434 (local, no key needed, free)
- **Streaming**: Use Server-Sent Events (SSE) for response streaming

## Core Architecture Principles

Based on YBS framework and bootstrap specifications:

1. **Local-first**: All tool execution happens locally; LLM can be local (Ollama) or remote
2. **Minimal dependencies**: Use Swift standard library and Foundation where possible
3. **Extensible**: Built-in tools (6 core) + external tools (JSON protocol)
4. **Secure by default**: Sandboxed shell execution, confirmation for destructive operations
5. **Simple core**: Agent loop designed to be understandable in <100 lines

## Tool Architecture

**Hybrid approach** (built-in + external):

**Built-in tools** (compiled into binary):
- `read_file` - Read file contents
- `write_file` - Write/create files
- `edit_file` - SEARCH/REPLACE edits
- `list_files` - File discovery
- `search_files` - Content search (grep/ripgrep)
- `run_shell` - Execute shell commands (sandboxed)

**External tools** (runtime-loaded executables):
- JSON protocol: executable receives JSON via argv, outputs JSON to stdout
- Language-agnostic: any language that can handle JSON I/O
- Examples: web_search, web_fetch, project-specific test runners

## Security Model

- **Path sandboxing**: All file operations restricted to allowed directories (project root, temp, config)
- **Shell sandboxing**: sandbox-exec with restrictive profile blocks ~/.ssh, ~/.aws, network access
- **Confirmation required**: write_file, run_shell, destructive operations need user approval
- **Session allow-list**: User can approve tool for current session only (not persisted)
- **Blocked commands**: `rm -rf /`, `sudo`, `chmod 777`, etc.

## Next Steps

Step 3 (ybs-step_89b9e6233da5) will set up the Swift project structure with Package.swift and initial source files.

---

**Reference Documentation**:
- Language chosen: User preference via BUILD_CONFIG.json
- Original spec reference: `../../specs/ybs-spec.md` (Swift-specific bootstrap spec)
- Architectural decisions: `../../specs/ybs-decisions.md` (reference for design patterns)
- Implementation checklist: `../../specs/ybs-lessons-learned.md`
