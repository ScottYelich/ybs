# Step 000025: Token Counting & Tracking

**GUID**: e5f6a1b2c3d4
**Type**: Implementation
**Status**: Planned
**Last Updated**: 2026-01-17

---

## Overview

**Purpose**: Track token usage in conversations to prevent context overflow and monitor costs.

**What This Step Does**:
- Counts tokens in messages (approximation method)
- Tracks cumulative token usage per session
- Warns when approaching context limit
- Displays token usage in UI
- Provides usage statistics

**Why This Step Exists**:
LLMs have context limits (e.g., 128K tokens for Claude). Without tracking:
- Context overflow causes errors
- User surprised by costs
- No warning before limit
- Can't optimize prompt size

**Dependencies**:
- ✅ Step 5: Message model
- ✅ Step 15: ConversationContext (where tokens are tracked)

---

## Specifications

**Implements**:
- Spec: `systems/bootstrap/specs/technical/ybs-spec.md` § Context Management (Token tracking)
- ADR: `systems/bootstrap/specs/architecture/ybs-decisions.md` § Use approximation for token counting

**References**:
- `systems/bootstrap/specs/technical/ybs-spec.md` lines 610-630 (Token tracking)
- `systems/bootstrap/docs/tool-architecture.md` (Performance considerations)

---

## What to Build

### File Structure

```
Sources/YBS/Context/
├── TokenCounter.swift         # Token counting logic
└── TokenUsageStats.swift      # Usage tracking and stats
```

### 1. TokenCounter.swift

**Purpose**: Count tokens in text using approximation.

**Key Components**:

```swift
public class TokenCounter {
    /// Token counting method
    public enum Method {
        case approximation  // Fast: ~4 chars per token
        case gpt2BPE        // Accurate: GPT-2 BPE encoding (future)
    }

    private let method: Method

    public init(method: Method = .approximation) {
        self.method = method
    }

    /// Count tokens in text
    /// - Returns: Estimated token count
    public func count(_ text: String) -> Int

    /// Count tokens in message
    public func count(message: Message) -> Int

    /// Count tokens in message array
    public func count(messages: [Message]) -> Int

    /// Approximation method: ~4 characters per token
    private func countApproximation(_ text: String) -> Int
}
```

**Implementation Details**:

1. **Approximation Method**:
   ```swift
   func countApproximation(_ text: String) -> Int {
       // OpenAI rule of thumb: ~4 chars per token
       // Add overhead for message formatting
       let baseCount = text.count / 4

       // Add 4 tokens per message for role/formatting
       return baseCount + 4
   }
   ```

2. **Message Counting**:
   ```swift
   func count(message: Message) -> Int {
       var total = 0

       // Count role (usually "user", "assistant", "system")
       total += 1

       // Count content
       switch message.content {
       case .text(let text):
           total += countApproximation(text)

       case .toolCall(let toolCall):
           // Tool name
           total += countApproximation(toolCall.name)
           // Parameters (JSON)
           if let jsonData = try? JSONSerialization.data(
               withJSONObject: toolCall.parameters
           ),
              let jsonString = String(data: jsonData, encoding: .utf8) {
               total += countApproximation(jsonString)
           }

       case .toolResult(let result):
           total += countApproximation(result.content)
       }

       return total
   }
   ```

3. **Array Counting**:
   ```swift
   func count(messages: [Message]) -> Int {
       messages.reduce(0) { $0 + count(message: $1) }
   }
   ```

**Size**: ~100 lines

---

### 2. TokenUsageStats.swift

**Purpose**: Track and report token usage statistics.

**Key Components**:

```swift
public class TokenUsageStats {
    /// Current session usage
    public private(set) var currentTokens: Int = 0

    /// Total tokens used (all time)
    public private(set) var totalTokens: Int = 0

    /// Max tokens allowed
    public let maxTokens: Int

    /// Warning threshold (percentage)
    public let warningThreshold: Double

    /// Token counter
    private let counter: TokenCounter

    public init(
        maxTokens: Int = 100_000,
        warningThreshold: Double = 0.8,
        counter: TokenCounter = TokenCounter()
    ) {
        self.maxTokens = maxTokens
        self.warningThreshold = warningThreshold
        self.counter = counter
    }

    /// Add message to usage tracking
    public func addMessage(_ message: Message)

    /// Get current usage as percentage
    /// - Returns: 0.0 to 1.0
    public func usagePercentage() -> Double

    /// Check if approaching limit
    /// - Returns: true if above warning threshold
    public func isApproachingLimit() -> Bool

    /// Check if over limit
    /// - Returns: true if current usage > max
    public func isOverLimit() -> Bool

    /// Get formatted usage string
    /// - Returns: "1,234 / 100,000 tokens (1.2%)"
    public func formattedUsage() -> String

    /// Reset session usage
    public func resetSession()
}
```

**Implementation Details**:

1. **Add Message**:
   ```swift
   public func addMessage(_ message: Message) {
       let tokens = counter.count(message: message)
       currentTokens += tokens
       totalTokens += tokens
   }
   ```

2. **Usage Percentage**:
   ```swift
   public func usagePercentage() -> Double {
       guard maxTokens > 0 else { return 0.0 }
       return Double(currentTokens) / Double(maxTokens)
   }
   ```

3. **Threshold Checks**:
   ```swift
   public func isApproachingLimit() -> Bool {
       usagePercentage() >= warningThreshold
   }

   public func isOverLimit() -> Bool {
       currentTokens >= maxTokens
   }
   ```

4. **Formatted Output**:
   ```swift
   public func formattedUsage() -> String {
       let current = currentTokens.formatted()
       let max = maxTokens.formatted()
       let percentage = usagePercentage() * 100

       return "\(current) / \(max) tokens (\(String(format: "%.1f", percentage))%)"
   }
   ```

**Size**: ~120 lines

---

### 3. Integration with ConversationContext

**Update**: `Sources/YBS/Agent/ConversationContext.swift`

```swift
public class ConversationContext {
    private var messages: [Message] = []
    private var tokenStats: TokenUsageStats

    public init(config: Config) {
        self.tokenStats = TokenUsageStats(
            maxTokens: config.llm.maxContextTokens,
            warningThreshold: 0.8
        )
    }

    /// Add message to context
    public func addMessage(_ message: Message) {
        messages.append(message)
        tokenStats.addMessage(message)

        // Check for warnings
        if tokenStats.isApproachingLimit() {
            Logger.warning("Approaching token limit: \(tokenStats.formattedUsage())")
        }

        if tokenStats.isOverLimit() {
            Logger.error("Context limit exceeded: \(tokenStats.formattedUsage())")
            // Will trigger compaction in Step 26
        }
    }

    /// Get current token usage
    public func getTokenUsage() -> TokenUsageStats {
        tokenStats
    }
}
```

---

### 4. UI Integration

**Update**: Agent loop to display token usage

```swift
// In agent loop (Step 13)
func displayPrompt() {
    let usage = context.getTokenUsage()

    if config.ui.showTokenUsage {
        print("[\(usage.formattedUsage())]")
    }

    print("You: ", terminator: "")
}
```

**Example Output**:
```
[1,234 / 100,000 tokens (1.2%)]
You: Hello
AI: Hi there!

[1,456 / 100,000 tokens (1.5%)]
You: What's the weather?
```

---

### 5. CLI Flag

**Add --show-token-usage flag**:

```swift
extension YBSCommand {
    @Flag(name: .long, help: "Show token usage in prompt")
    var showTokenUsage: Bool = false

    // Pass to config
    var config: Config {
        var cfg = try! ConfigLoader.load()
        cfg.ui.showTokenUsage = showTokenUsage
        return cfg
    }
}
```

---

## Configuration

**Add to BUILD_CONFIG.json**:

```json
{
  "llm": {
    "maxContextTokens": 100000,
    "tokenWarningThreshold": 0.8
  },
  "ui": {
    "showTokenUsage": true
  }
}
```

**Configuration Options**:
- `maxContextTokens`: Context window size
- `tokenWarningThreshold`: When to warn (0.8 = 80%)
- `showTokenUsage`: Display in UI

---

## Tests

**Location**: `Tests/YBSTests/Context/TokenCounterTests.swift`

### Test Cases

**1. Token Approximation**:
```swift
func testTokenApproximation() {
    let counter = TokenCounter(method: .approximation)

    // ~4 chars per token + 4 overhead
    let text = "Hello, world!"  // 13 chars
    let tokens = counter.count(text)

    // 13/4 + 4 = 7 tokens (approximately)
    XCTAssertEqual(tokens, 7)
}
```

**2. Message Counting**:
```swift
func testMessageCounting() {
    let counter = TokenCounter()

    let message = Message(
        role: .user,
        content: .text("What is 2+2?")
    )

    let tokens = counter.count(message: message)

    // Should be > 0
    XCTAssertGreaterThan(tokens, 0)
}
```

**3. Usage Tracking**:
```swift
func testUsageTracking() {
    let stats = TokenUsageStats(maxTokens: 1000)

    let message1 = Message(role: .user, content: .text("Hello"))
    let message2 = Message(role: .assistant, content: .text("Hi there!"))

    stats.addMessage(message1)
    XCTAssertGreaterThan(stats.currentTokens, 0)

    let before = stats.currentTokens
    stats.addMessage(message2)
    XCTAssertGreaterThan(stats.currentTokens, before)
}
```

**4. Threshold Warnings**:
```swift
func testThresholdWarning() {
    let stats = TokenUsageStats(
        maxTokens: 100,
        warningThreshold: 0.8
    )

    // Add messages until approaching limit
    for _ in 0..<20 {
        let msg = Message(
            role: .user,
            content: .text("This is a test message")
        )
        stats.addMessage(msg)
    }

    // Should be approaching limit (>80 tokens)
    XCTAssertTrue(stats.isApproachingLimit())
}
```

**5. Over Limit Detection**:
```swift
func testOverLimitDetection() {
    let stats = TokenUsageStats(maxTokens: 50)

    // Add many messages
    for _ in 0..<30 {
        let msg = Message(
            role: .user,
            content: .text("Test message")
        )
        stats.addMessage(msg)
    }

    XCTAssertTrue(stats.isOverLimit())
}
```

**Total Tests**: ~8-10 tests

---

## Verification Steps

### 1. Manual Testing

**Test token display**:
```bash
cd systems/bootstrap/builds/test6
swift run ybs --show-token-usage

[0 / 100,000 tokens (0.0%)]
You: Hello
AI: Hi there! How can I help?

[45 / 100,000 tokens (0.0%)]
You: Read Package.swift
AI: <calls read_file>
...

[2,345 / 100,000 tokens (2.3%)]
You: quit
```

**Test warning threshold**:
```bash
# Set low limit for testing
# Edit config: maxContextTokens = 1000

swift run ybs

# Have long conversation
# Should see warning when > 800 tokens:
# [WARNING] Approaching token limit: 856 / 1,000 tokens (85.6%)
```

### 2. Automated Testing

```bash
swift test --filter TokenCounterTests
# All tests pass
```

### 3. Success Criteria

- ✅ Token counting approximation works
- ✅ Message token counting accurate (~10% margin)
- ✅ Usage tracking accumulates correctly
- ✅ Warning threshold detection works
- ✅ Over-limit detection works
- ✅ UI displays token usage
- ✅ All tests pass

---

## Dependencies

**Requires**:
- Step 5: Message model
- Step 15: ConversationContext

**Enables**:
- Step 26: Context compaction (triggered by limits)
- Cost awareness
- Context overflow prevention

---

## Implementation Notes

### Token Counting Accuracy

**Approximation vs Exact**:
- Approximation: Fast, ~10% error margin
- Exact (tiktoken): Slow, requires native library
- For YBS: Approximation sufficient (conservative)

**Why Approximation Works**:
- Err on side of overestimating
- Faster (no encoding overhead)
- Good enough for warnings
- Exact count not critical (API tells us actual)

### Model-Specific Limits

**Common limits**:
- GPT-4: 8K, 32K, 128K tokens
- Claude: 100K, 200K tokens
- Gemini: 32K, 1M tokens

**Configure per model**:
```json
{
  "llm": {
    "provider": "anthropic",
    "model": "claude-3-5-sonnet-20250115",
    "maxContextTokens": 200000
  }
}
```

### Performance

**Token counting is fast**:
- Approximation: O(n) where n = string length
- ~1μs per message
- Negligible overhead

---

## Future Enhancements

**Step 26 will add**:
- Context compaction when limit reached
- Automatic message pruning
- Conversation summarization

**Possible future**:
- Exact token counting (tiktoken)
- Per-model token counters
- Cost estimation ($ per token)
- Token usage analytics

---

## Lessons Learned Integration

**From** `systems/bootstrap/specs/general/ybs-lessons-learned.md`:

**§ User Awareness**:
- ✅ Show token usage prominently
- ✅ Warn before limit reached
- ✅ Help users understand context

**§ Performance**:
- ✅ Fast approximation method
- ✅ No blocking operations

---

## Completion Criteria

**This step is complete when**:

1. **Code Written**:
   - [ ] TokenCounter.swift with counting logic
   - [ ] TokenUsageStats.swift with tracking
   - [ ] ConversationContext integration
   - [ ] UI integration (display usage)

2. **Tests Pass**:
   - [ ] All TokenCounterTests pass
   - [ ] Approximation accurate (~10% margin)
   - [ ] Tracking accumulates correctly
   - [ ] Thresholds trigger correctly

3. **Verification Complete**:
   - [ ] Token usage displays in UI
   - [ ] Warnings appear at threshold
   - [ ] Usage resets between sessions

4. **Documentation Updated**:
   - [ ] Code comments explain approximation
   - [ ] Config options documented

**Estimated Time**: 2-3 hours
**Estimated Size**: ~220 lines

---

## Next Steps

**After This Step**:
→ **Step 26**: Context Compaction (automatic message pruning)

**What It Enables**:
- Context overflow prevention
- Cost awareness
- Foundation for automatic compaction

---

**Last Updated**: 2026-01-17
**Status**: Ready for implementation
