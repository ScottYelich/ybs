# Step 6: Create Unit Tests (Calculator)

**System**: calculator
**Step ID**: calc-step_c3d4e5f6a1b2
**Implements**: calculator-spec.md § 5.1 (Unit Tests - Calculator Module)
**Prerequisites**: Step 5 (Create CLI Interface)
**Duration**: 15-20 minutes

---

## Purpose

Create comprehensive unit tests for the calculator module. These tests verify all four operations work correctly with various inputs including positive, negative, zero, and decimal numbers.

---

## Inputs

- `BUILD_CONFIG.json` - Build configuration
- `src/calculator.{py|js}` - Calculator module from Step 2
- `tests/test_calculator.{py|js}` - Placeholder from Step 1

**Required fields**:
- `language` - Determines test framework (pytest or Jest)
- `test_framework` - Testing framework to use

---

## Outputs

- `tests/test_calculator.{py|js}` - Complete unit tests for calculator module

---

## Instructions

### 1. Read Configuration

```bash
# Read configuration
LANGUAGE=$(python -c "import json; c=json.load(open('BUILD_CONFIG.json')); print(c['language'])")
TEST_FRAMEWORK=$(python -c "import json; c=json.load(open('BUILD_CONFIG.json')); print(c['test_framework'])")

echo "Language: $LANGUAGE"
echo "Test Framework: $TEST_FRAMEWORK"
```

---

### 2. Implement Unit Tests

Choose implementation based on language:

#### Python Implementation (pytest)

**File**: `tests/test_calculator.py`

```python
# Implements: calculator-spec.md § 5.1 (Unit Tests - Calculator)
"""Unit tests for calculator module.

Tests all four operations (add, subtract, multiply, divide) with:
- Positive numbers
- Negative numbers
- Zero
- Decimal numbers
- Edge cases (division by zero)
"""

import pytest
from src.calculator import add, subtract, multiply, divide


class TestAdd:
    """Tests for add function."""

    def test_add_positive_numbers(self):
        """Test T1: Addition of positive numbers."""
        assert add(5, 3) == 8

    def test_add_negative_numbers(self):
        """Test T2: Addition with negative numbers."""
        assert add(-5, 3) == -2
        assert add(5, -3) == 2
        assert add(-5, -3) == -8

    def test_add_with_zero(self):
        """Test T2: Addition with zero."""
        assert add(0, 0) == 0
        assert add(5, 0) == 5
        assert add(0, 5) == 5

    def test_add_decimals(self):
        """Test T2: Addition with decimal numbers."""
        assert add(1.5, 2.5) == 4.0
        assert add(0.1, 0.2) == pytest.approx(0.3)


class TestSubtract:
    """Tests for subtract function."""

    def test_subtract_positive_numbers(self):
        """Test T3: Subtraction of positive numbers."""
        assert subtract(10, 4) == 6

    def test_subtract_negative_numbers(self):
        """Test T4: Subtraction with negative numbers."""
        assert subtract(-5, 3) == -8
        assert subtract(5, -3) == 8
        assert subtract(-5, -3) == -2

    def test_subtract_to_zero(self):
        """Test T4: Subtraction resulting in zero."""
        assert subtract(5, 5) == 0

    def test_subtract_decimals(self):
        """Test T4: Subtraction with decimal numbers."""
        assert subtract(10.5, 3.2) == pytest.approx(7.3)


class TestMultiply:
    """Tests for multiply function."""

    def test_multiply_positive_numbers(self):
        """Test T5: Multiplication of positive numbers."""
        assert multiply(6, 7) == 42

    def test_multiply_negative_numbers(self):
        """Test T6: Multiplication with negative numbers."""
        assert multiply(-5, 3) == -15
        assert multiply(5, -3) == -15
        assert multiply(-5, -3) == 15

    def test_multiply_with_zero(self):
        """Test T6: Multiplication with zero."""
        assert multiply(5, 0) == 0
        assert multiply(0, 5) == 0
        assert multiply(0, 0) == 0

    def test_multiply_decimals(self):
        """Test T6: Multiplication with decimal numbers."""
        assert multiply(2.5, 4) == 10.0
        assert multiply(0.5, 0.5) == 0.25


class TestDivide:
    """Tests for divide function."""

    def test_divide_positive_numbers(self):
        """Test T7: Division of positive numbers."""
        assert divide(15, 3) == 5

    def test_divide_negative_numbers(self):
        """Test T8: Division with negative numbers."""
        assert divide(-10, 2) == -5
        assert divide(10, -2) == -5
        assert divide(-10, -2) == 5

    def test_divide_resulting_in_decimal(self):
        """Test T8: Division resulting in decimal."""
        assert divide(7, 2) == 3.5
        assert divide(1, 3) == pytest.approx(0.333333, rel=1e-5)

    def test_divide_zero_by_number(self):
        """Test T8: Division of zero by number."""
        assert divide(0, 5) == 0

    def test_divide_by_zero(self):
        """Test T9: Division by zero raises error."""
        with pytest.raises(ValueError, match="Division by zero"):
            divide(10, 0)

        with pytest.raises(ValueError):
            divide(0, 0)


class TestEdgeCases:
    """Additional edge case tests."""

    def test_large_numbers(self):
        """Test operations with large numbers."""
        assert add(1000000, 2000000) == 3000000
        assert multiply(1000, 1000) == 1000000

    def test_very_small_decimals(self):
        """Test operations with very small decimals."""
        assert add(0.0001, 0.0002) == pytest.approx(0.0003)
        assert multiply(0.001, 0.001) == pytest.approx(0.000001)
```

---

#### JavaScript Implementation (Jest)

**File**: `tests/calculator.test.js`

```javascript
// Implements: calculator-spec.md § 5.1 (Unit Tests - Calculator)
/**
 * Unit tests for calculator module.
 *
 * Tests all four operations (add, subtract, multiply, divide) with:
 * - Positive numbers
 * - Negative numbers
 * - Zero
 * - Decimal numbers
 * - Edge cases (division by zero)
 */

const { add, subtract, multiply, divide } = require('../src/calculator');

describe('add', () => {
  test('T1: adds positive numbers', () => {
    expect(add(5, 3)).toBe(8);
  });

  test('T2: adds negative numbers', () => {
    expect(add(-5, 3)).toBe(-2);
    expect(add(5, -3)).toBe(2);
    expect(add(-5, -3)).toBe(-8);
  });

  test('T2: adds with zero', () => {
    expect(add(0, 0)).toBe(0);
    expect(add(5, 0)).toBe(5);
    expect(add(0, 5)).toBe(5);
  });

  test('T2: adds decimal numbers', () => {
    expect(add(1.5, 2.5)).toBe(4.0);
    expect(add(0.1, 0.2)).toBeCloseTo(0.3);
  });
});

describe('subtract', () => {
  test('T3: subtracts positive numbers', () => {
    expect(subtract(10, 4)).toBe(6);
  });

  test('T4: subtracts negative numbers', () => {
    expect(subtract(-5, 3)).toBe(-8);
    expect(subtract(5, -3)).toBe(8);
    expect(subtract(-5, -3)).toBe(-2);
  });

  test('T4: subtracts to zero', () => {
    expect(subtract(5, 5)).toBe(0);
  });

  test('T4: subtracts decimal numbers', () => {
    expect(subtract(10.5, 3.2)).toBeCloseTo(7.3);
  });
});

describe('multiply', () => {
  test('T5: multiplies positive numbers', () => {
    expect(multiply(6, 7)).toBe(42);
  });

  test('T6: multiplies negative numbers', () => {
    expect(multiply(-5, 3)).toBe(-15);
    expect(multiply(5, -3)).toBe(-15);
    expect(multiply(-5, -3)).toBe(15);
  });

  test('T6: multiplies with zero', () => {
    expect(multiply(5, 0)).toBe(0);
    expect(multiply(0, 5)).toBe(0);
    expect(multiply(0, 0)).toBe(0);
  });

  test('T6: multiplies decimal numbers', () => {
    expect(multiply(2.5, 4)).toBe(10.0);
    expect(multiply(0.5, 0.5)).toBe(0.25);
  });
});

describe('divide', () => {
  test('T7: divides positive numbers', () => {
    expect(divide(15, 3)).toBe(5);
  });

  test('T8: divides negative numbers', () => {
    expect(divide(-10, 2)).toBe(-5);
    expect(divide(10, -2)).toBe(-5);
    expect(divide(-10, -2)).toBe(5);
  });

  test('T8: divides resulting in decimal', () => {
    expect(divide(7, 2)).toBe(3.5);
    expect(divide(1, 3)).toBeCloseTo(0.333333, 5);
  });

  test('T8: divides zero by number', () => {
    expect(divide(0, 5)).toBe(0);
  });

  test('T9: throws error for division by zero', () => {
    expect(() => divide(10, 0)).toThrow('Division by zero');
    expect(() => divide(0, 0)).toThrow('Division by zero');
  });
});

describe('edge cases', () => {
  test('operations with large numbers', () => {
    expect(add(1000000, 2000000)).toBe(3000000);
    expect(multiply(1000, 1000)).toBe(1000000);
  });

  test('operations with very small decimals', () => {
    expect(add(0.0001, 0.0002)).toBeCloseTo(0.0003);
    expect(multiply(0.001, 0.001)).toBeCloseTo(0.000001);
  });
});
```

---

### 3. Run Tests

#### Python (pytest)

```bash
# Run tests
pytest tests/test_calculator.py -v

# Run with coverage
pytest tests/test_calculator.py --cov=src.calculator --cov-report=term-missing -v

# Expected output:
# - All tests pass (green)
# - Coverage ≥ 90% for calculator module
```

---

#### JavaScript (Jest)

```bash
# Run tests
npm test tests/calculator.test.js

# Run with coverage
npm test -- --coverage --testPathPattern=calculator.test.js

# Expected output:
# - All tests pass (green)
# - Coverage ≥ 90% for calculator module
```

---

### 4. Verify Test Results

**Success indicators**:
- All tests pass (no failures)
- Coverage for `calculator.{py|js}` ≥ 90%
- All four operations tested
- Edge cases covered (zero, negatives, decimals, division by zero)

**Example output**:
```
tests/test_calculator.py::TestAdd::test_add_positive_numbers PASSED
tests/test_calculator.py::TestAdd::test_add_negative_numbers PASSED
...
tests/test_calculator.py::TestDivide::test_divide_by_zero PASSED

========== 22 passed in 0.15s ==========

Coverage:
src/calculator.py    100%
```

---

### 5. Update BUILD_STATUS.md

Add Step 6 completion to the build log:

```markdown
### Step 6: Create Unit Tests (Calculator)
- **Started**: <ISO8601_timestamp>
- **Completed**: <ISO8601_timestamp>
- **Duration**: X minutes
- **Status**: ✅ PASS
- **Notes**: All 22+ tests passed, calculator module coverage: 100%
```

Update the progress checklist:
```markdown
- [x] Step 0: Build Configuration (COMPLETE)
- [x] Step 1: Initialize Project Structure (COMPLETE)
- [x] Step 2: Create Calculator Module (COMPLETE)
- [x] Step 3: Create Parser Module (COMPLETE)
- [x] Step 4: Create Formatter Module (COMPLETE)
- [x] Step 5: Create CLI Interface (COMPLETE)
- [x] Step 6: Create Unit Tests (Calculator) (COMPLETE)
- [ ] Step 7: Create Unit Tests (Parser & Formatter)
```

---

## Verification

### Success Criteria

- ✅ All unit tests pass (no failures)
- ✅ Test coverage ≥ 90% for calculator module
- ✅ All test requirements T1-T9 covered
- ✅ Tests include positive, negative, zero, and decimal cases
- ✅ Division by zero error properly tested
- ✅ Proper traceability comments in test file
- ✅ BUILD_STATUS.md updated

### Verification Commands

```bash
# Check test file exists
test -f tests/test_calculator.py && echo "✅ Python tests exist" || \
test -f tests/calculator.test.js && echo "✅ JavaScript tests exist"

# Verify traceability
grep -q "Implements: calculator-spec.md" tests/test_calculator.py || \
grep -q "Implements: calculator-spec.md" tests/calculator.test.js && echo "✅ Traceability present"

# Count tests (should be ≥ 20)
# Python:
grep -c "def test_" tests/test_calculator.py

# JavaScript:
grep -c "test(" tests/calculator.test.js

# Run tests with coverage
pytest tests/test_calculator.py --cov=src.calculator -v || \
npm test -- --coverage --testPathPattern=calculator.test.js
```

---

## Error Handling

### Common Issues

1. **Import errors**: Ensure src/calculator module exists and is correct
2. **Test failures**: Review expected vs actual output, fix implementation if needed
3. **Low coverage**: Add tests for missing branches/lines
4. **Floating point precision**: Use `pytest.approx()` or `toBeCloseTo()` for decimals

### Recovery

If tests fail:
1. Review error messages carefully
2. Fix implementation in src/calculator.{py|js} if incorrect
3. Fix test expectations if implementation is correct
4. Re-run tests
5. Maximum 3 attempts - escalate if still failing

---

## Next Step

**Step 7**: Create Unit Tests (Parser & Formatter) (calc-step_d4e5f6a1b2c3.md)

---

## Notes

- Tests organized by function using classes (Python) or describe blocks (Jest)
- Each test has descriptive name and references spec test ID (T1-T9)
- pytest.approx() and toBeCloseTo() handle floating-point precision issues
- Edge cases tested separately for clarity
- 100% coverage achievable for calculator module (simple functions)
- Tests follow AAA pattern: Arrange, Act, Assert

---

**Traceability**: Implements calculator-spec.md § 5.1 (Unit Tests - Calculator Module)
