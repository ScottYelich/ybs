#!/bin/bash
#
# list-steps.sh - Display build steps in order
#
# Usage: ./list-steps.sh [SYSTEM] [--full]
#
# Shows numbered list of steps from STEPS_ORDER.txt
# Use --full to show complete file paths
# SYSTEM defaults to "bootstrap" if not specified
#
# Environment variables:
#   YBS_ROOT - Override YBS repository root (default: auto-detect from script location)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
SYSTEM="bootstrap"
SHOW_FULL=false

for arg in "$@"; do
    if [ "$arg" == "--full" ]; then
        SHOW_FULL=true
    elif [ -z "$SYSTEM_SET" ]; then
        SYSTEM="$arg"
        SYSTEM_SET=true
    fi
done

# Determine YBS root: use YBS_ROOT if set, otherwise calculate from script location
if [ -n "$YBS_ROOT" ]; then
    YBS_ROOT_DIR="$YBS_ROOT"
else
    YBS_ROOT_DIR="$SCRIPT_DIR/../.."
fi

STEPS_DIR="$YBS_ROOT_DIR/systems/$SYSTEM/steps"
ORDER_FILE="$STEPS_DIR/STEPS_ORDER.txt"

if [ ! -f "$ORDER_FILE" ]; then
    echo "Error: STEPS_ORDER.txt not found at $ORDER_FILE"
    exit 1
fi

echo "Build Steps for system '$SYSTEM' (from STEPS_ORDER.txt):"
echo ""

# Parse STEPS_ORDER.txt, skip comments and empty lines, number the steps
STEP_NUM=0
while IFS= read -r line; do
    # Skip comments and empty lines
    if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
        continue
    fi

    # Extract GUID (first field - now 12 hex chars)
    GUID=$(echo "$line" | awk '{print $1}')

    # Extract description (everything after # if present, else rest of line)
    if [[ "$line" =~ "#" ]]; then
        DESC=$(echo "$line" | sed 's/^[^#]*#//' | sed 's/^[[:space:]]*//')
    else
        DESC=$(echo "$line" | cut -d' ' -f2-)
    fi

    STEP_NUM=$((STEP_NUM + 1))

    # Format: 000001 ybs-step_478a8c4b0cef  # Description
    printf "%06d ybs-step_%s  # %s\n" "$STEP_NUM" "$GUID" "$DESC"

    if [ "$SHOW_FULL" = true ]; then
        STEP_FILE="$STEPS_DIR/ybs-step_${GUID}.md"
        if [ -f "$STEP_FILE" ]; then
            echo "       $STEP_FILE"
        else
            echo "       [FILE NOT FOUND: ybs-step_${GUID}.md]"
        fi
    fi
done < "$ORDER_FILE"

echo ""
echo "Total steps: $STEP_NUM"
echo ""
echo "To see full paths: ./list-steps.sh --full"
echo "To execute a step: Read ybs-step_<guid>.md"
