# Step 2: Create Main Script

**Step ID**: c5404152680d
**System**: hello-world
**Version**: 1.0.0
**Estimated Time**: 2 minutes

---

## Context

**What**: Create the main executable script that prints the configured message

**Why**: This is the core implementation - a minimal script demonstrating language-specific syntax and YBS traceability patterns.

**Previous Step**: Step 1 (Initialize Project Structure) - directories and templates ready

**This Step**: Generate the actual executable script based on configuration

---

## Prerequisites

- [x] Step 0 complete (BUILD_CONFIG.json exists)
- [x] Step 1 complete (directory structure ready)
- [x] BUILD_CONFIG.json readable
- [x] Working directory is builds/{{CONFIG:build_name}}/

---

## Instructions

### 1. Read Configuration

Load all configuration values needed for script generation:

```bash
# Read configuration
BUILD_NAME=$(jq -r '.build_name' BUILD_CONFIG.json)
LANGUAGE=$(jq -r '.language' BUILD_CONFIG.json)
PLATFORM=$(jq -r '.platform' BUILD_CONFIG.json)
SCRIPT_NAME=$(jq -r '.script_name' BUILD_CONFIG.json)
MESSAGE=$(jq -r '.message' BUILD_CONFIG.json)

# Determine file extension
case "$LANGUAGE" in
  python) EXT="py" ;;
  bash) EXT="sh" ;;
  ruby) EXT="rb" ;;
  javascript) EXT="js" ;;
  *) echo "❌ Unknown language: $LANGUAGE"; exit 1 ;;
esac

SCRIPT_FILE="${SCRIPT_NAME}.${EXT}"

echo "Creating script: $SCRIPT_FILE"
echo "  Language: $LANGUAGE"
echo "  Platform: $PLATFORM"
echo "  Message: $MESSAGE"
```

---

### 2. Generate Script Based on Language

Create the script file with language-appropriate syntax.

**IMPORTANT**: All scripts MUST include:
1. Shebang line (for Unix-like systems)
2. Traceability comment (references spec)
3. Single statement to print configured message

---

#### 2a. Python Implementation

If `LANGUAGE == "python"`:

```bash
cat > "$SCRIPT_FILE" << EOF
#!/usr/bin/env python3
# Implements: hello-world-spec.md § 2.1 F1 (Output Message)
# Implements: hello-world-spec.md § 2.1 F2 (Execution)
# Implements: hello-world-spec.md § 2.1 F3 (Cross-Platform)

print("${MESSAGE}")
EOF

echo "✅ Python script created: $SCRIPT_FILE"
```

**Python specifics**:
- Shebang: `#!/usr/bin/env python3`
- Print function: `print("message")`
- Line count: 5 lines (including traceability)

---

#### 2b. Bash Implementation

If `LANGUAGE == "bash"`:

```bash
cat > "$SCRIPT_FILE" << EOF
#!/usr/bin/env bash
# Implements: hello-world-spec.md § 2.1 F1 (Output Message)
# Implements: hello-world-spec.md § 2.1 F2 (Execution)
# Implements: hello-world-spec.md § 2.1 F3 (Cross-Platform)

echo "${MESSAGE}"
EOF

echo "✅ Bash script created: $SCRIPT_FILE"
```

**Bash specifics**:
- Shebang: `#!/usr/bin/env bash`
- Echo command: `echo "message"`
- Line count: 5 lines (including traceability)

---

#### 2c. Ruby Implementation

If `LANGUAGE == "ruby"`:

```bash
cat > "$SCRIPT_FILE" << EOF
#!/usr/bin/env ruby
# Implements: hello-world-spec.md § 2.1 F1 (Output Message)
# Implements: hello-world-spec.md § 2.1 F2 (Execution)
# Implements: hello-world-spec.md § 2.1 F3 (Cross-Platform)

puts "${MESSAGE}"
EOF

echo "✅ Ruby script created: $SCRIPT_FILE"
```

**Ruby specifics**:
- Shebang: `#!/usr/bin/env ruby`
- Puts method: `puts "message"`
- Line count: 5 lines (including traceability)

---

#### 2d. JavaScript (Node.js) Implementation

If `LANGUAGE == "javascript"`:

```bash
cat > "$SCRIPT_FILE" << EOF
#!/usr/bin/env node
// Implements: hello-world-spec.md § 2.1 F1 (Output Message)
// Implements: hello-world-spec.md § 2.1 F2 (Execution)
// Implements: hello-world-spec.md § 2.1 F3 (Cross-Platform)

console.log("${MESSAGE}");
EOF

echo "✅ JavaScript script created: $SCRIPT_FILE"
```

**JavaScript specifics**:
- Shebang: `#!/usr/bin/env node`
- Console.log: `console.log("message")`
- Comment style: `//` (not `#`)
- Line count: 5 lines (including traceability)

---

### 3. Verify Script Contents

Check that the script was created correctly:

```bash
echo ""
echo "Script contents:"
echo "---"
cat "$SCRIPT_FILE"
echo "---"
echo ""

# Verify file exists and is not empty
if [ ! -f "$SCRIPT_FILE" ]; then
  echo "❌ Script file not created"
  exit 1
fi

if [ ! -s "$SCRIPT_FILE" ]; then
  echo "❌ Script file is empty"
  exit 1
fi

echo "✅ Script file created and contains content"
```

---

### 4. Verify Traceability

Check that traceability comments are present:

```bash
# Check for traceability comments
if ! grep -q "Implements: hello-world-spec.md" "$SCRIPT_FILE"; then
  echo "❌ Missing traceability comments"
  exit 1
fi

if ! grep -q "§ 2.1 F1" "$SCRIPT_FILE"; then
  echo "❌ Missing F1 requirement reference"
  exit 1
fi

echo "✅ Traceability comments present"
```

**Required traceability format**:
- Must reference: `hello-world-spec.md`
- Must reference: `§ 2.1 F1` (Output Message)
- Must reference: `§ 2.1 F2` (Execution)
- Must reference: `§ 2.1 F3` (Cross-Platform)

---

### 5. Line Count Check

Verify script meets simplicity requirement (< 10 lines):

```bash
LINE_COUNT=$(wc -l < "$SCRIPT_FILE")

if [ "$LINE_COUNT" -gt 10 ]; then
  echo "⚠️ Warning: Script has $LINE_COUNT lines (spec requires < 10)"
else
  echo "✅ Line count: $LINE_COUNT (meets requirement)"
fi
```

---

### 6. Update BUILD_STATUS.md

Mark Step 2 as complete:

```bash
cat >> BUILD_STATUS.md << EOF

### Step 2: Create Main Script
- **Started**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- **Completed**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- **Duration**: < 1 minute
- **Status**: ✅ PASS
- **Script**: $SCRIPT_FILE
- **Language**: $LANGUAGE
- **Lines**: $LINE_COUNT
- **Notes**: Main script created with traceability comments
EOF

# Update steps checklist
sed -i.bak 's/\[ \] Step 2: Create Main Script/[x] Step 2: Create Main Script/' BUILD_STATUS.md
rm BUILD_STATUS.md.bak 2>/dev/null || true

echo "✅ BUILD_STATUS.md updated"
```

---

## Verification

**Verify Step 2 completion**:

```bash
echo "Verifying Step 2..."

# 1. Script file exists
test -f "$SCRIPT_FILE" && echo "✅ $SCRIPT_FILE exists" || { echo "❌ Script missing"; exit 1; }

# 2. Script is not empty
test -s "$SCRIPT_FILE" && echo "✅ Script has content" || { echo "❌ Script is empty"; exit 1; }

# 3. Shebang present
head -1 "$SCRIPT_FILE" | grep -q '^#!' && echo "✅ Shebang present" || echo "⚠️ Shebang missing"

# 4. Traceability comments present
grep -q "Implements: hello-world-spec.md" "$SCRIPT_FILE" && echo "✅ Traceability present" || { echo "❌ No traceability"; exit 1; }

# 5. Message appears in script
grep -q "$MESSAGE" "$SCRIPT_FILE" && echo "✅ Message configured correctly" || echo "⚠️ Message not found"

# 6. Line count reasonable
LINE_COUNT=$(wc -l < "$SCRIPT_FILE")
[ "$LINE_COUNT" -le 10 ] && echo "✅ Line count: $LINE_COUNT" || echo "⚠️ Line count: $LINE_COUNT (> 10)"

# 7. BUILD_STATUS.md updated
grep -q "Step 2: Create Main Script" BUILD_STATUS.md && echo "✅ Status updated" || echo "❌ Status not updated"

echo ""
echo "✅ Step 2 verification complete"
```

**All critical checks must pass** before proceeding to Step 3.

---

## Completion Criteria

- [x] Configuration read from BUILD_CONFIG.json
- [x] Script file created ({{SCRIPT_NAME}}.{{EXT}})
- [x] Script contains shebang line
- [x] Script contains traceability comments (minimum 3)
- [x] Script prints configured message
- [x] Script has < 10 lines of code
- [x] BUILD_STATUS.md updated with Step 2 completion
- [x] All verification checks pass

---

## On Failure

If verification fails:
1. Check BUILD_CONFIG.json values are correct
2. Verify language is supported (python/bash/ruby/javascript)
3. Check file creation permissions
4. Verify traceability comments format
5. Retry this step (up to 3 attempts)
6. If still failing: Stop and report error

---

## Next Step

**Step 3**: Set Permissions (hello-step_89b9e6233da5.md)

---

## Traceability

**Implements**:
- hello-world-spec.md § 2.1 F1 (Output Message) - Script prints message
- hello-world-spec.md § 2.1 F2 (Execution) - Script is executable
- hello-world-spec.md § 2.1 F3 (Cross-Platform) - Shebang for compatibility
- hello-world-spec.md § 4.2 (Implementation Pattern) - Language-specific patterns
- hello-world-spec.md § NF1 (Simplicity) - < 10 lines, single file
- hello-world-spec.md § NF2 (Traceability) - Spec references in comments

**References**:
- hello-world-spec.md § 3.1 (Build Configuration)
- hello-world-spec.md § 6.1 (Development Guidelines)

---

## Notes for AI Agents

- **Read configuration first** - don't hardcode values
- **Language-specific syntax** - use correct print/echo/puts/console.log
- **Traceability is MANDATORY** - all files must reference spec
- **Keep it simple** - resist urge to add error handling, logging, etc.
- **Exact message** - use configured message, don't modify it
- **No user prompts** - this step is fully autonomous

---

**Version**: 1.0.0
**Last Updated**: 2026-01-18
