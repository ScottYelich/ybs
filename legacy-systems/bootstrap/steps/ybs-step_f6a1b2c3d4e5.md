# Step 000026: Context Compaction

**GUID**: f6a1b2c3d4e5
**Type**: Implementation
**Status**: Planned
**Last Updated**: 2026-01-17

---

## Overview

**Purpose**: Automatically compact conversation context when approaching token limit to prevent overflow.

**What This Step Does**:
- Monitors token count during conversation
- Triggers compaction at threshold (e.g., 95% full)
- Summarizes old messages using LLM
- Replaces old messages with summary
- Preserves recent messages for continuity

**Why This Step Exists**:
After Step 25, we know when context is full. This step prevents overflow:
- Long conversations would hit limit
- Error if limit exceeded
- User loses conversation history
- Need automatic pruning

**Dependencies**:
- ✅ Step 12: LLM client (for summarization)
- ✅ Step 15: ConversationContext
- ✅ Step 25: Token counting (triggers compaction)

---

## Specifications

**Implements**:
- Spec: `systems/bootstrap/specs/technical/ybs-spec.md` § Context Management (Compaction)
- ADR: `systems/bootstrap/specs/architecture/ybs-decisions.md` § LLM-based summarization for compaction

**References**:
- `systems/bootstrap/specs/technical/ybs-spec.md` lines 631-660 (Context compaction)
- `systems/bootstrap/docs/tool-architecture.md` (Context strategies)

---

## What to Build

### File Structure

```
Sources/YBS/Context/
├── ContextCompactor.swift     # Compaction logic
└── CompactionStrategy.swift   # Strategy interface
```

### 1. ContextCompactor.swift

**Purpose**: Compact conversation context when approaching limit.

**Key Components**:

```swift
public class ContextCompactor {
    private let llmClient: LLMClient
    private let tokenCounter: TokenCounter
    private let config: Config

    public init(
        llmClient: LLMClient,
        tokenCounter: TokenCounter,
        config: Config
    ) {
        self.llmClient = llmClient
        self.tokenCounter = tokenCounter
        self.config = config
    }

    /// Check if compaction needed
    /// - Returns: true if should compact now
    public func shouldCompact(
        messages: [Message],
        currentTokens: Int,
        maxTokens: Int
    ) -> Bool

    /// Compact messages by summarizing old ones
    /// - Returns: Compacted message array
    public func compact(
        messages: [Message]
    ) async throws -> [Message]

    /// Summarize messages using LLM
    /// - Returns: Summary text
    private func summarize(messages: [Message]) async throws -> String

    /// Determine split point (keep recent, summarize old)
    /// - Returns: Index to split at
    private func determineSplitPoint(
        messages: [Message],
        targetTokens: Int
    ) -> Int
}
```

**Implementation Details**:

1. **Should Compact Check**:
   ```swift
   public func shouldCompact(
       messages: [Message],
       currentTokens: Int,
       maxTokens: Int
   ) -> Bool {
       let threshold = config.context.compactionThreshold
       let percentage = Double(currentTokens) / Double(maxTokens)

       return percentage >= threshold
   }
   ```

2. **Compaction Process**:
   ```swift
   public func compact(messages: [Message]) async throws -> [Message] {
       Logger.info("Starting context compaction...")

       // Always keep system message
       let systemMessages = messages.filter { $0.role == .system }

       // Find split point
       let targetTokens = config.llm.maxContextTokens / 2
       let splitIndex = determineSplitPoint(
           messages: messages,
           targetTokens: targetTokens
       )

       // Messages to summarize (old)
       let oldMessages = Array(messages[..<splitIndex])

       // Messages to keep (recent)
       let recentMessages = Array(messages[splitIndex...])

       // Summarize old messages
       Logger.info("Summarizing \(oldMessages.count) old messages...")
       let summary = try await summarize(messages: oldMessages)

       // Create summary message
       let summaryMessage = Message(
           role: .system,
           content: .text("""
           [Previous conversation summary]
           \(summary)
           [End of summary]
           """)
       )

       // Reconstruct context
       var compacted: [Message] = []
       compacted.append(contentsOf: systemMessages)
       compacted.append(summaryMessage)
       compacted.append(contentsOf: recentMessages)

       let oldTokens = tokenCounter.count(messages: messages)
       let newTokens = tokenCounter.count(messages: compacted)

       Logger.info("Compaction complete: \(oldTokens) → \(newTokens) tokens")
       Logger.info("Saved: \(oldTokens - newTokens) tokens")

       return compacted
   }
   ```

3. **Summarization**:
   ```swift
   private func summarize(messages: [Message]) async throws -> String {
       // Build summarization prompt
       let prompt = buildSummarizationPrompt(messages: messages)

       // Call LLM
       let summaryMessage = Message(role: .user, content: .text(prompt))
       let response = try await llmClient.sendMessage(
           messages: [summaryMessage],
           tools: []  // No tools for summarization
       )

       guard case .text(let summary) = response.content else {
           throw YBSError.summarizationFailed(reason: "Invalid response format")
       }

       return summary
   }

   private func buildSummarizationPrompt(messages: [Message]) -> String {
       var transcript = ""

       for message in messages {
           let role = message.role.rawValue
           let content = message.contentAsText()
           transcript += "\(role): \(content)\n\n"
       }

       return """
       Summarize the following conversation in 2-3 paragraphs. \
       Focus on key decisions, outcomes, and context needed for continuing \
       the conversation. Be concise but preserve important details.

       Conversation:
       \(transcript)

       Summary:
       """
   }
   ```

4. **Split Point Determination**:
   ```swift
   private func determineSplitPoint(
       messages: [Message],
       targetTokens: Int
   ) -> Int {
       var tokensFromEnd = 0
       var splitIndex = messages.count

       // Work backwards, keeping messages until target reached
       for i in stride(from: messages.count - 1, through: 0, by: -1) {
           let tokens = tokenCounter.count(message: messages[i])
           tokensFromEnd += tokens

           if tokensFromEnd >= targetTokens {
               splitIndex = i
               break
           }
       }

       // Ensure at least some messages kept (minimum 5)
       return max(0, min(splitIndex, messages.count - 5))
   }
   ```

**Size**: ~200 lines

---

### 2. CompactionStrategy.swift

**Purpose**: Interface for different compaction strategies (future).

**Key Components**:

```swift
/// Compaction strategy interface
public protocol CompactionStrategy {
    /// Compact messages
    func compact(messages: [Message]) async throws -> [Message]

    /// Check if should compact
    func shouldCompact(
        messages: [Message],
        currentTokens: Int,
        maxTokens: Int
    ) -> Bool
}

/// LLM-based summarization strategy
public class SummarizationStrategy: CompactionStrategy {
    // Implementation from ContextCompactor
}

/// Simple pruning strategy (remove oldest messages)
public class PruningStrategy: CompactionStrategy {
    public func compact(messages: [Message]) async throws -> [Message] {
        // Keep last N messages
        let keepCount = 50
        return Array(messages.suffix(keepCount))
    }

    public func shouldCompact(
        messages: [Message],
        currentTokens: Int,
        maxTokens: Int
    ) -> Bool {
        return currentTokens >= maxTokens * 95 / 100
    }
}
```

**Size**: ~80 lines

---

### 3. Integration with ConversationContext

**Update**: `Sources/YBS/Agent/ConversationContext.swift`

```swift
public class ConversationContext {
    private var messages: [Message] = []
    private var tokenStats: TokenUsageStats
    private let compactor: ContextCompactor?

    public init(
        config: Config,
        compactor: ContextCompactor?
    ) {
        self.tokenStats = TokenUsageStats(
            maxTokens: config.llm.maxContextTokens
        )
        self.compactor = compactor
    }

    /// Add message with automatic compaction
    public func addMessage(_ message: Message) async throws {
        messages.append(message)
        tokenStats.addMessage(message)

        // Check if compaction needed
        if let compactor = compactor,
           compactor.shouldCompact(
               messages: messages,
               currentTokens: tokenStats.currentTokens,
               maxTokens: tokenStats.maxTokens
           ) {

            Logger.info("Token limit approaching, compacting context...")

            // Perform compaction
            messages = try await compactor.compact(messages: messages)

            // Recalculate token stats
            tokenStats.resetSession()
            for msg in messages {
                tokenStats.addMessage(msg)
            }

            Logger.info("Context compacted to \(tokenStats.currentTokens) tokens")
        }
    }

    /// Get messages for LLM request
    public func getMessages() -> [Message] {
        messages
    }
}
```

---

## Configuration

**Add to BUILD_CONFIG.json**:

```json
{
  "context": {
    "compactionThreshold": 0.95,
    "compactionStrategy": "summarization",
    "minMessagesToKeep": 5,
    "targetTokensAfterCompaction": 50000
  }
}
```

**Configuration Options**:
- `compactionThreshold`: Trigger at this percentage (0.95 = 95%)
- `compactionStrategy`: "summarization" or "pruning"
- `minMessagesToKeep`: Minimum recent messages to preserve
- `targetTokensAfterCompaction`: Aim for this many tokens after compaction

---

## Tests

**Location**: `Tests/YBSTests/Context/ContextCompactorTests.swift`

### Test Cases

**1. Compaction Trigger**:
```swift
func testCompactionTrigger() {
    let compactor = ContextCompactor(
        llmClient: mockLLM,
        tokenCounter: TokenCounter(),
        config: testConfig
    )

    // Below threshold
    XCTAssertFalse(compactor.shouldCompact(
        messages: [],
        currentTokens: 90_000,
        maxTokens: 100_000
    ))

    // Above threshold
    XCTAssertTrue(compactor.shouldCompact(
        messages: [],
        currentTokens: 96_000,
        maxTokens: 100_000
    ))
}
```

**2. Split Point Determination**:
```swift
func testSplitPointDetermination() {
    let compactor = ContextCompactor(
        llmClient: mockLLM,
        tokenCounter: TokenCounter(),
        config: testConfig
    )

    // Create 20 messages
    let messages = (0..<20).map { i in
        Message(role: .user, content: .text("Message \(i)"))
    }

    // Target: keep last 10 messages worth of tokens
    let splitIndex = compactor.determineSplitPoint(
        messages: messages,
        targetTokens: 1000
    )

    // Should split somewhere in middle
    XCTAssertGreaterThan(splitIndex, 0)
    XCTAssertLessThan(splitIndex, messages.count)
}
```

**3. Message Preservation**:
```swift
func testPreservesSystemMessages() async throws {
    let compactor = ContextCompactor(
        llmClient: mockLLM,
        tokenCounter: TokenCounter(),
        config: testConfig
    )

    var messages: [Message] = []
    messages.append(Message(role: .system, content: .text("System prompt")))

    // Add many user messages
    for i in 0..<100 {
        messages.append(Message(role: .user, content: .text("Message \(i)")))
    }

    let compacted = try await compactor.compact(messages: messages)

    // System message should be preserved
    XCTAssertEqual(compacted.first?.role, .system)
    XCTAssertEqual(compacted.first?.content.text, "System prompt")
}
```

**4. Token Reduction**:
```swift
func testReducesTokenCount() async throws {
    let compactor = ContextCompactor(
        llmClient: mockLLM,
        tokenCounter: TokenCounter(),
        config: testConfig
    )

    // Create many messages
    var messages: [Message] = []
    for i in 0..<100 {
        messages.append(Message(
            role: .user,
            content: .text("This is message number \(i)")
        ))
    }

    let beforeTokens = TokenCounter().count(messages: messages)
    let compacted = try await compactor.compact(messages: messages)
    let afterTokens = TokenCounter().count(messages: compacted)

    // Should have fewer tokens after compaction
    XCTAssertLessThan(afterTokens, beforeTokens)
}
```

**5. Integration Test**:
```swift
func testContextAutoCompaction() async throws {
    let context = ConversationContext(
        config: testConfig,
        compactor: testCompactor
    )

    // Add many messages
    for i in 0..<200 {
        let msg = Message(role: .user, content: .text("Message \(i)"))
        try await context.addMessage(msg)
    }

    // Context should have been compacted
    let messages = context.getMessages()

    // Should have fewer than 200 messages
    XCTAssertLessThan(messages.count, 200)

    // Should contain summary
    let hasSummary = messages.contains { msg in
        msg.content.text?.contains("Previous conversation summary") ?? false
    }
    XCTAssertTrue(hasSummary)
}
```

**Total Tests**: ~8-10 tests

---

## Verification Steps

### 1. Manual Testing

**Test compaction trigger**:
```bash
cd systems/bootstrap/builds/test6

# Set low limit for testing
# Edit BUILD_CONFIG.json: maxContextTokens = 2000

swift run ybs

# Have long conversation (many turns)
# Should see compaction message:
# [INFO] Token limit approaching, compacting context...
# [INFO] Summarizing 45 old messages...
# [INFO] Context compacted to 987 tokens
# [INFO] Saved: 1,234 tokens
```

**Verify conversation continuity**:
```bash
You: My name is Alice
AI: Nice to meet you, Alice!

# Many more messages...
# Compaction happens...

You: What's my name?
AI: Your name is Alice.
# Should remember due to summary
```

### 2. Automated Testing

```bash
swift test --filter ContextCompactorTests
# All tests pass
```

### 3. Success Criteria

- ✅ Compaction triggers at threshold (95%)
- ✅ Old messages summarized
- ✅ Recent messages preserved
- ✅ System messages preserved
- ✅ Token count reduced significantly (>50%)
- ✅ Conversation continuity maintained
- ✅ All tests pass

---

## Dependencies

**Requires**:
- Step 12: LLM client (for summarization)
- Step 15: ConversationContext
- Step 25: Token counting

**Enables**:
- Unlimited conversation length
- No context overflow errors
- Better long-term memory

---

## Implementation Notes

### Compaction Strategies

**Summarization** (default):
- Best quality (preserves meaning)
- Slower (LLM call required)
- Uses tokens for summarization

**Pruning** (fallback):
- Fast (no LLM call)
- Loses information
- Good for testing

### When to Compact

**Threshold trade-offs**:
- 80%: Frequent compaction, more overhead
- 95%: Rare compaction, risk of overflow
- 90%: Good balance (recommended)

**Why 95% chosen**:
- Gives buffer before hard limit
- Rare enough (long conversations only)
- Prevents emergency compaction

### Summary Message Format

**Use system role**:
```
[Previous conversation summary]
The user asked about X. The assistant explained Y.
Key decisions: Z. The user prefers A.
[End of summary]
```

**Why system role**:
- LLM treats as context, not conversation
- Clear separation from user/assistant messages
- Can have multiple summaries (nested compaction)

### Performance

**Compaction cost**:
- LLM call: ~5 seconds
- Infrequent (only at 95% full)
- User sees "Compacting context..." message

---

## Future Enhancements

**Possible improvements**:
- Sliding window compaction (multiple summaries)
- Semantic importance ranking (keep important, drop trivial)
- User-triggered compaction (--compact-now)
- Compaction history tracking

---

## Lessons Learned Integration

**From** `systems/bootstrap/specs/general/ybs-lessons-learned.md`:

**§ Context Management**:
- ✅ Automatic compaction (no user intervention)
- ✅ Preserve recent context (continuity)
- ✅ Clear logging (user knows what's happening)

**§ LLM Best Practices**:
- ✅ Use system role for summaries
- ✅ Clear prompt for summarization
- ✅ No tools during summarization

---

## Completion Criteria

**This step is complete when**:

1. **Code Written**:
   - [ ] ContextCompactor.swift with compaction logic
   - [ ] CompactionStrategy.swift with strategies
   - [ ] ConversationContext integration
   - [ ] Automatic trigger on threshold

2. **Tests Pass**:
   - [ ] All ContextCompactorTests pass
   - [ ] Compaction reduces tokens
   - [ ] System messages preserved
   - [ ] Recent messages preserved

3. **Verification Complete**:
   - [ ] Long conversation doesn't overflow
   - [ ] Compaction logs visible
   - [ ] Conversation continuity maintained

4. **Documentation Updated**:
   - [ ] Code comments explain compaction process
   - [ ] Config options documented

**Estimated Time**: 3-4 hours
**Estimated Size**: ~280 lines

---

## Next Steps

**After This Step**:
→ **Step 27**: Repo Map Generation (codebase context)

**What It Enables**:
- Unlimited conversation length
- No context overflow
- Long-running sessions

---

**Last Updated**: 2026-01-17
**Status**: Ready for implementation
