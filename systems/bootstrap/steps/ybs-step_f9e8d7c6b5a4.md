# Step 000031: Unit Tests for Tools

**GUID**: f9e8d7c6b5a4
**Version**: 0.1.0
**Estimated Duration**: 20 minutes

## Objectives
- Write comprehensive unit tests for all 6 built-in tools
- Achieve 80%+ coverage for tool implementations
- Verify success cases, error cases, and edge cases
- Ensure tests pass before proceeding

## Prerequisites
- Step 21 completed (all tools implemented)
- XCTest framework available (built into Swift)
- Test target configured in Package.swift

## Instructions

### 1. Create Test Directory Structure
```bash
mkdir -p Tests/YBSTests/ToolTests
```

### 2. Create Test Files

Create `Tests/YBSTests/ToolTests/ReadFileToolTests.swift`:
- Test reading existing file
- Test reading non-existent file
- Test reading empty file
- Test path validation

Create `Tests/YBSTests/ToolTests/WriteFileToolTests.swift`:
- Test writing new file
- Test overwriting existing file
- Test invalid path
- Test permissions

Create `Tests/YBSTests/ToolTests/EditFileToolTests.swift`:
- Test successful edit
- Test non-unique match failure
- Test no match found
- Test replace_all option

Create `Tests/YBSTests/ToolTests/ListFilesToolTests.swift`:
- Test listing current directory
- Test listing specific path
- Test glob patterns
- Test empty directory

Create `Tests/YBSTests/ToolTests/SearchFilesToolTests.swift`:
- Test pattern matching
- Test no matches
- Test context lines
- Test multiple matches

Create `Tests/YBSTests/ToolTests/RunShellToolTests.swift`:
- Test successful command
- Test command timeout
- Test blocked command
- Test non-zero exit code

### 3. Run Tests
```bash
swift test
```

All tests must pass.

## Verification Criteria
- [ ] 6 test files created (one per tool)
- [ ] Minimum 30 test cases implemented
- [ ] `swift test` completes successfully
- [ ] All tests pass (0 failures)
- [ ] Tests cover success, error, and edge cases

## Common Issues
- XCTest not finding @testable import: Ensure target name is correct
- Async tests timing out: Increase timeout or check await usage
- File path issues: Use temporary directories

## Rollback Plan
If tests fail to compile:
1. Comment out failing test cases
2. Document issues in BUILD_STATUS.md
3. Fix tests before proceeding

## Documentation
Create: `docs/build-history/ybs-step_f9e8d7c6b5a4-DONE.txt`

## Next Step
Proceed to Step 32: Apple Foundation Model Integration
