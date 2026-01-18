# Testing BASE Specification

**System**: [System Name]
**Version**: 1.0.0
**Last Updated**: [YYYY-MM-DD]

## Overview

This BASE spec defines **system-wide testing standards** including test infrastructure, tools, coverage requirements, and testing patterns.

## Test Infrastructure

### Test Frameworks

| Type | Framework | Version | Purpose |
|------|-----------|---------|---------|
| Unit Tests | [Framework] | [Version] | Testing individual components |
| Integration Tests | [Framework] | [Version] | Testing component interactions |
| E2E Tests | [Framework] | [Version] | Testing full user workflows |
| Accessibility Tests | [Framework] | [Version] | WCAG compliance testing |

### Test Environment

**Local Development**:
- Run tests before commit
- Fast feedback (< 5 seconds for unit tests)
- Mock external dependencies

**CI/CD Pipeline**:
- Run full test suite on every commit
- Fail build if tests fail
- Report coverage

**Staging Environment**:
- Mirror production configuration
- Use production-like data (anonymized)
- Run E2E tests before deployment

## Coverage Requirements

### Target Coverage

| Type | Target | Minimum | Critical Paths |
|------|--------|---------|----------------|
| Unit Tests | 80% | 70% | 100% |
| Integration Tests | 60% | 50% | 90% |
| E2E Tests | Key workflows | N/A | 100% |

### What to Test

**Always Test**:
- Business logic
- Data validation
- Error handling
- Edge cases
- Security-sensitive code

**Optional Testing**:
- Simple getters/setters
- Framework code
- Third-party libraries

## Test Naming Convention

```
test_[functionality]_[scenario]_[expectedResult]

Examples:
- test_login_validCredentials_returnsToken
- test_saveFile_readOnlyDirectory_throwsError
- test_calculateTotal_emptyCart_returnsZero
```

## Test Structure (AAA Pattern)

```
// Arrange: Set up test data and preconditions
let user = createTestUser()
let cart = createEmptyCart()

// Act: Execute the functionality being tested
let result = cart.calculateTotal()

// Assert: Verify the result
XCTAssertEqual(result, 0)
```

## Test Data Management

### Test Fixtures

**Location**: `tests/fixtures/`

**Files**:
```
fixtures/
├── users.json          # Sample user data
├── products.json       # Sample product data
└── configurations.json # Sample config data
```

### Test Database

- Use in-memory database for speed
- Reset between tests (isolation)
- Seed with minimal data needed

### Mocking Strategy

**Mock External Dependencies**:
- Network requests (APIs)
- File system operations
- Time/Date functions
- Random number generation

**Don't Mock**:
- Internal code being tested
- Simple data structures
- Framework features

## Accessibility Testing

### Automated Tests

```bash
# Run accessibility audit
npm run test:a11y

# Check specific page
axe-core scan --url http://localhost:3000/page
```

### Required Checks
- [ ] Color contrast ratios (WCAG AA)
- [ ] Keyboard navigation (all interactive elements)
- [ ] Screen reader compatibility (ARIA labels)
- [ ] Focus indicators visible
- [ ] Alt text on images

### Manual Testing Checklist
- [ ] Test with keyboard only (no mouse)
- [ ] Test with screen reader (VoiceOver, NVDA)
- [ ] Test with 200% zoom
- [ ] Test in dark mode
- [ ] Test with large text size

## Performance Testing

### Benchmarks

| Operation | Target | Maximum | How to Measure |
|-----------|--------|---------|----------------|
| Page Load | < 2s | 5s | Lighthouse score |
| API Response | < 500ms | 2s | Integration tests |
| UI Interaction | < 100ms | 300ms | Performance API |
| Database Query | < 100ms | 500ms | Query logs |

### Load Testing

**Tools**: [Load testing framework]

**Scenarios**:
- Normal load: [X] concurrent users
- Peak load: [Y] concurrent users
- Stress test: [Z] concurrent users (until failure)

## Security Testing

### Required Security Tests

- [ ] Input validation (SQL injection, XSS)
- [ ] Authentication bypass attempts
- [ ] Authorization checks (access control)
- [ ] CSRF protection
- [ ] Rate limiting
- [ ] Secrets not exposed in logs/errors

### Security Scanning

```bash
# Run security audit
npm audit

# Check for vulnerabilities
safety check  # Python
bundle audit  # Ruby
```

## Integration Testing Patterns

### API Integration Tests

```
Given: API endpoint exists
When: Send HTTP request with valid payload
Then: Receive expected response status and data

Given: API endpoint requires authentication
When: Send request without token
Then: Receive 401 Unauthorized
```

### Database Integration Tests

```
Given: Database is seeded with test data
When: Execute query/mutation
Then: Verify data changed correctly
And: Verify no unintended side effects
```

## End-to-End Testing Patterns

### Critical User Workflows

**Test These Workflows**:
1. User registration and login
2. Core feature usage
3. Data creation/modification/deletion
4. Error recovery
5. Checkout/payment (if applicable)

### E2E Test Structure

```
Feature: User Login

Scenario: Successful login with valid credentials
  Given: User is on login page
  And: User has valid credentials
  When: User enters username "test@example.com"
  And: User enters password "password123"
  And: User clicks "Log In" button
  Then: User is redirected to dashboard
  And: User sees welcome message
```

## Test Maintenance

### Flaky Tests

**Definition**: Tests that sometimes pass, sometimes fail

**Policy**:
- Fix or delete flaky tests immediately
- Don't skip flaky tests (they hide real issues)
- Root cause: timing issues, test pollution, environment

### Test Cleanup

**Run Monthly**:
- Remove obsolete tests
- Update tests for deprecated features
- Refactor duplicated test code

## CI/CD Integration

### Pre-Commit Hooks

```bash
# Run before allowing commit
1. Run linter
2. Run unit tests
3. Check code coverage
```

### CI Pipeline Stages

```
1. Install dependencies
2. Run linter
3. Run unit tests
4. Run integration tests
5. Build application
6. Run E2E tests (on staging)
7. Deploy (if all pass)
```

### Test Reporting

- Generate coverage report (HTML + JSON)
- Upload to coverage service
- Report failures in PR comments

---

## Usage in Feature Specs

Feature specs reference this BASE spec:

```markdown
## Test Strategy

**Extends**: $ref:testing/_BASE.md#test-infrastructure

### Feature-Specific Tests

#### Unit Tests
- test_feature_scenario_result

#### Integration Tests
- test_feature_integration_with_X

#### E2E Tests
- User workflow: [description]
```

---

**Related BASE Specs**:
- `functional/_BASE.md` - Accessibility testing requirements
- `technical/_BASE.md` - Performance targets
- `security/_BASE.md` - Security testing requirements
