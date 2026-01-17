# Testing test1

**Version**: 0.1.0

## Running Tests

### All Tests

```bash
swift test
```

### Specific Test

```bash
swift test --filter TestClassName.testMethodName
```

### Test Coverage

Swift Package Manager doesn't include built-in coverage, but you can use Xcode:

```bash
xcodebuild test -scheme test1 -enableCodeCoverage YES
```

## Writing Tests

### Unit Tests

- Location: `Tests/test1Tests/`
- Framework: XCTest (built-in)
- Convention: Test files should end with `Tests.swift`

Example:
```swift
import XCTest
@testable import test1

final class MyComponentTests: XCTestCase {
    func testExample() {
        // Arrange
        let component = MyComponent()

        // Act
        let result = component.doSomething()

        // Assert
        XCTAssertEqual(result, expectedValue)
    }
}
```

### Integration Tests

Integration tests should also go in `Tests/test1Tests/` but test multiple components working together:

```swift
final class IntegrationTests: XCTestCase {
    func testEndToEndFlow() {
        // Test complete workflows
    }
}
```

## Test Requirements

- All new code must have tests
- All tests must pass before committing
- Aim for high code coverage (70%+ recommended)
- Tests should be fast and deterministic
- Avoid external dependencies in unit tests (mock them)

## Test Organization

```
Tests/
└── test1Tests/
    ├── UnitTests/
    │   ├── ComponentATests.swift
    │   └── ComponentBTests.swift
    └── IntegrationTests/
        └── FlowTests.swift
```

---

**Last updated**: 2026-01-16 19:20:00
