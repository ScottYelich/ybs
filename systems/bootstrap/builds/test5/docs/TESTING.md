# Testing test5

**Version**: 0.1.0

## Running Tests

### All Tests

```bash
cd builds/test5
swift test
```

### Specific Test

```bash
swift test --filter test5Tests.SomeTestClass/testSomeMethod
```

### Test Coverage

*(XCTest doesn't provide built-in coverage reporting on command line. Use Xcode for coverage analysis.)*

## Writing Tests

### Unit Tests

- Location: `Tests/test5Tests/`
- Framework: XCTest (built-in)
- Convention: Test files end with `Tests.swift`, test classes inherit from `XCTestCase`

Example:
```swift
import XCTest
@testable import test5

final class ExampleTests: XCTestCase {
    func testExample() throws {
        // Given
        let input = "test"

        // When
        let result = someFunction(input)

        // Then
        XCTAssertEqual(result, "expected")
    }
}
```

### Integration Tests

Place integration tests in `Tests/test5Tests/` but name them clearly (e.g., `IntegrationTests.swift`).

### Test Organization

- One test file per source file being tested
- Group related tests in test classes
- Use descriptive test names: `testFeatureName_WhenCondition_ExpectedResult`

## Test Requirements

- All new code must have tests
- All tests must pass before committing
- Aim for meaningful coverage (focus on critical paths, not 100%)
- Test both success and failure cases

## Continuous Testing

During development, run tests frequently:

```bash
# Quick loop: edit code, run tests
swift test
```

---

**Last updated**: 2026-01-17 07:41 UTC
