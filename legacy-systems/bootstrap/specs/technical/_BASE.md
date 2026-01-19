# Technical BASE Specification: Bootstrap

**System**: Bootstrap (Swift AI Chat Tool)
**Version**: 1.0.0
**Last Updated**: 2026-01-17

## Overview

System-wide technical standards for the Bootstrap Swift AI tool for macOS.

## Design Tokens (UI)

### Colors (macOS Native)

```swift
// Use native macOS system colors for automatic light/dark mode support
struct Colors {
    static let primary = Color.accentColor
    static let background = Color(NSColor.windowBackgroundColor)
    static let text = Color.primary
    static let textSecondary = Color.secondary
    static let divider = Color(NSColor.separatorColor)

    static let semantic = SemanticColors()
}

struct SemanticColors {
    let success = Color.green
    let warning = Color.orange
    let error = Color.red
    let info = Color.blue
}
```

### Typography (SF Font)

```swift
struct Typography {
    static let title = Font.title
    static let headline = Font.headline
    static let body = Font.body
    static let caption = Font.caption
    static let monospace = Font.system(.body, design: .monospaced)
}
```

### Spacing (SwiftUI Standard)

```swift
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}
```

### Platform Guidelines

- **SwiftUI Native**: Use native controls for macOS feel
- **Apple HIG**: Follow Human Interface Guidelines
- **SF Symbols**: Use SF Symbols for all icons
- **Dynamic Type**: Support user font size preferences
- **Dark Mode**: Full support (automatic with native colors)
- **VoiceOver**: Full accessibility support

## Error Handling Standards

### Error Code Ranges

| Range | Category | Description |
|-------|----------|-------------|
| 1000-1099 | System Errors | macOS environment, permissions |
| 1100-1199 | File I/O Errors | Config files, data storage |
| 2000-2099 | Validation Errors | User input validation |
| 3000-3099 | LLM Errors | API communication, parsing |
| 4000-4099 | Configuration Errors | Invalid config, missing keys |

### Error Type Enum

```swift
enum BootstrapError: Error {
    case configNotFound
    case configInvalidFormat(String)
    case llmAPIFailure(statusCode: Int, message: String)
    case filePermissionDenied(path: String)
    case invalidInput(field: String, reason: String)

    var code: Int {
        switch self {
        case .configNotFound: return 4001
        case .configInvalidFormat: return 4002
        case .llmAPIFailure: return 3001
        case .filePermissionDenied: return 1001
        case .invalidInput: return 2001
        }
    }

    var userMessage: String {
        switch self {
        case .configNotFound:
            return "Configuration file not found. Run 'bootstrap init' to create one."
        case .configInvalidFormat(let detail):
            return "Configuration file is invalid: \(detail)"
        case .llmAPIFailure(_, let message):
            return "Failed to communicate with AI service: \(message)"
        case .filePermissionDenied(let path):
            return "Permission denied accessing \(path). Check file permissions."
        case .invalidInput(let field, let reason):
            return "Invalid \(field): \(reason)"
        }
    }
}
```

### Retry Strategy

| Error Type | Retry | Max Attempts | Backoff |
|------------|-------|--------------|---------|
| Network timeout | Yes | 3 | Exponential (1s, 2s, 4s) |
| Rate limit (429) | Yes | 5 | Linear (60s) |
| Server error (500) | Yes | 2 | Exponential (2s, 4s) |
| Client error (400) | No | 0 | N/A |
| Auth error (401) | No | 0 | N/A |

## Internationalization (i18n)

### Supported Languages

- **Default**: en-US (English)
- **Future**: Extensible for additional languages

### String Management

```swift
// Use SwiftUI's native localization
Text("welcome_message")
Text("item_count \(count)")

// LocalizedStringKey for formatted strings
```

**File**: `Localizable.strings`

```
// English (en)
"welcome_message" = "Welcome to Bootstrap";
"item_count" = "%lld items";
"error_config_not_found" = "Configuration file not found";
```

## Data Formats

### Configuration Format

```json
{
  "version": "1.0",
  "llm": {
    "provider": "anthropic",
    "model": "claude-sonnet-4.5",
    "apiKey": "${ANTHROPIC_API_KEY}"
  },
  "ui": {
    "theme": "system",
    "fontSize": "medium"
  }
}
```

**Location**: `~/.bootstrap/config.json`

### API Request/Response

- **Format**: JSON
- **Encoding**: UTF-8
- **Content-Type**: `application/json`

## Performance Standards

| Operation | Target | Maximum |
|-----------|--------|---------|
| App Launch | < 500ms | 1s |
| Message Send | < 100ms | 300ms |
| LLM Response (first token) | < 2s | 5s |
| UI Interaction | < 16ms | 100ms |

## Logging Standards

### Log Levels

```swift
enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARN"
    case error = "ERROR"
}
```

### Log Format

```swift
struct LogEntry {
    let timestamp: Date
    let level: LogLevel
    let component: String
    let message: String
    let context: [String: Any]?
}

// Example output:
// 2026-01-17 16:30:00.123 [INFO] LLMClient: Request sent | requestId=req_123
```

### Log Location

- **Development**: Console only
- **Production**: `~/Library/Logs/Bootstrap/bootstrap.log`
- **Rotation**: 10 MB max file size, keep 5 files

## Testing Standards

### Coverage Targets

- **Unit Tests**: 80% line coverage
- **Integration Tests**: Key workflows
- **UI Tests**: Critical user paths

### Test Naming

```swift
func test_sendMessage_validInput_sendsToLLM() {}
func test_loadConfig_fileNotFound_throwsError() {}
```

## Dependencies

### Swift Package Manager

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/anthropics/anthropic-sdk-swift", from: "0.1.0"),
    // Add other dependencies here
]
```

### Version Policy

- Use semantic versioning
- Lock versions in production
- Update dependencies monthly (security patches)

## macOS-Specific Considerations

### Sandboxing

- **App Sandbox**: Enabled
- **Entitlements**: Network, user-selected file read/write
- **Keychain**: Use for API key storage

### File Access

```swift
// Use FileManager for cross-platform paths
let configURL = FileManager.default
    .homeDirectoryForCurrentUser
    .appendingPathComponent(".bootstrap/config.json")
```

### Process Communication

- Use `Process` for running external commands
- Sanitize inputs to prevent command injection
- Set timeout for all process executions

---

## Usage in Feature Specs

```markdown
## Design Tokens

**Extends**: $ref:technical/_BASE.md#design-tokens

### Feature-Specific Colors
[Any feature-specific color overrides]

## Error Handling

**Extends**: $ref:technical/_BASE.md#error-handling-standards

### Feature-Specific Errors
- Error code 3010: [New error specific to this feature]
```

---

**Related BASE Specs**:
- `functional/_BASE.md` - macOS accessibility, UX patterns
- `security/_BASE.md` - API key security, sandboxing
- `operations/_BASE.md` - macOS deployment
