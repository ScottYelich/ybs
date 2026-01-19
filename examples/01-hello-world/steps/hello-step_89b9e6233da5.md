# Step 3: Set Permissions

**Step ID**: 89b9e6233da5
**System**: hello-world
**Version**: 1.0.0
**Estimated Time**: 1 minute

---

## Context

**What**: Make the script executable on Unix-like systems (Linux, macOS)

**Why**: On Unix-like platforms, files need explicit execute permissions to run directly. This step handles platform-specific permission settings.

**Previous Step**: Step 2 (Create Main Script) - script file created

**This Step**: Set appropriate file permissions based on target platform

---

## Prerequisites

- [x] Step 0 complete (BUILD_CONFIG.json exists)
- [x] Step 1 complete (directory structure ready)
- [x] Step 2 complete (script file created)
- [x] Script file exists ({{SCRIPT_NAME}}.{{EXT}})

---

## Instructions

### 1. Read Configuration

Load configuration to determine platform and script file:

```bash
# Read configuration
PLATFORM=$(jq -r '.platform' BUILD_CONFIG.json)
LANGUAGE=$(jq -r '.language' BUILD_CONFIG.json)
SCRIPT_NAME=$(jq -r '.script_name' BUILD_CONFIG.json)

# Determine file extension
case "$LANGUAGE" in
  python) EXT="py" ;;
  bash) EXT="sh" ;;
  ruby) EXT="rb" ;;
  javascript) EXT="js" ;;
esac

SCRIPT_FILE="${SCRIPT_NAME}.${EXT}"

echo "Script: $SCRIPT_FILE"
echo "Platform: $PLATFORM"
```

---

### 2. Detect Current Platform

Determine the actual platform we're running on:

```bash
# Detect current platform
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  CURRENT_PLATFORM="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  CURRENT_PLATFORM="macos"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
  CURRENT_PLATFORM="windows"
else
  CURRENT_PLATFORM="unknown"
fi

echo "Current platform: $CURRENT_PLATFORM"
```

---

### 3. Set Permissions (Unix-like Systems)

If running on Linux or macOS, set executable permissions:

```bash
if [[ "$CURRENT_PLATFORM" == "linux" || "$CURRENT_PLATFORM" == "macos" ]]; then
  echo "Setting executable permissions on Unix-like system..."

  # Make script executable
  chmod +x "$SCRIPT_FILE"

  # Verify permissions were set
  if [ -x "$SCRIPT_FILE" ]; then
    echo "✅ Script is now executable"
    ls -l "$SCRIPT_FILE"
  else
    echo "❌ Failed to set executable permissions"
    exit 1
  fi

else
  echo "ℹ️  Not a Unix-like system, skipping chmod"
  echo "   (Windows uses file associations, not execute bits)"
fi
```

**Permissions**:
- Unix/Linux/macOS: `chmod +x` sets execute bit
- Windows: File associations handle execution (no chmod needed)

---

### 4. Test Basic Execution

Attempt to run the script to verify it's executable:

```bash
echo ""
echo "Testing script execution..."

# Determine how to execute based on platform
if [[ "$CURRENT_PLATFORM" == "linux" || "$CURRENT_PLATFORM" == "macos" ]]; then
  # Unix-like: Can execute directly
  if [ -x "$SCRIPT_FILE" ]; then
    echo "Running: ./$SCRIPT_FILE"
    OUTPUT=$(./"$SCRIPT_FILE" 2>&1)
    EXIT_CODE=$?
  else
    echo "⚠️  Script not executable, trying with interpreter..."
    case "$LANGUAGE" in
      python) OUTPUT=$(python3 "$SCRIPT_FILE" 2>&1); EXIT_CODE=$? ;;
      bash) OUTPUT=$(bash "$SCRIPT_FILE" 2>&1); EXIT_CODE=$? ;;
      ruby) OUTPUT=$(ruby "$SCRIPT_FILE" 2>&1); EXIT_CODE=$? ;;
      javascript) OUTPUT=$(node "$SCRIPT_FILE" 2>&1); EXIT_CODE=$? ;;
    esac
  fi
else
  # Windows: Call interpreter explicitly
  echo "Running with interpreter (Windows)..."
  case "$LANGUAGE" in
    python) OUTPUT=$(python "$SCRIPT_FILE" 2>&1); EXIT_CODE=$? ;;
    bash) OUTPUT=$(bash "$SCRIPT_FILE" 2>&1); EXIT_CODE=$? ;;
    ruby) OUTPUT=$(ruby "$SCRIPT_FILE" 2>&1); EXIT_CODE=$? ;;
    javascript) OUTPUT=$(node "$SCRIPT_FILE" 2>&1); EXIT_CODE=$? ;;
  esac
fi

# Check execution results
if [ $EXIT_CODE -eq 0 ]; then
  echo "✅ Script executed successfully"
  echo "   Output: $OUTPUT"
else
  echo "⚠️  Script execution returned non-zero exit code: $EXIT_CODE"
  echo "   Output: $OUTPUT"
  echo "   (This will be fully verified in Step 4)"
fi
```

---

### 5. Platform-Specific Notes

Document any platform-specific execution instructions:

```bash
cat > EXECUTION_NOTES.txt << EOF
# Hello World - Execution Instructions
# Platform: $CURRENT_PLATFORM
# Script: $SCRIPT_FILE

## How to Run

### Linux / macOS:
  ./$SCRIPT_FILE

### Windows (PowerShell):
  $LANGUAGE $SCRIPT_FILE

### Windows (CMD):
  $LANGUAGE $SCRIPT_FILE

### Using Interpreter (all platforms):
EOF

case "$LANGUAGE" in
  python)
    echo "  python3 $SCRIPT_FILE" >> EXECUTION_NOTES.txt
    ;;
  bash)
    echo "  bash $SCRIPT_FILE" >> EXECUTION_NOTES.txt
    ;;
  ruby)
    echo "  ruby $SCRIPT_FILE" >> EXECUTION_NOTES.txt
    ;;
  javascript)
    echo "  node $SCRIPT_FILE" >> EXECUTION_NOTES.txt
    ;;
esac

cat >> EXECUTION_NOTES.txt << EOF

## Expected Output:
  $(jq -r '.message' BUILD_CONFIG.json)

## Troubleshooting:
- Ensure interpreter is installed ($LANGUAGE)
- Check file permissions (Unix-like systems)
- Verify file has correct shebang line
- Try running with explicit interpreter (see above)
EOF

echo "✅ Execution notes created: EXECUTION_NOTES.txt"
```

---

### 6. Update BUILD_STATUS.md

Mark Step 3 as complete:

```bash
cat >> BUILD_STATUS.md << EOF

### Step 3: Set Permissions
- **Started**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- **Completed**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- **Duration**: < 1 minute
- **Status**: ✅ PASS
- **Platform**: $CURRENT_PLATFORM
- **Executable**: $(if [ -x "$SCRIPT_FILE" ]; then echo "Yes"; else echo "No (Windows)"; fi)
- **Notes**: Permissions set for $CURRENT_PLATFORM platform
EOF

# Update steps checklist
sed -i.bak 's/\[ \] Step 3: Set Permissions/[x] Step 3: Set Permissions/' BUILD_STATUS.md
rm BUILD_STATUS.md.bak 2>/dev/null || true

echo "✅ BUILD_STATUS.md updated"
```

---

## Verification

**Verify Step 3 completion**:

```bash
echo "Verifying Step 3..."

# 1. Script file still exists
test -f "$SCRIPT_FILE" && echo "✅ $SCRIPT_FILE exists" || { echo "❌ Script missing"; exit 1; }

# 2. Check executable bit (Unix-like only)
if [[ "$CURRENT_PLATFORM" == "linux" || "$CURRENT_PLATFORM" == "macos" ]]; then
  if [ -x "$SCRIPT_FILE" ]; then
    echo "✅ Script has execute permission"
  else
    echo "❌ Script is not executable"
    exit 1
  fi
else
  echo "ℹ️  Windows platform - execute permission not applicable"
fi

# 3. Script can be executed
case "$LANGUAGE" in
  python)
    if command -v python3 &> /dev/null; then
      python3 "$SCRIPT_FILE" > /dev/null 2>&1 && echo "✅ Script runs with interpreter" || echo "⚠️  Execution issue (will verify in Step 4)"
    else
      echo "⚠️  python3 not found - cannot test execution"
    fi
    ;;
  bash)
    bash "$SCRIPT_FILE" > /dev/null 2>&1 && echo "✅ Script runs with interpreter" || echo "⚠️  Execution issue (will verify in Step 4)"
    ;;
  ruby)
    if command -v ruby &> /dev/null; then
      ruby "$SCRIPT_FILE" > /dev/null 2>&1 && echo "✅ Script runs with interpreter" || echo "⚠️  Execution issue (will verify in Step 4)"
    else
      echo "⚠️  ruby not found - cannot test execution"
    fi
    ;;
  javascript)
    if command -v node &> /dev/null; then
      node "$SCRIPT_FILE" > /dev/null 2>&1 && echo "✅ Script runs with interpreter" || echo "⚠️  Execution issue (will verify in Step 4)"
    else
      echo "⚠️  node not found - cannot test execution"
    fi
    ;;
esac

# 4. Execution notes created
test -f EXECUTION_NOTES.txt && echo "✅ EXECUTION_NOTES.txt exists" || echo "⚠️  Execution notes missing"

# 5. BUILD_STATUS.md updated
grep -q "Step 3: Set Permissions" BUILD_STATUS.md && echo "✅ Status updated" || echo "❌ Status not updated"

echo ""
echo "✅ Step 3 verification complete"
```

---

## Completion Criteria

- [x] Configuration read from BUILD_CONFIG.json
- [x] Platform detected correctly
- [x] Execute permissions set (Unix-like systems) OR skipped (Windows)
- [x] Basic execution test passed (exit code 0)
- [x] EXECUTION_NOTES.txt created with platform-specific instructions
- [x] BUILD_STATUS.md updated with Step 3 completion
- [x] All verification checks pass

---

## On Failure

If verification fails:

**Unix-like systems**:
1. Check chmod command succeeded
2. Verify file system supports execute permissions
3. Check file ownership
4. Retry chmod: `chmod +x SCRIPT_FILE`

**Windows**:
1. Verify interpreter is installed and in PATH
2. Check file associations (python, node, ruby, bash)
3. Try running with explicit interpreter

**All platforms**:
1. Check script syntax (no syntax errors)
2. Verify interpreter version (python3, node, etc.)
3. Retry this step (up to 3 attempts)
4. If still failing: Stop and report error

---

## Next Step

**Step 4**: Verify Implementation (hello-step_a1b2c3d4e5f6.md)

---

## Traceability

**Implements**:
- hello-world-spec.md § 2.1 F2 (Execution) - Script must be executable
- hello-world-spec.md § 2.1 F3 (Cross-Platform) - Platform-specific handling
- hello-world-spec.md § 4.3 (Platform Considerations) - Unix/Windows differences

**References**:
- hello-world-spec.md § 3.1 C3 (Target Platform)
- hello-world-spec.md § 6.2 (Common Pitfalls - Permissions)

---

## Notes for AI Agents

- **Platform detection** - Different handling for Unix vs Windows
- **chmod is Unix-specific** - Don't fail on Windows if chmod doesn't exist
- **Test execution** - Basic smoke test, full verification in Step 4
- **Document execution** - Create clear instructions for users
- **No user prompts** - This step is fully autonomous

---

**Version**: 1.0.0
**Last Updated**: 2026-01-18
