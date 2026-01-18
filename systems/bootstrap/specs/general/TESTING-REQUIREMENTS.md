# Testing Requirements for Bootstrap System

**Version**: 1.0.0
**Created**: 2026-01-18
**Purpose**: Define mandatory testing requirements to prevent "test coverage needs improvement" in future builds

---

## Problem Statement

**Issue Identified**: test7 build completed successfully with minimal test coverage (1 test file), because:
1. The specifications mentioned testing in `ybs-lessons-learned.md` but didn't mandate it
2. The build steps (Steps 0-36) didn't include dedicated testing steps
3. Without explicit testing steps, the AI agent didn't create comprehensive tests

**Impact**: System is production-ready code-wise but lacks verification tests for confidence in future changes.

---

## Solution: Multi-Layered Testing Requirements

### 1. Update Specifications (WHAT)

Add explicit testing section to `ybs-spec.md`:

```markdown
## 12. Testing Requirements

### 12.1 Mandatory Test Coverage

All implementations MUST include:
- **Unit tests**: For each tool, model, and core component
- **Integration tests**: For agent loop, LLM clients, tool executor
- **End-to-end tests**: For complete user workflows

### 12.2 Test Structure

Tests must be organized as:
```
Tests/
└── YBSTests/
    ├── ToolTests/           # Unit tests for each tool
    ├── LLMTests/            # Unit tests for LLM clients
    ├── AgentTests/          # Integration tests for agent loop
    ├── ConfigTests/         # Unit tests for configuration
    └── E2ETests/            # End-to-end workflow tests
```

### 12.3 Test Coverage Targets

- **Minimum**: 60% line coverage
- **Target**: 80% line coverage
- **Critical paths**: 100% coverage (tool execution, LLM communication)

### 12.4 Testing Before Step Completion

No implementation step is considered complete until:
1. Tests are written for the implemented code
2. All tests pass (`swift test` succeeds)
3. Code coverage meets minimum threshold
```

### 2. Add Dedicated Testing Steps (HOW)

Insert new testing steps at strategic points in the build sequence:

#### Proposed New Steps

**Step 31: Unit Tests for Tools** (after Step 21 - all tools implemented)
- Test each tool independently with mock inputs
- Verify success and error cases
- Test edge cases (empty files, missing paths, etc.)
- Estimated duration: 15-20 minutes

**Step 37: Unit Tests for LLM Clients** (after Step 34 - providers complete)
- Test message format conversion (especially Anthropic)
- Test API header construction
- Mock HTTP responses and verify parsing
- Test streaming functionality
- Estimated duration: 15 minutes

**Step 38: Integration Tests for Agent Loop** (after Step 36 - system complete)
- Test full conversation flow with mock LLM
- Test tool execution loop
- Test meta-commands
- Test shell injection
- Test provider switching
- Estimated duration: 20 minutes

**Step 39: Configuration and Error Handling Tests** (after Step 38)
- Test config loading from various sources
- Test validation and error messages
- Test logger functionality
- Test HTTP client error handling
- Estimated duration: 10 minutes

**Step 40: End-to-End Workflow Tests** (after Step 39)
- Test complete user workflows (read file, edit, save)
- Test provider switching workflow
- Test error recovery
- Estimated duration: 15 minutes

**Total Additional Time**: ~75-80 minutes (about 1.3 hours)

### 3. Testing Step Template

Each testing step should follow this structure:

```markdown
# Step XXXXXX: [Testing Phase Name]

**GUID**: XXXXXXXXXXXX
**Version**: 0.1.0
**Estimated Duration**: [X] minutes

## Objectives
- Write [unit/integration/e2e] tests for [component]
- Achieve [X]% coverage for [component]
- Verify [specific behaviors]

## Prerequisites
- Step YYY completed (implementation of components to test)
- XCTest framework available (built into Swift)

## Instructions

### 1. Create Test File Structure
[Create Tests/YBSTests/[Category]Tests/ directory]
[Create test file: [Component]Tests.swift]

### 2. Write Test Cases
[Specific test cases to implement]

Example test structure:
```swift
import XCTest
@testable import YBS

final class ReadFileToolTests: XCTestCase {
    var tool: ReadFileTool!

    override func setUp() {
        super.setUp()
        tool = ReadFileTool()
    }

    func testReadExistingFile() async throws {
        // Test reading a valid file
    }

    func testReadNonExistentFile() async throws {
        // Test error handling for missing file
    }

    func testReadEmptyFile() async throws {
        // Test edge case
    }
}
```

### 3. Run Tests
```bash
swift test
```

### 4. Verify Coverage (Optional but Recommended)
```bash
swift test --enable-code-coverage
xcrun llvm-cov report .build/debug/YBSPackageTests.xctest/Contents/MacOS/YBSPackageTests
```

## Verification Criteria
- [ ] All tests pass (`swift test` succeeds)
- [ ] No compilation errors in test code
- [ ] [Minimum X test cases implemented]
- [ ] Tests cover success, error, and edge cases
- [ ] (Optional) Code coverage meets [X]% threshold

## Common Issues
- XCTest not finding @testable import: Ensure target name is correct in Package.swift
- Async tests timing out: Increase timeout or check for proper await usage
- File path issues in tests: Use temporary directories or fixtures

## Rollback Plan
If tests fail to compile or run:
1. Comment out failing test cases
2. Document issues in BUILD_STATUS.md
3. Continue to next step if at least basic tests pass
4. Return to fix tests in subsequent iteration
```

---

## Implementation Strategy

### Option A: Retrofit Current Steps (Moderate Effort)
1. Update existing steps 16-21 (tool implementations) to include tests
2. Update existing steps 32-34 (provider implementations) to include tests
3. AI agent re-executes modified steps

**Pros**: Tests written alongside implementation
**Cons**: Requires modifying many existing steps, harder to maintain

### Option B: Add New Testing Steps (Recommended)
1. Insert 5 new dedicated testing steps (31, 37-40)
2. Keep existing implementation steps unchanged
3. AI agent executes new testing steps in next build

**Pros**:
- Clean separation of concerns
- Easier to maintain
- Can be optional (skip if rapid prototyping)
- Doesn't break existing builds

**Cons**: Tests written after implementation (less TDD-like)

### Option C: Test-Driven Development (Most Rigorous)
1. For each implementation step, create corresponding test step BEFORE implementation
2. Write failing tests first, then implement to make them pass

**Pros**: True TDD, highest quality
**Cons**: Doubles number of steps, more complex orchestration

---

## Recommended Approach

**Use Option B: Add New Dedicated Testing Steps**

### Why This Works Best:
1. **Non-Breaking**: Existing 36 steps remain unchanged and validated
2. **Modular**: Tests can be added, modified, or skipped independently
3. **Clear Progress**: Separate testing milestones visible in build status
4. **Flexible**: Future builds can skip tests for rapid prototyping, include for production

### Where to Insert:

Current step sequence has logical groupings:
- Steps 0-3: Setup
- Steps 4-11: Core infrastructure (models, LLM, HTTP)
- Steps 12-21: Tool framework and implementations → **INSERT: Step 31 (Tool Tests)**
- Steps 22-27: Tool registration and agent loop
- Steps 28-30: CLI and entry point
- Steps 32-34: Multi-provider support
- Steps 35-36: Meta-commands and shell injection → **INSERT: Steps 37-40 (Tests)**

**New Step Sequence**:
```
Steps 0-30: [Unchanged - Core implementation]
Step 31: Unit Tests for Tools ← NEW
Steps 32-36: [Unchanged - Advanced features]
Step 37: Unit Tests for LLM Clients ← NEW
Step 38: Integration Tests for Agent Loop ← NEW
Step 39: Configuration and Error Tests ← NEW
Step 40: End-to-End Workflow Tests ← NEW
```

**Updated Build Metrics**:
- **Total steps**: 41 (was 36)
- **Estimated duration**: ~6.8 hours (was 5.5 hours)
- **Additional time**: ~1.3 hours (24% increase)
- **Benefit**: Comprehensive test coverage, production confidence

---

## Specification Updates Required

### 1. Update `ybs-spec.md`
Add section 12 "Testing Requirements" with:
- Mandatory test coverage levels
- Test structure requirements
- Testing before step completion rule

### 2. Update `ybs-lessons-learned.md`
Change section 10.3 from checkboxes to imperative statements:
```markdown
### 10.3 Testing (MANDATORY)
- ✅ **Unit tests for tools**: MUST test each tool independently
- ✅ **Integration tests for loop**: MUST test full agent loop with mock LLM
- ✅ **Sandbox tests**: MUST verify sandbox blocks dangerous operations
- ✅ **Replay tests**: SHOULD record and replay LLM interactions for regression
```

### 3. Create New Step Files
Create 5 new step files:
- `ybs-step_[GUID-31].md` - Unit Tests for Tools
- `ybs-step_[GUID-37].md` - Unit Tests for LLM Clients
- `ybs-step_[GUID-38].md` - Integration Tests for Agent Loop
- `ybs-step_[GUID-39].md` - Configuration and Error Tests
- `ybs-step_[GUID-40].md` - End-to-End Workflow Tests

### 4. Update `STEPS_ORDER.txt`
Insert new step GUIDs at appropriate positions

---

## Example: Step 31 (Unit Tests for Tools) - DRAFT

```markdown
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
- Step 21 completed (all tools implemented: read_file, write_file, edit_file, list_files, search_files, run_shell)
- XCTest framework available (built into Swift)
- Test target configured in Package.swift

## Instructions

### 1. Create Test Directory Structure
```bash
mkdir -p Tests/YBSTests/ToolTests
```

### 2. Create Test Files for Each Tool

Create the following test files:
- `Tests/YBSTests/ToolTests/ReadFileToolTests.swift`
- `Tests/YBSTests/ToolTests/WriteFileToolTests.swift`
- `Tests/YBSTests/ToolTests/EditFileToolTests.swift`
- `Tests/YBSTests/ToolTests/ListFilesToolTests.swift`
- `Tests/YBSTests/ToolTests/SearchFilesToolTests.swift`
- `Tests/YBSTests/ToolTests/RunShellToolTests.swift`

### 3. Implement Tests for ReadFileTool

[Detailed implementation guide for each test case]

[Include ~30-40 test cases total across all 6 tools]

### 4. Run Tests
```bash
swift test
```

All tests must pass.

## Verification Criteria
- [ ] 6 test files created (one per tool)
- [ ] Minimum 30 test cases implemented
- [ ] `swift test` completes successfully
- [ ] All tests pass (0 failures)
- [ ] Tests cover:
  - [ ] Success cases (happy path)
  - [ ] Error cases (missing files, invalid paths)
  - [ ] Edge cases (empty files, large files, special characters)
- [ ] Test output shows expected number of tests run

## Common Issues
[List common testing issues and solutions]

## Rollback Plan
[Rollback procedure if tests fail]

## Documentation
Create: `docs/build-history/ybs-step_f9e8d7c6b5a4-DONE.txt`

## Next Step
Proceed to Step 32: Apple Foundation Model Integration
```

---

## Success Metrics for Testing Steps

After implementing testing steps, successful builds should have:
- ✅ **>30 test cases** total
- ✅ **All tests passing** (swift test succeeds)
- ✅ **60%+ code coverage** (minimum)
- ✅ **80%+ code coverage** (target)
- ✅ **Tests for critical paths**: 100% coverage (tool execution, LLM API calls)

---

## Alternative: Lightweight Testing Approach

If full testing is too heavy for prototyping, implement **smoke tests only**:

**Single Step: Step 31 (Smoke Tests)**
- One test file: `SmokeTests.swift`
- Test basic functionality only:
  - Can tools be instantiated?
  - Do tools return expected schema?
  - Can agent loop start?
  - Can LLM client be created?
- Duration: 5 minutes
- Provides basic confidence without full coverage

---

## Conclusion

**Recommended Action Plan**:

1. **Immediate**: Document testing requirements in this file (done)
2. **Short term**: Update `ybs-spec.md` with mandatory testing section
3. **Short term**: Update `ybs-lessons-learned.md` with imperative testing requirements
4. **Medium term**: Create 5 new testing step files (31, 37-40)
5. **Medium term**: Update `STEPS_ORDER.txt` with new steps
6. **Next build**: Execute new steps to achieve 80% test coverage

**Benefit**: Future builds will have comprehensive test coverage by default, eliminating the "test coverage needs improvement" issue.

**Alternative**: For rapid prototyping, add metadata to steps allowing testing steps to be skipped:
```markdown
**Optional**: true
**Skip for**: rapid-prototype builds
**Required for**: production-ready builds
```

---

## Related Documents
- `ybs-spec.md` - Technical specification (needs update)
- `ybs-lessons-learned.md` - Implementation checklist (needs update)
- `CHECKPOINT-test7-complete.md` - Identified testing gap
- Step files 31, 37-40 - To be created

---

**Status**: Draft recommendation
**Next Action**: User decision on approach (Option A, B, or C)
