# Testing test2

**Version**: 0.1.0

## Running Tests

### All Tests

```bash
swift test
```

This runs all tests in the `Tests/test2Tests/` directory.

### Specific Test

```bash
swift test --filter <TestClassName>
```

Replace `<TestClassName>` with the name of the specific test class.

### Test Coverage

Test coverage is not yet configured. This will be added in a future step.

## Writing Tests

### Unit Tests

- **Location**: Tests/test2Tests/
- **Framework**: XCTest (Swift standard testing framework)
- **Convention**: Test files should be named `<ComponentName>Tests.swift`

Example:
```swift
import XCTest
@testable import test2

final class ExampleTests: XCTestCase {
    func testExample() {
        // Arrange
        let expected = "expected value"

        // Act
        let actual = functionUnderTest()

        // Assert
        XCTAssertEqual(actual, expected)
    }
}
```

### Integration Tests

Integration tests should also be placed in `Tests/test2Tests/` but should test interactions between multiple components.

Convention: Name integration test files with `Integration` suffix, e.g., `AgentIntegrationTests.swift`.

## Test Requirements

- All new code must have tests
- All tests must pass before committing
- Aim for high code coverage on critical paths (configuration, agent loop, tools)

---

**Last updated**: 2026-01-17
