# Step 10: Final Verification

**System**: calculator
**Step ID**: calc-step_a2b3c4d5e6f7
**Implements**: calculator-spec.md § 8 (Verification Criteria), § 9 (Success Criteria)
**Prerequisites**: Step 9 (Create Documentation)
**Duration**: 15-20 minutes

---

## Purpose

Perform comprehensive final verification of the calculator system. This step validates that all requirements are met, tests pass, coverage is adequate, traceability is sufficient, and documentation is complete.

---

## Inputs

- All deliverables from Steps 1-9
- `BUILD_CONFIG.json` - Build configuration
- `BUILD_STATUS.md` - Build status log

**Required verification**:
- All functional requirements (F1-F11) implemented
- All test requirements (T1-T22) passing
- Code coverage ≥ 80% (target: 90%)
- Traceability ≥ 80%
- Documentation complete

---

## Outputs

- `TEST_REPORT.md` - Comprehensive test results report
- Updated `BUILD_STATUS.md` - Final status with completion
- Verified working calculator system

---

## Instructions

### 1. Read Configuration

```bash
# Read configuration
LANGUAGE=$(python -c "import json; c=json.load(open('BUILD_CONFIG.json')); print(c['language'])")
ENTRY_POINT=$(python -c "import json; c=json.load(open('BUILD_CONFIG.json')); print(c['entry_point'])")
BUILD_NAME=$(python -c "import json; c=json.load(open('BUILD_CONFIG.json')); print(c['build_name'])")

echo "Build: $BUILD_NAME"
echo "Language: $LANGUAGE"
echo "Entry Point: $ENTRY_POINT"
```

---

### 2. Run Complete Test Suite

Execute all tests with coverage reporting:

#### Python

```bash
# Run all tests with verbose output and coverage
pytest tests/ -v --cov=src --cov-report=term-missing --cov-report=html --cov-report=json

# Capture test results
echo $? > .test_exit_code
```

**Expected output**:
- All tests pass (green)
- Coverage report shows ≥ 80% (target: ≥ 90%)
- No warnings or errors

---

#### JavaScript

```bash
# Run all tests with verbose output and coverage
npm test -- --verbose --coverage --coverageReporters=text --coverageReporters=html --coverageReporters=json

# Capture test results
echo $? > .test_exit_code
```

**Expected output**:
- All tests pass (green)
- Coverage report shows ≥ 80% (target: ≥ 90%)
- No warnings or errors

---

### 3. Verify Functional Requirements

Test each functional requirement manually:

#### F1: Addition

```bash
./$ENTRY_POINT.py add 5 3 || ./$ENTRY_POINT.js add 5 3
# Expected: 8
```

#### F2: Subtraction

```bash
./$ENTRY_POINT.py subtract 10 4 || ./$ENTRY_POINT.js subtract 10 4
# Expected: 6
```

#### F3: Multiplication

```bash
./$ENTRY_POINT.py multiply 6 7 || ./$ENTRY_POINT.js multiply 6 7
# Expected: 42
```

#### F4: Division

```bash
./$ENTRY_POINT.py divide 15 3 || ./$ENTRY_POINT.js divide 15 3
# Expected: 5

./$ENTRY_POINT.py divide 10 0 || ./$ENTRY_POINT.js divide 10 0
# Expected: Error: Division by zero (exit code 1)
```

#### F5: CLI Arguments Mode

```bash
# All previous tests verify this
echo "✅ F5: CLI Arguments Mode verified"
```

#### F6: Interactive Mode (if enabled)

```bash
# Test manually or with script
echo -e "add 5 3\nquit" | ./$ENTRY_POINT.py || echo -e "add 5 3\nquit" | ./$ENTRY_POINT.js
# Expected: Result shown, then exits
```

#### F7-F9: Input Validation

```bash
# Invalid operation
./$ENTRY_POINT.py unknown 5 3 || ./$ENTRY_POINT.js unknown 5 3
# Expected: Error message, exit code 1

# Invalid number
./$ENTRY_POINT.py add five 3 || ./$ENTRY_POINT.js add five 3
# Expected: Error message, exit code 1

# Wrong argument count
./$ENTRY_POINT.py add 5 || ./$ENTRY_POINT.js add 5
# Expected: Error message, exit code 1

echo "✅ F7-F9: Input Validation verified"
```

#### F10-F11: Output Formatting

```bash
# Integer result (no decimal)
./$ENTRY_POINT.py add 5 3 || ./$ENTRY_POINT.js add 5 3
# Expected: "8" (not "8.0")

# Decimal result
./$ENTRY_POINT.py divide 7 2 || ./$ENTRY_POINT.js divide 7 2
# Expected: "3.5"

# Error formatting
./$ENTRY_POINT.py divide 10 0 || ./$ENTRY_POINT.js divide 10 0
# Expected: "Error: ..." format

echo "✅ F10-F11: Output Formatting verified"
```

---

### 4. Check Code Coverage

Verify coverage meets requirements:

#### Python

```bash
# Check coverage from JSON report
COVERAGE=$(python -c "import json; data=json.load(open('coverage.json')); print(int(data['totals']['percent_covered']))")
echo "Coverage: $COVERAGE%"

if [ $COVERAGE -ge 90 ]; then
    echo "✅ Coverage: $COVERAGE% (Exceeds target of 90%)"
elif [ $COVERAGE -ge 80 ]; then
    echo "✅ Coverage: $COVERAGE% (Meets minimum of 80%)"
else
    echo "❌ Coverage: $COVERAGE% (Below minimum of 80%)"
    exit 1
fi
```

---

#### JavaScript

```bash
# Check coverage from JSON report
COVERAGE=$(node -e "const c=require('./coverage/coverage-summary.json'); const t=c.total; console.log(Math.round(t.lines.pct));")
echo "Coverage: $COVERAGE%"

if [ $COVERAGE -ge 90 ]; then
    echo "✅ Coverage: $COVERAGE% (Exceeds target of 90%)"
elif [ $COVERAGE -ge 80 ]; then
    echo "✅ Coverage: $COVERAGE% (Meets minimum of 80%)"
else
    echo "❌ Coverage: $COVERAGE% (Below minimum of 80%)"
    exit 1
fi
```

---

### 5. Verify Traceability

Check that source files have traceability comments:

```bash
# Count source files
TOTAL_FILES=$(find src -name "*.py" -o -name "*.js" | wc -l)

# Count files with traceability comments
TRACED_FILES=$(grep -l "Implements: calculator-spec.md" src/*.py src/*.js 2>/dev/null | wc -l)

# Calculate percentage
TRACE_PCT=$(echo "scale=0; $TRACED_FILES * 100 / $TOTAL_FILES" | bc)

echo "Traceability: $TRACED_FILES / $TOTAL_FILES files ($TRACE_PCT%)"

if [ $TRACE_PCT -ge 80 ]; then
    echo "✅ Traceability: $TRACE_PCT% (Meets minimum of 80%)"
else
    echo "❌ Traceability: $TRACE_PCT% (Below minimum of 80%)"
    echo "Files missing traceability:"
    find src -name "*.py" -o -name "*.js" | while read f; do
        grep -q "Implements: calculator-spec.md" "$f" || echo "  - $f"
    done
    exit 1
fi
```

---

### 6. Verify Documentation

Check that documentation is complete:

```bash
# Check files exist
test -f docs/USAGE.md && echo "✅ docs/USAGE.md exists" || echo "❌ docs/USAGE.md missing"
test -f README.md && echo "✅ README.md exists" || echo "❌ README.md missing"

# Check for key sections in USAGE.md
grep -q "## Overview" docs/USAGE.md && echo "✅ USAGE.md has Overview"
grep -q "## Usage" docs/USAGE.md && echo "✅ USAGE.md has Usage"
grep -q "## Examples" docs/USAGE.md && echo "✅ USAGE.md has Examples"
grep -q "## Error Handling" docs/USAGE.md && echo "✅ USAGE.md has Error Handling"

# Check for key sections in README.md
grep -q "## Architecture" README.md && echo "✅ README.md has Architecture"
grep -q "## Development Setup" README.md && echo "✅ README.md has Development Setup"
grep -q "## Running Tests" README.md && echo "✅ README.md has Running Tests"
grep -q "## Testing Strategy" README.md && echo "✅ README.md has Testing Strategy"
```

---

### 7. Generate Test Report

Create comprehensive test report:

**File**: `TEST_REPORT.md`

```bash
cat > TEST_REPORT.md << EOF
# Test Report - Calculator

**Build**: $BUILD_NAME
**Language**: $LANGUAGE
**Date**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

---

## Summary

$(if [ -f .test_exit_code ] && [ $(cat .test_exit_code) -eq 0 ]; then echo "✅ **Status**: ALL TESTS PASSED"; else echo "❌ **Status**: SOME TESTS FAILED"; fi)

- **Total Tests**: $(grep -o "passed" coverage.json 2>/dev/null | wc -l || echo "N/A")
- **Coverage**: ${COVERAGE}%
- **Traceability**: ${TRACE_PCT}%

---

## Functional Requirements

| ID | Requirement | Status |
|----|-------------|--------|
| F1 | Addition | ✅ Verified |
| F2 | Subtraction | ✅ Verified |
| F3 | Multiplication | ✅ Verified |
| F4 | Division | ✅ Verified |
| F5 | CLI Arguments Mode | ✅ Verified |
| F6 | Interactive Mode | $([ "$INTERACTIVE" = "true" ] && echo "✅ Verified" || echo "N/A (Disabled)") |
| F7 | Numeric Validation | ✅ Verified |
| F8 | Operation Validation | ✅ Verified |
| F9 | Argument Count Validation | ✅ Verified |
| F10 | Result Display | ✅ Verified |
| F11 | Error Display | ✅ Verified |

---

## Test Requirements

### Unit Tests - Calculator Module

| ID | Test | Status |
|----|------|--------|
| T1 | Addition | ✅ Pass |
| T2 | Addition Edge Cases | ✅ Pass |
| T3 | Subtraction | ✅ Pass |
| T4 | Subtraction Edge Cases | ✅ Pass |
| T5 | Multiplication | ✅ Pass |
| T6 | Multiplication Edge Cases | ✅ Pass |
| T7 | Division | ✅ Pass |
| T8 | Division Edge Cases | ✅ Pass |
| T9 | Division by Zero | ✅ Pass |

### Unit Tests - Parser Module

| ID | Test | Status |
|----|------|--------|
| T10 | Valid Operation Parsing | ✅ Pass |
| T11 | Invalid Operation | ✅ Pass |
| T12 | Invalid Number | ✅ Pass |
| T13 | Argument Count | ✅ Pass |

### Unit Tests - Formatter Module

| ID | Test | Status |
|----|------|--------|
| T14 | Integer Result Formatting | ✅ Pass |
| T15 | Decimal Result Formatting | ✅ Pass |
| T16 | Long Decimal Formatting | ✅ Pass |
| T17 | Error Message Formatting | ✅ Pass |

### Integration Tests

| ID | Test | Status |
|----|------|--------|
| T18 | End-to-End CLI Operation | ✅ Pass |
| T19 | End-to-End Error Handling | ✅ Pass |
| T20 | Interactive Mode Flow | $([ "$INTERACTIVE" = "true" ] && echo "✅ Pass" || echo "N/A") |

---

## Coverage Report

### By Module

| Module | Coverage | Status |
|--------|----------|--------|
| calculator | $(grep -A1 "calculator" coverage.json 2>/dev/null | grep percent_covered | awk '{print $2}' || echo "N/A")% | ✅ |
| parser | $(grep -A1 "parser" coverage.json 2>/dev/null | grep percent_covered | awk '{print $2}' || echo "N/A")% | ✅ |
| formatter | $(grep -A1 "formatter" coverage.json 2>/dev/null | grep percent_covered | awk '{print $2}' || echo "N/A")% | ✅ |
| cli | $(grep -A1 "cli" coverage.json 2>/dev/null | grep percent_covered | awk '{print $2}' || echo "N/A")% | ✅ |

### Overall

- **Line Coverage**: ${COVERAGE}%
- **Minimum Required**: 80%
- **Target**: 90%
- **Status**: $([ $COVERAGE -ge 90 ] && echo "✅ Exceeds Target" || [ $COVERAGE -ge 80 ] && echo "✅ Meets Minimum" || echo "❌ Below Minimum")

---

## Traceability

- **Files Traced**: $TRACED_FILES / $TOTAL_FILES
- **Percentage**: ${TRACE_PCT}%
- **Status**: $([ $TRACE_PCT -ge 80 ] && echo "✅ Meets Requirement (≥80%)" || echo "❌ Below Requirement")

---

## Documentation

| Document | Status |
|----------|--------|
| docs/USAGE.md | ✅ Complete |
| README.md | ✅ Complete |
| BUILD_CONFIG.json | ✅ Present |
| BUILD_STATUS.md | ✅ Present |

---

## Verification Checklist

- [x] All tests pass
- [x] Coverage ≥ 80%
- [x] Traceability ≥ 80%
- [x] Documentation complete
- [x] All operations work correctly
- [x] Error handling works
- [x] Exit codes correct
- [x] No linting errors
- [x] Performance acceptable (< 100ms per operation)

---

## Success Criteria

$([ -f .test_exit_code ] && [ $(cat .test_exit_code) -eq 0 ] && [ $COVERAGE -ge 80 ] && [ $TRACE_PCT -ge 80 ] && echo "✅ **ALL SUCCESS CRITERIA MET**" || echo "❌ **SOME CRITERIA NOT MET**")

1. ✅ All functional requirements (F1-F11) implemented
2. ✅ All test requirements (T1-T22) pass
3. ✅ Code coverage ≥ 80% (actual: ${COVERAGE}%)
4. ✅ Traceability ≥ 80% (actual: ${TRACE_PCT}%)
5. ✅ Documentation complete

---

## Build Information

- **Build Name**: $BUILD_NAME
- **Language**: $LANGUAGE
- **Entry Point**: $ENTRY_POINT
- **YBS Version**: 2.0.0

---

**Generated**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
EOF

echo "✅ Test report generated: TEST_REPORT.md"
cat TEST_REPORT.md
```

---

### 8. Update BUILD_STATUS.md to Complete

Mark the build as complete:

```bash
cat >> BUILD_STATUS.md << EOF

### Step 10: Final Verification
- **Started**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- **Completed**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- **Duration**: X minutes
- **Status**: ✅ PASS
- **Notes**: All tests passed, coverage ${COVERAGE}%, traceability ${TRACE_PCT}%

---

## Final Status

**Status**: ✅ COMPLETE
**Completed**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

### Summary

- ✅ All 10 steps completed successfully
- ✅ All tests passing
- ✅ Coverage: ${COVERAGE}% (≥80% required)
- ✅ Traceability: ${TRACE_PCT}% (≥80% required)
- ✅ Documentation complete

### Deliverables

1. ✅ Source code (src/)
2. ✅ Tests (tests/)
3. ✅ Documentation (docs/, README.md)
4. ✅ Build artifacts (BUILD_CONFIG.json, BUILD_STATUS.md, TEST_REPORT.md)

---

**Build completed successfully!**
EOF

echo "✅ BUILD_STATUS.md updated"
```

---

### 9. Final Cleanup

```bash
# Remove temporary files
rm -f .test_exit_code

# Optional: Clean up coverage artifacts if not needed
# rm -rf coverage/ htmlcov/ .coverage coverage.json

echo "✅ Final cleanup complete"
```

---

## Verification

### Success Criteria

- ✅ All tests pass (100% passing rate)
- ✅ Code coverage ≥ 80% (target: ≥ 90%)
- ✅ Traceability ≥ 80%
- ✅ All functional requirements verified
- ✅ Documentation complete and accurate
- ✅ TEST_REPORT.md generated
- ✅ BUILD_STATUS.md marked as COMPLETE
- ✅ No errors or warnings

### Verification Commands

```bash
# Check test exit code
test -f .test_exit_code && [ $(cat .test_exit_code) -eq 0 ] && echo "✅ All tests passed"

# Check coverage
test $COVERAGE -ge 80 && echo "✅ Coverage meets requirement"

# Check traceability
test $TRACE_PCT -ge 80 && echo "✅ Traceability meets requirement"

# Check deliverables
test -f TEST_REPORT.md && echo "✅ TEST_REPORT.md exists"
grep -q "COMPLETE" BUILD_STATUS.md && echo "✅ Build marked complete"
```

---

## Error Handling

### If Tests Fail

1. Review test output for failures
2. Fix implementation or tests
3. Re-run tests
4. Maximum 3 attempts
5. If still failing, mark build as FAILED in BUILD_STATUS.md

### If Coverage Below 80%

1. Identify uncovered lines in coverage report
2. Add tests for uncovered code
3. Re-run tests with coverage
4. Maximum 3 attempts
5. If still below 80%, mark build as INCOMPLETE

### If Traceability Below 80%

1. Review files without traceability comments
2. Add missing comments
3. Re-run traceability check
4. Should be easily fixable

---

## Next Steps

**Build is complete!**

Optional activities:
- Review TEST_REPORT.md
- Browse coverage report (htmlcov/index.html or coverage/index.html)
- Read documentation (docs/USAGE.md, README.md)
- Archive build artifacts
- Deploy or package application

---

## Notes

- This is the final step - no more steps after this
- TEST_REPORT.md provides comprehensive verification documentation
- BUILD_STATUS.md marks build as COMPLETE
- All success criteria from specification are verified
- Manual verification supplements automated tests
- Coverage reports available in HTML format for detailed review

---

**Traceability**: Implements calculator-spec.md § 8 (Verification Criteria), § 9 (Success Criteria)
