# Testing test3

**Version**: 0.1.0

## Running Tests

### All Tests

```bash
cd builds/test3
swift test
```

Runs all tests in the Tests/test3Tests/ directory.

### Specific Test

```bash
swift test --filter test3Tests.TestClassName.testMethodName
```

Runs a single test method.

### Test with Output

```bash
swift test --verbose
```

Shows detailed test output.

### Test Coverage

Test coverage reporting is not yet configured. Will be added in a future step.

## Writing Tests

### Unit Tests

- **Location**: Tests/test3Tests/
- **Framework**: XCTest (Swift standard testing framework)
- **Convention**: Test files should be named `<ComponentName>Tests.swift`

Example:
```swift
import XCTest
@testable import test3

final class MyComponentTests: XCTestCase {
    func testExample() throws {
        // Given
        let expected = "expected value"

        // When
        let actual = someFunction()

        // Then
        XCTAssertEqual(actual, expected)
    }
}
```

### Integration Tests

Integration tests should also go in Tests/test3Tests/ but focus on testing multiple components working together rather than individual units.

Naming convention: `<Feature>IntegrationTests.swift`

Example:
```swift
final class AgentLoopIntegrationTests: XCTestCase {
    func testFullAgentCycle() throws {
        // Test the complete agent loop:
        // User input → LLM call → Tool execution → Response
    }
}
```

## Test Requirements

- **All new code must have tests**: Before marking a code step complete
- **All tests must pass**: No failing tests allowed in completed steps
- **Aim for high coverage**: Focus on critical paths and edge cases
- **Test isolation**: Each test should be independent and not rely on others

## Test Organization

```
Tests/
└── test3Tests/
    ├── ComponentTests.swift       # Unit tests for Component
    ├── FeatureIntegrationTests.swift  # Integration tests
    └── ...
```

## Running Tests in Xcode

If you prefer using Xcode:
1. Open Package.swift in Xcode
2. Press Cmd+U to run all tests
3. Or click the diamond icon next to individual tests

---

**Last updated**: 2026-01-17 06:32 UTC
