# Step 5: Create CLI Interface

**System**: calculator
**Step ID**: calc-step_b2c3d4e5f6a1
**Implements**: calculator-spec.md § 2.2 (Input Modes)
**Prerequisites**: Step 4 (Create Formatter Module)
**Duration**: 20-30 minutes

---

## Purpose

Implement the command-line interface that ties together all modules. This is the main entry point that handles both CLI arguments mode and interactive mode (if enabled).

---

## Inputs

- `BUILD_CONFIG.json` - Build configuration
- `src/cli.{py|js}` - Placeholder file from Step 1
- All modules from Steps 2-4: calculator, parser, formatter

**Required fields**:
- `language` - Determines implementation language
- `interactive_mode` - Whether to include interactive mode

---

## Outputs

- `src/cli.{py|js}` - Complete CLI interface module

---

## Instructions

### 1. Read Configuration

```bash
# Read configuration from BUILD_CONFIG.json
LANGUAGE=$(python -c "import json; c=json.load(open('BUILD_CONFIG.json')); print(c['language'])")
INTERACTIVE=$(python -c "import json; c=json.load(open('BUILD_CONFIG.json')); print(c['interactive_mode'])")

echo "Language: $LANGUAGE"
echo "Interactive Mode: $INTERACTIVE"
```

---

### 2. Implement CLI Module

Choose implementation based on language:

#### Python Implementation

**File**: `src/cli.py`

```python
# Implements: calculator-spec.md § 2.2 (Input Modes)
"""Command-line interface module.

This module provides the main entry point for the calculator.
Supports both CLI arguments mode and interactive mode.
"""

import sys
from typing import List, Optional

from src.calculator import add, subtract, multiply, divide
from src.parser import (
    parse,
    InvalidOperationError,
    InvalidNumberError,
    ArgumentCountError
)
from src.formatter import format_result, format_error, format_interactive_result


# Map operation names to functions
OPERATIONS = {
    'add': add,
    'subtract': subtract,
    'multiply': multiply,
    'divide': divide
}


def execute_operation(operation: str, operand1: float, operand2: float) -> float:
    """Execute a calculator operation.

    Args:
        operation: Operation name (add, subtract, multiply, divide)
        operand1: First operand
        operand2: Second operand

    Returns:
        Result of the operation

    Raises:
        ValueError: If operation is unknown or division by zero
    """
    if operation not in OPERATIONS:
        raise ValueError(f"Unknown operation: {operation}")

    func = OPERATIONS[operation]
    return func(operand1, operand2)


def run_cli_mode(args: List[str]) -> int:
    """Run calculator in CLI arguments mode.

    Implements: calculator-spec.md § 2.2 F5 (Command-Line Arguments Mode)

    Args:
        args: Command-line arguments (operation, num1, num2)

    Returns:
        Exit code (0 for success, 1 for error)
    """
    if len(args) < 3:
        print(format_error("Usage: calculator <operation> <num1> <num2>"))
        print("Operations: add, subtract, multiply, divide")
        return 1

    try:
        # Parse input
        operation, operand1, operand2 = parse(args[0], args[1], args[2])

        # Execute operation
        result = execute_operation(operation, operand1, operand2)

        # Format and print result
        print(format_result(result))
        return 0

    except (InvalidOperationError, InvalidNumberError, ArgumentCountError) as e:
        print(format_error(str(e)))
        return 1
    except ValueError as e:
        # Catch division by zero and other value errors
        print(format_error(str(e)))
        return 1
    except Exception as e:
        print(format_error(f"Unexpected error: {e}"))
        return 1


def run_interactive_mode() -> int:
    """Run calculator in interactive mode.

    Implements: calculator-spec.md § 2.2 F6 (Interactive Mode)

    Returns:
        Exit code (0 for success)
    """
    print("Calculator - Interactive Mode")
    print("Operations: add, subtract, multiply, divide")
    print("Type 'quit' or 'exit' to quit\n")

    while True:
        try:
            # Get user input
            user_input = input("> ").strip()

            # Check for quit commands
            if user_input.lower() in ('quit', 'exit', 'q'):
                print("Goodbye!")
                return 0

            # Skip empty input
            if not user_input:
                continue

            # Split input into parts
            parts = user_input.split()
            if len(parts) < 3:
                print(format_error("Usage: <operation> <num1> <num2>"))
                continue

            # Parse input
            operation, operand1, operand2 = parse(parts[0], parts[1], parts[2])

            # Execute operation
            result = execute_operation(operation, operand1, operand2)

            # Format and print result (with expression for interactive mode)
            print(format_interactive_result(operation, operand1, operand2, result))

        except (InvalidOperationError, InvalidNumberError, ArgumentCountError) as e:
            print(format_error(str(e)))
        except ValueError as e:
            # Catch division by zero
            print(format_error(str(e)))
        except KeyboardInterrupt:
            print("\nGoodbye!")
            return 0
        except EOFError:
            print("\nGoodbye!")
            return 0
        except Exception as e:
            print(format_error(f"Unexpected error: {e}"))


def main(args: Optional[List[str]] = None) -> int:
    """Main entry point for calculator.

    Implements: calculator-spec.md § 2.2 (Input Modes)

    Args:
        args: Command-line arguments (defaults to sys.argv[1:])

    Returns:
        Exit code (0 for success, non-zero for error)
    """
    if args is None:
        args = sys.argv[1:]

    # If no arguments provided, run interactive mode
    # Otherwise, run CLI mode
    if len(args) == 0:
        # Check if interactive mode is enabled
        # (This would be read from BUILD_CONFIG.json in production)
        return run_interactive_mode()
    else:
        return run_cli_mode(args)


if __name__ == "__main__":
    sys.exit(main())
```

**If interactive mode is disabled**, replace the interactive mode check in `main()`:

```python
def main(args: Optional[List[str]] = None) -> int:
    """Main entry point for calculator."""
    if args is None:
        args = sys.argv[1:]

    # Interactive mode disabled - require arguments
    if len(args) == 0:
        print(format_error("Usage: calculator <operation> <num1> <num2>"))
        print("Operations: add, subtract, multiply, divide")
        return 1

    return run_cli_mode(args)
```

---

#### JavaScript Implementation

**File**: `src/cli.js`

```javascript
// Implements: calculator-spec.md § 2.2 (Input Modes)
/**
 * Command-line interface module.
 *
 * This module provides the main entry point for the calculator.
 * Supports both CLI arguments mode and interactive mode.
 */

const readline = require('readline');
const { add, subtract, multiply, divide } = require('./calculator');
const {
  parse,
  InvalidOperationError,
  InvalidNumberError,
  ArgumentCountError
} = require('./parser');
const {
  formatResult,
  formatError,
  formatInteractiveResult
} = require('./formatter');

// Map operation names to functions
const OPERATIONS = {
  'add': add,
  'subtract': subtract,
  'multiply': multiply,
  'divide': divide
};

/**
 * Execute a calculator operation.
 *
 * @param {string} operation - Operation name (add, subtract, multiply, divide)
 * @param {number} operand1 - First operand
 * @param {number} operand2 - Second operand
 * @returns {number} Result of the operation
 * @throws {Error} If operation is unknown or division by zero
 */
function executeOperation(operation, operand1, operand2) {
  if (!(operation in OPERATIONS)) {
    throw new Error(`Unknown operation: ${operation}`);
  }

  const func = OPERATIONS[operation];
  return func(operand1, operand2);
}

/**
 * Run calculator in CLI arguments mode.
 *
 * Implements: calculator-spec.md § 2.2 F5 (Command-Line Arguments Mode)
 *
 * @param {string[]} args - Command-line arguments (operation, num1, num2)
 * @returns {number} Exit code (0 for success, 1 for error)
 */
function runCliMode(args) {
  if (args.length < 3) {
    console.log(formatError("Usage: calculator <operation> <num1> <num2>"));
    console.log("Operations: add, subtract, multiply, divide");
    return 1;
  }

  try {
    // Parse input
    const [operation, operand1, operand2] = parse(args[0], args[1], args[2]);

    // Execute operation
    const result = executeOperation(operation, operand1, operand2);

    // Format and print result
    console.log(formatResult(result));
    return 0;

  } catch (e) {
    if (e instanceof InvalidOperationError ||
        e instanceof InvalidNumberError ||
        e instanceof ArgumentCountError ||
        e instanceof Error) {
      console.log(formatError(e.message));
      return 1;
    }
    console.log(formatError(`Unexpected error: ${e}`));
    return 1;
  }
}

/**
 * Run calculator in interactive mode.
 *
 * Implements: calculator-spec.md § 2.2 F6 (Interactive Mode)
 *
 * @returns {Promise<number>} Exit code (0 for success)
 */
function runInteractiveMode() {
  return new Promise((resolve) => {
    console.log("Calculator - Interactive Mode");
    console.log("Operations: add, subtract, multiply, divide");
    console.log("Type 'quit' or 'exit' to quit\n");

    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
      prompt: '> '
    });

    rl.prompt();

    rl.on('line', (line) => {
      const userInput = line.trim();

      // Check for quit commands
      if (['quit', 'exit', 'q'].includes(userInput.toLowerCase())) {
        console.log("Goodbye!");
        rl.close();
        resolve(0);
        return;
      }

      // Skip empty input
      if (!userInput) {
        rl.prompt();
        return;
      }

      // Split input into parts
      const parts = userInput.split(/\s+/);
      if (parts.length < 3) {
        console.log(formatError("Usage: <operation> <num1> <num2>"));
        rl.prompt();
        return;
      }

      try {
        // Parse input
        const [operation, operand1, operand2] = parse(parts[0], parts[1], parts[2]);

        // Execute operation
        const result = executeOperation(operation, operand1, operand2);

        // Format and print result (with expression for interactive mode)
        console.log(formatInteractiveResult(operation, operand1, operand2, result));

      } catch (e) {
        if (e instanceof InvalidOperationError ||
            e instanceof InvalidNumberError ||
            e instanceof ArgumentCountError ||
            e instanceof Error) {
          console.log(formatError(e.message));
        } else {
          console.log(formatError(`Unexpected error: ${e}`));
        }
      }

      rl.prompt();
    });

    rl.on('close', () => {
      console.log("\nGoodbye!");
      resolve(0);
    });
  });
}

/**
 * Main entry point for calculator.
 *
 * Implements: calculator-spec.md § 2.2 (Input Modes)
 *
 * @param {string[]} [args] - Command-line arguments (defaults to process.argv.slice(2))
 * @returns {number|Promise<number>} Exit code (0 for success, non-zero for error)
 */
function main(args) {
  if (args === undefined) {
    args = process.argv.slice(2);
  }

  // If no arguments provided, run interactive mode
  // Otherwise, run CLI mode
  if (args.length === 0) {
    // Check if interactive mode is enabled
    // (This would be read from BUILD_CONFIG.json in production)
    return runInteractiveMode();
  } else {
    return runCliMode(args);
  }
}

/**
 * If interactive mode is disabled, use this main function instead:
 *
 * function main(args) {
 *   if (args === undefined) {
 *     args = process.argv.slice(2);
 *   }
 *
 *   // Interactive mode disabled - require arguments
 *   if (args.length === 0) {
 *     console.log(formatError("Usage: calculator <operation> <num1> <num2>"));
 *     console.log("Operations: add, subtract, multiply, divide");
 *     return 1;
 *   }
 *
 *   return runCliMode(args);
 * }
 */

module.exports = {
  main,
  runCliMode,
  runInteractiveMode,
  executeOperation
};
```

---

### 3. Update Entry Point

Update the main executable to properly call the CLI module:

#### Python Entry Point

**File**: `calculator.py` (or your configured entry point name)

```python
#!/usr/bin/env python3
# Implements: calculator-spec.md § 2.2 (Input Modes)
"""Calculator entry point."""

import sys
from src.cli import main

if __name__ == "__main__":
    sys.exit(main())
```

---

#### JavaScript Entry Point

**File**: `calculator.js` (or your configured entry point name)

```javascript
#!/usr/bin/env node
// Implements: calculator-spec.md § 2.2 (Input Modes)
/**
 * Calculator entry point.
 */

const { main } = require('./src/cli');

const exitCode = main();

// Handle Promise for interactive mode
if (exitCode instanceof Promise) {
  exitCode.then(code => process.exit(code));
} else {
  process.exit(exitCode);
}
```

---

### 4. Manual Testing

#### Test CLI Mode (Python)

```bash
# Test addition
./calculator.py add 5 3
# Expected: 8

# Test subtraction
./calculator.py subtract 10 4
# Expected: 6

# Test multiplication
./calculator.py multiply 6 7
# Expected: 42

# Test division
./calculator.py divide 15 3
# Expected: 5

# Test division by zero
./calculator.py divide 10 0
# Expected: Error: Division by zero

# Test invalid operation
./calculator.py unknown 5 3
# Expected: Error: Unknown operation 'unknown'...

# Test invalid number
./calculator.py add five 3
# Expected: Error: 'five' is not a valid number
```

---

#### Test CLI Mode (JavaScript)

```bash
# Test addition
./calculator.js add 5 3
# Expected: 8

# Test subtraction
./calculator.js subtract 10 4
# Expected: 6

# Test multiplication
./calculator.js multiply 6 7
# Expected: 42

# Test division
./calculator.js divide 15 3
# Expected: 5

# Test division by zero
./calculator.js divide 10 0
# Expected: Error: Division by zero

# Test invalid operation
./calculator.js unknown 5 3
# Expected: Error: Unknown operation 'unknown'...

# Test invalid number
./calculator.js add five 3
# Expected: Error: 'five' is not a valid number
```

---

#### Test Interactive Mode (if enabled)

```bash
# Start interactive mode
./calculator.py  # or ./calculator.js

# At the prompt, try:
> add 5 3
# Expected: 5 + 3 = 8

> multiply 6 7
# Expected: 6 × 7 = 42

> divide 10 0
# Expected: Error: Division by zero

> quit
# Expected: Goodbye!
```

---

### 5. Update BUILD_STATUS.md

Add Step 5 completion to the build log:

```markdown
### Step 5: Create CLI Interface
- **Started**: <ISO8601_timestamp>
- **Completed**: <ISO8601_timestamp>
- **Duration**: X minutes
- **Status**: ✅ PASS
- **Notes**: Implemented CLI and interactive modes, all manual tests passed
```

Update the progress checklist:
```markdown
- [x] Step 0: Build Configuration (COMPLETE)
- [x] Step 1: Initialize Project Structure (COMPLETE)
- [x] Step 2: Create Calculator Module (COMPLETE)
- [x] Step 3: Create Parser Module (COMPLETE)
- [x] Step 4: Create Formatter Module (COMPLETE)
- [x] Step 5: Create CLI Interface (COMPLETE)
- [ ] Step 6: Create Unit Tests (Calculator)
```

---

## Verification

### Success Criteria

- ✅ CLI arguments mode works for all operations
- ✅ Interactive mode works (if enabled)
- ✅ Error handling works for all error types
- ✅ Exit codes correct (0 for success, 1 for errors)
- ✅ Entry point script is executable
- ✅ Proper traceability comments present
- ✅ All manual tests pass
- ✅ BUILD_STATUS.md updated

### Verification Commands

```bash
# Check CLI module exists
test -f src/cli.py && echo "✅ Python CLI exists" || \
test -f src/cli.js && echo "✅ JavaScript CLI exists"

# Verify traceability comments
grep -q "Implements: calculator-spec.md" src/cli.py || \
grep -q "Implements: calculator-spec.md" src/cli.js && echo "✅ Traceability present"

# Verify entry point is executable
test -x calculator.py || test -x calculator.js && echo "✅ Entry point executable"

# Quick functional test
./calculator.py add 5 3 || ./calculator.js add 5 3
# Expected output: 8
```

---

## Error Handling

### Common Issues

1. **Import errors**: Ensure all modules are in correct locations
2. **Permission denied**: Ensure entry point is executable (`chmod +x`)
3. **Interactive mode hangs**: Ensure readline (JS) or input() (Python) work properly
4. **Exit code not returned**: Ensure main() returns integer

### Recovery

If step fails:
1. Check all previous modules are complete (Steps 2-4)
2. Verify import statements/require paths
3. Test each module independently
4. Re-run manual tests

---

## Next Step

**Step 6**: Create Unit Tests (Calculator) (calc-step_c3d4e5f6a1b2.md)

---

## Notes

- CLI module integrates all previous modules
- Error handling uses try-except blocks for each error type
- Interactive mode uses readline (JS) or input() (Python) for user input
- Exit codes follow Unix convention (0=success, non-zero=error)
- This completes the functional implementation - remaining steps add tests and docs

---

**Traceability**: Implements calculator-spec.md § 2.2 (Input Modes)
