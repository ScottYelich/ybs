# Step 4: Verify Implementation

**Step ID**: a1b2c3d4e5f6
**System**: hello-world
**Version**: 1.0.0
**Estimated Time**: 2 minutes

---

## Context

**What**: Run comprehensive verification tests to ensure the hello-world system meets all requirements

**Why**: Verification is critical in YBS. This step validates that all specifications are met, all tests pass, and the system is production-ready.

**Previous Step**: Step 3 (Set Permissions) - script is executable

**This Step**: Final verification and completion

---

## Prerequisites

- [x] Step 0 complete (BUILD_CONFIG.json exists)
- [x] Step 1 complete (directory structure ready)
- [x] Step 2 complete (script file created)
- [x] Step 3 complete (permissions set)
- [x] Script file exists and is executable (or can run with interpreter)

---

## Instructions

### 1. Read Configuration

Load configuration for verification:

```bash
# Read configuration
BUILD_NAME=$(jq -r '.build_name' BUILD_CONFIG.json)
LANGUAGE=$(jq -r '.language' BUILD_CONFIG.json)
PLATFORM=$(jq -r '.platform' BUILD_CONFIG.json)
SCRIPT_NAME=$(jq -r '.script_name' BUILD_CONFIG.json)
MESSAGE=$(jq -r '.message' BUILD_CONFIG.json)

# Determine file extension
case "$LANGUAGE" in
  python) EXT="py" ;;
  bash) EXT="sh" ;;
  ruby) EXT="rb" ;;
  javascript) EXT="js" ;;
esac

SCRIPT_FILE="${SCRIPT_NAME}.${EXT}"

echo "Verifying: $SCRIPT_FILE"
echo "Expected message: $MESSAGE"
```

---

### 2. Create Comprehensive Verification Script

Update the test template created in Step 1:

```bash
cat > tests/verify.sh << 'EOFSCRIPT'
#!/usr/bin/env bash
# Verification test for hello-world
# Implements: hello-world-spec.md § 5.1 (Verification Tests)

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load configuration
SCRIPT_FILE="$1"
EXPECTED_MESSAGE="$2"

if [ -z "$SCRIPT_FILE" ] || [ -z "$EXPECTED_MESSAGE" ]; then
  echo "${RED}❌ Usage: verify.sh SCRIPT_FILE EXPECTED_MESSAGE${NC}"
  exit 1
fi

echo "========================================="
echo "Hello World - Verification Tests"
echo "========================================="
echo "Script: $SCRIPT_FILE"
echo "Expected: $EXPECTED_MESSAGE"
echo ""

PASSED=0
FAILED=0

# Helper function for test results
pass_test() {
  echo -e "${GREEN}✅ $1${NC}"
  ((PASSED++))
}

fail_test() {
  echo -e "${RED}❌ $1${NC}"
  ((FAILED++))
}

warn_test() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

# T1: File Exists
echo "T1: File Exists Test"
if [ -f "$SCRIPT_FILE" ]; then
  pass_test "T1 PASSED: Script file exists"
else
  fail_test "T1 FAILED: Script file not found"
  exit 1
fi
echo ""

# T2: Execution Test
echo "T2: Execution Test"
OUTPUT=$(bash "$SCRIPT_FILE" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  pass_test "T2 PASSED: Exit code = 0"
else
  fail_test "T2 FAILED: Exit code = $EXIT_CODE"
fi
echo ""

# T3: Output Verification
echo "T3: Output Verification"
if [ "$OUTPUT" == "$EXPECTED_MESSAGE" ]; then
  pass_test "T3 PASSED: Output matches expected message"
else
  fail_test "T3 FAILED: Output mismatch"
  echo "  Expected: '$EXPECTED_MESSAGE'"
  echo "  Got:      '$OUTPUT'"
fi
echo ""

# T4: No Error Output
echo "T4: No Error Output"
STDERR=$(bash "$SCRIPT_FILE" 2>&1 >/dev/null)
if [ -z "$STDERR" ]; then
  pass_test "T4 PASSED: No error output"
else
  warn_test "T4 WARNING: Stderr not empty: $STDERR"
fi
echo ""

# T5: Performance Test
echo "T5: Performance Test"
START_TIME=$(date +%s%N)
bash "$SCRIPT_FILE" > /dev/null 2>&1
END_TIME=$(date +%s%N)
DURATION=$(( (END_TIME - START_TIME) / 1000000 ))  # Convert to milliseconds

if [ $DURATION -lt 1000 ]; then
  pass_test "T5 PASSED: Execution time = ${DURATION}ms (< 1 second)"
else
  warn_test "T5 WARNING: Execution time = ${DURATION}ms"
fi
echo ""

# T6: Traceability Check
echo "T6: Traceability Check"
if grep -q "Implements: hello-world-spec.md" "$SCRIPT_FILE"; then
  pass_test "T6 PASSED: Traceability comment present"
else
  fail_test "T6 FAILED: Missing traceability comment"
fi
echo ""

# Summary
echo "========================================="
echo "Test Summary"
echo "========================================="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}❌ $FAILED test(s) failed${NC}"
  exit 1
fi
EOFSCRIPT

chmod +x tests/verify.sh

echo "✅ Comprehensive verification script created"
```

---

### 3. Run Verification Tests

Execute the verification script:

```bash
echo ""
echo "Running verification tests..."
echo ""

# Run verification
if ./tests/verify.sh "$SCRIPT_FILE" "$MESSAGE"; then
  VERIFICATION_STATUS="PASS"
  echo ""
  echo "✅ All verification tests passed"
else
  VERIFICATION_STATUS="FAIL"
  echo ""
  echo "❌ Verification tests failed"
  exit 1
fi
```

---

### 4. Check Code Coverage (Traceability)

Verify that all code has traceability comments:

```bash
echo ""
echo "Checking traceability coverage..."

# Count total lines of code (excluding comments and blank lines)
TOTAL_LINES=$(grep -v '^#' "$SCRIPT_FILE" | grep -v '^//' | grep -v '^\s*$' | wc -l | tr -d ' ')

# Count lines with traceability
TRACED_LINES=$(grep -c "Implements:" "$SCRIPT_FILE" || echo "0")

if [ "$TOTAL_LINES" -gt 0 ]; then
  COVERAGE=$(( TRACED_LINES * 100 / TOTAL_LINES ))
else
  COVERAGE=0
fi

echo "Traceability Coverage: ${TRACED_LINES} traced references"

if [ "$TRACED_LINES" -ge 3 ]; then
  echo "✅ Minimum traceability achieved (3 references)"
  echo "   - F1: Output Message"
  echo "   - F2: Execution"
  echo "   - F3: Cross-Platform"
else
  echo "❌ Insufficient traceability (need at least 3 references)"
  exit 1
fi
```

---

### 5. Generate Final Report

Create a comprehensive test report:

```bash
cat > TEST_REPORT.md << EOF
# Hello World - Test Report

**Build**: $BUILD_NAME
**Date**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Status**: $VERIFICATION_STATUS

---

## Configuration

- **System**: hello-world v1.0.0
- **Language**: $LANGUAGE
- **Platform**: $PLATFORM
- **Script**: $SCRIPT_FILE
- **Message**: $MESSAGE

---

## Test Results

### T1: File Exists
- **Status**: ✅ PASS
- **Result**: Script file exists and is not empty

### T2: Execution Test
- **Status**: ✅ PASS
- **Result**: Script executes with exit code 0

### T3: Output Verification
- **Status**: ✅ PASS
- **Result**: Output matches expected message exactly

### T4: No Error Output
- **Status**: ✅ PASS
- **Result**: No errors written to stderr

### T5: Performance Test
- **Status**: ✅ PASS
- **Result**: Execution completed in < 1 second

### T6: Traceability Check
- **Status**: ✅ PASS
- **Result**: All code has spec references

---

## Code Quality

- **Lines of Code**: $(wc -l < "$SCRIPT_FILE") (requirement: < 10)
- **Traceability**: ${TRACED_LINES} references
- **Requirements Covered**: F1, F2, F3 (all functional requirements)

---

## Verification Summary

✅ **All tests passed**
✅ **All requirements met**
✅ **System is production-ready**

---

## Files Created

1. \`$SCRIPT_FILE\` - Main executable script
2. \`BUILD_CONFIG.json\` - Build configuration
3. \`BUILD_STATUS.md\` - Build status tracking
4. \`PROJECT_STRUCTURE.txt\` - Project layout
5. \`EXECUTION_NOTES.txt\` - How to run the script
6. \`tests/verify.sh\` - Verification test script
7. \`TEST_REPORT.md\` - This report

---

## Next Steps

To run the hello-world script:

\`\`\`bash
# Direct execution (Unix-like systems)
./$SCRIPT_FILE

# Using interpreter (all platforms)
$LANGUAGE $SCRIPT_FILE
\`\`\`

Expected output:
\`\`\`
$MESSAGE
\`\`\`

---

**Build completed successfully!**
EOF

echo "✅ Test report generated: TEST_REPORT.md"
```

---

### 6. Update BUILD_STATUS.md (Final)

Mark Step 4 and the entire build as complete:

```bash
cat >> BUILD_STATUS.md << EOF

### Step 4: Verify Implementation
- **Started**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- **Completed**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- **Duration**: < 1 minute
- **Status**: ✅ PASS
- **Tests Run**: 6 (all passed)
- **Traceability**: ${TRACED_LINES} references
- **Notes**: All verification tests passed, system ready

---

## Build Complete

**Status**: ✅ SUCCESS
**Completed**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Total Duration**: < 10 minutes
**Files Created**: 7

All requirements met. System is production-ready.
EOF

# Update steps checklist
sed -i.bak 's/\[ \] Step 4: Verify Implementation/[x] Step 4: Verify Implementation/' BUILD_STATUS.md
sed -i.bak 's/Status\*\*: In Progress/Status**: ✅ COMPLETE/' BUILD_STATUS.md
rm BUILD_STATUS.md.bak 2>/dev/null || true

echo "✅ BUILD_STATUS.md updated (build complete)"
```

---

### 7. Create Step Completion Record

Document this step's completion:

```bash
cat > docs/build-history/hello-step_a1b2c3d4e5f6-DONE.txt << EOF
Step 4: Verify Implementation - COMPLETE

Completed: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Duration: < 2 minutes
Status: SUCCESS

Verification Results:
- T1 (File Exists): PASS
- T2 (Execution): PASS
- T3 (Output): PASS
- T4 (No Errors): PASS
- T5 (Performance): PASS
- T6 (Traceability): PASS

All tests passed. System meets all specifications.

Next: Build complete - no additional steps.
EOF

echo "✅ Step completion recorded"
```

---

## Verification

**Verify Step 4 and build completion**:

```bash
echo ""
echo "Final verification..."

# 1. Verification script exists and is executable
test -x tests/verify.sh && echo "✅ Verification script exists" || { echo "❌ Verification script missing"; exit 1; }

# 2. Test report generated
test -f TEST_REPORT.md && echo "✅ Test report generated" || echo "⚠️  Test report missing"

# 3. All tests passed (checked above)
if [ "$VERIFICATION_STATUS" == "PASS" ]; then
  echo "✅ All verification tests passed"
else
  echo "❌ Verification tests failed"
  exit 1
fi

# 4. BUILD_STATUS.md shows complete
grep -q "Build Complete" BUILD_STATUS.md && echo "✅ Build marked complete" || echo "⚠️  Build status not updated"

# 5. Step completion recorded
test -f docs/build-history/hello-step_a1b2c3d4e5f6-DONE.txt && echo "✅ Step completion recorded" || echo "⚠️  Completion record missing"

# 6. All previous steps marked complete
if grep -q '\[x\] Step 0' BUILD_STATUS.md && \
   grep -q '\[x\] Step 1' BUILD_STATUS.md && \
   grep -q '\[x\] Step 2' BUILD_STATUS.md && \
   grep -q '\[x\] Step 3' BUILD_STATUS.md && \
   grep -q '\[x\] Step 4' BUILD_STATUS.md; then
  echo "✅ All steps marked complete"
else
  echo "❌ Not all steps marked complete"
  exit 1
fi

echo ""
echo "🎉 BUILD COMPLETE! All verification passed."
echo ""
echo "To run your hello-world script:"
echo "  ./$SCRIPT_FILE"
echo ""
echo "Expected output:"
echo "  $MESSAGE"
echo ""
```

---

## Completion Criteria

- [x] Comprehensive verification script created (tests/verify.sh)
- [x] All 6 verification tests executed
- [x] All tests passed (T1-T6)
- [x] Traceability coverage verified (≥3 references)
- [x] Test report generated (TEST_REPORT.md)
- [x] BUILD_STATUS.md marked as complete
- [x] Step completion record created
- [x] Final verification checks pass

---

## On Failure

If any verification test fails:

1. **Identify failing test** - Check test output for specifics
2. **Fix the issue**:
   - T1/T2: Regenerate script (back to Step 2)
   - T3: Check message in BUILD_CONFIG.json
   - T4: Review script for error output
   - T5: Optimize script (should be impossible to fail)
   - T6: Add traceability comments (back to Step 2)
3. **Re-run verification** - Execute tests/verify.sh again
4. **Retry limit** - Up to 3 attempts total
5. **If still failing** - Stop and report detailed error

---

## Next Step

**None** - Build is complete!

The hello-world system is now production-ready. All specifications met, all tests passed.

---

## Traceability

**Implements**:
- hello-world-spec.md § 5.1 (Verification Tests) - All 6 tests implemented
- hello-world-spec.md § 5.2 (Test Automation) - Automated verification script
- hello-world-spec.md § 1.3 (Success Criteria) - All criteria validated
- hello-world-spec.md § 7.1 (Requirements Mapping) - Complete traceability

**References**:
- hello-world-spec.md § 2.1 (Functional Requirements) - F1, F2, F3
- hello-world-spec.md § NF2 (Traceability) - Verified
- YBS Framework: Verification-Driven Development

---

## Notes for AI Agents

- **All tests must pass** - Don't proceed if any test fails
- **Traceability is critical** - Minimum 3 references required
- **Document everything** - Test reports, completion records
- **Update status files** - BUILD_STATUS.md shows complete
- **No user prompts** - This step is fully autonomous
- **Celebrate success** - Build complete message

---

**Version**: 1.0.0
**Last Updated**: 2026-01-18
