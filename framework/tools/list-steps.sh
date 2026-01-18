#!/bin/bash
#
# list-steps.sh - Display build steps in order
#
# Usage: ./list-steps.sh [SYSTEM] [OPTIONS]
#
# Shows numbered list of steps from STEPS_ORDER.txt with titles extracted from step files
#
# Options:
#   --full      Show complete file paths
#   --verbose   Show step objectives (summary of what each step does)
#   -v          Same as --verbose
#
# SYSTEM defaults to "bootstrap" if not specified
#
# Environment variables:
#   YBS_ROOT - Override YBS repository root (default: auto-detect from script location)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
SYSTEM="bootstrap"
SHOW_FULL=false
SHOW_VERBOSE=false

for arg in "$@"; do
    if [ "$arg" == "--full" ]; then
        SHOW_FULL=true
    elif [ "$arg" == "--verbose" ] || [ "$arg" == "-v" ]; then
        SHOW_VERBOSE=true
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

# Function to extract title from step file
extract_title() {
    local STEP_FILE=$1
    if [ ! -f "$STEP_FILE" ]; then
        echo "(file not found)"
        return
    fi

    # Extract title from first line: "# Step NNNNNN: Title"
    TITLE=$(head -1 "$STEP_FILE" | sed 's/^# Step [0-9]*: //')
    if [ -z "$TITLE" ]; then
        echo "(no title)"
    else
        echo "$TITLE"
    fi
}

# Function to extract objectives from step file
extract_objectives() {
    local STEP_FILE=$1
    if [ ! -f "$STEP_FILE" ]; then
        echo "       (file not found)"
        return
    fi

    # Extract objectives - lines starting with "- " or numbered after "## Objectives" or "## Step Objectives"
    # Stop at next section (## or ---)
    awk '
        /^## Objectives$/ || /^## Step Objectives$/ { in_obj=1; next }
        /^##/ || /^---/ { in_obj=0 }
        in_obj && (/^- / || /^[0-9]+\./) { print "       " $0 }
    ' "$STEP_FILE" | head -10  # Limit to first 10 objectives
}

# Parse STEPS_ORDER.txt, skip comments and empty lines, number the steps
STEP_NUM=0
while IFS= read -r line; do
    # Skip comments and empty lines
    if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
        continue
    fi

    # Extract GUID (first field - 12 hex chars)
    GUID=$(echo "$line" | awk '{print $1}')

    STEP_NUM=$((STEP_NUM + 1))

    # Get step file path
    STEP_FILE="$STEPS_DIR/ybs-step_${GUID}.md"

    # Extract title from step file
    TITLE=$(extract_title "$STEP_FILE")

    # Format: 000001 ybs-step_478a8c4b0cef  Title
    printf "%06d ybs-step_%s  %s\n" "$STEP_NUM" "$GUID" "$TITLE"

    if [ "$SHOW_FULL" = true ]; then
        if [ -f "$STEP_FILE" ]; then
            echo "       $STEP_FILE"
        else
            echo "       [FILE NOT FOUND: $STEP_FILE]"
        fi
    fi

    if [ "$SHOW_VERBOSE" = true ]; then
        extract_objectives "$STEP_FILE"
        echo ""
    fi
done < "$ORDER_FILE"

echo ""
echo "Total steps: $STEP_NUM"
echo ""
echo "Options:"
echo "  --full      Show complete file paths"
echo "  --verbose   Show step objectives"
echo ""
echo "To execute a step: Read ybs-step_<guid>.md"
