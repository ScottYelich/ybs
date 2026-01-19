# Calculator System - Technical Specification

**System**: calculator
**Version**: 1.0.0
**Last Updated**: 2026-01-18
**Complexity**: Simple (Multi-module with testing)

---

## 1. System Overview

### 1.1 Purpose

Build a command-line calculator that performs basic arithmetic operations with a modular architecture, comprehensive testing, and user-friendly interface.

### 1.2 Scope

**In Scope**:
- CLI calculator with four basic operations (add, subtract, multiply, divide)
- Multi-module architecture (calculator core, parser, formatter, CLI)
- Comprehensive unit and integration tests
- Interactive and command-line argument modes
- Error handling and input validation
- User documentation

**Out of Scope**:
- Advanced operations (trigonometry, logarithms, etc.)
- Graphical user interface
- Expression parsing (complex equations)
- History tracking
- Configuration files

### 1.3 Architecture

```
calculator/
├── src/
│   ├── calculator.{py|js}      # Core arithmetic operations
│   ├── parser.{py|js}          # Input parsing and validation
│   ├── formatter.{py|js}       # Output formatting
│   └── cli.{py|js}             # Command-line interface
├── tests/
│   ├── test_calculator.{py|js} # Unit tests for calculator
│   ├── test_parser.{py|js}     # Unit tests for parser
│   ├── test_formatter.{py|js}  # Unit tests for formatter
│   └── test_integration.{py|js}# Integration tests
├── docs/
│   └── USAGE.md                # User documentation
├── calculator.{py|js}          # Entry point (executable)
└── README.md                   # Build documentation
```

---

## 2. Functional Requirements

### 2.1 Core Operations

**F1: Addition**
- **Requirement**: System shall add two numbers
- **Input**: Two numeric values
- **Output**: Sum of the two numbers
- **Example**: `add 5 3` → `8`

**F2: Subtraction**
- **Requirement**: System shall subtract second number from first
- **Input**: Two numeric values
- **Output**: Difference between the two numbers
- **Example**: `subtract 10 4` → `6`

**F3: Multiplication**
- **Requirement**: System shall multiply two numbers
- **Input**: Two numeric values
- **Output**: Product of the two numbers
- **Example**: `multiply 6 7` → `42`

**F4: Division**
- **Requirement**: System shall divide first number by second
- **Input**: Two numeric values
- **Output**: Quotient of the division
- **Error**: Division by zero shall be handled gracefully
- **Example**: `divide 15 3` → `5`
- **Error Example**: `divide 10 0` → `Error: Division by zero`

### 2.2 Input Modes

**F5: Command-Line Arguments Mode**
- **Requirement**: System shall accept operation and operands as CLI arguments
- **Format**: `./calculator operation num1 num2`
- **Example**: `./calculator add 5 3`
- **Output**: Result printed to stdout

**F6: Interactive Mode**
- **Requirement**: System shall provide interactive prompt when no arguments given
- **Behavior**: Prompt user for operation and operands
- **Commands**: Operations (add, subtract, multiply, divide), quit/exit
- **Example**:
  ```
  $ ./calculator
  > add 5 3
  8
  > multiply 4 7
  28
  > quit
  ```

### 2.3 Input Validation

**F7: Numeric Validation**
- **Requirement**: System shall validate that operands are valid numbers
- **Error Handling**: Provide clear error messages for invalid input
- **Example**: `add five 3` → `Error: 'five' is not a valid number`

**F8: Operation Validation**
- **Requirement**: System shall validate that operation is supported
- **Supported**: add, subtract, multiply, divide (case-insensitive)
- **Error**: `unknown 5 3` → `Error: Unknown operation 'unknown'`

**F9: Argument Count Validation**
- **Requirement**: System shall validate correct number of arguments
- **Required**: Exactly 2 operands for all operations
- **Error**: `add 5` → `Error: Expected 2 operands, got 1`

### 2.4 Output Formatting

**F10: Result Display**
- **Requirement**: System shall display results clearly
- **Format**: Plain numeric result for CLI mode
- **Format**: Formatted result for interactive mode
- **Precision**: Floating-point results shown with reasonable precision (max 10 decimal places)

**F11: Error Display**
- **Requirement**: System shall display errors clearly
- **Format**: `Error: <descriptive message>`
- **Exit Code**: Non-zero exit code for errors (CLI mode)

---

## 3. Non-Functional Requirements

### 3.1 Code Quality

**NF1: Modularity**
- **Requirement**: System shall be organized into distinct modules
- **Modules**: calculator, parser, formatter, CLI
- **Separation**: Each module has single, clear responsibility
- **Interfaces**: Clean interfaces between modules

**NF2: Testability**
- **Requirement**: All modules shall be unit testable
- **Coverage**: Minimum 80% line coverage required
- **Tests**: Unit tests for each module
- **Tests**: Integration tests for end-to-end flows

**NF3: Code Simplicity**
- **Requirement**: Code shall be clear and maintainable
- **Complexity**: Functions should be < 20 lines where possible
- **Naming**: Clear, descriptive names for functions and variables

### 3.2 Performance

**NF4: Response Time**
- **Requirement**: Operations shall complete in < 100ms
- **Rationale**: Calculator should feel instant to users

### 3.3 Traceability

**NF5: Specification Traceability**
- **Requirement**: All source files shall reference this specification
- **Format**: `# Implements: calculator-spec.md § X.Y`
- **Minimum**: 80% of source files must have traceability comments

### 3.4 Documentation

**NF6: User Documentation**
- **Requirement**: System shall include usage documentation
- **Content**: How to run, examples, supported operations
- **Location**: `docs/USAGE.md`

**NF7: Developer Documentation**
- **Requirement**: Build shall include README with architecture overview
- **Content**: Module structure, how to run tests, development setup

---

## 4. Configuration Items (Step 0)

These items are collected during Step 0 (Build Configuration).

### 4.1 Build Configuration

**C1: Build Name**
- **CONFIG**: `build_name`
- **Type**: text
- **Description**: Name of this build instance
- **Default**: `demo`
- **Example**: `build1`, `test3`, `prod`

**C2: Programming Language**
- **CONFIG**: `language`
- **Type**: choice[python,javascript]
- **Description**: Programming language for implementation
- **Default**: `python`
- **Notes**:
  - Python: Uses Python 3.8+ with pytest for testing
  - JavaScript: Uses Node.js with Jest for testing

**C3: Target Platform**
- **CONFIG**: `platform`
- **Type**: choice[linux,macos,windows,all]
- **Description**: Target operating system(s)
- **Default**: `all`

**C4: Entry Point Name**
- **CONFIG**: `entry_point`
- **Type**: text
- **Description**: Name of main executable script
- **Default**: `calculator`
- **Example**: `calc`, `calculator`, `compute`

**C5: Interactive Mode**
- **CONFIG**: `interactive_mode`
- **Type**: boolean
- **Description**: Whether to include interactive mode
- **Default**: `true`
- **Notes**: If false, only CLI arguments mode is implemented

**C6: Test Framework**
- **CONFIG**: `test_framework`
- **Type**: derived from language
- **Description**: Testing framework to use
- **Values**:
  - Python → pytest
  - JavaScript → Jest

---

## 5. Test Requirements

### 5.1 Unit Tests - Calculator Module

**T1: Addition Test**
- **Test**: Verify addition of positive numbers
- **Example**: `add(5, 3)` → `8`

**T2: Addition Edge Cases**
- **Test**: Verify addition with negative numbers, zero, decimals
- **Examples**:
  - `add(-5, 3)` → `-2`
  - `add(0, 0)` → `0`
  - `add(1.5, 2.5)` → `4.0`

**T3: Subtraction Test**
- **Test**: Verify subtraction of positive numbers
- **Example**: `subtract(10, 4)` → `6`

**T4: Subtraction Edge Cases**
- **Test**: Verify subtraction with negative numbers, zero, decimals
- **Examples**:
  - `subtract(-5, 3)` → `-8`
  - `subtract(5, 5)` → `0`
  - `subtract(10.5, 3.2)` → `7.3`

**T5: Multiplication Test**
- **Test**: Verify multiplication of positive numbers
- **Example**: `multiply(6, 7)` → `42`

**T6: Multiplication Edge Cases**
- **Test**: Verify multiplication with negative, zero, decimals
- **Examples**:
  - `multiply(-5, 3)` → `-15`
  - `multiply(5, 0)` → `0`
  - `multiply(2.5, 4)` → `10.0`

**T7: Division Test**
- **Test**: Verify division of positive numbers
- **Example**: `divide(15, 3)` → `5`

**T8: Division Edge Cases**
- **Test**: Verify division with negative, decimals
- **Examples**:
  - `divide(-10, 2)` → `-5`
  - `divide(7, 2)` → `3.5`
  - `divide(0, 5)` → `0`

**T9: Division by Zero**
- **Test**: Verify division by zero raises appropriate error
- **Example**: `divide(10, 0)` → raises `DivisionByZeroError` or equivalent

### 5.2 Unit Tests - Parser Module

**T10: Valid Operation Parsing**
- **Test**: Verify parsing of valid operations
- **Examples**:
  - `parse("add", "5", "3")` → `("add", 5.0, 3.0)`
  - `parse("ADD", "5", "3")` → `("add", 5.0, 3.0)` (case-insensitive)

**T11: Invalid Operation**
- **Test**: Verify error on invalid operation
- **Example**: `parse("unknown", "5", "3")` → raises `InvalidOperationError`

**T12: Invalid Number**
- **Test**: Verify error on invalid numeric input
- **Examples**:
  - `parse("add", "five", "3")` → raises `InvalidNumberError`
  - `parse("add", "5", "abc")` → raises `InvalidNumberError`

**T13: Argument Count**
- **Test**: Verify error on wrong number of arguments
- **Examples**:
  - `parse("add", "5")` → raises `ArgumentCountError`
  - `parse("add", "5", "3", "7")` → raises `ArgumentCountError`

### 5.3 Unit Tests - Formatter Module

**T14: Integer Result Formatting**
- **Test**: Verify formatting of integer results
- **Example**: `format_result(8)` → `"8"`

**T15: Decimal Result Formatting**
- **Test**: Verify formatting of decimal results
- **Example**: `format_result(3.5)` → `"3.5"`

**T16: Long Decimal Formatting**
- **Test**: Verify long decimals are rounded appropriately
- **Example**: `format_result(3.333333333333333)` → `"3.3333333333"` (max 10 decimal places)

**T17: Error Message Formatting**
- **Test**: Verify error messages are properly formatted
- **Example**: `format_error("Division by zero")` → `"Error: Division by zero"`

### 5.4 Integration Tests

**T18: End-to-End CLI Operation**
- **Test**: Verify complete flow from CLI arguments to output
- **Example**: Execute `./calculator add 5 3` → output `8`, exit code `0`

**T19: End-to-End Error Handling**
- **Test**: Verify error flow from invalid input to error message
- **Example**: Execute `./calculator divide 10 0` → output `Error: Division by zero`, exit code `1`

**T20: Interactive Mode Flow**
- **Test**: Verify interactive mode accepts commands and displays results
- **Requires**: If interactive mode is enabled
- **Example**: Send `add 5 3\n` → output includes `8`

### 5.5 Coverage Requirements

**T21: Code Coverage**
- **Requirement**: Minimum 80% line coverage across all modules
- **Target**: 90% line coverage recommended
- **Critical**: 100% coverage for calculator core operations

**T22: Test Execution**
- **Requirement**: All tests must pass before proceeding to next step
- **Retry**: Maximum 3 attempts to fix failing tests
- **Failure**: Build stops if tests fail after 3 attempts

---

## 6. Implementation Patterns

### 6.1 Python Implementation

**Module Structure**:
```python
# src/calculator.py
# Implements: calculator-spec.md § 2.1 (Core Operations)

def add(a: float, b: float) -> float:
    """Add two numbers."""
    return a + b

def subtract(a: float, b: float) -> float:
    """Subtract b from a."""
    return a - b

def multiply(a: float, b: float) -> float:
    """Multiply two numbers."""
    return a * b

def divide(a: float, b: float) -> float:
    """Divide a by b."""
    if b == 0:
        raise ValueError("Division by zero")
    return a / b
```

**Testing Framework**: pytest
```python
# tests/test_calculator.py
# Implements: calculator-spec.md § 5.1 (Unit Tests - Calculator)

import pytest
from src.calculator import add, subtract, multiply, divide

def test_add():
    assert add(5, 3) == 8

def test_divide_by_zero():
    with pytest.raises(ValueError, match="Division by zero"):
        divide(10, 0)
```

### 6.2 JavaScript Implementation

**Module Structure**:
```javascript
// src/calculator.js
// Implements: calculator-spec.md § 2.1 (Core Operations)

function add(a, b) {
  return a + b;
}

function subtract(a, b) {
  return a - b;
}

function multiply(a, b) {
  return a * b;
}

function divide(a, b) {
  if (b === 0) {
    throw new Error('Division by zero');
  }
  return a / b;
}

module.exports = { add, subtract, multiply, divide };
```

**Testing Framework**: Jest
```javascript
// tests/calculator.test.js
// Implements: calculator-spec.md § 5.1 (Unit Tests - Calculator)

const { add, subtract, multiply, divide } = require('../src/calculator');

test('add two numbers', () => {
  expect(add(5, 3)).toBe(8);
});

test('divide by zero throws error', () => {
  expect(() => divide(10, 0)).toThrow('Division by zero');
});
```

---

## 7. Dependencies

### 7.1 Python Dependencies

**Runtime**: None (uses standard library only)

**Development/Testing**:
- pytest >= 7.0.0 (testing framework)
- pytest-cov >= 4.0.0 (coverage reporting)

**Installation**:
```bash
pip install pytest pytest-cov
```

### 7.2 JavaScript Dependencies

**Runtime**: None (uses Node.js standard library only)

**Development/Testing**:
- jest >= 29.0.0 (testing framework)

**Installation**:
```bash
npm install --save-dev jest
```

---

## 8. Verification Criteria

### 8.1 Functional Verification

- ✅ All four operations (add, subtract, multiply, divide) work correctly
- ✅ CLI arguments mode works (3 arguments: operation num1 num2)
- ✅ Interactive mode works (if enabled)
- ✅ Error handling works (division by zero, invalid input, etc.)
- ✅ Exit codes correct (0 for success, non-zero for errors)

### 8.2 Test Verification

- ✅ All unit tests pass (calculator, parser, formatter)
- ✅ All integration tests pass
- ✅ Code coverage ≥ 80% (target: 90%)
- ✅ Test execution time < 5 seconds

### 8.3 Quality Verification

- ✅ All source files have traceability comments (≥ 80%)
- ✅ Documentation exists (USAGE.md, README.md)
- ✅ Code follows language conventions (PEP 8 for Python, Standard for JS)
- ✅ No linting errors

---

## 9. Success Criteria

Build is considered successful when:

1. ✅ All functional requirements (F1-F11) are implemented
2. ✅ All test requirements (T1-T22) pass
3. ✅ Code coverage ≥ 80% (minimum) or ≥ 90% (target)
4. ✅ All verification criteria met
5. ✅ Documentation complete (USAGE.md, README.md)
6. ✅ Traceability ≥ 80% of source files

---

## 10. References

- **YBS Framework**: [../../framework/README.md](../../framework/README.md)
- **Writing Steps**: [../../framework/methodology/writing-steps.md](../../framework/methodology/writing-steps.md)
- **Previous Example**: [../01-hello-world/](../01-hello-world/)
- **Next Example**: [../03-rest-api/](../03-rest-api/)

---

**Document History**:
- v1.0.0 (2026-01-18): Initial specification
