# Step 1: Initialize Project Structure

**System**: calculator
**Step ID**: calc-step_478a8c4b0cef
**Implements**: calculator-spec.md § 1.3 (Architecture)
**Prerequisites**: Step 0 (Build Configuration)
**Duration**: 5-10 minutes

---

## Purpose

Create the directory structure, package files, and placeholder files for the calculator system. This establishes the foundation for modular development and testing.

---

## Inputs

- `BUILD_CONFIG.json` - Build configuration from Step 0

**Required fields**:
- `language` - Determines which package files to create
- `entry_point` - Name of main executable
- `file_ext` - File extension (.py or .js)

---

## Outputs

**Directories**:
- `src/` - Source code modules
- `tests/` - Test files
- `docs/` - Documentation

**Files (Python)**:
- `requirements.txt` - Python dependencies
- `setup.py` - Package configuration (optional)
- `src/__init__.py` - Makes src a package
- Placeholder source files in `src/`
- Placeholder test files in `tests/`

**Files (JavaScript)**:
- `package.json` - Node package configuration
- Placeholder source files in `src/`
- Placeholder test files in `tests/`

---

## Instructions

### 1. Read Configuration

```bash
# Read language from BUILD_CONFIG.json
LANGUAGE=$(python -c "import json; print(json.load(open('BUILD_CONFIG.json'))['language'])")
ENTRY_POINT=$(python -c "import json; print(json.load(open('BUILD_CONFIG.json'))['entry_point'])")
FILE_EXT=$(python -c "import json; print(json.load(open('BUILD_CONFIG.json'))['file_ext'])")

echo "Language: $LANGUAGE"
echo "Entry Point: $ENTRY_POINT"
echo "File Extension: $FILE_EXT"
```

**Note**: For Node.js only environment, use:
```bash
LANGUAGE=$(node -e "console.log(JSON.parse(require('fs').readFileSync('BUILD_CONFIG.json')).language)")
```

---

### 2. Create Directory Structure

```bash
# Create main directories
mkdir -p src
mkdir -p tests
mkdir -p docs

# Verify directories created
ls -la
```

**Expected output**:
```
src/
tests/
docs/
BUILD_CONFIG.json
BUILD_STATUS.md
```

---

### 3. Create Package Configuration Files

#### For Python

**Create `requirements.txt`**:
```txt
# Implements: calculator-spec.md § 7.1 (Python Dependencies)

# Testing dependencies
pytest>=7.0.0
pytest-cov>=4.0.0
```

**Create `src/__init__.py`**:
```python
# Implements: calculator-spec.md § 1.3 (Architecture)
"""Calculator package."""

__version__ = "1.0.0"
```

---

#### For JavaScript

**Create `package.json`**:
```json
{
  "name": "calculator",
  "version": "1.0.0",
  "description": "Command-line calculator with basic arithmetic operations",
  "main": "src/calculator.js",
  "scripts": {
    "test": "jest",
    "test:coverage": "jest --coverage",
    "start": "node calculator.js"
  },
  "keywords": ["calculator", "cli", "arithmetic"],
  "author": "",
  "license": "MIT",
  "devDependencies": {
    "jest": "^29.0.0"
  },
  "jest": {
    "testEnvironment": "node",
    "coverageDirectory": "coverage",
    "collectCoverageFrom": [
      "src/**/*.js"
    ],
    "coverageThreshold": {
      "global": {
        "lines": 80,
        "statements": 80
      }
    }
  }
}
```

**Note**: Implements calculator-spec.md § 7.2 (JavaScript Dependencies)

---

### 4. Create Placeholder Source Files

Create empty placeholder files with traceability headers. These will be implemented in subsequent steps.

#### Python Placeholders

**`src/calculator.py`**:
```python
# Implements: calculator-spec.md § 2.1 (Core Operations)
"""Calculator core operations module."""

# Functions will be implemented in Step 2
```

**`src/parser.py`**:
```python
# Implements: calculator-spec.md § 2.3 (Input Validation)
"""Input parsing and validation module."""

# Functions will be implemented in Step 3
```

**`src/formatter.py`**:
```python
# Implements: calculator-spec.md § 2.4 (Output Formatting)
"""Output formatting module."""

# Functions will be implemented in Step 4
```

**`src/cli.py`**:
```python
# Implements: calculator-spec.md § 2.2 (Input Modes)
"""Command-line interface module."""

# Functions will be implemented in Step 5
```

---

#### JavaScript Placeholders

**`src/calculator.js`**:
```javascript
// Implements: calculator-spec.md § 2.1 (Core Operations)
/**
 * Calculator core operations module.
 */

// Functions will be implemented in Step 2
module.exports = {};
```

**`src/parser.js`**:
```javascript
// Implements: calculator-spec.md § 2.3 (Input Validation)
/**
 * Input parsing and validation module.
 */

// Functions will be implemented in Step 3
module.exports = {};
```

**`src/formatter.js`**:
```javascript
// Implements: calculator-spec.md § 2.4 (Output Formatting)
/**
 * Output formatting module.
 */

// Functions will be implemented in Step 4
module.exports = {};
```

**`src/cli.js`**:
```javascript
// Implements: calculator-spec.md § 2.2 (Input Modes)
/**
 * Command-line interface module.
 */

// Functions will be implemented in Step 5
module.exports = {};
```

---

### 5. Create Placeholder Test Files

#### Python Test Placeholders

**`tests/__init__.py`**:
```python
"""Test suite for calculator."""
```

**`tests/test_calculator.py`**:
```python
# Implements: calculator-spec.md § 5.1 (Unit Tests - Calculator)
"""Unit tests for calculator module."""

# Tests will be implemented in Step 6
```

**`tests/test_parser.py`**:
```python
# Implements: calculator-spec.md § 5.2 (Unit Tests - Parser)
"""Unit tests for parser module."""

# Tests will be implemented in Step 7
```

**`tests/test_formatter.py`**:
```python
# Implements: calculator-spec.md § 5.3 (Unit Tests - Formatter)
"""Unit tests for formatter module."""

# Tests will be implemented in Step 7
```

**`tests/test_integration.py`**:
```python
# Implements: calculator-spec.md § 5.4 (Integration Tests)
"""Integration tests for calculator system."""

# Tests will be implemented in Step 8
```

---

#### JavaScript Test Placeholders

**`tests/calculator.test.js`**:
```javascript
// Implements: calculator-spec.md § 5.1 (Unit Tests - Calculator)
/**
 * Unit tests for calculator module.
 */

// Tests will be implemented in Step 6
```

**`tests/parser.test.js`**:
```javascript
// Implements: calculator-spec.md § 5.2 (Unit Tests - Parser)
/**
 * Unit tests for parser module.
 */

// Tests will be implemented in Step 7
```

**`tests/formatter.test.js`**:
```javascript
// Implements: calculator-spec.md § 5.3 (Unit Tests - Formatter)
/**
 * Unit tests for formatter module.
 */

// Tests will be implemented in Step 7
```

**`tests/integration.test.js`**:
```javascript
// Implements: calculator-spec.md § 5.4 (Integration Tests)
/**
 * Integration tests for calculator system.
 */

// Tests will be implemented in Step 8
```

---

### 6. Create Entry Point Placeholder

Create the main executable script placeholder.

#### Python Entry Point

**`<entry_point>.py`** (e.g., `calculator.py`):
```python
#!/usr/bin/env python3
# Implements: calculator-spec.md § 2.2 (Input Modes)
"""Calculator entry point."""

import sys
from src.cli import main

if __name__ == "__main__":
    sys.exit(main())
```

Make executable:
```bash
chmod +x calculator.py
```

---

#### JavaScript Entry Point

**`<entry_point>.js`** (e.g., `calculator.js`):
```javascript
#!/usr/bin/env node
// Implements: calculator-spec.md § 2.2 (Input Modes)
/**
 * Calculator entry point.
 */

const { main } = require('./src/cli');

process.exit(main());
```

Make executable:
```bash
chmod +x calculator.js
```

---

### 7. Install Dependencies

#### Python

```bash
# Install testing dependencies
pip install -r requirements.txt

# Verify installation
pytest --version
```

**Expected output**: `pytest 7.x.x` or higher

---

#### JavaScript

```bash
# Install dependencies
npm install

# Verify installation
npx jest --version
```

**Expected output**: `29.x.x` or higher

---

### 8. Update BUILD_STATUS.md

Add Step 1 completion to the build log:

```markdown
### Step 1: Initialize Project Structure
- **Started**: <ISO8601_timestamp>
- **Completed**: <ISO8601_timestamp>
- **Duration**: X minutes
- **Status**: ✅ PASS
- **Notes**: Directory structure created, dependencies installed
```

Update the progress checklist:
```markdown
- [x] Step 0: Build Configuration (COMPLETE)
- [x] Step 1: Initialize Project Structure (COMPLETE)
- [ ] Step 2: Create Calculator Module
```

---

## Verification

### Success Criteria

- ✅ Directories created: `src/`, `tests/`, `docs/`
- ✅ Package files created and valid
- ✅ All placeholder source files created with traceability headers
- ✅ All placeholder test files created
- ✅ Entry point script created and executable
- ✅ Dependencies installed successfully
- ✅ BUILD_STATUS.md updated

### Verification Commands

```bash
# Check directory structure
ls -la src/ tests/ docs/

# Verify package configuration
# Python:
test -f requirements.txt && echo "✅ requirements.txt exists"
test -f src/__init__.py && echo "✅ src/__init__.py exists"

# JavaScript:
test -f package.json && echo "✅ package.json exists"
node -e "JSON.parse(require('fs').readFileSync('package.json'))" && echo "✅ Valid package.json"

# Verify source placeholders
ls -la src/

# Verify test placeholders
ls -la tests/

# Verify entry point is executable
test -x calculator.py && echo "✅ Entry point is executable" # Python
test -x calculator.js && echo "✅ Entry point is executable" # JavaScript

# Verify dependencies installed
# Python:
pytest --version

# JavaScript:
npx jest --version
```

**Expected file count**:
- Python: 4 source files + 5 test files + entry point + requirements.txt + BUILD files = 12+ files
- JavaScript: 4 source files + 4 test files + entry point + package.json + BUILD files = 11+ files

---

## Error Handling

### Common Issues

1. **Permission denied on chmod**: Run with appropriate permissions
2. **pip/npm not found**: Ensure Python/Node.js is installed
3. **Dependency installation fails**: Check internet connection, verify package names

### Recovery

If step fails:
1. Remove created directories: `rm -rf src/ tests/ docs/`
2. Remove package files: `rm -f requirements.txt package.json setup.py`
3. Re-run Step 1

---

## Next Step

**Step 2**: Create Calculator Module (calc-step_c5404152680d.md)

---

## Notes

- Placeholder files serve as documentation and prevent import errors
- Traceability comments added now, implementation follows in later steps
- Dependencies installed early to enable test-driven development
- Entry point created but won't work until Step 5 implements CLI module

---

**Traceability**: Implements calculator-spec.md § 1.3 (Architecture)
