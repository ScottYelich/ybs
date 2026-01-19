# Step 000037: Unit Tests for LLM Clients

**GUID**: g1h2i3j4k5l6
**Version**: 0.1.0
**Estimated Duration**: 15 minutes

## Objectives
- Write unit tests for all LLM client implementations
- Test message format conversion (especially Anthropic)
- Verify API header construction
- Test response parsing and error handling

## Prerequisites
- Step 34 completed (Runtime Provider Switching)
- All LLM clients implemented (LLMClient, AnthropicLLMClient, AppleLLMClient)
- LLMClientFactory implemented

## Instructions

### 1. Create Test Directory
```bash
mkdir -p Tests/YBSTests/LLMTests
```

### 2. Create Test Files

Create `Tests/YBSTests/LLMTests/LLMClientTests.swift`:
- Test OpenAI message format
- Test request construction
- Test response parsing
- Test error handling

Create `Tests/YBSTests/LLMTests/AnthropicLLMClientTests.swift`:
- Test system message extraction (separate field)
- Test Anthropic header construction (x-api-key)
- Test content blocks parsing
- Test message format conversion

Create `Tests/YBSTests/LLMTests/LLMClientFactoryTests.swift`:
- Test factory creates correct client per provider
- Test unknown provider fallback
- Test configuration passing

### 3. Run Tests
```bash
swift test --filter LLMTests
```

## Verification Criteria
- [ ] 3 test files created
- [ ] Minimum 15 test cases implemented
- [ ] All tests pass
- [ ] Anthropic format conversion tested
- [ ] Factory pattern tested

## Common Issues
- Mock HTTP responses needed for testing
- Async HTTP calls need proper mocking

## Documentation
Create: `docs/build-history/ybs-step_g1h2i3j4k5l6-DONE.txt`

## Next Step
Proceed to Step 38: Integration Tests for Agent Loop
