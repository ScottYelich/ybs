# Step 1: Initialize Project Structure

**Step ID**: 478a8c4b0cef
**System**: hello-world
**Version**: 1.0.0
**Estimated Time**: 1 minute

---

## Context

**What**: Create the project directory structure and prepare for script creation

**Why**: Establishes clean workspace organization and ensures all necessary directories exist before creating the main script.

**Previous Step**: Step 0 (Build Configuration) - collected all configuration

**This Step**: Set up minimal project structure for single-script system

---

## Prerequisites

- [x] Step 0 complete
- [x] BUILD_CONFIG.json exists
- [x] BUILD_STATUS.md exists
- [x] Working directory is builds/{{CONFIG:build_name}}/

---

## Instructions

### 1. Read Configuration

Load configuration from BUILD_CONFIG.json:

```bash
# Read configuration values
BUILD_NAME=$(jq -r '.build_name' BUILD_CONFIG.json)
LANGUAGE=$(jq -r '.language' BUILD_CONFIG.json)
PLATFORM=$(jq -r '.platform' BUILD_CONFIG.json)
SCRIPT_NAME=$(jq -r '.script_name' BUILD_CONFIG.json)
MESSAGE=$(jq -r '.message' BUILD_CONFIG.json)

echo "Configuration loaded:"
echo "  Build: $BUILD_NAME"
echo "  Language: $LANGUAGE"
echo "  Platform: $PLATFORM"
echo "  Script: $SCRIPT_NAME"
echo "  Message: $MESSAGE"
```

---

### 2. Determine File Extension

Based on the configured language, determine the script file extension:

```bash
case "$LANGUAGE" in
  python)
    EXT="py"
    ;;
  bash)
    EXT="sh"
    ;;
  ruby)
    EXT="rb"
    ;;
  javascript)
    EXT="js"
    ;;
  *)
    echo "❌ Unknown language: $LANGUAGE"
    exit 1
    ;;
esac

SCRIPT_FILE="${SCRIPT_NAME}.${EXT}"
echo "✅ Script will be: $SCRIPT_FILE"
```

**Mapping**:
- `python` → `.py`
- `bash` → `.sh`
- `ruby` → `.rb`
- `javascript` → `.js`

---

### 3. Create Source Directory (Optional)

For this simple example, we'll place the script in the build root. But we'll create a placeholder src/ directory to demonstrate structure:

```bash
# Create source directory (not used in this simple example, but demonstrates structure)
mkdir -p src

echo "✅ Directory structure ready"
```

**Final structure**:
```
builds/{{CONFIG:build_name}}/
├── BUILD_CONFIG.json
├── BUILD_STATUS.md
├── docs/
│   └── build-history/
├── tests/
└── src/                       # Created (for future expansion)
```

**Note**: The main script will be created in the build root (next step), not in src/, to keep this example maximally simple.

---

### 4. Create Verification Test Template

Create a basic test script template that will be filled in during Step 4:

```bash
cat > tests/verify.sh << 'EOF'
#!/usr/bin/env bash
# Verification test for hello-world
# Implements: hello-world-spec.md § 5.1 (Verification Tests)

# This script will be completed in Step 4
echo "Test script template created"
exit 0
EOF

chmod +x tests/verify.sh

echo "✅ Test template created"
```

---

### 5. Document Project Structure

Create a PROJECT_STRUCTURE.txt file documenting the layout:

```bash
cat > PROJECT_STRUCTURE.txt << EOF
# Hello World - Project Structure
# Build: {{CONFIG:build_name}}
# Language: {{CONFIG:language}}

builds/{{CONFIG:build_name}}/
├── BUILD_CONFIG.json          # Build configuration (Step 0)
├── BUILD_STATUS.md            # Build status tracking
├── PROJECT_STRUCTURE.txt      # This file
├── {{SCRIPT_FILE}}            # Main script (created in Step 2)
├── docs/
│   └── build-history/         # Completed step records
├── tests/
│   └── verify.sh              # Verification test script
└── src/                       # Source directory (for future expansion)

---

Configuration:
- Build Name: {{CONFIG:build_name}}
- Language: {{CONFIG:language}}
- Platform: {{CONFIG:platform}}
- Script Name: {{CONFIG:script_name}}
- Message: {{CONFIG:message}}

Next Step: Create main script ({{SCRIPT_FILE}})
EOF

echo "✅ Project structure documented"
```

---

### 6. Update BUILD_STATUS.md

Mark Step 1 as complete:

```bash
cat >> BUILD_STATUS.md << EOF

### Step 1: Initialize Project Structure
- **Started**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- **Completed**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- **Duration**: < 1 minute
- **Status**: ✅ PASS
- **Notes**: Project structure initialized, ready for script creation
EOF

# Update steps checklist
sed -i.bak 's/\[ \] Step 1: Initialize Project Structure/[x] Step 1: Initialize Project Structure/' BUILD_STATUS.md
rm BUILD_STATUS.md.bak 2>/dev/null || true

echo "✅ BUILD_STATUS.md updated"
```

---

## Verification

**Verify Step 1 completion**:

```bash
echo "Verifying Step 1..."

# 1. Configuration loaded successfully
test -n "$BUILD_NAME" && echo "✅ BUILD_NAME loaded" || echo "❌ BUILD_NAME missing"
test -n "$LANGUAGE" && echo "✅ LANGUAGE loaded" || echo "❌ LANGUAGE missing"
test -n "$SCRIPT_NAME" && echo "✅ SCRIPT_NAME loaded" || echo "❌ SCRIPT_NAME missing"

# 2. File extension determined
test -n "$EXT" && echo "✅ File extension: .$EXT" || echo "❌ Extension not determined"

# 3. Directories exist
test -d src && echo "✅ src/ directory exists" || echo "❌ src/ directory missing"
test -d tests && echo "✅ tests/ directory exists" || echo "❌ tests/ directory missing"
test -d docs/build-history && echo "✅ docs/build-history/ exists" || echo "❌ Missing directory"

# 4. Files created
test -f tests/verify.sh && echo "✅ tests/verify.sh exists" || echo "❌ Test template missing"
test -x tests/verify.sh && echo "✅ tests/verify.sh is executable" || echo "⚠️ Not executable"
test -f PROJECT_STRUCTURE.txt && echo "✅ PROJECT_STRUCTURE.txt exists" || echo "❌ Documentation missing"

# 5. BUILD_STATUS.md updated
grep -q "Step 1: Initialize Project Structure" BUILD_STATUS.md && echo "✅ Status updated" || echo "❌ Status not updated"

echo ""
echo "✅ Step 1 verification complete"
```

**All checks must pass** before proceeding to Step 2.

---

## Completion Criteria

- [x] BUILD_CONFIG.json read successfully
- [x] File extension determined from language
- [x] src/ directory created
- [x] tests/verify.sh template created (executable)
- [x] PROJECT_STRUCTURE.txt created
- [x] BUILD_STATUS.md updated with Step 1 completion
- [x] All verification checks pass

---

## On Failure

If verification fails:
1. Check BUILD_CONFIG.json is readable and valid
2. Verify jq is installed (for JSON parsing)
3. Check directory creation permissions
4. Retry this step (up to 3 attempts)
5. If still failing: Stop and report error

---

## Next Step

**Step 2**: Create Main Script (hello-step_c5404152680d.md)

---

## Traceability

**Implements**:
- hello-world-spec.md § 4.1 (Component Overview)
- hello-world-spec.md § 6.1 (Development Guidelines - File Organization)

**References**:
- hello-world-spec.md § 3.1 (Build Configuration)
- YBS Framework: Step-by-step execution

---

## Notes for AI Agents

- **Read BUILD_CONFIG.json** - all configuration is already collected
- **No user prompts** - this step is fully autonomous
- **Check file extensions** - language determines extension
- **Create directories** - even if not immediately used (demonstrates structure)
- **Update status** - keep BUILD_STATUS.md current

---

**Version**: 1.0.0
**Last Updated**: 2026-01-18
