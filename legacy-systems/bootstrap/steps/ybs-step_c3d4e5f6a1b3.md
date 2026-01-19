# Step 000029: Error Recovery & Retry

**GUID**: c3d4e5f6a1b3
**Type**: Implementation
**Status**: Planned
**Last Updated**: 2026-01-17

---

## Overview

**Purpose**: Handle transient failures gracefully with automatic retry and error recovery.

**What This Step Does**:
- Retry failed LLM requests with exponential backoff
- Repair malformed JSON from tool calls
- Detect incomplete responses (max_tokens cutoff)
- Re-prompt LLM when responses are invalid
- Handle network errors gracefully

**Why This Step Exists**:
After Steps 4-28, system works but fails on transient errors:
- Network timeouts (WiFi hiccup)
- Rate limits (HTTP 429)
- Malformed JSON (LLM hallucinated invalid syntax)
- Incomplete responses (context limit hit mid-response)

Automatic recovery prevents interrupting user workflow.

**Dependencies**:
- ✅ Step 11: HTTP client (where errors occur)
- ✅ Step 12: LLM client (retry logic)
- ✅ Step 14: Tool calling (JSON repair)

---

## Specifications

**Implements**:
- Spec: `systems/bootstrap/specs/technical/ybs-spec.md` § Error Handling (Retry & recovery)
- ADR: `systems/bootstrap/specs/architecture/ybs-decisions.md` § Exponential backoff for retries

**References**:
- `systems/bootstrap/specs/technical/ybs-spec.md` lines 751-780 (Error handling)

---

## What to Build

### File Structure

```
Sources/YBS/Reliability/
├── RetryPolicy.swift          # Retry logic with backoff
├── JSONRepair.swift           # Fix malformed JSON
└── ErrorRecovery.swift        # Recovery strategies
```

### 1. RetryPolicy.swift

**Purpose**: Retry operations with exponential backoff.

**Key Components**:

```swift
public struct RetryPolicy {
    public let maxAttempts: Int
    public let initialDelay: TimeInterval
    public let maxDelay: TimeInterval
    public let multiplier: Double

    public static let `default` = RetryPolicy(
        maxAttempts: 3,
        initialDelay: 1.0,
        maxDelay: 10.0,
        multiplier: 2.0
    )

    /// Execute operation with retry
    public func execute<T>(
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        var delay = initialDelay

        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error

                // Check if retryable
                guard isRetryable(error) else {
                    throw error
                }

                // Last attempt?
                guard attempt < maxAttempts else {
                    break
                }

                // Log retry
                Logger.warning("Attempt \(attempt) failed: \(error)")
                Logger.info("Retrying in \(delay)s...")

                // Wait with exponential backoff
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

                // Increase delay
                delay = min(delay * multiplier, maxDelay)
            }
        }

        throw lastError ?? YBSError.retryFailed
    }

    /// Check if error is retryable
    private func isRetryable(_ error: Error) -> Bool {
        switch error {
        case YBSError.networkError:
            return true
        case YBSError.timeout:
            return true
        case YBSError.rateLimited:
            return true
        case YBSError.serverError:
            return true
        default:
            return false
        }
    }
}
```

**Size**: ~100 lines

---

### 2. JSONRepair.swift

**Purpose**: Repair malformed JSON from LLM responses.

**Key Components**:

```swift
public class JSONRepair {
    /// Attempt to repair malformed JSON
    /// - Returns: Repaired JSON string, or nil if unrepairable
    public static func repair(_ json: String) -> String? {
        // Try parsing first
        if isValidJSON(json) {
            return json
        }

        // Common repairs
        var repaired = json

        // 1. Fix missing closing braces
        repaired = fixMissingBraces(repaired)

        // 2. Fix unquoted keys
        repaired = fixUnquotedKeys(repaired)

        // 3. Fix trailing commas
        repaired = fixTrailingCommas(repaired)

        // 4. Fix single quotes
        repaired = fixSingleQuotes(repaired)

        // 5. Fix escaped quotes
        repaired = fixEscapedQuotes(repaired)

        // Validate repair
        if isValidJSON(repaired) {
            return repaired
        }

        return nil
    }

    /// Check if valid JSON
    private static func isValidJSON(_ string: String) -> Bool {
        guard let data = string.data(using: .utf8) else {
            return false
        }

        do {
            _ = try JSONSerialization.jsonObject(with: data)
            return true
        } catch {
            return false
        }
    }

    /// Fix missing closing braces
    private static func fixMissingBraces(_ json: String) -> String {
        var fixed = json
        let openBraces = json.filter { $0 == "{" }.count
        let closeBraces = json.filter { $0 == "}" }.count

        if openBraces > closeBraces {
            fixed += String(repeating: "}", count: openBraces - closeBraces)
        }

        return fixed
    }

    /// Fix unquoted keys
    private static func fixUnquotedKeys(_ json: String) -> String {
        // Replace: {key: value} → {"key": value}
        let pattern = #"\{(\s*)([a-zA-Z_][a-zA-Z0-9_]*)\s*:"#
        let replacement = "{$1\"$2\":"

        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return json
        }

        let range = NSRange(json.startIndex..., in: json)
        return regex.stringByReplacingMatches(
            in: json,
            range: range,
            withTemplate: replacement
        )
    }

    /// Fix trailing commas
    private static func fixTrailingCommas(_ json: String) -> String {
        // Remove: ,} → }
        // Remove: ,] → ]
        var fixed = json
        fixed = fixed.replacingOccurrences(of: ",}", with: "}")
        fixed = fixed.replacingOccurrences(of: ",]", with: "]")
        return fixed
    }

    /// Fix single quotes to double quotes
    private static func fixSingleQuotes(_ json: String) -> String {
        // Replace: 'value' → "value"
        // But not inside already quoted strings
        return json.replacingOccurrences(of: "'", with: "\"")
    }

    /// Fix escaped quotes
    private static func fixEscapedQuotes(_ json: String) -> String {
        // Fix common escaping issues
        var fixed = json
        fixed = fixed.replacingOccurrences(of: "\\'", with: "'")
        fixed = fixed.replacingOccurrences(of: "\\\"", with: "\"")
        return fixed
    }
}
```

**Size**: ~150 lines

---

### 3. ErrorRecovery.swift

**Purpose**: High-level error recovery strategies.

**Key Components**:

```swift
public class ErrorRecovery {
    private let llmClient: LLMClient

    public init(llmClient: LLMClient) {
        self.llmClient = llmClient
    }

    /// Recover from malformed tool call
    /// - Returns: Repaired tool call, or re-prompts LLM
    public func recoverFromMalformedToolCall(
        originalResponse: String,
        error: Error
    ) async throws -> ToolCall {
        Logger.warning("Tool call parsing failed: \(error)")

        // 1. Try JSON repair
        if let repaired = JSONRepair.repair(originalResponse) {
            Logger.info("JSON repaired successfully")

            if let toolCall = try? parseToolCall(repaired) {
                return toolCall
            }
        }

        // 2. Re-prompt LLM
        Logger.info("Re-prompting LLM for valid tool call")

        let message = Message(
            role: .user,
            content: .text("""
            Your previous response contained invalid JSON. \
            Please provide a valid tool call in correct JSON format.

            Error: \(error.localizedDescription)

            Previous response:
            \(originalResponse)
            """)
        )

        let response = try await llmClient.sendMessage(
            messages: [message],
            tools: []
        )

        guard let toolCall = parseToolCallFromResponse(response) else {
            throw YBSError.unrecoverableToolCallError
        }

        return toolCall
    }

    /// Recover from incomplete response (max_tokens cutoff)
    public func recoverFromIncompleteResponse(
        partialResponse: String,
        context: [Message]
    ) async throws -> String {
        Logger.warning("Detected incomplete response (max_tokens cutoff)")

        // Re-prompt to continue
        let message = Message(
            role: .user,
            content: .text("""
            Your previous response was cut off. \
            Please continue from where you left off.

            Previous response (incomplete):
            \(partialResponse)
            """)
        )

        var continueContext = context
        continueContext.append(message)

        let response = try await llmClient.sendMessage(
            messages: continueContext,
            tools: []
        )

        return partialResponse + response.contentAsText()
    }

    /// Detect if response is incomplete
    public func isIncompleteResponse(_ response: String) -> Bool {
        // Check for truncation indicators
        let truncationPatterns = [
            #"\{[^}]*$"#,     // Unclosed brace
            #"\[[^\]]*$"#,    // Unclosed bracket
            #"[^\.!?]$"#      // Doesn't end with punctuation
        ]

        for pattern in truncationPatterns {
            if response.range(
                of: pattern,
                options: .regularExpression
            ) != nil {
                return true
            }
        }

        return false
    }

    /// Handle rate limit error
    public func handleRateLimit(_ error: Error) async throws {
        // Extract retry-after header if available
        let retryAfter: TimeInterval = 60.0 // Default 1 minute

        Logger.warning("Rate limited. Waiting \(retryAfter)s before retry...")

        try await Task.sleep(nanoseconds: UInt64(retryAfter * 1_000_000_000))
    }
}
```

**Size**: ~150 lines

---

### 4. Integration with LLMClient

**Update**: `Sources/YBS/LLM/LLMClient.swift`

```swift
public class LLMClient {
    private let retryPolicy: RetryPolicy
    private let errorRecovery: ErrorRecovery

    public init(config: LLMConfig, retryPolicy: RetryPolicy = .default) {
        self.config = config
        self.retryPolicy = retryPolicy
        self.errorRecovery = ErrorRecovery(llmClient: self)
    }

    /// Send message with retry
    public func sendMessage(
        messages: [Message],
        tools: [Tool]
    ) async throws -> Message {
        return try await retryPolicy.execute {
            try await self.sendMessageWithoutRetry(messages, tools)
        }
    }

    /// Send message without retry (internal)
    private func sendMessageWithoutRetry(
        _ messages: [Message],
        _ tools: [Tool]
    ) async throws -> Message {
        // Build request
        let request = buildRequest(messages: messages, tools: tools)

        // Send HTTP request
        let response = try await httpClient.send(request)

        // Handle HTTP errors
        if response.statusCode == 429 {
            try await errorRecovery.handleRateLimit(...)
            throw YBSError.rateLimited
        }

        // Parse response
        guard let message = try? parseResponse(response) else {
            // Try recovery
            if let recovered = try? await errorRecovery.recoverFromMalformedToolCall(
                originalResponse: response.body,
                error: YBSError.jsonParsingFailed
            ) {
                return Message(role: .assistant, content: .toolCall(recovered))
            }

            throw YBSError.jsonParsingFailed
        }

        // Check for incomplete response
        if errorRecovery.isIncompleteResponse(message.contentAsText()) {
            let complete = try await errorRecovery.recoverFromIncompleteResponse(
                partialResponse: message.contentAsText(),
                context: messages
            )
            return Message(role: .assistant, content: .text(complete))
        }

        return message
    }
}
```

---

## Configuration

**Add to BUILD_CONFIG.json**:

```json
{
  "reliability": {
    "retryPolicy": {
      "maxAttempts": 3,
      "initialDelay": 1.0,
      "maxDelay": 10.0,
      "multiplier": 2.0
    },
    "jsonRepair": {
      "enabled": true,
      "maxRepairAttempts": 3
    },
    "errorRecovery": {
      "enabled": true,
      "rePromptOnError": true
    }
  }
}
```

---

## Tests

**Location**: `Tests/YBSTests/Reliability/`

### Test Cases

**1. Retry with Backoff**:
```swift
func testRetryWithBackoff() async throws {
    var attemptCount = 0

    let policy = RetryPolicy.default

    do {
        try await policy.execute {
            attemptCount += 1
            if attemptCount < 3 {
                throw YBSError.networkError
            }
            return "Success"
        }
    } catch {
        XCTFail("Should have succeeded on 3rd attempt")
    }

    XCTAssertEqual(attemptCount, 3)
}
```

**2. JSON Repair**:
```swift
func testJSONRepair() {
    // Missing closing brace
    let malformed1 = #"{"name": "test", "value": 42"#
    let repaired1 = JSONRepair.repair(malformed1)
    XCTAssertNotNil(repaired1)
    XCTAssertTrue(JSONRepair.isValidJSON(repaired1!))

    // Unquoted keys
    let malformed2 = #"{name: "test"}"#
    let repaired2 = JSONRepair.repair(malformed2)
    XCTAssertNotNil(repaired2)

    // Trailing comma
    let malformed3 = #"{"items": [1, 2, 3,]}"#
    let repaired3 = JSONRepair.repair(malformed3)
    XCTAssertNotNil(repaired3)
}
```

**3. Incomplete Response Detection**:
```swift
func testIncompleteDetection() {
    let recovery = ErrorRecovery(llmClient: mockLLM)

    // Incomplete (unclosed brace)
    XCTAssertTrue(recovery.isIncompleteResponse("{\"key\": \"val"))

    // Complete
    XCTAssertFalse(recovery.isIncompleteResponse("This is a complete sentence."))

    // Incomplete (no punctuation)
    XCTAssertTrue(recovery.isIncompleteResponse("This is incomplete"))
}
```

**4. Non-Retryable Error**:
```swift
func testNonRetryableError() async {
    let policy = RetryPolicy.default

    do {
        try await policy.execute {
            throw YBSError.invalidConfiguration
        }
        XCTFail("Should have thrown")
    } catch {
        // Should throw immediately (not retryable)
    }
}
```

**Total Tests**: ~10-12 tests

---

## Verification Steps

### 1. Manual Testing

**Test network retry**:
```bash
# Disconnect WiFi
swift run ybs

You: Hello
[WARNING] Attempt 1 failed: Network error
[INFO] Retrying in 1.0s...
# Reconnect WiFi
[INFO] Request successful
AI: Hi there!
```

**Test JSON repair**:
```bash
# Configure LLM to return malformed JSON (for testing)
You: List files
[WARNING] Tool call parsing failed
[INFO] JSON repaired successfully
→ list_files
✓ Success
```

### 2. Automated Testing

```bash
swift test --filter ReliabilityTests
# All tests pass
```

### 3. Success Criteria

- ✅ Failed requests retry with backoff
- ✅ Malformed JSON repaired automatically
- ✅ Incomplete responses detected and recovered
- ✅ Rate limits handled gracefully
- ✅ Non-retryable errors fail immediately
- ✅ User sees clear retry messages
- ✅ All tests pass

---

## Dependencies

**Requires**:
- Step 11: HTTP client (network errors)
- Step 12: LLM client (retry integration)
- Step 14: Tool calling (JSON parsing)

**Enables**:
- Robust operation
- Handle transient failures
- Better user experience

---

## Implementation Notes

### Retry Strategy

**Exponential backoff**:
- Attempt 1: 1s delay
- Attempt 2: 2s delay
- Attempt 3: 4s delay
- Max delay: 10s

**Why exponential**:
- Prevents thundering herd
- Gives service time to recover
- Standard practice for APIs

### JSON Repair Limitations

**Can repair**:
- Missing braces/brackets
- Unquoted keys
- Trailing commas
- Quote style issues

**Cannot repair**:
- Structurally invalid JSON
- Missing data
- Semantic errors

**Fallback**: Re-prompt LLM

### Error Classification

**Retryable**:
- Network timeout
- Connection error
- Rate limit (HTTP 429)
- Server error (HTTP 500)

**Not retryable**:
- Invalid config
- Authentication error (HTTP 401)
- Invalid request (HTTP 400)

---

## Future Enhancements

**Possible improvements**:
- Circuit breaker pattern (stop retrying after N failures)
- Jitter in backoff (randomize delays)
- Retry budget (global rate limit)
- Error analytics (track failure patterns)

---

## Lessons Learned Integration

**From** `systems/bootstrap/specs/general/ybs-lessons-learned.md`:

**§ Reliability**:
- ✅ Graceful error handling
- ✅ Automatic retry (no user intervention)
- ✅ Clear error messages

**§ LLM Integration**:
- ✅ Handle malformed responses
- ✅ Re-prompt when needed
- ✅ Detect incomplete output

---

## Completion Criteria

**This step is complete when**:

1. **Code Written**:
   - [ ] RetryPolicy.swift with backoff logic
   - [ ] JSONRepair.swift with repair strategies
   - [ ] ErrorRecovery.swift with recovery strategies
   - [ ] LLMClient integration

2. **Tests Pass**:
   - [ ] All ReliabilityTests pass
   - [ ] Retry backoff works
   - [ ] JSON repair works
   - [ ] Error classification correct

3. **Verification Complete**:
   - [ ] Network errors retry automatically
   - [ ] Malformed JSON repaired
   - [ ] User sees clear retry messages

4. **Documentation Updated**:
   - [ ] Code comments explain strategies
   - [ ] Config options documented

**Estimated Time**: 3-4 hours
**Estimated Size**: ~400 lines

---

## Next Steps

**After This Step**:
→ **Step 30**: Performance Optimization (final step!)

**What It Enables**:
- Robust operation
- Handle real-world errors
- Professional reliability

---

**Last Updated**: 2026-01-17
**Status**: Ready for implementation
