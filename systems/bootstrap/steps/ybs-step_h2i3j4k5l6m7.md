# Step 000038: Integration Tests for Agent Loop

**GUID**: h2i3j4k5l6m7
**Version**: 0.1.0
**Estimated Duration**: 20 minutes

## Objectives
- Test complete agent loop with mock LLM
- Verify tool execution flow
- Test meta-commands
- Test shell injection
- Test provider switching

## Prerequisites
- Step 36 completed (Shell Injection)
- AgentLoop, ConversationContext, MetaCommandHandler implemented
- Mock LLM client available for testing

## Instructions

### 1. Create Test Directory
```bash
mkdir -p Tests/YBSTests/AgentTests
```

### 2. Create Mock LLM Client

Create helper mock in test file:
```swift
class MockLLMClient: LLMClientProtocol {
    var responses: [Message] = []
    var currentIndex = 0
    
    func sendChatRequest(messages: [Message], tools: [Tool]?) async throws -> Message {
        defer { currentIndex += 1 }
        return responses[currentIndex]
    }
}
```

### 3. Create Test Files

Create `Tests/YBSTests/AgentTests/AgentLoopTests.swift`:
- Test basic conversation flow
- Test tool call execution
- Test multi-turn tool loops
- Test max iterations limit

Create `Tests/YBSTests/AgentTests/ConversationContextTests.swift`:
- Test message addition
- Test context limits
- Test statistics tracking
- Test message retrieval

Create `Tests/YBSTests/AgentTests/MetaCommandHandlerTests.swift`:
- Test /help command
- Test /tools command
- Test /provider command
- Test /config command
- Test unknown command handling

### 4. Run Tests
```bash
swift test --filter AgentTests
```

## Verification Criteria
- [ ] 3 test files created
- [ ] Minimum 20 test cases implemented
- [ ] All tests pass
- [ ] Mock LLM used for agent loop tests
- [ ] Meta-commands tested

## Common Issues
- Agent loop requires careful mocking
- Context management needs state verification

## Documentation
Create: `docs/build-history/ybs-step_h2i3j4k5l6m7-DONE.txt`

## Next Step
Proceed to Step 39: Configuration and Error Tests
