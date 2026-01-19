# REST API Client - Technical Specification

**System**: rest-api-client
**Version**: 1.0.0
**Last Updated**: 2026-01-18
**Status**: Draft

---

## 1. Overview

### 1.1 Purpose

Build a simple command-line REST API client that fetches data from JSONPlaceholder (a free REST API service) and displays JSON responses.

**Why this matters**:
- Demonstrates HTTP/REST API interaction patterns
- Shows error handling and network operations
- Introduces JSON parsing and display
- Provides template for API integration tools
- Example of real-world I/O operations

### 1.2 Scope

**In Scope**:
- HTTP GET requests to JSONPlaceholder API
- JSON response parsing and display
- Basic error handling (network errors, HTTP errors)
- Multiple endpoint support (posts, users, todos, comments)
- Pretty-printed JSON output
- Command-line interface

**Out of Scope**:
- Authentication/authorization
- POST/PUT/DELETE operations (write operations)
- Rate limiting or retry logic
- Caching mechanisms
- Configuration files
- Advanced CLI features (flags, subcommands)
- Multiple API provider support

### 1.3 Success Criteria

✅ Client can fetch data from JSONPlaceholder API
✅ JSON responses are properly parsed and displayed
✅ Error handling for network and HTTP errors
✅ Support for at least 3 different endpoints
✅ Pretty-printed JSON output
✅ All code has traceability comments
✅ Minimum 60% test coverage

---

## 2. Requirements

### 2.1 Functional Requirements

**F1: Fetch Posts**
- **ID**: F1
- **Priority**: CRITICAL
- **Description**: Client MUST fetch posts from /posts endpoint
- **Details**:
  - GET https://jsonplaceholder.typicode.com/posts
  - Parse JSON response
  - Display all posts or single post by ID
  - Handle list and single-item endpoints

**F2: Fetch Users**
- **ID**: F2
- **Priority**: HIGH
- **Description**: Client MUST fetch users from /users endpoint
- **Details**:
  - GET https://jsonplaceholder.typicode.com/users
  - Parse JSON response
  - Display user information
  - Support listing all users or fetching by ID

**F3: Fetch Todos**
- **ID**: F3
- **Priority**: HIGH
- **Description**: Client MUST fetch todos from /todos endpoint
- **Details**:
  - GET https://jsonplaceholder.typicode.com/todos
  - Parse JSON response
  - Display todo items
  - Support filtering by user ID (optional)

**F4: JSON Display**
- **ID**: F4
- **Priority**: CRITICAL
- **Description**: Client MUST display JSON responses in readable format
- **Details**:
  - Pretty-print JSON with indentation
  - Use 2-space or 4-space indentation
  - Handle nested JSON objects
  - Colorized output (optional enhancement)

**F5: Error Handling**
- **ID**: F5
- **Priority**: CRITICAL
- **Description**: Client MUST handle errors gracefully
- **Details**:
  - Network connection errors
  - HTTP 4xx/5xx errors
  - Invalid JSON responses
  - Timeout errors
  - Display user-friendly error messages

**F6: Command-Line Interface**
- **ID**: F6
- **Priority**: HIGH
- **Description**: Client SHOULD accept command-line arguments
- **Details**:
  - Endpoint type (posts/users/todos)
  - Optional resource ID
  - Example: `client posts` or `client posts 1`

### 2.2 Non-Functional Requirements

**NF1: Simplicity**
- **ID**: NF1
- **Priority**: HIGH
- **Description**: Code SHOULD be clear and educational
- **Details**:
  - Total lines of code: < 300
  - Single file or simple module structure
  - Minimal external dependencies
  - Clear, readable code

**NF2: Traceability**
- **ID**: NF2
- **Priority**: CRITICAL
- **Description**: Code MUST link back to this specification
- **Details**:
  - File headers with spec reference
  - Function-level traceability comments
  - Minimum 80% traceability coverage

**NF3: Test Coverage**
- **ID**: NF3
- **Priority**: CRITICAL
- **Description**: Code MUST have adequate test coverage
- **Details**:
  - Minimum 60% line coverage (REQUIRED)
  - Target 80% line coverage (RECOMMENDED)
  - 100% coverage for critical paths (error handling, JSON parsing)
  - Mock HTTP responses for testing

**NF4: Performance**
- **ID**: NF4
- **Priority**: MEDIUM
- **Description**: Client SHOULD respond quickly
- **Details**:
  - HTTP request timeout: 10 seconds
  - Total execution time: < 15 seconds
  - Minimal memory footprint

**NF5: Maintainability**
- **ID**: NF5
- **Priority**: MEDIUM
- **Description**: Code SHOULD be easy to extend
- **Details**:
  - Clear separation of concerns
  - Easy to add new endpoints
  - Documented functions/methods
  - Standard language idioms

---

## 3. Configuration

### 3.1 Build Configuration (Step 0)

The following configuration items will be collected in Step 0:

**C1: Build Name**
- **CONFIG**: `build_name`
- **Type**: text
- **Default**: `demo`
- **Question**: "What should we name this build?"
- **Purpose**: Directory name for build output
- **Validation**: Alphanumeric, hyphens, underscores only

**C2: Programming Language**
- **CONFIG**: `language`
- **Type**: choice[python,javascript,ruby]
- **Default**: `python`
- **Question**: "Which programming language?"
- **Purpose**: Determines implementation language
- **Note**: All languages have good HTTP/JSON libraries

**C3: API Base URL**
- **CONFIG**: `api_base_url`
- **Type**: text
- **Default**: `https://jsonplaceholder.typicode.com`
- **Question**: "API base URL?"
- **Purpose**: Allows testing with different API endpoints
- **Note**: Default is JSONPlaceholder

**C4: Default Endpoint**
- **CONFIG**: `default_endpoint`
- **Type**: choice[posts,users,todos,comments]
- **Default**: `posts`
- **Question**: "Default endpoint to query?"
- **Purpose**: Determines which endpoint to use if none specified

**C5: JSON Indentation**
- **CONFIG**: `json_indent`
- **Type**: choice[2,4]
- **Default**: `2`
- **Question**: "JSON output indentation (spaces)?"
- **Purpose**: Pretty-print formatting

**C6: Request Timeout**
- **CONFIG**: `timeout`
- **Type**: number
- **Default**: `10`
- **Question**: "HTTP request timeout (seconds)?"
- **Purpose**: Prevent hanging on slow connections
- **Validation**: 1-60 seconds

### 3.2 Configuration File Structure

```json
{
  "system": "rest-api-client",
  "version": "1.0.0",
  "build_name": "demo",
  "language": "python",
  "api_base_url": "https://jsonplaceholder.typicode.com",
  "default_endpoint": "posts",
  "json_indent": 2,
  "timeout": 10
}
```

---

## 4. Architecture

### 4.1 Component Overview

**Single Component**: REST API Client Script

```
rest-api-client/builds/BUILD_NAME/
├── api_client.{ext}         # Main client script
├── test_api_client.{ext}    # Test suite
└── verify.sh                # Verification script
```

### 4.2 API Endpoints

**JSONPlaceholder Endpoints**:

| Endpoint | URL | Description |
|----------|-----|-------------|
| Posts | /posts | Blog posts (100 items) |
| Users | /users | User accounts (10 items) |
| Todos | /todos | Todo items (200 items) |
| Comments | /comments | Post comments (500 items) |

**Single Item Access**:
- `/posts/1` - Get post with ID 1
- `/users/5` - Get user with ID 5
- `/todos/42` - Get todo with ID 42

### 4.3 Implementation Pattern

**Python Implementation** (using requests library):

```python
#!/usr/bin/env python3
# Implements: rest-api-client-spec.md § 2.1 F1-F6

import sys
import json
import requests

API_BASE = "https://jsonplaceholder.typicode.com"
TIMEOUT = 10

def fetch_data(endpoint, item_id=None):
    """
    Fetch data from API endpoint.
    Implements: rest-api-client-spec.md § 2.1 F1, F2, F3
    """
    try:
        url = f"{API_BASE}/{endpoint}"
        if item_id:
            url += f"/{item_id}"

        response = requests.get(url, timeout=TIMEOUT)
        response.raise_for_status()  # F5: Error handling

        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

def display_json(data, indent=2):
    """
    Display JSON data with pretty printing.
    Implements: rest-api-client-spec.md § 2.1 F4
    """
    print(json.dumps(data, indent=indent))

def main():
    """
    Main CLI entry point.
    Implements: rest-api-client-spec.md § 2.1 F6
    """
    if len(sys.argv) < 2:
        print("Usage: api_client.py <endpoint> [id]")
        print("Endpoints: posts, users, todos, comments")
        sys.exit(1)

    endpoint = sys.argv[1]
    item_id = sys.argv[2] if len(sys.argv) > 2 else None

    data = fetch_data(endpoint, item_id)
    display_json(data)

if __name__ == "__main__":
    main()
```

**JavaScript (Node.js) Implementation**:

```javascript
#!/usr/bin/env node
// Implements: rest-api-client-spec.md § 2.1 F1-F6

const https = require('https');

const API_BASE = 'jsonplaceholder.typicode.com';
const TIMEOUT = 10000;

// Implements: rest-api-client-spec.md § 2.1 F1, F2, F3
function fetchData(endpoint, itemId = null) {
  const path = itemId ? `/${endpoint}/${itemId}` : `/${endpoint}`;

  return new Promise((resolve, reject) => {
    const req = https.get({
      hostname: API_BASE,
      path: path,
      timeout: TIMEOUT
    }, (res) => {
      let data = '';

      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        if (res.statusCode !== 200) {
          reject(new Error(`HTTP ${res.statusCode}`));
        } else {
          resolve(JSON.parse(data));
        }
      });
    });

    req.on('error', reject);
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });
  });
}

// Implements: rest-api-client-spec.md § 2.1 F4
function displayJson(data, indent = 2) {
  console.log(JSON.stringify(data, null, indent));
}

// Implements: rest-api-client-spec.md § 2.1 F6
async function main() {
  const args = process.argv.slice(2);

  if (args.length < 1) {
    console.error('Usage: api_client.js <endpoint> [id]');
    console.error('Endpoints: posts, users, todos, comments');
    process.exit(1);
  }

  const [endpoint, itemId] = args;

  try {
    const data = await fetchData(endpoint, itemId);
    displayJson(data);
  } catch (error) {
    // Implements: rest-api-client-spec.md § 2.1 F5
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
}

main();
```

### 4.4 Error Handling Strategy

**Error Types**:
1. **Network Errors**: Connection refused, DNS failure, timeout
2. **HTTP Errors**: 4xx (client errors), 5xx (server errors)
3. **Parse Errors**: Invalid JSON in response
4. **Usage Errors**: Invalid command-line arguments

**Error Display Format**:
```
Error: Connection timeout after 10 seconds
Error: HTTP 404 - Resource not found
Error: Invalid JSON in response
Error: Unknown endpoint 'invalid'
```

---

## 5. Test Requirements

### 5.1 Unit Tests

**T1: Fetch Posts - Success**
- **ID**: T1
- **Type**: Unit test
- **Description**: Verify posts endpoint returns valid data
- **Mock**: GET /posts returns array of posts
- **Expected**: Returns list of post objects with id, title, body

**T2: Fetch Single Post - Success**
- **ID**: T2
- **Type**: Unit test
- **Description**: Verify single post fetch by ID
- **Mock**: GET /posts/1 returns single post
- **Expected**: Returns single post object

**T3: Fetch Users - Success**
- **ID**: T3
- **Type**: Unit test
- **Description**: Verify users endpoint returns valid data
- **Mock**: GET /users returns array of users
- **Expected**: Returns list of user objects

**T4: Network Error Handling**
- **ID**: T4
- **Type**: Unit test
- **Description**: Verify graceful handling of network errors
- **Mock**: Connection refused
- **Expected**: Error message displayed, exit code 1

**T5: HTTP 404 Handling**
- **ID**: T5
- **Type**: Unit test
- **Description**: Verify 404 error handling
- **Mock**: GET /posts/9999 returns 404
- **Expected**: Error message displayed, exit code 1

**T6: Timeout Handling**
- **ID**: T6
- **Type**: Unit test
- **Description**: Verify request timeout handling
- **Mock**: Request hangs beyond timeout
- **Expected**: Timeout error after configured seconds

**T7: Invalid JSON Handling**
- **ID**: T7
- **Type**: Unit test
- **Description**: Verify handling of malformed JSON
- **Mock**: Response with invalid JSON
- **Expected**: Parse error message, exit code 1

**T8: JSON Pretty-Print**
- **ID**: T8
- **Type**: Unit test
- **Description**: Verify JSON formatting
- **Mock**: Simple JSON object
- **Expected**: Properly indented JSON output

**T9: Command-Line Arguments**
- **ID**: T9
- **Type**: Unit test
- **Description**: Verify CLI argument parsing
- **Mock**: Various argument combinations
- **Expected**: Correct endpoint and ID extracted

**T10: Usage Help**
- **ID**: T10
- **Type**: Unit test
- **Description**: Verify help message on invalid usage
- **Mock**: No arguments provided
- **Expected**: Usage message displayed

### 5.2 Integration Tests

**I1: Real API Call - Posts**
- **ID**: I1
- **Type**: Integration test
- **Description**: Verify actual API call to JSONPlaceholder
- **Steps**:
  1. Execute client with 'posts' endpoint
  2. Verify HTTP 200 response
  3. Verify valid JSON returned
- **Expected**: Real posts data retrieved

**I2: Real API Call - Single Post**
- **ID**: I2
- **Type**: Integration test
- **Description**: Verify fetching single post
- **Steps**:
  1. Execute client with 'posts 1'
  2. Verify post ID 1 returned
- **Expected**: Single post object with id=1

**I3: Real API Call - Users**
- **ID**: I3
- **Type**: Integration test
- **Description**: Verify users endpoint
- **Steps**:
  1. Execute client with 'users'
  2. Verify array of 10 users
- **Expected**: 10 user objects returned

### 5.3 Coverage Requirements

**Minimum Coverage**: 60% line coverage (REQUIRED)
**Target Coverage**: 80% line coverage (RECOMMENDED)

**Critical Paths** (must be 100% covered):
- Error handling code
- JSON parsing
- HTTP request logic
- Timeout handling

---

## 6. Implementation Notes

### 6.1 Development Guidelines

**Code Style**:
- Follow language-standard conventions (PEP 8 for Python, Standard for JS)
- Use meaningful function/variable names
- Include traceability comments
- Handle errors explicitly (no silent failures)

**File Organization**:
```
builds/BUILD_NAME/
├── api_client.{ext}         # Main script
├── test_api_client.{ext}    # Tests with mocks
├── BUILD_CONFIG.json        # Configuration (from Step 0)
├── BUILD_STATUS.md          # Build status tracking
├── coverage.txt             # Coverage report
└── verify.sh                # Verification script
```

**Traceability Format**:
```python
# Implements: rest-api-client-spec.md § 2.1 F1 (Fetch Posts)
# Implements: rest-api-client-spec.md § 2.1 F5 (Error Handling)
```

### 6.2 Common Pitfalls

❌ **No error handling** - Network errors will crash program
❌ **Missing timeout** - Requests can hang indefinitely
❌ **Invalid JSON handling** - Parse errors not caught
❌ **No traceability** - Code doesn't reference spec
❌ **Low test coverage** - Critical paths untested
❌ **Hardcoded values** - API URL should use config

### 6.3 Dependencies

**Python**:
- `requests` library (external dependency)
- `pytest` for testing
- `pytest-mock` for mocking
- `pytest-cov` for coverage

**JavaScript (Node.js)**:
- Built-in `https` module (no external deps for client)
- `jest` for testing (external)
- Mock HTTP responses in tests

**Ruby**:
- `net/http` (built-in)
- `json` (built-in)
- `rspec` for testing (external)
- `webmock` for HTTP mocking

---

## 7. Traceability

### 7.1 Requirements Mapping

| Requirement | Implementation | Test |
|-------------|----------------|------|
| F1: Fetch Posts | fetch_data('posts') | T1, T2, I1, I2 |
| F2: Fetch Users | fetch_data('users') | T3, I3 |
| F3: Fetch Todos | fetch_data('todos') | T3 |
| F4: JSON Display | display_json() | T8 |
| F5: Error Handling | try/catch blocks | T4, T5, T6, T7 |
| F6: CLI Interface | main() arg parsing | T9, T10 |
| NF2: Traceability | File headers, comments | Code review |
| NF3: Test Coverage | Test suite | Coverage report ≥60% |

### 7.2 Dependencies

**External APIs**: JSONPlaceholder (https://jsonplaceholder.typicode.com)
**Framework**: YBS Framework v2.0.0+
**Runtime**:
- Python 3.6+ with `requests` library
- Node.js 12+ (built-in modules)
- Ruby 2.5+ (built-in modules)

---

## 8. Version History

- **1.0.0** (2026-01-18): Initial specification for REST API client example

---

## 9. References

- **JSONPlaceholder API**: https://jsonplaceholder.typicode.com
- **YBS Framework**: [../../framework/README.md](../../framework/README.md)
- **Writing Specs Guide**: [../../framework/methodology/writing-specs.md](../../framework/methodology/writing-specs.md)
- **Testing Guide**: [../../framework/methodology/executing-builds.md](../../framework/methodology/executing-builds.md)

**API Documentation**:
- [JSONPlaceholder Guide](https://jsonplaceholder.typicode.com/guide/)
- [GitHub Repository](https://github.com/typicode/jsonplaceholder)

---

**End of Specification**
