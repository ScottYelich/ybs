#!/bin/bash
#
# check-traceability.sh - Verify code-to-spec traceability
#
# Usage: ./check-traceability.sh [SYSTEM] [BUILD]
#
# Checks that source files have traceability comments linking back to specs.
# Generates a report showing traced vs untraced files.
#
# Environment variables:
#   YBS_ROOT - Override YBS repository root (default: auto-detect from script location)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
SYSTEM="${1:-bootstrap}"
BUILD="${2:-test7}"

# Determine YBS root
if [ -n "$YBS_ROOT" ]; then
    YBS_ROOT_DIR="$YBS_ROOT"
else
    YBS_ROOT_DIR="$SCRIPT_DIR/../.."
fi

BUILD_DIR="$YBS_ROOT_DIR/systems/$SYSTEM/builds/$BUILD"

if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory not found: $BUILD_DIR"
    echo "Usage: $0 [SYSTEM] [BUILD]"
    echo "  SYSTEM defaults to 'bootstrap'"
    echo "  BUILD defaults to 'test7'"
    exit 1
fi

echo "Traceability Check for $SYSTEM/$BUILD"
echo "======================================"
echo ""

# Find all source files (Swift in this case, adjust for other languages)
SOURCE_FILES=$(find "$BUILD_DIR/Sources" -name "*.swift" 2>/dev/null)

if [ -z "$SOURCE_FILES" ]; then
    echo "No source files found in $BUILD_DIR/Sources"
    exit 0
fi

TOTAL_FILES=$(echo "$SOURCE_FILES" | wc -l | tr -d ' ')
TRACED_FILES=0
UNTRACED_FILES=()

# Check each file for traceability comment
while IFS= read -r file; do
    # Look for comment: // Implements: ybs-spec.md § X.Y
    # or: // Implements: spec § X.Y
    # or: // Implements: Step X
    if grep -q "// Implements:" "$file"; then
        TRACED_FILES=$((TRACED_FILES + 1))
    else
        # Get relative path from build directory
        REL_PATH="${file#$BUILD_DIR/}"
        UNTRACED_FILES+=("$REL_PATH")
    fi
done <<< "$SOURCE_FILES"

# Calculate percentage
if [ "$TOTAL_FILES" -gt 0 ]; then
    PERCENTAGE=$((TRACED_FILES * 100 / TOTAL_FILES))
else
    PERCENTAGE=0
fi

# Determine status
if [ "$PERCENTAGE" -ge 80 ]; then
    STATUS="✓ PASS"
    COLOR="\033[32m"  # Green
elif [ "$PERCENTAGE" -ge 60 ]; then
    STATUS="⚠ WARN"
    COLOR="\033[33m"  # Yellow
else
    STATUS="✗ FAIL"
    COLOR="\033[31m"  # Red
fi
RESET="\033[0m"

# Print report
echo "Summary:"
echo "--------"
echo -e "Status:      ${COLOR}${STATUS}${RESET}"
echo "Total files: $TOTAL_FILES"
echo "Traced:      $TRACED_FILES"
echo "Untraced:    ${#UNTRACED_FILES[@]}"
echo "Coverage:    ${PERCENTAGE}%"
echo ""

# Show untraced files if any
if [ "${#UNTRACED_FILES[@]}" -gt 0 ]; then
    echo "Untraced files (need // Implements: comment):"
    echo "----------------------------------------------"
    for file in "${UNTRACED_FILES[@]}"; do
        echo "  - $file"
    done
    echo ""
fi

# Guidance
if [ "$PERCENTAGE" -lt 100 ]; then
    echo "How to fix:"
    echo "-----------"
    echo "Add a traceability comment to each file:"
    echo ""
    echo "  // Implements: ybs-spec.md § 3.1"
    echo "  class ReadFileTool: ToolProtocol { ... }"
    echo ""
    echo "Or for infrastructure code:"
    echo ""
    echo "  // Implements: Step 1 (Project Skeleton)"
    echo "  struct Config { ... }"
    echo ""
fi

# Exit code based on threshold
if [ "$PERCENTAGE" -ge 80 ]; then
    exit 0
else
    exit 1
fi
