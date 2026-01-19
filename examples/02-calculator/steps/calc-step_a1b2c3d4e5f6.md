# Step 4: Create Formatter Module

**System**: calculator
**Step ID**: calc-step_a1b2c3d4e5f6
**Implements**: calculator-spec.md § 2.4 (Output Formatting)
**Prerequisites**: Step 3 (Create Parser Module)
**Duration**: 10-15 minutes

---

## Purpose

Implement the formatter module that formats calculation results and error messages for display. This module ensures consistent output formatting with appropriate decimal precision.

---

## Inputs

- `BUILD_CONFIG.json` - Build configuration
- `src/formatter.{py|js}` - Placeholder file from Step 1

**Required fields**:
- `language` - Determines implementation language

---

## Outputs

- `src/formatter.{py|js}` - Complete formatter module

---

## Instructions

### 1. Read Configuration

```bash
# Read language from BUILD_CONFIG.json
LANGUAGE=$(python -c "import json; print(json.load(open('BUILD_CONFIG.json'))['language'])")
echo "Language: $LANGUAGE"
```

---

### 2. Implement Formatter Module

Choose implementation based on language:

#### Python Implementation

**File**: `src/formatter.py`

```python
# Implements: calculator-spec.md § 2.4 (Output Formatting)
"""Output formatting module.

This module formats calculation results and error messages for display.
Handles decimal precision and consistent error message formatting.
"""

import math


def format_result(value: float) -> str:
    """Format a calculation result for display.

    Implements: calculator-spec.md § 2.4 F10 (Result Display)

    - Shows integers without decimal point (8 instead of 8.0)
    - Shows decimals with up to 10 decimal places
    - Removes trailing zeros from decimals

    Args:
        value: Numeric result to format

    Returns:
        Formatted string representation

    Examples:
        >>> format_result(8.0)
        '8'
        >>> format_result(3.5)
        '3.5'
        >>> format_result(3.333333333333333)
        '3.3333333333'
        >>> format_result(10.0)
        '10'
    """
    # Check if value is effectively an integer
    if isinstance(value, float) and value == math.floor(value):
        return str(int(value))

    # Format with up to 10 decimal places, removing trailing zeros
    formatted = f"{value:.10f}".rstrip('0').rstrip('.')
    return formatted


def format_error(message: str) -> str:
    """Format an error message for display.

    Implements: calculator-spec.md § 2.4 F11 (Error Display)

    Args:
        message: Error message text

    Returns:
        Formatted error message with "Error: " prefix

    Examples:
        >>> format_error("Division by zero")
        'Error: Division by zero'
        >>> format_error("Invalid input")
        'Error: Invalid input'
    """
    return f"Error: {message}"


def format_interactive_result(operation: str, operand1: float,
                               operand2: float, result: float) -> str:
    """Format result for interactive mode with full expression.

    Args:
        operation: Operation performed
        operand1: First operand
        operand2: Second operand
        result: Calculation result

    Returns:
        Formatted string showing expression and result

    Examples:
        >>> format_interactive_result("add", 5, 3, 8)
        '5 + 3 = 8'
        >>> format_interactive_result("multiply", 6, 7, 42)
        '6 × 7 = 42'
    """
    # Map operation names to symbols
    symbols = {
        'add': '+',
        'subtract': '-',
        'multiply': '×',
        'divide': '÷'
    }

    symbol = symbols.get(operation, operation)
    op1_str = format_result(operand1)
    op2_str = format_result(operand2)
    result_str = format_result(result)

    return f"{op1_str} {symbol} {op2_str} = {result_str}"
```

---

#### JavaScript Implementation

**File**: `src/formatter.js`

```javascript
// Implements: calculator-spec.md § 2.4 (Output Formatting)
/**
 * Output formatting module.
 *
 * This module formats calculation results and error messages for display.
 * Handles decimal precision and consistent error message formatting.
 */

/**
 * Format a calculation result for display.
 *
 * Implements: calculator-spec.md § 2.4 F10 (Result Display)
 *
 * - Shows integers without decimal point (8 instead of 8.0)
 * - Shows decimals with up to 10 decimal places
 * - Removes trailing zeros from decimals
 *
 * @param {number} value - Numeric result to format
 * @returns {string} Formatted string representation
 *
 * @example
 * formatResult(8.0)  // returns '8'
 * formatResult(3.5)  // returns '3.5'
 * formatResult(3.333333333333333)  // returns '3.3333333333'
 * formatResult(10.0)  // returns '10'
 */
function formatResult(value) {
  // Check if value is effectively an integer
  if (Number.isInteger(value)) {
    return String(value);
  }

  // Format with up to 10 decimal places, removing trailing zeros
  const formatted = value.toFixed(10).replace(/\.?0+$/, '');
  return formatted;
}

/**
 * Format an error message for display.
 *
 * Implements: calculator-spec.md § 2.4 F11 (Error Display)
 *
 * @param {string} message - Error message text
 * @returns {string} Formatted error message with "Error: " prefix
 *
 * @example
 * formatError("Division by zero")  // returns 'Error: Division by zero'
 * formatError("Invalid input")  // returns 'Error: Invalid input'
 */
function formatError(message) {
  return `Error: ${message}`;
}

/**
 * Format result for interactive mode with full expression.
 *
 * @param {string} operation - Operation performed
 * @param {number} operand1 - First operand
 * @param {number} operand2 - Second operand
 * @param {number} result - Calculation result
 * @returns {string} Formatted string showing expression and result
 *
 * @example
 * formatInteractiveResult("add", 5, 3, 8)  // returns '5 + 3 = 8'
 * formatInteractiveResult("multiply", 6, 7, 42)  // returns '6 × 7 = 42'
 */
function formatInteractiveResult(operation, operand1, operand2, result) {
  // Map operation names to symbols
  const symbols = {
    'add': '+',
    'subtract': '-',
    'multiply': '×',
    'divide': '÷'
  };

  const symbol = symbols[operation] || operation;
  const op1Str = formatResult(operand1);
  const op2Str = formatResult(operand2);
  const resultStr = formatResult(result);

  return `${op1Str} ${symbol} ${op2Str} = ${resultStr}`;
}

module.exports = {
  formatResult,
  formatError,
  formatInteractiveResult
};
```

---

### 3. Verify Implementation

#### Manual Testing (Python)

```python
# Start Python REPL
python3

# Import and test
>>> from src.formatter import format_result, format_error, format_interactive_result

# Test integer formatting
>>> format_result(8.0)
'8'

# Test decimal formatting
>>> format_result(3.5)
'3.5'

# Test long decimal formatting
>>> format_result(3.333333333333333)
'3.3333333333'

# Test error formatting
>>> format_error("Division by zero")
'Error: Division by zero'

# Test interactive formatting
>>> format_interactive_result("add", 5, 3, 8)
'5 + 3 = 8'
```

---

#### Manual Testing (JavaScript)

```bash
# Start Node REPL
node

# Import and test
> const { formatResult, formatError, formatInteractiveResult } = require('./src/formatter');

# Test integer formatting
> formatResult(8.0)
'8'

# Test decimal formatting
> formatResult(3.5)
'3.5'

# Test long decimal formatting
> formatResult(3.333333333333333)
'3.3333333333'

# Test error formatting
> formatError("Division by zero")
'Error: Division by zero'

# Test interactive formatting
> formatInteractiveResult("add", 5, 3, 8)
'5 + 3 = 8'
```

---

### 4. Quick Smoke Test

Create a temporary test file to verify basic functionality:

#### Python Smoke Test

```bash
cat > test_smoke.py << 'EOF'
from src.formatter import format_result, format_error, format_interactive_result

# Test integer result
result = format_result(8.0)
assert result == "8", f"Expected '8', got '{result}'"
print("✅ Integer formatting: 8.0 → '8'")

# Test decimal result
result = format_result(3.5)
assert result == "3.5", f"Expected '3.5', got '{result}'"
print("✅ Decimal formatting: 3.5 → '3.5'")

# Test long decimal (should truncate to 10 places)
result = format_result(3.333333333333333)
assert result.startswith("3.3333"), f"Expected starts with '3.3333', got '{result}'"
assert len(result) <= 12, f"Result too long: '{result}'"
print(f"✅ Long decimal formatting: 3.333... → '{result}'")

# Test error formatting
error = format_error("Division by zero")
assert error == "Error: Division by zero", f"Expected 'Error: Division by zero', got '{error}'"
print("✅ Error formatting")

# Test interactive formatting
formatted = format_interactive_result("add", 5, 3, 8)
assert formatted == "5 + 3 = 8", f"Expected '5 + 3 = 8', got '{formatted}'"
print("✅ Interactive formatting")

print("\n✅ All smoke tests passed")
EOF

python test_smoke.py
rm test_smoke.py
```

---

#### JavaScript Smoke Test

```bash
cat > test_smoke.js << 'EOF'
const { formatResult, formatError, formatInteractiveResult } = require('./src/formatter');

// Test integer result
let result = formatResult(8.0);
console.assert(result === "8", `Expected '8', got '${result}'`);
console.log("✅ Integer formatting: 8.0 → '8'");

// Test decimal result
result = formatResult(3.5);
console.assert(result === "3.5", `Expected '3.5', got '${result}'`);
console.log("✅ Decimal formatting: 3.5 → '3.5'");

// Test long decimal (should truncate to 10 places)
result = formatResult(3.333333333333333);
console.assert(result.startsWith("3.3333"), `Expected starts with '3.3333', got '${result}'`);
console.assert(result.length <= 12, `Result too long: '${result}'`);
console.log(`✅ Long decimal formatting: 3.333... → '${result}'`);

// Test error formatting
const error = formatError("Division by zero");
console.assert(error === "Error: Division by zero", `Expected 'Error: Division by zero', got '${error}'`);
console.log("✅ Error formatting");

// Test interactive formatting
const formatted = formatInteractiveResult("add", 5, 3, 8);
console.assert(formatted === "5 + 3 = 8", `Expected '5 + 3 = 8', got '${formatted}'`);
console.log("✅ Interactive formatting");

console.log("\n✅ All smoke tests passed");
EOF

node test_smoke.js
rm test_smoke.js
```

---

### 5. Update BUILD_STATUS.md

Add Step 4 completion to the build log:

```markdown
### Step 4: Create Formatter Module
- **Started**: <ISO8601_timestamp>
- **Completed**: <ISO8601_timestamp>
- **Duration**: X minutes
- **Status**: ✅ PASS
- **Notes**: Implemented result and error formatting with decimal precision handling
```

Update the progress checklist:
```markdown
- [x] Step 0: Build Configuration (COMPLETE)
- [x] Step 1: Initialize Project Structure (COMPLETE)
- [x] Step 2: Create Calculator Module (COMPLETE)
- [x] Step 3: Create Parser Module (COMPLETE)
- [x] Step 4: Create Formatter Module (COMPLETE)
- [ ] Step 5: Create CLI Interface
```

---

## Verification

### Success Criteria

- ✅ Result formatting handles integers and decimals correctly
- ✅ Long decimals are truncated to max 10 places
- ✅ Error formatting adds "Error: " prefix consistently
- ✅ Interactive formatting shows mathematical symbols
- ✅ Proper traceability comments present
- ✅ All smoke tests pass
- ✅ BUILD_STATUS.md updated

### Verification Commands

```bash
# Check file exists
test -f src/formatter.py && echo "✅ Python formatter exists" || \
test -f src/formatter.js && echo "✅ JavaScript formatter exists"

# Verify traceability comments
# Python:
grep -q "Implements: calculator-spec.md" src/formatter.py && echo "✅ Traceability present"

# JavaScript:
grep -q "Implements: calculator-spec.md" src/formatter.js && echo "✅ Traceability present"

# Count exported functions (should be at least 2-3)
# Python:
grep -c "^def " src/formatter.py

# JavaScript:
grep -c "^function " src/formatter.js

# Run smoke test (see section 4 above)
```

---

## Error Handling

### Common Issues

1. **Decimal precision**: Ensure max 10 decimal places
2. **Integer detection**: Use proper method (Number.isInteger or math.floor)
3. **Trailing zeros**: Must be removed (3.50 → 3.5)

### Recovery

If step fails:
1. Restore placeholder: `git checkout src/formatter.{py|js}`
2. Re-implement following instructions
3. Verify with smoke tests

---

## Next Step

**Step 5**: Create CLI Interface (calc-step_b2c3d4e5f6a1.md)

---

## Notes

- Formatter is presentation layer only - no business logic
- Mathematical symbols (×, ÷) enhance interactive mode readability
- Decimal precision limit (10 places) prevents excessive output
- Integer detection ensures clean output for whole numbers
- Unit tests for this module will be written in Step 7

---

**Traceability**: Implements calculator-spec.md § 2.4 (Output Formatting)
