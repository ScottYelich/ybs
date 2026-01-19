# Testing test7

**Version**: 0.1.0

## Running Tests

### All Tests

```bash
swift test
```

### Specific Test

```bash
swift test --filter <TestName>
```

Example:
```bash
swift test --filter test7Tests.ConfigTests/testLoadConfig
```

### Test Coverage

Swift Package Manager supports code coverage:

```bash
swift test --enable-code-coverage
```

Coverage report location: `.build/debug/codecov/`

## Writing Tests

### Unit Tests

- Location: Tests/test7Tests/
- Framework: XCTest (built into Swift)
- Convention: Test files should end with `Tests.swift`

Example:
```swift
import XCTest
@testable import test7

final class ExampleTests: XCTestCase {
    func testExample() {
        // Given
        let input = "test"

        // When
        let result = processInput(input)

        // Then
        XCTAssertEqual(result, "expected")
    }
}
```

### Integration Tests

Integration tests should:
- Test multiple components working together
- Use test fixtures for file operations
- Mock external LLM API calls
- Test the full agent loop with simulated inputs

## Test Requirements

- All new code must have tests
- All tests must pass before committing
- Aim for 80%+ code coverage
- Tests should be fast (<5 seconds total)

## Test Structure

```
Tests/
└── test7Tests/
    ├── ConfigTests.swift      # Configuration system tests
    ├── ToolTests.swift        # Tool implementation tests
    ├── AgentTests.swift       # Agent loop tests
    ├── LLMClientTests.swift   # LLM client tests
    └── IntegrationTests.swift # End-to-end tests
```

---

**Last updated**: 2026-01-18T02:09:31Z
