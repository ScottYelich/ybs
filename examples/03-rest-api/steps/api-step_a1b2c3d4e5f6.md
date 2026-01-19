# Step 4: Run Tests and Verify Coverage

**Step ID**: a1b2c3d4e5f6
**System**: rest-api-client
**Version**: 1.0.0
**Estimated Time**: 5 minutes
**Depends On**: Step 3 (Create Test Suite)

---

## Context

**What**: Execute the test suite and verify minimum 60% code coverage

**Why**: Validates implementation meets requirements and has adequate test coverage

**Implements**:
- rest-api-client-spec.md § 2.2 NF3 (Test Coverage ≥60%)
- rest-api-client-spec.md § 5.3 (Coverage Requirements)

---

## Prerequisites

- ✅ Step 3 complete (test suite created)
- ✅ Test dependencies installed
- ✅ Client script exists and runs

---

## Instructions

### 1. Run Tests with Coverage

Execute tests using language-appropriate test runner:

#### **For Python** ({{CONFIG:language}} == "python"):

```bash
# Run tests with coverage
python3 -m pytest test_api_client.py -v --cov=api_client --cov-report=term --cov-report=html

# Save coverage report
python3 -m pytest test_api_client.py --cov=api_client --cov-report=term > coverage.txt
```

---

#### **For JavaScript** ({{CONFIG:language}} == "javascript"):

```bash
# Run tests with coverage
npm test -- --coverage --verbose

# Coverage report saved automatically to coverage/ directory
```

---

#### **For Ruby** ({{CONFIG:language}} == "ruby"):

```bash
# Run tests with coverage (using simplecov)
rspec api_client_spec.rb --format documentation

# If simplecov configured, coverage saved to coverage/ directory
```

---

### 2. Check Coverage Results

**CRITICAL**: Coverage MUST be ≥60% (REQUIRED), target is 80% (RECOMMENDED)

**Python output example**:
```
----------- coverage: platform linux, python 3.9 -----------
Name              Stmts   Miss  Cover
-------------------------------------
api_client.py        42      8    81%
-------------------------------------
TOTAL                42      8    81%
```

**JavaScript output example**:
```
----------|---------|----------|---------|---------|
File      | % Stmts | % Branch | % Funcs | % Lines |
----------|---------|----------|---------|---------|
All files |   75.5  |    68.2  |   80.0  |   75.5  |
 api_client.js |   75.5  |    68.2  |   80.0  |   75.5  |
----------|---------|----------|---------|---------|
```

---

### 3. Verify Minimum Coverage

Check that line coverage is ≥60%:

```bash
# Extract coverage percentage
COVERAGE=$(grep "TOTAL" coverage.txt | awk '{print $NF}' | sed 's/%//')

if [ "$COVERAGE" -ge 60 ]; then
  echo "✅ Coverage: ${COVERAGE}% (meets 60% requirement)"
else
  echo "❌ Coverage: ${COVERAGE}% (below 60% requirement)"
  exit 1
fi
```

---

### 4. Check Test Results

Verify all tests pass:

**Expected**: All tests green, no failures

**If tests fail**:
1. Review failure messages
2. Fix implementation or test code
3. Re-run tests
4. Maximum 3 attempts before escalating

---

### 5. Review Uncovered Code

If coverage < 80%, review what's not covered:

**Python**:
```bash
# Open HTML coverage report
python3 -m http.server 8000 &
# Open http://localhost:8000/htmlcov/index.html in browser
```

**JavaScript**:
```bash
# Coverage report in coverage/lcov-report/index.html
open coverage/lcov-report/index.html
```

**Identify**: Which lines/functions are uncovered?

---

### 6. Document Coverage

Add coverage results to BUILD_STATUS.md:

```markdown
## Test Results

**Date**: $(date '+%Y-%m-%d %H:%M:%S')
**Test Runner**: pytest / jest / rspec
**Tests Run**: X passed, 0 failed
**Coverage**: X% line coverage
**Status**: ✅ PASSED (≥60% requirement met)

### Coverage Breakdown
- Total Statements: X
- Covered: X
- Uncovered: X
- Line Coverage: X%
```

---

## Verification

**This step is complete when:**
- ✅ All tests executed without errors
- ✅ All tests pass (green)
- ✅ Line coverage ≥60% (REQUIRED)
- ✅ Coverage report generated (coverage.txt or coverage/)
- ✅ BUILD_STATUS.md updated with test results
- ✅ No critical paths uncovered

**Verification Commands**:
```bash
# Check tests passed
echo $? # Should be 0 (success)

# Check coverage file exists
[ -f coverage.txt ] || [ -d coverage/ ] && echo "✅ Coverage report exists" || echo "❌ Missing"

# Check BUILD_STATUS.md updated
grep -q "Test Results" BUILD_STATUS.md && echo "✅ Status updated" || echo "❌ Not updated"
```

**Retry Limit**: 3 attempts

---

## Troubleshooting

**Problem**: Tests fail due to missing dependencies
**Solution**: Reinstall dependencies from requirements.txt/package.json/Gemfile

**Problem**: Coverage below 60%
**Solution**: Add more test cases or refactor code to be more testable

**Problem**: Tests hang or timeout
**Solution**: Check for infinite loops, verify mock setup correct

**Problem**: Import/module errors in tests
**Solution**: Verify PYTHONPATH, check file locations

**Problem**: Coverage tool not installed
**Solution**: Install pytest-cov / jest / simplecov per Step 1

---

## If Coverage < 60%

**CRITICAL**: If coverage is below 60%, this step FAILS:

1. Review uncovered code sections
2. Add missing test cases
3. Return to Step 3, add tests
4. Re-run this step
5. If 3 attempts fail, document and escalate

**Do NOT proceed to Step 5 with coverage < 60%**

---

## Next Step

**Step 5**: Integration Test with Real API

---

## References

- **Specification**: [../specs/rest-api-client-spec.md](../specs/rest-api-client-spec.md) § 5.3
- **YBS Framework**: [../../framework/methodology/executing-builds.md](../../framework/methodology/executing-builds.md)
- **Feature Addition Protocol**: [../../framework/methodology/feature-addition-protocol.md](../../framework/methodology/feature-addition-protocol.md)

---

**End of Step 4**
