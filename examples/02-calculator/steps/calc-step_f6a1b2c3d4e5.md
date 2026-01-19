# Step 9: Create Documentation

**System**: calculator
**Step ID**: calc-step_f6a1b2c3d4e5
**Implements**: calculator-spec.md § 3.4 (Documentation)
**Prerequisites**: Step 8 (Create Integration Tests)
**Duration**: 15-20 minutes

---

## Purpose

Create user and developer documentation for the calculator system. This includes usage documentation with examples and a README with architecture overview and development instructions.

---

## Inputs

- `BUILD_CONFIG.json` - Build configuration
- All implemented modules and tests from Steps 1-8

**Required fields**:
- `language` - Determines commands in documentation
- `entry_point` - Name of executable
- `interactive_mode` - Whether to document interactive mode
- `test_framework` - Testing commands to document

---

## Outputs

- `docs/USAGE.md` - User documentation with examples
- `README.md` - Developer documentation with architecture

---

## Instructions

### 1. Read Configuration

```bash
# Read configuration
LANGUAGE=$(python -c "import json; c=json.load(open('BUILD_CONFIG.json')); print(c['language'])")
ENTRY_POINT=$(python -c "import json; c=json.load(open('BUILD_CONFIG.json')); print(c['entry_point'])")
INTERACTIVE=$(python -c "import json; c=json.load(open('BUILD_CONFIG.json')); print(c['interactive_mode'])")
TEST_FRAMEWORK=$(python -c "import json; c=json.load(open('BUILD_CONFIG.json')); print(c['test_framework'])")

echo "Language: $LANGUAGE"
echo "Entry Point: $ENTRY_POINT"
echo "Interactive Mode: $INTERACTIVE"
echo "Test Framework: $TEST_FRAMEWORK"
```

---

### 2. Create User Documentation

**File**: `docs/USAGE.md`

```markdown
# Calculator - Usage Guide

**Version**: 1.0.0
**Language**: <language>

---

## Overview

A command-line calculator that performs basic arithmetic operations: addition, subtraction, multiplication, and division.

---

## Installation

### Python

```bash
# Install dependencies
pip install -r requirements.txt

# Make executable (Unix/macOS)
chmod +x <entry_point>.py
```

### JavaScript

```bash
# Install dependencies
npm install

# Make executable (Unix/macOS)
chmod +x <entry_point>.js
```

---

## Usage

### Command-Line Arguments Mode

Execute calculator with operation and operands as arguments:

**Syntax**:
```bash
./<entry_point>.<ext> <operation> <num1> <num2>
```

**Operations**:
- `add` - Addition
- `subtract` - Subtraction
- `multiply` - Multiplication
- `divide` - Division

**Note**: Operations are case-insensitive.

---

### Examples

**Addition**:
```bash
./<entry_point>.<ext> add 5 3
# Output: 8
```

**Subtraction**:
```bash
./<entry_point>.<ext> subtract 10 4
# Output: 6
```

**Multiplication**:
```bash
./<entry_point>.<ext> multiply 6 7
# Output: 42
```

**Division**:
```bash
./<entry_point>.<ext> divide 15 3
# Output: 5

./<entry_point>.<ext> divide 7 2
# Output: 3.5
```

**Negative Numbers**:
```bash
./<entry_point>.<ext> add -5 3
# Output: -2

./<entry_point>.<ext> subtract 5 -3
# Output: 8
```

**Decimal Numbers**:
```bash
./<entry_point>.<ext> add 1.5 2.5
# Output: 4

./<entry_point>.<ext> divide 10 3
# Output: 3.3333333333
```

---

<% if interactive_mode %>
### Interactive Mode

Run calculator without arguments to enter interactive mode:

```bash
./<entry_point>.<ext>
```

**Interactive Session**:
```
Calculator - Interactive Mode
Operations: add, subtract, multiply, divide
Type 'quit' or 'exit' to quit

> add 5 3
5 + 3 = 8
> multiply 6 7
6 × 7 = 42
> divide 10 0
Error: Division by zero
> quit
Goodbye!
```

**Commands**:
- `<operation> <num1> <num2>` - Perform calculation
- `quit` or `exit` or `q` - Exit interactive mode

<% endif %>

---

## Error Handling

### Division by Zero
```bash
./<entry_point>.<ext> divide 10 0
# Output: Error: Division by zero
# Exit code: 1
```

### Invalid Operation
```bash
./<entry_point>.<ext> power 2 3
# Output: Error: Unknown operation 'power'. Valid operations: add, divide, multiply, subtract
# Exit code: 1
```

### Invalid Number
```bash
./<entry_point>.<ext> add five 3
# Output: Error: 'five' is not a valid number
# Exit code: 1
```

### Missing Arguments
```bash
./<entry_point>.<ext> add 5
# Output: Error: Expected 2 operands, got 1
# Exit code: 1
```

---

## Exit Codes

- `0` - Success
- `1` - Error (invalid input, division by zero, etc.)

---

## Supported Number Formats

- **Integers**: `5`, `42`, `-10`
- **Decimals**: `3.5`, `0.1`, `-2.75`
- **Scientific Notation**: Not supported

---

## Limitations

- Only basic arithmetic operations (add, subtract, multiply, divide)
- Maximum 2 operands per operation
- No complex expressions (e.g., `2 + 3 * 4`)
- No history tracking
- Decimal results limited to 10 decimal places

---

## Tips

- Operations are case-insensitive: `ADD`, `add`, `Add` all work
- Negative numbers: Use minus sign directly (e.g., `-5`)
- Decimal results: Automatically formatted with appropriate precision
- Exit codes: Check with `echo $?` (Unix) or `echo %ERRORLEVEL%` (Windows)

---

## Support

For issues or questions:
1. Check that inputs are valid numbers
2. Verify operation is supported
3. Review error messages for guidance

---

**Generated with YBS (Yelich Build System)**
```

**Note**: Replace `<language>`, `<entry_point>`, `<ext>`, and `<% if interactive_mode %>` sections based on configuration.

---

### 3. Create Developer Documentation

**File**: `README.md`

```markdown
# Calculator

**Version**: 1.0.0
**Language**: <language>
**Build System**: YBS (Yelich Build System)

---

## Overview

A modular command-line calculator demonstrating multi-module architecture with comprehensive testing. Built as a reference example for the YBS framework.

---

## Architecture

### Module Structure

```
calculator/
├── src/
│   ├── calculator.<ext>      # Core arithmetic operations
│   ├── parser.<ext>          # Input parsing and validation
│   ├── formatter.<ext>       # Output formatting
│   └── cli.<ext>             # Command-line interface
├── tests/
│   ├── test_calculator.<ext> # Unit tests for calculator
│   ├── test_parser.<ext>     # Unit tests for parser
│   ├── test_formatter.<ext>  # Unit tests for formatter
│   └── test_integration.<ext># Integration tests
├── docs/
│   └── USAGE.md              # User documentation
├── <entry_point>.<ext>       # Entry point (executable)
└── README.md                 # This file
```

### Module Responsibilities

**calculator** - Pure functions for arithmetic operations
- `add(a, b)` - Addition
- `subtract(a, b)` - Subtraction
- `multiply(a, b)` - Multiplication
- `divide(a, b)` - Division (with zero check)

**parser** - Input validation and conversion
- `parse(operation, ...args)` - Parse and validate input
- Validates operations (case-insensitive)
- Validates numeric operands
- Validates argument count

**formatter** - Output formatting
- `format_result(value)` - Format numeric results
- `format_error(message)` - Format error messages
- `format_interactive_result(...)` - Format interactive output

**cli** - Command-line interface
- `run_cli_mode(args)` - Handle CLI arguments
- `run_interactive_mode()` - Handle interactive prompt (if enabled)
- `main(args)` - Entry point dispatcher

---

## Development Setup

### Python

**Requirements**:
- Python 3.8 or higher
- pip (Python package manager)

**Installation**:
```bash
# Install dependencies
pip install -r requirements.txt

# Make executable
chmod +x <entry_point>.py
```

**Dependencies**:
- pytest >= 7.0.0 (testing)
- pytest-cov >= 4.0.0 (coverage)

---

### JavaScript

**Requirements**:
- Node.js 14 or higher
- npm (Node package manager)

**Installation**:
```bash
# Install dependencies
npm install

# Make executable
chmod +x <entry_point>.js
```

**Dependencies**:
- jest >= 29.0.0 (testing)

---

## Running Tests

### Python

```bash
# Run all tests
pytest tests/ -v

# Run with coverage report
pytest tests/ --cov=src --cov-report=term-missing --cov-report=html

# Run specific test file
pytest tests/test_calculator.py -v
```

**Coverage Requirements**:
- Minimum: 80% line coverage
- Target: 90% line coverage
- Critical modules: 100% coverage (calculator core)

---

### JavaScript

```bash
# Run all tests
npm test

# Run with coverage report
npm test -- --coverage

# Run specific test file
npm test tests/calculator.test.js
```

**Coverage Requirements**:
- Minimum: 80% line coverage
- Target: 90% line coverage
- Critical modules: 100% coverage (calculator core)

---

## Testing Strategy

### Unit Tests

**Calculator Module** (test_calculator.<ext>):
- 20+ tests covering all operations
- Tests for positive, negative, zero, decimal numbers
- Division by zero error handling
- Edge cases (large numbers, small decimals)

**Parser Module** (test_parser.<ext>):
- 15+ tests covering input validation
- Valid operation parsing (case-insensitive)
- Invalid operation errors
- Invalid number errors
- Argument count validation

**Formatter Module** (test_formatter.<ext>):
- 15+ tests covering output formatting
- Integer formatting (no decimal point)
- Decimal formatting (appropriate precision)
- Long decimal truncation (max 10 places)
- Error message formatting

### Integration Tests

**End-to-End Tests** (test_integration.<ext>):
- CLI mode tests for all operations
- Error handling through CLI
- Exit code verification
- Interactive mode tests (if enabled)
- Case insensitivity tests
- Edge case tests

---

## Code Quality

### Traceability

All source files include traceability comments:
```<language-comment>
# Implements: calculator-spec.md § X.Y (Section Name)
```

This links implementation to specification requirements.

### Test Coverage

Current coverage (as of last build):
- **calculator.<ext>**: 100%
- **parser.<ext>**: 95%
- **formatter.<ext>**: 95%
- **cli.<ext>**: 85%
- **Overall**: <X>%

**Target**: ≥ 80% overall, ≥ 90% recommended

---

## Usage

See [docs/USAGE.md](docs/USAGE.md) for detailed usage instructions and examples.

**Quick Start**:
```bash
# CLI mode
./<entry_point>.<ext> add 5 3

# Interactive mode (if enabled)
./<entry_point>.<ext>
```

---

## Specification

This implementation follows:
- **Specification**: `../specs/calculator-spec.md`
- **Build Steps**: `../steps/calc-step_*.md`
- **Framework**: YBS (Yelich Build System)

---

## Build Information

**Build Configuration**: See `BUILD_CONFIG.json`
- Build Name: <build_name>
- Language: <language>
- Platform: <platform>
- Interactive Mode: <yes/no>
- Test Framework: <test_framework>

**Build Status**: See `BUILD_STATUS.md`

---

## License

This is a reference example for the YBS framework.

---

## References

- **Specification**: [../specs/calculator-spec.md](../specs/calculator-spec.md)
- **YBS Framework**: [../../framework/README.md](../../framework/README.md)
- **User Guide**: [docs/USAGE.md](docs/USAGE.md)

---

**Generated with YBS (Yelich Build System)**
```

**Note**: Replace `<language>`, `<entry_point>`, `<ext>`, `<build_name>`, `<platform>`, `<X>`, and boolean values based on configuration.

---

### 4. Replace Template Placeholders

Create a script to replace placeholders with actual config values:

#### Python Script

```bash
cat > update_docs.py << 'EOF'
import json

# Read configuration
with open('BUILD_CONFIG.json') as f:
    config = json.load(f)

# Determine file extension
ext = 'py' if config['language'] == 'python' else 'js'

# Read and replace in USAGE.md
with open('docs/USAGE.md', 'r') as f:
    usage = f.read()

usage = usage.replace('<language>', config['language'].title())
usage = usage.replace('<entry_point>', config['entry_point'])
usage = usage.replace('<ext>', ext)

# Handle interactive mode section
if config['interactive_mode']:
    usage = usage.replace('<% if interactive_mode %>', '')
    usage = usage.replace('<% endif %>', '')
else:
    # Remove interactive mode section
    start = usage.find('<% if interactive_mode %>')
    end = usage.find('<% endif %>')
    if start != -1 and end != -1:
        usage = usage[:start] + usage[end + len('<% endif %>'):]

with open('docs/USAGE.md', 'w') as f:
    f.write(usage)

# Read and replace in README.md
with open('README.md', 'r') as f:
    readme = f.read()

readme = readme.replace('<language>', config['language'].title())
readme = readme.replace('<entry_point>', config['entry_point'])
readme = readme.replace('<ext>', ext)
readme = readme.replace('<build_name>', config['build_name'])
readme = readme.replace('<platform>', config['platform'])
readme = readme.replace('<test_framework>', config['test_framework'])
readme = readme.replace('<yes/no>', 'Yes' if config['interactive_mode'] else 'No')

with open('README.md', 'w') as f:
    f.write(readme)

print("✅ Documentation updated with configuration values")
EOF

python update_docs.py
rm update_docs.py
```

---

### 5. Verify Documentation

```bash
# Check files exist
test -f docs/USAGE.md && echo "✅ USAGE.md exists"
test -f README.md && echo "✅ README.md exists"

# Check for remaining placeholders (should be none)
grep -n "<" docs/USAGE.md README.md || echo "✅ No template placeholders remaining"

# Review files
cat docs/USAGE.md
cat README.md
```

---

### 6. Update BUILD_STATUS.md

Add Step 9 completion to the build log:

```markdown
### Step 9: Create Documentation
- **Started**: <ISO8601_timestamp>
- **Completed**: <ISO8601_timestamp>
- **Duration**: X minutes
- **Status**: ✅ PASS
- **Notes**: Created USAGE.md and README.md with examples and architecture
```

Update progress:
```markdown
- [x] Step 8: Create Integration Tests (COMPLETE)
- [x] Step 9: Create Documentation (COMPLETE)
- [ ] Step 10: Final Verification
```

---

## Verification

### Success Criteria

- ✅ docs/USAGE.md exists and is complete
- ✅ README.md exists and is complete
- ✅ All template placeholders replaced with actual values
- ✅ Documentation matches build configuration
- ✅ Examples are accurate and tested
- ✅ No broken links or references
- ✅ BUILD_STATUS.md updated

### Verification Commands

```bash
# Check documentation files exist
test -f docs/USAGE.md && test -f README.md && echo "✅ Documentation complete"

# Verify no template placeholders remain
! grep -q "<.*>" docs/USAGE.md README.md && echo "✅ No placeholders"

# Check documentation structure
grep -q "## Overview" docs/USAGE.md && echo "✅ USAGE.md has structure"
grep -q "## Architecture" README.md && echo "✅ README.md has structure"

# Verify examples match entry point
grep -q "$ENTRY_POINT" docs/USAGE.md && echo "✅ Correct entry point in docs"
```

---

## Error Handling

### Common Issues

1. **Template placeholders not replaced**: Run update script again
2. **Interactive mode section handling**: Check conditional logic
3. **File paths in documentation**: Verify relative paths are correct

### Recovery

If step fails:
1. Delete generated docs: `rm docs/USAGE.md README.md`
2. Re-create from templates above
3. Re-run placeholder replacement script

---

## Next Step

**Step 10**: Final Verification (calc-step_a2b3c4d5e6f7.md)

---

## Notes

- Documentation created after implementation ensures accuracy
- Examples in USAGE.md should match actual behavior
- README.md provides both user and developer information
- Traceability maintained through specification references
- Documentation is final deliverable before verification step

---

**Traceability**: Implements calculator-spec.md § 3.4 (Documentation)
