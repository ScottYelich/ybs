# Step 6: Final Verification

**Step ID**: c3d4e5f6a1b2
**System**: rest-api-client
**Version**: 1.0.0
**Estimated Time**: 5 minutes
**Depends On**: Step 5 (Integration Test)

---

## Context

**What**: Perform final checks to ensure all requirements met and build is complete

**Why**: Final validation before marking build as DONE

**Implements**: rest-api-client-spec.md § 1.3 (Success Criteria)

---

## Prerequisites

- ✅ Step 5 complete (integration tests passing)
- ✅ All previous steps completed
- ✅ No blocking issues

---

## Instructions

### 1. Verify All Success Criteria

Check each success criterion from spec:

#### ✅ **Client can fetch data from JSONPlaceholder API**
```bash
./api_client.* posts 1 && echo "✅ PASS" || echo "❌ FAIL"
```

#### ✅ **JSON responses are properly parsed and displayed**
```bash
./api_client.* posts 1 | jq empty && echo "✅ PASS" || echo "❌ FAIL"
```

#### ✅ **Error handling for network and HTTP errors**
```bash
# This should fail gracefully
./api_client.* posts 99999 2>&1 | grep -q "Error" && echo "✅ PASS" || echo "❌ FAIL"
```

#### ✅ **Support for at least 3 different endpoints**
```bash
# Test posts
./api_client.* posts 1 > /dev/null && echo "✅ posts endpoint works"

# Test users
./api_client.* users 1 > /dev/null && echo "✅ users endpoint works"

# Test todos
./api_client.* todos 1 > /dev/null && echo "✅ todos endpoint works"
```

#### ✅ **Pretty-printed JSON output**
```bash
# Check for indentation in output
./api_client.* posts 1 | grep -q "  \"" && echo "✅ PASS (indented)" || echo "❌ FAIL"
```

#### ✅ **All code has traceability comments**
```bash
# Check for spec references
grep -c "Implements: rest-api-client-spec.md" api_client.* && echo "✅ PASS" || echo "❌ FAIL"
```

#### ✅ **Minimum 60% test coverage**
```bash
# Check coverage from Step 4
grep -q "6[0-9]%" coverage.txt || grep -q "[7-9][0-9]%" coverage.txt && echo "✅ PASS (≥60%)" || echo "❌ FAIL (<60%)"
```

---

### 2. Verify All Files Present

Check that all expected files were created:

```bash
echo "Checking files..."

[ -f BUILD_CONFIG.json ] && echo "✅ BUILD_CONFIG.json" || echo "❌ Missing"
[ -f BUILD_STATUS.md ] && echo "✅ BUILD_STATUS.md" || echo "❌ Missing"
[ -f api_client.* ] && echo "✅ api_client script" || echo "❌ Missing"
[ -f test_* ] || [ -f *_spec.rb ] || [ -f *.test.js ] && echo "✅ Test file" || echo "❌ Missing"
[ -f coverage.txt ] || [ -d coverage/ ] && echo "✅ Coverage report" || echo "❌ Missing"
[ -f integration_test_*.json ] && echo "✅ Integration test outputs" || echo "❌ Missing"
```

---

### 3. Check Traceability Coverage

Verify traceability comments:

```bash
# Count traceability comments in source
TRACE_COUNT=$(grep -c "Implements: rest-api-client-spec.md" api_client.*)

echo "Traceability comments found: $TRACE_COUNT"

if [ "$TRACE_COUNT" -ge 5 ]; then
  echo "✅ Adequate traceability (≥5 references)"
else
  echo "⚠️  Low traceability (<5 references)"
fi
```

**Target**: ≥80% of functions/classes have traceability comments

---

### 4. Run Final Smoke Tests

Quick end-to-end tests:

```bash
echo "Running smoke tests..."

# Test 1: Fetch and parse posts
echo "Test 1: Fetch posts..."
./api_client.* posts | jq '.[0:3]' && echo "✅ PASS" || echo "❌ FAIL"

# Test 2: Fetch single item
echo "Test 2: Fetch single post..."
./api_client.* posts 1 | jq '.id' && echo "✅ PASS" || echo "❌ FAIL"

# Test 3: Invalid endpoint handling
echo "Test 3: Invalid endpoint..."
./api_client.* invalid 2>&1 | grep -q "Invalid endpoint" && echo "✅ PASS" || echo "❌ FAIL"

# Test 4: No arguments (usage message)
echo "Test 4: Usage message..."
./api_client.* 2>&1 | grep -q "Usage:" && echo "✅ PASS" || echo "❌ FAIL"
```

---

### 5. Update BUILD_STATUS.md to COMPLETE

Update the status file:

```markdown
# Build Status: {{CONFIG:build_name}}

**System**: rest-api-client
**Started**: [original date]
**Completed**: $(date '+%Y-%m-%d %H:%M:%S')
**Language**: {{CONFIG:language}}
**Status**: ✅ COMPLETE

---

## Steps

- [x] Step 0: Build Configuration
- [x] Step 1: Initialize Project Structure
- [x] Step 2: Create Main Client Script
- [x] Step 3: Create Test Suite
- [x] Step 4: Run Tests and Verify Coverage
- [x] Step 5: Integration Test
- [x] Step 6: Final Verification

---

## Final Verification Results

**Date**: $(date '+%Y-%m-%d %H:%M:%S')

### Success Criteria
- ✅ Client can fetch data from JSONPlaceholder API
- ✅ JSON responses properly parsed and displayed
- ✅ Error handling for network and HTTP errors
- ✅ Support for 3+ different endpoints (posts, users, todos)
- ✅ Pretty-printed JSON output
- ✅ All code has traceability comments
- ✅ Test coverage ≥60%

### File Inventory
- ✅ BUILD_CONFIG.json
- ✅ BUILD_STATUS.md
- ✅ api_client.* (main script)
- ✅ test_* / *_spec.rb / *.test.js (tests)
- ✅ coverage.txt or coverage/ (coverage report)
- ✅ integration_test_*.json (integration test outputs)

### Test Results Summary
- Unit Tests: All passed
- Test Coverage: X% (≥60% requirement met)
- Integration Tests: All passed
- Smoke Tests: All passed

---

## Build Complete

**Status**: ✅ BUILD SUCCESSFUL

All requirements met. System ready for use.

**To use the client**:
```bash
./api_client.* posts      # List all posts
./api_client.* posts 1    # Get post ID 1
./api_client.* users      # List all users
./api_client.* todos      # List all todos
```
```

---

### 6. Create DONE Marker

Create a DONE file to mark completion:

```bash
cat > DONE.txt << EOF
Build Complete: rest-api-client
Date: $(date '+%Y-%m-%d %H:%M:%S')
Build Name: {{CONFIG:build_name}}
Language: {{CONFIG:language}}
Status: SUCCESS

All steps completed successfully.
All tests passing.
Coverage ≥60%.
All requirements met.
EOF

echo "✅ DONE.txt created"
```

---

### 7. Display Summary

Show final summary to user:

```bash
echo ""
echo "════════════════════════════════════════════════"
echo "  REST API Client - Build Complete"
echo "════════════════════════════════════════════════"
echo ""
echo "Build Name: {{CONFIG:build_name}}"
echo "Language: {{CONFIG:language}}"
echo "API: {{CONFIG:api_base_url}}"
echo ""
echo "Files Created:"
find . -type f -name "*.py" -o -name "*.js" -o -name "*.rb" -o -name "*.json" -o -name "*.txt" -o -name "*.md" | sort
echo ""
echo "Usage Examples:"
echo "  ./api_client.* posts       # List all posts"
echo "  ./api_client.* posts 1     # Get post ID 1"
echo "  ./api_client.* users 5     # Get user ID 5"
echo ""
echo "Status: ✅ BUILD SUCCESSFUL"
echo "════════════════════════════════════════════════"
```

---

## Verification

**This step is complete when:**
- ✅ All success criteria verified
- ✅ All files present and correct
- ✅ Traceability coverage adequate
- ✅ Smoke tests all pass
- ✅ BUILD_STATUS.md marked COMPLETE
- ✅ DONE.txt created
- ✅ Summary displayed

**Verification Commands**:
```bash
# Check BUILD_STATUS.md shows complete
grep -q "✅ COMPLETE" BUILD_STATUS.md && echo "✅ Status complete" || echo "❌ Not complete"

# Check DONE.txt exists
[ -f DONE.txt ] && echo "✅ DONE marker" || echo "❌ Missing"

# Final smoke test
./api_client.* posts 1 > /dev/null && echo "✅ Client works" || echo "❌ Client broken"
```

**Retry Limit**: 3 attempts

---

## Troubleshooting

**Problem**: Some success criteria fail
**Solution**: Go back to relevant step, fix issue, re-verify

**Problem**: Traceability coverage low
**Solution**: Add missing traceability comments to source

**Problem**: Smoke tests fail
**Solution**: Debug specific failure, fix code, re-test

---

## Build Complete

**Congratulations!** The REST API client build is complete.

The client:
- Fetches data from JSONPlaceholder API
- Supports multiple endpoints (posts, users, todos, comments)
- Handles errors gracefully
- Pretty-prints JSON output
- Has ≥60% test coverage
- Passes all integration tests

---

## Next Steps (Optional)

After build completion, consider:
- Testing with other JSONPlaceholder endpoints (comments, albums, photos)
- Adding command-line flags (--format, --verbose, --timeout)
- Implementing caching
- Adding support for POST/PUT/DELETE methods
- Creating a package/distribution

**Note**: These are out of scope for v1.0 but could be future enhancements.

---

## References

- **Specification**: [../specs/rest-api-client-spec.md](../specs/rest-api-client-spec.md) § 1.3
- **YBS Framework**: [../../framework/methodology/executing-builds.md](../../framework/methodology/executing-builds.md)

---

**End of Step 6 - Build Complete!**
