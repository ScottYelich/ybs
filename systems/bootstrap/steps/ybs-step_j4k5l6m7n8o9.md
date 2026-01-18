# Step 000040: End-to-End Workflow Tests

**GUID**: j4k5l6m7n8o9
**Version**: 0.1.0
**Estimated Duration**: 15 minutes

## Objectives
- Test complete user workflows end-to-end
- Verify provider switching workflow
- Test error recovery scenarios
- Ensure all components work together

## Prerequisites
- All previous test steps completed (31, 37-39)
- Complete system implemented and unit/integration tested

## Instructions

### 1. Create Test Directory
```bash
mkdir -p Tests/YBSTests/E2ETests
```

### 2. Create Test File

Create `Tests/YBSTests/E2ETests/WorkflowTests.swift`:

**Test Workflows**:
1. Complete file operation workflow:
   - User asks to read file
   - Agent uses read_file tool
   - User asks to edit file
   - Agent uses edit_file tool
   - Verify file was modified

2. Provider switching workflow:
   - Start with default provider
   - Use /provider to switch
   - Verify conversation continues
   - Verify new provider is used

3. Error recovery workflow:
   - Tool execution fails
   - Agent receives error message
   - Agent retries or adapts
   - Workflow completes successfully

4. Multi-turn tool workflow:
   - User requests complex task
   - Agent uses multiple tools
   - Tool results feed into next tool
   - Final response synthesizes results

### 3. Run Tests
```bash
swift test --filter E2ETests
```

### 4. Run All Tests
```bash
swift test
```

Verify full test suite passes.

## Verification Criteria
- [ ] E2E test file created
- [ ] Minimum 4 workflow tests implemented
- [ ] All E2E tests pass
- [ ] COMPLETE test suite passes (`swift test`)
- [ ] Test coverage >= 60% (run with --enable-code-coverage)

## Common Issues
- E2E tests may be slow (increase timeout)
- Need comprehensive mocking for full workflows

## Documentation
Create: `docs/build-history/ybs-step_j4k5l6m7n8o9-DONE.txt`

## Test Coverage Report

After this step, generate coverage report:
```bash
swift test --enable-code-coverage
xcrun llvm-cov report .build/debug/YBSPackageTests.xctest/Contents/MacOS/YBSPackageTests
```

Verify:
- Overall coverage >= 60%
- Tool coverage >= 80%
- Core components >= 70%

## Next Steps

Testing complete! System now has comprehensive test coverage.

Future builds can:
- Add more edge case tests
- Add performance benchmarks
- Add stress tests
- Add security penetration tests
