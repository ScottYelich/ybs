# Step 3: Create Parser Module

**System**: calculator
**Step ID**: calc-step_89b9e6233da5
**Implements**: calculator-spec.md § 2.3 (Input Validation)
**Prerequisites**: Step 2 (Create Calculator Module)
**Duration**: 15-20 minutes

---

## Purpose

Implement the parser module that validates and parses user input. This module ensures operations are valid, numbers are numeric, and the correct number of arguments are provided.

---

## Inputs

- `BUILD_CONFIG.json` - Build configuration
- `src/parser.{py|js}` - Placeholder file from Step 1

**Required fields**:
- `language` - Determines implementation language

---

## Outputs

- `src/parser.{py|js}` - Complete parser module with validation

---

## Instructions

### 1. Read Configuration

```bash
# Read language from BUILD_CONFIG.json
LANGUAGE=$(python -c "import json; print(json.load(open('BUILD_CONFIG.json'))['language'])")
echo "Language: $LANGUAGE"
```

---

### 2. Implement Parser Module

Choose implementation based on language:

#### Python Implementation

**File**: `src/parser.py`

```python
# Implements: calculator-spec.md § 2.3 (Input Validation)
"""Input parsing and validation module.

This module validates user input and converts strings to appropriate types.
Validates operations, numeric values, and argument counts.
"""

from typing import Tuple


class InvalidOperationError(ValueError):
    """Raised when an invalid operation is provided."""
    pass


class InvalidNumberError(ValueError):
    """Raised when a non-numeric value is provided as operand."""
    pass


class ArgumentCountError(ValueError):
    """Raised when wrong number of arguments are provided."""
    pass


# Valid operations (case-insensitive)
VALID_OPERATIONS = {'add', 'subtract', 'multiply', 'divide'}


def parse(operation: str, *args: str) -> Tuple[str, float, float]:
    """Parse and validate calculator input.

    Implements: calculator-spec.md § 2.3 (F7, F8, F9)

    Args:
        operation: Operation name (add, subtract, multiply, divide)
        *args: Variable number of operand strings

    Returns:
        Tuple of (operation_lowercase, operand1, operand2)

    Raises:
        InvalidOperationError: If operation is not valid
        InvalidNumberError: If operand cannot be converted to number
        ArgumentCountError: If number of operands is not exactly 2

    Examples:
        >>> parse("add", "5", "3")
        ('add', 5.0, 3.0)
        >>> parse("ADD", "5", "3")
        ('add', 5.0, 3.0)
        >>> parse("multiply", "6", "7")
        ('multiply', 6.0, 7.0)
    """
    # Validate operation (F8)
    operation_lower = operation.lower()
    if operation_lower not in VALID_OPERATIONS:
        raise InvalidOperationError(
            f"Unknown operation '{operation}'. "
            f"Valid operations: {', '.join(sorted(VALID_OPERATIONS))}"
        )

    # Validate argument count (F9)
    if len(args) != 2:
        raise ArgumentCountError(
            f"Expected 2 operands, got {len(args)}"
        )

    # Validate and convert operands (F7)
    try:
        operand1 = float(args[0])
    except (ValueError, TypeError):
        raise InvalidNumberError(
            f"'{args[0]}' is not a valid number"
        )

    try:
        operand2 = float(args[1])
    except (ValueError, TypeError):
        raise InvalidNumberError(
            f"'{args[1]}' is not a valid number"
        )

    return operation_lower, operand1, operand2


def validate_operation(operation: str) -> bool:
    """Check if operation is valid.

    Args:
        operation: Operation name to validate

    Returns:
        True if valid, False otherwise
    """
    return operation.lower() in VALID_OPERATIONS


def parse_number(value: str) -> float:
    """Parse string to number.

    Args:
        value: String representation of number

    Returns:
        Numeric value as float

    Raises:
        InvalidNumberError: If value cannot be parsed
    """
    try:
        return float(value)
    except (ValueError, TypeError):
        raise InvalidNumberError(f"'{value}' is not a valid number")
```

---

#### JavaScript Implementation

**File**: `src/parser.js`

```javascript
// Implements: calculator-spec.md § 2.3 (Input Validation)
/**
 * Input parsing and validation module.
 *
 * This module validates user input and converts strings to appropriate types.
 * Validates operations, numeric values, and argument counts.
 */

/**
 * Custom error for invalid operations.
 */
class InvalidOperationError extends Error {
  constructor(message) {
    super(message);
    this.name = 'InvalidOperationError';
  }
}

/**
 * Custom error for invalid numbers.
 */
class InvalidNumberError extends Error {
  constructor(message) {
    super(message);
    this.name = 'InvalidNumberError';
  }
}

/**
 * Custom error for wrong argument count.
 */
class ArgumentCountError extends Error {
  constructor(message) {
    super(message);
    this.name = 'ArgumentCountError';
  }
}

// Valid operations (case-insensitive)
const VALID_OPERATIONS = new Set(['add', 'subtract', 'multiply', 'divide']);

/**
 * Parse and validate calculator input.
 *
 * Implements: calculator-spec.md § 2.3 (F7, F8, F9)
 *
 * @param {string} operation - Operation name (add, subtract, multiply, divide)
 * @param {...string} args - Variable number of operand strings
 * @returns {Array} Array of [operation_lowercase, operand1, operand2]
 * @throws {InvalidOperationError} If operation is not valid
 * @throws {InvalidNumberError} If operand cannot be converted to number
 * @throws {ArgumentCountError} If number of operands is not exactly 2
 *
 * @example
 * parse("add", "5", "3")  // returns ['add', 5.0, 3.0]
 * parse("ADD", "5", "3")  // returns ['add', 5.0, 3.0]
 * parse("multiply", "6", "7")  // returns ['multiply', 6.0, 7.0]
 */
function parse(operation, ...args) {
  // Validate operation (F8)
  const operationLower = operation.toLowerCase();
  if (!VALID_OPERATIONS.has(operationLower)) {
    const validOps = Array.from(VALID_OPERATIONS).sort().join(', ');
    throw new InvalidOperationError(
      `Unknown operation '${operation}'. Valid operations: ${validOps}`
    );
  }

  // Validate argument count (F9)
  if (args.length !== 2) {
    throw new ArgumentCountError(
      `Expected 2 operands, got ${args.length}`
    );
  }

  // Validate and convert operands (F7)
  const operand1 = parseNumber(args[0]);
  const operand2 = parseNumber(args[1]);

  return [operationLower, operand1, operand2];
}

/**
 * Check if operation is valid.
 *
 * @param {string} operation - Operation name to validate
 * @returns {boolean} True if valid, false otherwise
 */
function validateOperation(operation) {
  return VALID_OPERATIONS.has(operation.toLowerCase());
}

/**
 * Parse string to number.
 *
 * @param {string} value - String representation of number
 * @returns {number} Numeric value as float
 * @throws {InvalidNumberError} If value cannot be parsed
 */
function parseNumber(value) {
  const num = parseFloat(value);
  if (isNaN(num)) {
    throw new InvalidNumberError(`'${value}' is not a valid number`);
  }
  return num;
}

module.exports = {
  parse,
  validateOperation,
  parseNumber,
  InvalidOperationError,
  InvalidNumberError,
  ArgumentCountError
};
```

---

### 3. Verify Implementation

#### Manual Testing (Python)

```python
# Start Python REPL
python3

# Import and test
>>> from src.parser import parse, InvalidOperationError, InvalidNumberError, ArgumentCountError

# Test valid input
>>> parse("add", "5", "3")
('add', 5.0, 3.0)

# Test case insensitivity
>>> parse("ADD", "5", "3")
('add', 5.0, 3.0)

# Test invalid operation
>>> parse("unknown", "5", "3")
Traceback (most recent call last):
  ...
InvalidOperationError: Unknown operation 'unknown'. Valid operations: add, divide, multiply, subtract

# Test invalid number
>>> parse("add", "five", "3")
Traceback (most recent call last):
  ...
InvalidNumberError: 'five' is not a valid number

# Test wrong argument count
>>> parse("add", "5")
Traceback (most recent call last):
  ...
ArgumentCountError: Expected 2 operands, got 1
```

---

#### Manual Testing (JavaScript)

```bash
# Start Node REPL
node

# Import and test
> const { parse, InvalidOperationError, InvalidNumberError, ArgumentCountError } = require('./src/parser');

# Test valid input
> parse("add", "5", "3")
[ 'add', 5, 3 ]

# Test case insensitivity
> parse("ADD", "5", "3")
[ 'add', 5, 3 ]

# Test invalid operation
> parse("unknown", "5", "3")
InvalidOperationError: Unknown operation 'unknown'. Valid operations: add, divide, multiply, subtract

# Test invalid number
> parse("add", "five", "3")
InvalidNumberError: 'five' is not a valid number

# Test wrong argument count
> parse("add", "5")
ArgumentCountError: Expected 2 operands, got 1
```

---

### 4. Quick Smoke Test

Create a temporary test file to verify basic functionality:

#### Python Smoke Test

```bash
cat > test_smoke.py << 'EOF'
from src.parser import parse, InvalidOperationError, InvalidNumberError, ArgumentCountError

# Test valid parsing
op, a, b = parse("add", "5", "3")
assert op == "add" and a == 5.0 and b == 3.0, "Valid parse failed"
print("✅ Valid parse: add 5 3")

# Test case insensitivity
op, a, b = parse("MULTIPLY", "6", "7")
assert op == "multiply", "Case insensitivity failed"
print("✅ Case insensitivity: MULTIPLY → multiply")

# Test invalid operation
try:
    parse("unknown", "5", "3")
    print("❌ Should have raised InvalidOperationError")
except InvalidOperationError:
    print("✅ Invalid operation caught")

# Test invalid number
try:
    parse("add", "five", "3")
    print("❌ Should have raised InvalidNumberError")
except InvalidNumberError:
    print("✅ Invalid number caught")

# Test argument count
try:
    parse("add", "5")
    print("❌ Should have raised ArgumentCountError")
except ArgumentCountError:
    print("✅ Argument count error caught")

print("\n✅ All smoke tests passed")
EOF

python test_smoke.py
rm test_smoke.py
```

---

#### JavaScript Smoke Test

```bash
cat > test_smoke.js << 'EOF'
const { parse, InvalidOperationError, InvalidNumberError, ArgumentCountError } = require('./src/parser');

// Test valid parsing
let [op, a, b] = parse("add", "5", "3");
console.assert(op === "add" && a === 5 && b === 3, "Valid parse failed");
console.log("✅ Valid parse: add 5 3");

// Test case insensitivity
[op, a, b] = parse("MULTIPLY", "6", "7");
console.assert(op === "multiply", "Case insensitivity failed");
console.log("✅ Case insensitivity: MULTIPLY → multiply");

// Test invalid operation
try {
    parse("unknown", "5", "3");
    console.log("❌ Should have thrown InvalidOperationError");
} catch (e) {
    if (e instanceof InvalidOperationError) {
        console.log("✅ Invalid operation caught");
    }
}

// Test invalid number
try {
    parse("add", "five", "3");
    console.log("❌ Should have thrown InvalidNumberError");
} catch (e) {
    if (e instanceof InvalidNumberError) {
        console.log("✅ Invalid number caught");
    }
}

// Test argument count
try {
    parse("add", "5");
    console.log("❌ Should have thrown ArgumentCountError");
} catch (e) {
    if (e instanceof ArgumentCountError) {
        console.log("✅ Argument count error caught");
    }
}

console.log("\n✅ All smoke tests passed");
EOF

node test_smoke.js
rm test_smoke.js
```

---

### 5. Update BUILD_STATUS.md

Add Step 3 completion to the build log:

```markdown
### Step 3: Create Parser Module
- **Started**: <ISO8601_timestamp>
- **Completed**: <ISO8601_timestamp>
- **Duration**: X minutes
- **Status**: ✅ PASS
- **Notes**: Implemented input validation with custom error classes
```

Update the progress checklist:
```markdown
- [x] Step 0: Build Configuration (COMPLETE)
- [x] Step 1: Initialize Project Structure (COMPLETE)
- [x] Step 2: Create Calculator Module (COMPLETE)
- [x] Step 3: Create Parser Module (COMPLETE)
- [ ] Step 4: Create Formatter Module
```

---

## Verification

### Success Criteria

- ✅ Parser validates operations (case-insensitive)
- ✅ Parser validates numeric input
- ✅ Parser validates argument count
- ✅ Custom error classes defined for each validation type
- ✅ Proper traceability comments present
- ✅ All smoke tests pass
- ✅ BUILD_STATUS.md updated

### Verification Commands

```bash
# Check file exists
test -f src/parser.py && echo "✅ Python parser exists" || \
test -f src/parser.js && echo "✅ JavaScript parser exists"

# Verify traceability comments
# Python:
grep -q "Implements: calculator-spec.md" src/parser.py && echo "✅ Traceability present"

# JavaScript:
grep -q "Implements: calculator-spec.md" src/parser.js && echo "✅ Traceability present"

# Count custom error classes (should be 3)
# Python:
grep -c "^class.*Error" src/parser.py  # Should output: 3

# JavaScript:
grep -c "^class.*Error" src/parser.js  # Should output: 3

# Run smoke test (see section 4 above)
```

---

## Error Handling

### Common Issues

1. **Import errors**: Ensure module structure is correct
2. **Error inheritance**: Ensure custom errors extend proper base class
3. **Case sensitivity**: Remember to use `.lower()` or `.toLowerCase()` for operations

### Recovery

If step fails:
1. Restore placeholder: `git checkout src/parser.{py|js}`
2. Re-implement following instructions
3. Verify with smoke tests

---

## Next Step

**Step 4**: Create Formatter Module (calc-step_a1b2c3d4e5f6.md)

---

## Notes

- Three custom error types enable specific error handling in CLI
- Case-insensitive operation matching improves user experience
- Parser does not perform calculations, only validation and conversion
- Helper functions (`validate_operation`, `parse_number`) enable reuse
- Unit tests for this module will be written in Step 7

---

**Traceability**: Implements calculator-spec.md § 2.3 (Input Validation)
