# Step 7: Create Unit Tests (Parser & Formatter)

**System**: calculator
**Step ID**: calc-step_d4e5f6a1b2c3
**Implements**: calculator-spec.md § 5.2, § 5.3 (Unit Tests - Parser & Formatter)
**Prerequisites**: Step 6 (Create Unit Tests - Calculator)
**Duration**: 20-25 minutes

---

## Purpose

Create comprehensive unit tests for the parser and formatter modules. Parser tests verify input validation, and formatter tests verify output formatting with proper decimal precision.

---

## Inputs

- `BUILD_CONFIG.json` - Build configuration
- `src/parser.{py|js}` - Parser module from Step 3
- `src/formatter.{py|js}` - Formatter module from Step 4
- Test placeholders from Step 1

**Required fields**:
- `language` - Determines test framework
- `test_framework` - Testing framework to use

---

## Outputs

- `tests/test_parser.{py|js}` - Complete unit tests for parser module
- `tests/test_formatter.{py|js}` - Complete unit tests for formatter module

---

## Instructions

### 1. Read Configuration

```bash
# Read configuration
LANGUAGE=$(python -c "import json; c=json.load(open('BUILD_CONFIG.json')); print(c['language'])")
echo "Language: $LANGUAGE"
```

---

### 2. Implement Parser Tests

Choose implementation based on language:

#### Python Implementation - Parser Tests

**File**: `tests/test_parser.py`

```python
# Implements: calculator-spec.md § 5.2 (Unit Tests - Parser)
"""Unit tests for parser module.

Tests input validation for:
- Valid operation parsing (including case insensitivity)
- Invalid operation handling
- Invalid number handling
- Argument count validation
"""

import pytest
from src.parser import (
    parse,
    validate_operation,
    parse_number,
    InvalidOperationError,
    InvalidNumberError,
    ArgumentCountError
)


class TestParse:
    """Tests for parse function."""

    def test_valid_operation_parsing(self):
        """Test T10: Parse valid operations."""
        operation, op1, op2 = parse("add", "5", "3")
        assert operation == "add"
        assert op1 == 5.0
        assert op2 == 3.0

    def test_case_insensitive_operation(self):
        """Test T10: Parse case-insensitive operations."""
        operation, op1, op2 = parse("ADD", "5", "3")
        assert operation == "add"

        operation, op1, op2 = parse("MuLtIpLy", "6", "7")
        assert operation == "multiply"

    def test_all_operations(self):
        """Test T10: Parse all four operations."""
        assert parse("add", "1", "2")[0] == "add"
        assert parse("subtract", "1", "2")[0] == "subtract"
        assert parse("multiply", "1", "2")[0] == "multiply"
        assert parse("divide", "1", "2")[0] == "divide"

    def test_decimal_operands(self):
        """Test parsing decimal operands."""
        operation, op1, op2 = parse("add", "1.5", "2.7")
        assert operation == "add"
        assert op1 == 1.5
        assert op2 == 2.7

    def test_negative_operands(self):
        """Test parsing negative operands."""
        operation, op1, op2 = parse("add", "-5", "3")
        assert op1 == -5.0
        assert op2 == 3.0


class TestInvalidOperation:
    """Tests for invalid operation errors."""

    def test_unknown_operation(self):
        """Test T11: Invalid operation raises error."""
        with pytest.raises(InvalidOperationError, match="Unknown operation 'unknown'"):
            parse("unknown", "5", "3")

    def test_empty_operation(self):
        """Test empty operation string."""
        with pytest.raises(InvalidOperationError):
            parse("", "5", "3")

    def test_error_message_lists_valid_operations(self):
        """Test error message includes valid operations."""
        with pytest.raises(InvalidOperationError, match="add, divide, multiply, subtract"):
            parse("invalid", "5", "3")


class TestInvalidNumber:
    """Tests for invalid number errors."""

    def test_non_numeric_first_operand(self):
        """Test T12: Invalid first operand raises error."""
        with pytest.raises(InvalidNumberError, match="'five' is not a valid number"):
            parse("add", "five", "3")

    def test_non_numeric_second_operand(self):
        """Test T12: Invalid second operand raises error."""
        with pytest.raises(InvalidNumberError, match="'abc' is not a valid number"):
            parse("add", "5", "abc")

    def test_both_operands_invalid(self):
        """Test both operands invalid."""
        with pytest.raises(InvalidNumberError):
            parse("add", "foo", "bar")


class TestArgumentCount:
    """Tests for argument count validation."""

    def test_too_few_arguments(self):
        """Test T13: Too few operands raises error."""
        with pytest.raises(ArgumentCountError, match="Expected 2 operands, got 1"):
            parse("add", "5")

    def test_too_many_arguments(self):
        """Test T13: Too many operands raises error."""
        with pytest.raises(ArgumentCountError, match="Expected 2 operands, got 3"):
            parse("add", "5", "3", "7")

    def test_no_arguments(self):
        """Test no operands."""
        with pytest.raises(ArgumentCountError, match="Expected 2 operands, got 0"):
            parse("add")


class TestHelperFunctions:
    """Tests for helper functions."""

    def test_validate_operation(self):
        """Test validate_operation function."""
        assert validate_operation("add") is True
        assert validate_operation("ADD") is True
        assert validate_operation("unknown") is False

    def test_parse_number(self):
        """Test parse_number function."""
        assert parse_number("5") == 5.0
        assert parse_number("3.14") == 3.14
        assert parse_number("-10") == -10.0

        with pytest.raises(InvalidNumberError):
            parse_number("abc")
```

---

#### JavaScript Implementation - Parser Tests

**File**: `tests/parser.test.js`

```javascript
// Implements: calculator-spec.md § 5.2 (Unit Tests - Parser)
/**
 * Unit tests for parser module.
 *
 * Tests input validation for:
 * - Valid operation parsing (including case insensitivity)
 * - Invalid operation handling
 * - Invalid number handling
 * - Argument count validation
 */

const {
  parse,
  validateOperation,
  parseNumber,
  InvalidOperationError,
  InvalidNumberError,
  ArgumentCountError
} = require('../src/parser');

describe('parse', () => {
  test('T10: parses valid operations', () => {
    const [operation, op1, op2] = parse("add", "5", "3");
    expect(operation).toBe("add");
    expect(op1).toBe(5.0);
    expect(op2).toBe(3.0);
  });

  test('T10: handles case-insensitive operations', () => {
    expect(parse("ADD", "5", "3")[0]).toBe("add");
    expect(parse("MuLtIpLy", "6", "7")[0]).toBe("multiply");
  });

  test('T10: parses all four operations', () => {
    expect(parse("add", "1", "2")[0]).toBe("add");
    expect(parse("subtract", "1", "2")[0]).toBe("subtract");
    expect(parse("multiply", "1", "2")[0]).toBe("multiply");
    expect(parse("divide", "1", "2")[0]).toBe("divide");
  });

  test('parses decimal operands', () => {
    const [operation, op1, op2] = parse("add", "1.5", "2.7");
    expect(operation).toBe("add");
    expect(op1).toBe(1.5);
    expect(op2).toBe(2.7);
  });

  test('parses negative operands', () => {
    const [operation, op1, op2] = parse("add", "-5", "3");
    expect(op1).toBe(-5.0);
    expect(op2).toBe(3.0);
  });
});

describe('invalid operation', () => {
  test('T11: throws error for unknown operation', () => {
    expect(() => parse("unknown", "5", "3"))
      .toThrow(InvalidOperationError);
    expect(() => parse("unknown", "5", "3"))
      .toThrow(/Unknown operation 'unknown'/);
  });

  test('throws error for empty operation', () => {
    expect(() => parse("", "5", "3"))
      .toThrow(InvalidOperationError);
  });

  test('error message lists valid operations', () => {
    expect(() => parse("invalid", "5", "3"))
      .toThrow(/add, divide, multiply, subtract/);
  });
});

describe('invalid number', () => {
  test('T12: throws error for non-numeric first operand', () => {
    expect(() => parse("add", "five", "3"))
      .toThrow(InvalidNumberError);
    expect(() => parse("add", "five", "3"))
      .toThrow(/'five' is not a valid number/);
  });

  test('T12: throws error for non-numeric second operand', () => {
    expect(() => parse("add", "5", "abc"))
      .toThrow(InvalidNumberError);
    expect(() => parse("add", "5", "abc"))
      .toThrow(/'abc' is not a valid number/);
  });

  test('throws error when both operands invalid', () => {
    expect(() => parse("add", "foo", "bar"))
      .toThrow(InvalidNumberError);
  });
});

describe('argument count', () => {
  test('T13: throws error for too few arguments', () => {
    expect(() => parse("add", "5"))
      .toThrow(ArgumentCountError);
    expect(() => parse("add", "5"))
      .toThrow(/Expected 2 operands, got 1/);
  });

  test('T13: throws error for too many arguments', () => {
    expect(() => parse("add", "5", "3", "7"))
      .toThrow(ArgumentCountError);
    expect(() => parse("add", "5", "3", "7"))
      .toThrow(/Expected 2 operands, got 3/);
  });

  test('throws error for no arguments', () => {
    expect(() => parse("add"))
      .toThrow(ArgumentCountError);
    expect(() => parse("add"))
      .toThrow(/Expected 2 operands, got 0/);
  });
});

describe('helper functions', () => {
  test('validateOperation', () => {
    expect(validateOperation("add")).toBe(true);
    expect(validateOperation("ADD")).toBe(true);
    expect(validateOperation("unknown")).toBe(false);
  });

  test('parseNumber', () => {
    expect(parseNumber("5")).toBe(5.0);
    expect(parseNumber("3.14")).toBe(3.14);
    expect(parseNumber("-10")).toBe(-10.0);

    expect(() => parseNumber("abc"))
      .toThrow(InvalidNumberError);
  });
});
```

---

### 3. Implement Formatter Tests

#### Python Implementation - Formatter Tests

**File**: `tests/test_formatter.py`

```python
# Implements: calculator-spec.md § 5.3 (Unit Tests - Formatter)
"""Unit tests for formatter module.

Tests output formatting for:
- Integer results (no decimal point)
- Decimal results (appropriate precision)
- Long decimals (max 10 decimal places)
- Error messages (proper prefix)
"""

import pytest
from src.formatter import format_result, format_error, format_interactive_result


class TestFormatResult:
    """Tests for format_result function."""

    def test_integer_result(self):
        """Test T14: Format integer results without decimal point."""
        assert format_result(8.0) == "8"
        assert format_result(42.0) == "42"
        assert format_result(0.0) == "0"

    def test_decimal_result(self):
        """Test T15: Format decimal results."""
        assert format_result(3.5) == "3.5"
        assert format_result(7.25) == "7.25"

    def test_long_decimal(self):
        """Test T16: Format long decimals with max 10 places."""
        result = format_result(3.333333333333333)
        assert result.startswith("3.3333")
        # Should have at most 10 decimal places
        decimal_part = result.split('.')[1] if '.' in result else ""
        assert len(decimal_part) <= 10

    def test_removes_trailing_zeros(self):
        """Test trailing zeros are removed."""
        assert format_result(3.50) == "3.5"
        assert format_result(10.0) == "10"

    def test_negative_numbers(self):
        """Test formatting negative numbers."""
        assert format_result(-5.0) == "-5"
        assert format_result(-3.5) == "-3.5"

    def test_very_small_decimals(self):
        """Test very small decimal numbers."""
        result = format_result(0.000123456789123)
        assert result.startswith("0.0001234")


class TestFormatError:
    """Tests for format_error function."""

    def test_error_formatting(self):
        """Test T17: Format error messages with prefix."""
        assert format_error("Division by zero") == "Error: Division by zero"
        assert format_error("Invalid input") == "Error: Invalid input"

    def test_empty_error_message(self):
        """Test formatting empty error message."""
        assert format_error("") == "Error: "

    def test_multiline_error(self):
        """Test formatting multiline error."""
        msg = "Something went wrong\nDetails here"
        result = format_error(msg)
        assert result.startswith("Error: ")


class TestFormatInteractiveResult:
    """Tests for format_interactive_result function."""

    def test_addition_formatting(self):
        """Test interactive formatting for addition."""
        result = format_interactive_result("add", 5, 3, 8)
        assert result == "5 + 3 = 8"

    def test_subtraction_formatting(self):
        """Test interactive formatting for subtraction."""
        result = format_interactive_result("subtract", 10, 4, 6)
        assert result == "10 - 4 = 6"

    def test_multiplication_formatting(self):
        """Test interactive formatting for multiplication."""
        result = format_interactive_result("multiply", 6, 7, 42)
        assert result == "6 × 7 = 42"

    def test_division_formatting(self):
        """Test interactive formatting for division."""
        result = format_interactive_result("divide", 15, 3, 5)
        assert result == "15 ÷ 3 = 5"

    def test_decimal_operands(self):
        """Test interactive formatting with decimals."""
        result = format_interactive_result("add", 1.5, 2.5, 4.0)
        assert result == "1.5 + 2.5 = 4"

    def test_negative_operands(self):
        """Test interactive formatting with negative numbers."""
        result = format_interactive_result("subtract", -5, 3, -8)
        assert result == "-5 - 3 = -8"
```

---

#### JavaScript Implementation - Formatter Tests

**File**: `tests/formatter.test.js`

```javascript
// Implements: calculator-spec.md § 5.3 (Unit Tests - Formatter)
/**
 * Unit tests for formatter module.
 *
 * Tests output formatting for:
 * - Integer results (no decimal point)
 * - Decimal results (appropriate precision)
 * - Long decimals (max 10 decimal places)
 * - Error messages (proper prefix)
 */

const {
  formatResult,
  formatError,
  formatInteractiveResult
} = require('../src/formatter');

describe('formatResult', () => {
  test('T14: formats integer results without decimal point', () => {
    expect(formatResult(8.0)).toBe("8");
    expect(formatResult(42.0)).toBe("42");
    expect(formatResult(0.0)).toBe("0");
  });

  test('T15: formats decimal results', () => {
    expect(formatResult(3.5)).toBe("3.5");
    expect(formatResult(7.25)).toBe("7.25");
  });

  test('T16: formats long decimals with max 10 places', () => {
    const result = formatResult(3.333333333333333);
    expect(result).toMatch(/^3\.3333/);
    // Should have at most 10 decimal places
    const decimalPart = result.includes('.') ? result.split('.')[1] : "";
    expect(decimalPart.length).toBeLessThanOrEqual(10);
  });

  test('removes trailing zeros', () => {
    expect(formatResult(3.50)).toBe("3.5");
    expect(formatResult(10.0)).toBe("10");
  });

  test('formats negative numbers', () => {
    expect(formatResult(-5.0)).toBe("-5");
    expect(formatResult(-3.5)).toBe("-3.5");
  });

  test('formats very small decimals', () => {
    const result = formatResult(0.000123456789123);
    expect(result).toMatch(/^0\.0001234/);
  });
});

describe('formatError', () => {
  test('T17: formats error messages with prefix', () => {
    expect(formatError("Division by zero")).toBe("Error: Division by zero");
    expect(formatError("Invalid input")).toBe("Error: Invalid input");
  });

  test('formats empty error message', () => {
    expect(formatError("")).toBe("Error: ");
  });

  test('formats multiline error', () => {
    const msg = "Something went wrong\nDetails here";
    const result = formatError(msg);
    expect(result).toMatch(/^Error: /);
  });
});

describe('formatInteractiveResult', () => {
  test('formats addition', () => {
    const result = formatInteractiveResult("add", 5, 3, 8);
    expect(result).toBe("5 + 3 = 8");
  });

  test('formats subtraction', () => {
    const result = formatInteractiveResult("subtract", 10, 4, 6);
    expect(result).toBe("10 - 4 = 6");
  });

  test('formats multiplication', () => {
    const result = formatInteractiveResult("multiply", 6, 7, 42);
    expect(result).toBe("6 × 7 = 42");
  });

  test('formats division', () => {
    const result = formatInteractiveResult("divide", 15, 3, 5);
    expect(result).toBe("15 ÷ 3 = 5");
  });

  test('formats with decimal operands', () => {
    const result = formatInteractiveResult("add", 1.5, 2.5, 4.0);
    expect(result).toBe("1.5 + 2.5 = 4");
  });

  test('formats with negative operands', () => {
    const result = formatInteractiveResult("subtract", -5, 3, -8);
    expect(result).toBe("-5 - 3 = -8");
  });
});
```

---

### 4. Run Tests

#### Python (pytest)

```bash
# Run parser tests
pytest tests/test_parser.py -v

# Run formatter tests
pytest tests/test_formatter.py -v

# Run both with coverage
pytest tests/test_parser.py tests/test_formatter.py \
  --cov=src.parser --cov=src.formatter \
  --cov-report=term-missing -v
```

---

#### JavaScript (Jest)

```bash
# Run parser tests
npm test tests/parser.test.js

# Run formatter tests
npm test tests/formatter.test.js

# Run both with coverage
npm test -- --coverage --testPathPattern="(parser|formatter).test.js"
```

---

### 5. Update BUILD_STATUS.md

Add Step 7 completion to the build log:

```markdown
### Step 7: Create Unit Tests (Parser & Formatter)
- **Started**: <ISO8601_timestamp>
- **Completed**: <ISO8601_timestamp>
- **Duration**: X minutes
- **Status**: ✅ PASS
- **Notes**: Parser tests: 20+ passed, Formatter tests: 15+ passed, coverage ≥ 90%
```

Update progress:
```markdown
- [x] Step 6: Create Unit Tests (Calculator) (COMPLETE)
- [x] Step 7: Create Unit Tests (Parser & Formatter) (COMPLETE)
- [ ] Step 8: Create Integration Tests
```

---

## Verification

### Success Criteria

- ✅ All parser tests pass
- ✅ All formatter tests pass
- ✅ Test coverage ≥ 90% for parser module
- ✅ Test coverage ≥ 90% for formatter module
- ✅ All test requirements T10-T17 covered
- ✅ Custom error types tested
- ✅ Proper traceability comments in test files
- ✅ BUILD_STATUS.md updated

### Verification Commands

```bash
# Run all unit tests
pytest tests/test_parser.py tests/test_formatter.py -v || \
npm test -- --testPathPattern="(parser|formatter).test.js"

# Check coverage
pytest tests/ --cov=src --cov-report=term -v || \
npm test -- --coverage
```

---

## Next Step

**Step 8**: Create Integration Tests (calc-step_e5f6a1b2c3d4.md)

---

**Traceability**: Implements calculator-spec.md § 5.2, § 5.3 (Unit Tests - Parser & Formatter)
