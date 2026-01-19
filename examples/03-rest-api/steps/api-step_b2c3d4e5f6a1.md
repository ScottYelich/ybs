# Step 5: Integration Test with Real API

**Step ID**: b2c3d4e5f6a1
**System**: rest-api-client
**Version**: 1.0.0
**Estimated Time**: 5 minutes
**Depends On**: Step 4 (Run Tests and Verify Coverage)

---

## Context

**What**: Test the client against the real JSONPlaceholder API to verify end-to-end functionality

**Why**: Unit tests use mocks; integration tests verify real-world behavior with actual API

**Implements**:
- rest-api-client-spec.md § 5.2 I1 (Real API Call - Posts)
- rest-api-client-spec.md § 5.2 I2 (Real API Call - Single Post)
- rest-api-client-spec.md § 5.2 I3 (Real API Call - Users)

---

## Prerequisites

- ✅ Step 4 complete (unit tests passing, coverage ≥60%)
- ✅ Client script executable
- ✅ Internet connection available
- ✅ JSONPlaceholder API accessible

---

## Instructions

### 1. Check API Availability

Verify JSONPlaceholder API is reachable:

```bash
curl -s -o /dev/null -w "%{http_code}" {{CONFIG:api_base_url}}/posts/1
# Expected: 200
```

**If returns 000 or other error**:
- Check internet connection
- Verify API URL in BUILD_CONFIG.json
- Try alternative: curl https://jsonplaceholder.typicode.com/posts/1

---

### 2. Test Fetch All Posts (I1)

**Implements**: rest-api-client-spec.md § 5.2 I1

```bash
# Run client to fetch all posts
./api_client.* posts > integration_test_posts_all.json

# Verify output
if [ -s integration_test_posts_all.json ]; then
  echo "✅ I1 PASSED: Fetched posts list"
else
  echo "❌ I1 FAILED: No output"
  exit 1
fi

# Check JSON validity
if jq empty integration_test_posts_all.json 2>/dev/null; then
  echo "✅ Valid JSON output"
else
  echo "❌ Invalid JSON output"
  exit 1
fi

# Check array length (should be 100 posts)
POST_COUNT=$(jq 'length' integration_test_posts_all.json)
echo "Posts fetched: $POST_COUNT"

if [ "$POST_COUNT" -eq 100 ]; then
  echo "✅ Correct post count (100)"
else
  echo "⚠️  Unexpected post count: $POST_COUNT (expected 100)"
fi
```

---

### 3. Test Fetch Single Post (I2)

**Implements**: rest-api-client-spec.md § 5.2 I2

```bash
# Run client to fetch post ID 1
./api_client.* posts 1 > integration_test_post_1.json

# Verify output
if [ -s integration_test_post_1.json ]; then
  echo "✅ I2 PASSED: Fetched single post"
else
  echo "❌ I2 FAILED: No output"
  exit 1
fi

# Check it's a single object (not array)
if jq -e '.id' integration_test_post_1.json > /dev/null; then
  echo "✅ Single post object"
else
  echo "❌ Not a single post object"
  exit 1
fi

# Verify ID is 1
POST_ID=$(jq -r '.id' integration_test_post_1.json)
if [ "$POST_ID" -eq 1 ]; then
  echo "✅ Correct post ID (1)"
else
  echo "❌ Wrong post ID: $POST_ID"
  exit 1
fi

# Display post title
POST_TITLE=$(jq -r '.title' integration_test_post_1.json)
echo "Post 1 title: $POST_TITLE"
```

---

### 4. Test Fetch Users (I3)

**Implements**: rest-api-client-spec.md § 5.2 I3

```bash
# Run client to fetch all users
./api_client.* users > integration_test_users.json

# Verify output
if [ -s integration_test_users.json ]; then
  echo "✅ I3 PASSED: Fetched users list"
else
  echo "❌ I3 FAILED: No output"
  exit 1
fi

# Check array length (should be 10 users)
USER_COUNT=$(jq 'length' integration_test_users.json)
echo "Users fetched: $USER_COUNT"

if [ "$USER_COUNT" -eq 10 ]; then
  echo "✅ Correct user count (10)"
else
  echo "⚠️  Unexpected user count: $USER_COUNT (expected 10)"
fi

# Display first user name
USER_NAME=$(jq -r '.[0].name' integration_test_users.json)
echo "First user: $USER_NAME"
```

---

### 5. Test Error Handling

Test 404 error handling:

```bash
# Try to fetch non-existent post
./api_client.* posts 99999 2> integration_test_error.txt
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "✅ Error handling: Non-zero exit code on 404"
else
  echo "❌ Error handling: Should exit with error on 404"
fi

# Check error message
if grep -q "Error" integration_test_error.txt; then
  echo "✅ Error message displayed"
else
  echo "❌ No error message"
fi
```

---

### 6. Test Todos Endpoint

Test additional endpoint:

```bash
# Fetch first 5 todos
./api_client.* todos | jq '.[0:5]' > integration_test_todos.json

# Verify
TODO_COUNT=$(jq 'length' integration_test_todos.json)
echo "Todos fetched: $TODO_COUNT"
```

---

### 7. Document Integration Test Results

Update BUILD_STATUS.md:

```markdown
## Integration Tests

**Date**: $(date '+%Y-%m-%d %H:%M:%S')
**API**: {{CONFIG:api_base_url}}

### Results
- ✅ I1: Fetch Posts (100 items)
- ✅ I2: Fetch Single Post (ID 1)
- ✅ I3: Fetch Users (10 items)
- ✅ Error Handling (404 tested)
- ✅ Additional: Todos endpoint working

**Status**: All integration tests PASSED
```

---

### 8. Clean Up Test Files (Optional)

```bash
# Keep test outputs for review
ls -lh integration_test_*.json integration_test_error.txt
```

---

## Verification

**This step is complete when:**
- ✅ I1: Fetched all posts (100 items)
- ✅ I2: Fetched single post by ID
- ✅ I3: Fetched all users (10 items)
- ✅ Error handling tested (404 returns error)
- ✅ JSON output valid for all tests
- ✅ BUILD_STATUS.md updated with results
- ✅ Integration test outputs saved

**Verification Commands**:
```bash
# Check all integration test files exist
[ -f integration_test_posts_all.json ] && echo "✅ Posts test" || echo "❌ Missing"
[ -f integration_test_post_1.json ] && echo "✅ Single post test" || echo "❌ Missing"
[ -f integration_test_users.json ] && echo "✅ Users test" || echo "❌ Missing"

# Verify BUILD_STATUS.md updated
grep -q "Integration Tests" BUILD_STATUS.md && echo "✅ Status updated" || echo "❌ Not updated"
```

**Retry Limit**: 3 attempts

---

## Troubleshooting

**Problem**: No internet connection
**Solution**: Connect to internet or skip integration tests (document why)

**Problem**: JSONPlaceholder API down
**Solution**: Check https://jsonplaceholder.typicode.com/, retry later, or use alternative API

**Problem**: Timeout errors
**Solution**: Increase timeout in BUILD_CONFIG.json, check network speed

**Problem**: jq not installed
**Solution**: Install jq or manually verify JSON output

**Problem**: Permission denied executing script
**Solution**: chmod +x api_client.*

---

## Alternative If No Internet

If no internet connection available:

1. Document in BUILD_STATUS.md: "Integration tests skipped - no internet"
2. Mark step as CONDITIONAL PASS
3. Note: Unit tests with mocks still validate logic
4. Integration tests should be run when internet available

**This is acceptable** - unit tests are sufficient for initial validation.

---

## Next Step

**Step 6**: Final Verification

---

## References

- **Specification**: [../specs/rest-api-client-spec.md](../specs/rest-api-client-spec.md) § 5.2
- **YBS Framework**: [../../framework/methodology/executing-builds.md](../../framework/methodology/executing-builds.md)
- **JSONPlaceholder**: https://jsonplaceholder.typicode.com

---

**End of Step 5**
