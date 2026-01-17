#!/bin/bash
#
# list-specs.sh - List all specification files for a system
#
# Usage: ./list-specs.sh [SYSTEM]
#
# SYSTEM defaults to "bootstrap" if not specified

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
SYSTEM="${1:-bootstrap}"

SPECS_DIR="$SCRIPT_DIR/../systems/$SYSTEM/specs"

if [ ! -d "$SPECS_DIR" ]; then
    echo "Error: Specs directory not found at $SPECS_DIR"
    echo "Usage: $0 [SYSTEM]"
    echo "  SYSTEM defaults to 'bootstrap'"
    exit 1
fi

echo "Specifications for system '$SYSTEM':"
echo ""

# Find all .md files in specs directory
SPEC_FILES=$(find "$SPECS_DIR" -maxdepth 1 -name "*.md" -type f | sort)

if [ -z "$SPEC_FILES" ]; then
    echo "  No specification files found."
    exit 0
fi

# List each spec file with its title
while IFS= read -r SPEC_FILE; do
    FILENAME=$(basename "$SPEC_FILE")

    # Extract title from file (look for # Title on first non-empty line)
    TITLE=$(grep -m 1 '^# ' "$SPEC_FILE" | sed 's/^# //')
    if [ -z "$TITLE" ]; then
        TITLE="(no title)"
    fi

    # Get file size
    SIZE=$(ls -lh "$SPEC_FILE" | awk '{print $5}')

    printf "  ✓ %-35s %6s  %s\n" "$FILENAME" "$SIZE" "$TITLE"
done <<< "$SPEC_FILES"

echo ""
echo "Total: $(echo "$SPEC_FILES" | wc -l | tr -d ' ') specification file(s)"
echo ""
echo "Location: $SPECS_DIR"
