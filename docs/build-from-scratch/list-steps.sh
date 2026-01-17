#!/bin/bash
#
# list-steps.sh - Display build steps in order
#
# Usage: ./list-steps.sh [--full]
#
# Shows numbered list of steps from STEPS_ORDER.txt
# Use --full to show complete file paths

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEPS_DIR="$SCRIPT_DIR/steps"
ORDER_FILE="$STEPS_DIR/STEPS_ORDER.txt"

if [ ! -f "$ORDER_FILE" ]; then
    echo "Error: STEPS_ORDER.txt not found at $ORDER_FILE"
    exit 1
fi

SHOW_FULL=false
if [ "$1" == "--full" ]; then
    SHOW_FULL=true
fi

echo "Build Steps (from STEPS_ORDER.txt):"
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
