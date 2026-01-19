# Step 8: Create Integration Tests

**System**: calculator
**Step ID**: calc-step_e5f6a1b2c3d4
**Implements**: calculator-spec.md § 5.4 (Integration Tests)
**Prerequisites**: Step 7 (Create Unit Tests - Parser & Formatter)
**Duration**: 20-30 minutes

---

## Purpose

Create integration tests that verify end-to-end functionality of the calculator system. These tests ensure all modules work together correctly by testing the CLI interface with actual command execution.

---

## Inputs

- `BUILD_CONFIG.json` - Build configuration
- All modules from Steps 2-5
- Test placeholder from Step 1

**Required fields**:
- `language` - Determines test approach
- `entry_point` - Name of executable to test
- `interactive_mode` - Whether to test interactive mode

---

## Outputs

- `tests/test_integration.{py|js}` - Complete integration tests

---

## Instructions

### 1. Read Configuration

```bash
# Read configuration
LANGUAGE=$(python -c "import json; c=json.load(open('BUILD_CONFIG.json')); print(c['language'])")
ENTRY_POINT=$(python -c "import json; c=json.load(open('BUILD_CONFIG.json')); print(c['entry_point'])")
INTERACTIVE=$(python -c "import json; c=json.load(open('BUILD_CONFIG.json')); print(c['interactive_mode'])")

echo "Language: $LANGUAGE"
echo "Entry Point: $ENTRY_POINT"
echo "Interactive Mode: $INTERACTIVE"
```

---

### 2. Implement Integration Tests

Choose implementation based on language:

#### Python Implementation

**File**: `tests/test_integration.py`

```python
# Implements: calculator-spec.md § 5.4 (Integration Tests)
"""Integration tests for calculator system.

Tests end-to-end functionality:
- CLI arguments mode with all operations
- Error handling through CLI
- Exit codes
- Interactive mode (if enabled)
"""

import subprocess
import sys
import json
import pytest


# Read configuration
with open('BUILD_CONFIG.json') as f:
    config = json.load(f)
    ENTRY_POINT = f"./{config['entry_point']}.py"
    INTERACTIVE_MODE = config['interactive_mode']


class TestCliMode:
    """Integration tests for CLI arguments mode."""

    def test_addition_cli(self):
        """Test T18: End-to-end addition via CLI."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "add", "5", "3"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert result.stdout.strip() == "8"

    def test_subtraction_cli(self):
        """Test T18: End-to-end subtraction via CLI."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "subtract", "10", "4"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert result.stdout.strip() == "6"

    def test_multiplication_cli(self):
        """Test T18: End-to-end multiplication via CLI."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "multiply", "6", "7"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert result.stdout.strip() == "42"

    def test_division_cli(self):
        """Test T18: End-to-end division via CLI."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "divide", "15", "3"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert result.stdout.strip() == "5"

    def test_decimal_result_cli(self):
        """Test CLI with decimal result."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "divide", "7", "2"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert result.stdout.strip() == "3.5"

    def test_negative_numbers_cli(self):
        """Test CLI with negative numbers."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "add", "-5", "3"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert result.stdout.strip() == "-2"


class TestErrorHandling:
    """Integration tests for error handling."""

    def test_division_by_zero_cli(self):
        """Test T19: End-to-end error handling for division by zero."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "divide", "10", "0"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 1
        assert "Error: Division by zero" in result.stdout

    def test_invalid_operation_cli(self):
        """Test T19: Error handling for invalid operation."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "unknown", "5", "3"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 1
        assert "Error:" in result.stdout
        assert "unknown" in result.stdout.lower()

    def test_invalid_number_cli(self):
        """Test T19: Error handling for invalid number."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "add", "five", "3"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 1
        assert "Error:" in result.stdout
        assert "five" in result.stdout

    def test_missing_arguments_cli(self):
        """Test T19: Error handling for missing arguments."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "add", "5"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 1
        assert "Error:" in result.stdout

    def test_no_arguments_shows_usage(self):
        """Test no arguments behavior."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT],
            capture_output=True,
            text=True,
            timeout=1,
            input="\n" if INTERACTIVE_MODE else ""
        )
        # If interactive mode, should start prompt
        # If not interactive, should show usage error
        if not INTERACTIVE_MODE:
            assert result.returncode == 1
            assert "Error:" in result.stdout or "Usage:" in result.stdout


class TestCaseInsensitivity:
    """Integration tests for case-insensitive operations."""

    def test_uppercase_operation(self):
        """Test operation with uppercase letters."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "ADD", "5", "3"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert result.stdout.strip() == "8"

    def test_mixed_case_operation(self):
        """Test operation with mixed case letters."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "MuLtIpLy", "6", "7"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert result.stdout.strip() == "42"


@pytest.mark.skipif(not INTERACTIVE_MODE, reason="Interactive mode disabled")
class TestInteractiveMode:
    """Integration tests for interactive mode."""

    def test_interactive_single_operation(self):
        """Test T20: Interactive mode with single operation."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT],
            input="add 5 3\nquit\n",
            capture_output=True,
            text=True,
            timeout=2
        )
        # Should show result in interactive format
        assert "5 + 3 = 8" in result.stdout or "8" in result.stdout
        assert result.returncode == 0

    def test_interactive_multiple_operations(self):
        """Test T20: Interactive mode with multiple operations."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT],
            input="add 5 3\nmultiply 6 7\nexit\n",
            capture_output=True,
            text=True,
            timeout=2
        )
        assert result.returncode == 0
        # Should process both operations
        output = result.stdout
        assert "8" in output or "5 + 3" in output
        assert "42" in output or "6 × 7" in output

    def test_interactive_error_recovery(self):
        """Test T20: Interactive mode recovers from errors."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT],
            input="divide 10 0\nadd 2 3\nquit\n",
            capture_output=True,
            text=True,
            timeout=2
        )
        assert result.returncode == 0
        # Should show error but continue
        assert "Error:" in result.stdout
        assert "5" in result.stdout or "2 + 3" in result.stdout

    def test_interactive_quit_commands(self):
        """Test various quit commands."""
        for quit_cmd in ["quit", "exit", "q"]:
            result = subprocess.run(
                [sys.executable, ENTRY_POINT],
                input=f"{quit_cmd}\n",
                capture_output=True,
                text=True,
                timeout=2
            )
            assert result.returncode == 0
            assert "Goodbye" in result.stdout or result.returncode == 0


class TestEdgeCases:
    """Additional edge case integration tests."""

    def test_zero_operations(self):
        """Test operations with zero."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "add", "0", "0"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert result.stdout.strip() == "0"

        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "multiply", "5", "0"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert result.stdout.strip() == "0"

    def test_large_numbers(self):
        """Test operations with large numbers."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "add", "1000000", "2000000"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert result.stdout.strip() == "3000000"

    def test_very_small_decimals(self):
        """Test operations with very small decimals."""
        result = subprocess.run(
            [sys.executable, ENTRY_POINT, "add", "0.1", "0.2"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        # Should be approximately 0.3 (formatted)
        output = result.stdout.strip()
        assert output.startswith("0.3")
```

---

#### JavaScript Implementation

**File**: `tests/integration.test.js`

```javascript
// Implements: calculator-spec.md § 5.4 (Integration Tests)
/**
 * Integration tests for calculator system.
 *
 * Tests end-to-end functionality:
 * - CLI arguments mode with all operations
 * - Error handling through CLI
 * - Exit codes
 * - Interactive mode (if enabled)
 */

const { execSync, spawn } = require('child_process');
const fs = require('fs');

// Read configuration
const config = JSON.parse(fs.readFileSync('BUILD_CONFIG.json', 'utf8'));
const ENTRY_POINT = `./${config.entry_point}.js`;
const INTERACTIVE_MODE = config.interactive_mode;

/**
 * Execute calculator CLI with arguments.
 */
function runCli(args) {
  try {
    const output = execSync(`node ${ENTRY_POINT} ${args.join(' ')}`, {
      encoding: 'utf8',
      timeout: 2000
    });
    return { stdout: output, stderr: '', exitCode: 0 };
  } catch (error) {
    return {
      stdout: error.stdout || '',
      stderr: error.stderr || '',
      exitCode: error.status || 1
    };
  }
}

/**
 * Execute calculator in interactive mode.
 */
function runInteractive(input) {
  return new Promise((resolve, reject) => {
    const proc = spawn('node', [ENTRY_POINT], {
      timeout: 2000
    });

    let stdout = '';
    let stderr = '';

    proc.stdout.on('data', (data) => {
      stdout += data.toString();
    });

    proc.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    proc.on('close', (code) => {
      resolve({ stdout, stderr, exitCode: code });
    });

    proc.on('error', (error) => {
      reject(error);
    });

    // Send input
    proc.stdin.write(input);
    proc.stdin.end();

    // Timeout
    setTimeout(() => {
      proc.kill();
      resolve({ stdout, stderr, exitCode: -1 });
    }, 2000);
  });
}

describe('CLI mode', () => {
  test('T18: addition via CLI', () => {
    const result = runCli(['add', '5', '3']);
    expect(result.exitCode).toBe(0);
    expect(result.stdout.trim()).toBe('8');
  });

  test('T18: subtraction via CLI', () => {
    const result = runCli(['subtract', '10', '4']);
    expect(result.exitCode).toBe(0);
    expect(result.stdout.trim()).toBe('6');
  });

  test('T18: multiplication via CLI', () => {
    const result = runCli(['multiply', '6', '7']);
    expect(result.exitCode).toBe(0);
    expect(result.stdout.trim()).toBe('42');
  });

  test('T18: division via CLI', () => {
    const result = runCli(['divide', '15', '3']);
    expect(result.exitCode).toBe(0);
    expect(result.stdout.trim()).toBe('5');
  });

  test('CLI with decimal result', () => {
    const result = runCli(['divide', '7', '2']);
    expect(result.exitCode).toBe(0);
    expect(result.stdout.trim()).toBe('3.5');
  });

  test('CLI with negative numbers', () => {
    const result = runCli(['add', '-5', '3']);
    expect(result.exitCode).toBe(0);
    expect(result.stdout.trim()).toBe('-2');
  });
});

describe('error handling', () => {
  test('T19: division by zero error', () => {
    const result = runCli(['divide', '10', '0']);
    expect(result.exitCode).toBe(1);
    expect(result.stdout).toMatch(/Error: Division by zero/);
  });

  test('T19: invalid operation error', () => {
    const result = runCli(['unknown', '5', '3']);
    expect(result.exitCode).toBe(1);
    expect(result.stdout).toMatch(/Error:/);
    expect(result.stdout.toLowerCase()).toMatch(/unknown/);
  });

  test('T19: invalid number error', () => {
    const result = runCli(['add', 'five', '3']);
    expect(result.exitCode).toBe(1);
    expect(result.stdout).toMatch(/Error:/);
    expect(result.stdout).toMatch(/five/);
  });

  test('T19: missing arguments error', () => {
    const result = runCli(['add', '5']);
    expect(result.exitCode).toBe(1);
    expect(result.stdout).toMatch(/Error:/);
  });
});

describe('case insensitivity', () => {
  test('uppercase operation', () => {
    const result = runCli(['ADD', '5', '3']);
    expect(result.exitCode).toBe(0);
    expect(result.stdout.trim()).toBe('8');
  });

  test('mixed case operation', () => {
    const result = runCli(['MuLtIpLy', '6', '7']);
    expect(result.exitCode).toBe(0);
    expect(result.stdout.trim()).toBe('42');
  });
});

if (INTERACTIVE_MODE) {
  describe('interactive mode', () => {
    test('T20: single operation in interactive mode', async () => {
      const result = await runInteractive('add 5 3\nquit\n');
      expect(result.exitCode).toBe(0);
      expect(result.stdout).toMatch(/8|5 \+ 3/);
    });

    test('T20: multiple operations in interactive mode', async () => {
      const result = await runInteractive('add 5 3\nmultiply 6 7\nexit\n');
      expect(result.exitCode).toBe(0);
      expect(result.stdout).toMatch(/8|5 \+ 3/);
      expect(result.stdout).toMatch(/42|6 × 7/);
    });

    test('T20: error recovery in interactive mode', async () => {
      const result = await runInteractive('divide 10 0\nadd 2 3\nquit\n');
      expect(result.exitCode).toBe(0);
      expect(result.stdout).toMatch(/Error:/);
      expect(result.stdout).toMatch(/5|2 \+ 3/);
    });

    test('quit commands', async () => {
      for (const quitCmd of ['quit', 'exit', 'q']) {
        const result = await runInteractive(`${quitCmd}\n`);
        expect(result.exitCode).toBe(0);
      }
    });
  });
}

describe('edge cases', () => {
  test('operations with zero', () => {
    expect(runCli(['add', '0', '0']).stdout.trim()).toBe('0');
    expect(runCli(['multiply', '5', '0']).stdout.trim()).toBe('0');
  });

  test('operations with large numbers', () => {
    const result = runCli(['add', '1000000', '2000000']);
    expect(result.exitCode).toBe(0);
    expect(result.stdout.trim()).toBe('3000000');
  });

  test('operations with very small decimals', () => {
    const result = runCli(['add', '0.1', '0.2']);
    expect(result.exitCode).toBe(0);
    expect(result.stdout.trim()).toMatch(/^0\.3/);
  });
});
```

---

### 3. Run Integration Tests

#### Python (pytest)

```bash
# Run integration tests
pytest tests/test_integration.py -v

# Run all tests with coverage
pytest tests/ --cov=src --cov-report=term --cov-report=html -v

# Expected: All tests pass, overall coverage ≥ 80%
```

---

#### JavaScript (Jest)

```bash
# Run integration tests
npm test tests/integration.test.js

# Run all tests with coverage
npm test -- --coverage

# Expected: All tests pass, overall coverage ≥ 80%
```

---

### 4. Verify Coverage Requirements

Check that overall code coverage meets requirements:

```bash
# Python: Check coverage report
pytest tests/ --cov=src --cov-report=term-missing

# JavaScript: Check coverage report
npm test -- --coverage

# Required: Overall coverage ≥ 80%
# Target: Overall coverage ≥ 90%
```

**If coverage is below 80%**:
- Add more tests for uncovered lines
- Focus on error paths and edge cases
- Maximum 3 attempts to reach coverage target

---

### 5. Update BUILD_STATUS.md

Add Step 8 completion to the build log:

```markdown
### Step 8: Create Integration Tests
- **Started**: <ISO8601_timestamp>
- **Completed**: <ISO8601_timestamp>
- **Duration**: X minutes
- **Status**: ✅ PASS
- **Notes**: All integration tests passed, overall coverage: X% (≥80% required)
```

Update progress:
```markdown
- [x] Step 7: Create Unit Tests (Parser & Formatter) (COMPLETE)
- [x] Step 8: Create Integration Tests (COMPLETE)
- [ ] Step 9: Create Documentation
```

---

## Verification

### Success Criteria

- ✅ All integration tests pass
- ✅ CLI mode tests work for all operations (T18)
- ✅ Error handling tests work (T19)
- ✅ Interactive mode tests work if enabled (T20)
- ✅ Overall code coverage ≥ 80% (target: 90%)
- ✅ All tests complete in < 5 seconds
- ✅ Proper traceability comments
- ✅ BUILD_STATUS.md updated

### Verification Commands

```bash
# Run all tests
pytest tests/ -v || npm test

# Check coverage
pytest tests/ --cov=src --cov-report=term || npm test -- --coverage

# Verify all test files exist
ls -la tests/

# Count total tests (should be 50+ across all files)
pytest tests/ --collect-only | grep "test session starts" -A 100
```

---

## Error Handling

### Common Issues

1. **Subprocess timeout**: Increase timeout values
2. **Interactive mode hangs**: Ensure quit command is sent
3. **Coverage below 80%**: Add tests for uncovered branches
4. **Exit code not propagated**: Check subprocess handling

### Recovery

If tests fail:
1. Review error output
2. Test CLI manually to verify functionality
3. Fix implementation if needed
4. Add missing tests if needed
5. Maximum 3 attempts

---

## Next Step

**Step 9**: Create Documentation (calc-step_f6a1b2c3d4e5.md)

---

## Notes

- Integration tests use subprocess to test actual CLI execution
- Tests verify both functionality and exit codes
- Interactive mode tests use stdin/stdout redirection
- Coverage threshold enforced at this step
- These are the final tests before documentation

---

**Traceability**: Implements calculator-spec.md § 5.4 (Integration Tests)
