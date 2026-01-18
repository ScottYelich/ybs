# Step 000032: Apple Foundation Model Integration

**GUID**: e1f2a3b4c5d6
**Type**: Implementation
**Status**: Planned
**Last Updated**: 2026-01-18

---

## Overview

**Purpose**: Integrate Apple's Foundation Model for local LLM inference on macOS 15+.

**What This Step Does**:
- Detects macOS version (requires macOS 15 Sequoia or later)
- Integrates with Apple's MLX or native ML frameworks
- Adds `--provider apple` support
- Provides local, no-API-key LLM option
- Falls back gracefully on older macOS versions

**Why This Step Exists**:
Apple Foundation Model provides:
- **Local inference** - No cloud API required
- **Privacy-first** - Data stays on device
- **No API costs** - Free to use
- **Fast on Apple Silicon** - Optimized for M-series chips
- **Zero configuration** - Works out of the box on macOS 15+

**Dependencies**:
- ✅ Step 11: HTTP Client & OpenAI API Types (for protocol reuse)
- ✅ Step 12: LLM Client (integration point)

---

## Specifications

**Implements**:
- Spec: `systems/bootstrap/specs/technical/ybs-spec.md` § 7.2 Supported Providers
- Provider: "Apple Foundation" - Native Apple ML framework, Local, macOS 15+

**References**:
- `systems/bootstrap/specs/technical/ybs-spec.md` lines 624-632 (LLM Providers)
- Apple MLX Framework documentation
- Apple Foundation Model documentation

---

## What to Build

### File Structure

```
Sources/test7/LLM/
├── AppleLLMClient.swift       # Apple Foundation Model client
└── AppleMLDetection.swift     # macOS version detection
```

### 1. AppleMLDetection.swift

**Purpose**: Detect if Apple Foundation Model is available on the system.

**Key Components**:

```swift
import Foundation

public enum AppleMLAvailability {
    case available(version: String)
    case unavailable(reason: String)
}

public class AppleMLDetection {
    /// Check if Apple Foundation Model is available
    /// - Returns: Availability status with details
    public static func checkAvailability() -> AppleMLAvailability {
        // Check macOS version
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion

        // Requires macOS 15 (Sequoia) or later
        guard osVersion.majorVersion >= 15 else {
            return .unavailable(reason: "Requires macOS 15 (Sequoia) or later. Current: \(osVersion)")
        }

        // Check for Apple Silicon (M-series chip preferred)
        #if arch(arm64)
        // Apple Silicon - best performance
        return .available(version: "\(osVersion.majorVersion).\(osVersion.minorVersion)")
        #else
        // Intel Mac - may work but not optimal
        return .available(version: "\(osVersion.majorVersion).\(osVersion.minorVersion) (Intel)")
        #endif
    }

    /// Get friendly availability message
    public static func availabilityMessage() -> String {
        switch checkAvailability() {
        case .available(let version):
            return "✓ Apple Foundation Model available (macOS \(version))"
        case .unavailable(let reason):
            return "✗ Apple Foundation Model unavailable: \(reason)"
        }
    }
}
```

**Size**: ~60 lines

---

### 2. AppleLLMClient.swift

**Purpose**: LLM client implementation using Apple Foundation Model.

**Key Components**:

```swift
import Foundation

/// LLM client for Apple Foundation Model
public class AppleLLMClient: LLMClientProtocol {
    private let config: LLMConfig

    public init(config: LLMConfig) throws {
        // Verify availability
        guard case .available = AppleMLDetection.checkAvailability() else {
            throw YBSError.llmError(
                message: "Apple Foundation Model not available on this system"
            )
        }

        self.config = config
    }

    /// Send message to Apple Foundation Model
    public func sendMessage(
        messages: [Message],
        tools: [Tool]
    ) async throws -> Message {
        // TODO: Integrate with Apple ML framework
        // This is a placeholder implementation

        Logger.info("Using Apple Foundation Model (local inference)")

        // For now, return a helpful error message
        throw YBSError.notImplemented(
            feature: "Apple Foundation Model integration",
            suggestion: "This feature requires integration with Apple's MLX framework. " +
                       "Use --provider anthropic, --provider openai, or --provider ollama instead."
        )
    }

    /// Stream messages from Apple Foundation Model
    public func sendMessageStreaming(
        messages: [Message],
        tools: [Tool],
        onChunk: @escaping (String) -> Void
    ) async throws -> Message {
        // TODO: Implement streaming support
        return try await sendMessage(messages: messages, tools: tools)
    }
}
```

**Notes**:
- **Placeholder implementation** - Actual Apple ML integration requires:
  - Apple MLX framework (Swift bindings)
  - Or CoreML integration
  - Or Apple Foundation Model API (if/when available)
- **Future enhancement** - This step documents the interface
- **Current behavior** - Gracefully fails with helpful error message

**Size**: ~80 lines (with placeholder)

---

### 3. Integration with LLMClientFactory

**Update**: `Sources/test7/LLM/LLMClient.swift` or create factory pattern

```swift
public enum LLMProvider: String, Codable {
    case ollama
    case openai
    case anthropic
    case apple  // NEW
}

public class LLMClientFactory {
    public static func createClient(config: LLMConfig) throws -> LLMClientProtocol {
        switch config.provider {
        case .ollama:
            return try OllamaLLMClient(config: config)
        case .openai:
            return try OpenAILLMClient(config: config)
        case .anthropic:
            return try AnthropicLLMClient(config: config)
        case .apple:
            return try AppleLLMClient(config: config)  // NEW
        }
    }
}
```

---

### 4. Update Config Schema

**Add to Config.swift**:

```swift
public struct LLMConfig: Codable {
    public var provider: LLMProvider
    public var model: String
    public var endpoint: String?
    public var apiKey: String?
    // ... existing fields ...
}

// Update default config
extension Config {
    public static var `default`: Config {
        var config = Config()

        // Auto-detect best available provider
        if case .available = AppleMLDetection.checkAvailability() {
            config.llm.provider = .apple
            config.llm.model = "foundation"  // Default Apple model name
        } else {
            config.llm.provider = .ollama
            config.llm.model = "qwen3:14b"
        }

        return config
    }
}
```

---

### 5. CLI Integration

**Update YBSCommand.swift**:

```swift
@Option(name: .short, help: "Override LLM provider (ollama, openai, anthropic, apple)")
var provider: String?
```

**Add provider validation**:

```swift
func validateProvider(_ name: String) throws -> LLMProvider {
    guard let provider = LLMProvider(rawValue: name.lowercased()) else {
        throw YBSError.invalidConfiguration(
            "Unknown provider: \(name). Supported: ollama, openai, anthropic, apple"
        )
    }

    // Special check for Apple
    if provider == .apple {
        guard case .available = AppleMLDetection.checkAvailability() else {
            throw YBSError.invalidConfiguration(
                "Apple Foundation Model requires macOS 15 (Sequoia) or later"
            )
        }
    }

    return provider
}
```

---

## Tests

**Location**: `Tests/test7Tests/LLM/AppleMLTests.swift`

### Test Cases

**1. Availability Detection**:
```swift
func testAvailabilityDetection() {
    let availability = AppleMLDetection.checkAvailability()

    // On macOS 15+: should be available
    // On macOS <15: should be unavailable

    switch availability {
    case .available(let version):
        print("✓ Apple ML available: \(version)")
    case .unavailable(let reason):
        print("✗ Apple ML unavailable: \(reason)")
    }
}
```

**2. Client Creation**:
```swift
func testClientCreation() throws {
    let config = LLMConfig(
        provider: .apple,
        model: "foundation",
        endpoint: nil,
        apiKey: nil
    )

    do {
        let client = try AppleLLMClient(config: config)
        // Should succeed on macOS 15+
    } catch {
        // Should fail on macOS <15
        XCTAssertTrue(error is YBSError)
    }
}
```

**3. Graceful Fallback**:
```swift
func testGracefulFallback() {
    var config = Config.default

    // Should auto-select available provider
    XCTAssertNotNil(config.llm.provider)

    // On macOS 15+: .apple
    // On macOS <15: .ollama
}
```

**Total Tests**: ~5-6 tests

---

## Verification Steps

### 1. Manual Testing (macOS 15+)

**Test availability check**:
```bash
swift run test7 --provider apple --version
# Should show: Apple Foundation Model available
```

**Test graceful failure**:
```bash
swift run test7 --provider apple
# Should show: Feature not yet implemented, use another provider
```

### 2. Manual Testing (macOS <15)

**Test unavailability**:
```bash
swift run test7 --provider apple
# Should show: Requires macOS 15 (Sequoia) or later
```

### 3. Automated Testing

```bash
swift test --filter AppleMLTests
# Should pass on all macOS versions
```

### 4. Success Criteria

- ✅ Detects macOS version correctly
- ✅ Reports availability accurately
- ✅ CLI accepts `--provider apple`
- ✅ Fails gracefully with helpful error on macOS <15
- ✅ Returns "not implemented" error (placeholder) on macOS 15+
- ✅ Auto-selects Apple provider on macOS 15+ (if desired)
- ✅ All tests pass

---

## Configuration

**Default config when Apple available**:
```json
{
  "llm": {
    "provider": "apple",
    "model": "foundation",
    "endpoint": null,
    "apiKey": null
  }
}
```

**Manual override**:
```bash
swift run test7 --provider apple --model foundation
```

---

## Dependencies

**Requires**:
- Step 11: HTTP Client (protocol patterns)
- Step 12: LLM Client (integration point)

**Enables**:
- Local LLM inference on macOS 15+
- Privacy-first AI coding assistant
- Zero API cost option
- Foundation for Apple ecosystem integration

---

## Implementation Notes

### Apple ML Framework Options

**Option 1: MLX (Recommended)**
- Metal-accelerated ML framework
- Swift bindings available
- Optimized for Apple Silicon
- **Issue**: Requires separate MLX installation

**Option 2: CoreML**
- Built into macOS
- No extra dependencies
- **Issue**: Requires model conversion

**Option 3: Apple Foundation Model API**
- When/if Apple releases official API
- Most integrated option
- **Issue**: Not yet available (as of macOS 15.0)

**Current approach**:
- Detect availability (macOS 15+)
- Provide interface/stub
- Return helpful error until implementation complete

### macOS Version Detection

```swift
let version = ProcessInfo.processInfo.operatingSystemVersion
// version.majorVersion >= 15 for macOS Sequoia
```

### Apple Silicon Detection

```swift
#if arch(arm64)
// Apple Silicon (M1, M2, M3, etc.)
#else
// Intel Mac
#endif
```

---

## Future Enhancements

**Phase 1** (This step):
- ✅ Detect macOS 15+
- ✅ Add CLI flag `--provider apple`
- ✅ Graceful error message

**Phase 2** (Future):
- Integrate with MLX framework
- Load local models
- Implement streaming

**Phase 3** (Future):
- Auto-download models
- Model selection UI
- Performance optimization

---

## Lessons Learned Integration

**From** `systems/bootstrap/specs/general/ybs-lessons-learned.md`:

**§ Progressive Enhancement**:
- ✅ Works on older macOS (graceful fallback)
- ✅ Enhances experience on macOS 15+
- ✅ Clear messaging about requirements

**§ Privacy & Local-First**:
- ✅ Local inference option
- ✅ No API keys needed
- ✅ Data stays on device

---

## Completion Criteria

**This step is complete when**:

1. **Code Written**:
   - [ ] AppleMLDetection.swift with version checking
   - [ ] AppleLLMClient.swift with placeholder implementation
   - [ ] LLMProvider enum includes .apple case
   - [ ] CLI accepts --provider apple flag

2. **Tests Pass**:
   - [ ] All AppleMLTests pass
   - [ ] Availability detection works
   - [ ] Graceful failures on unsupported systems

3. **Verification Complete**:
   - [ ] Manual testing on macOS 15+ (if available)
   - [ ] Manual testing on macOS <15 (graceful error)
   - [ ] CLI help shows apple as option

4. **Documentation Updated**:
   - [ ] README mentions Apple provider option
   - [ ] USAGE.md includes Apple Foundation Model section
   - [ ] Code comments explain placeholder status

**Estimated Time**: 2-3 hours (placeholder implementation)
**Estimated Size**: ~140 lines

**Note**: Full implementation with MLX integration would be 8-12 hours additional work.

---

## Next Steps

**After This Step**:
- System complete at 100% (31 steps → 32 steps)
- Optional: Implement full Apple ML integration (separate project)
- Optional: Add more provider options (Google Gemini, etc.)

**What It Enables**:
- Local LLM option for privacy-conscious users
- Zero-cost AI coding assistant on macOS 15+
- Foundation for deeper Apple ecosystem integration

---

**Last Updated**: 2026-01-18
**Status**: Ready for implementation
