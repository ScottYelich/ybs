# Testing test4

**Version**: 0.1.0

## Running Tests

### All Tests

```bash
swift test
```

This runs all unit tests in the `Tests/` directory.

### Specific Test

```bash
swift test --filter TestName
```

Replace `TestName` with the name of a specific test class or method.

### Test Coverage

*(Coverage support to be added later)*

```bash
# Future: Generate coverage report
# swift test --enable-code-coverage
```

## Writing Tests

### Unit Tests

- **Location**: `Tests/test4Tests/`
- **Framework**: XCTest (built into Swift)
- **Convention**: Test files should end with `Tests.swift`

Example:
```swift
import XCTest
@testable import test4

final class MyComponentTests: XCTestCase {
    func testExample() {
        // Arrange
        let component = MyComponent()

        // Act
        let result = component.doSomething()

        // Assert
        XCTAssertEqual(result, expectedValue)
    }

    func testAnotherScenario() throws {
        // Test code here
    }
}
```

### Test Structure

Follow the Arrange-Act-Assert pattern:
1. **Arrange**: Set up test data and preconditions
2. **Act**: Execute the code being tested
3. **Assert**: Verify the results

### Integration Tests

Integration tests should also go in `Tests/test4Tests/`:
- Test multiple components working together
- Test external API interactions (mock responses)
- Test file system operations (use temp directories)

## Test Requirements

- All new code must have tests
- All tests must pass before committing
- Aim for high code coverage on critical paths
- Mock external dependencies (LLM APIs, file system)

## XCTest Assertions

Common XCTest assertions:
- `XCTAssertEqual(a, b)` - Values are equal
- `XCTAssertTrue(condition)` - Condition is true
- `XCTAssertFalse(condition)` - Condition is false
- `XCTAssertNil(value)` - Value is nil
- `XCTAssertNotNil(value)` - Value is not nil
- `XCTAssertThrowsError(try expression)` - Expression throws an error

---

**Last updated**: 2026-01-16 23:05 UTC
