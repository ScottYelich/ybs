#!/bin/bash
#
# deps.sh - Show dependency tree for a spec GUID
#
# Usage: ./deps.sh <guid>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECS_DIR="$SCRIPT_DIR/../docs/specs"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <guid>"
    echo ""
    echo "Shows dependency tree from technical spec."
    echo "Example: $0 a1b2c3d4e5f6"
    exit 1
fi

GUID=$1
TECH_SPEC="$SPECS_DIR/technical/ybs-spec_${GUID}.md"

if [ ! -f "$TECH_SPEC" ]; then
    echo "Error: Technical spec not found: $TECH_SPEC"
    echo ""
    echo "Dependencies are defined in technical specs."
    exit 1
fi

echo "Dependency Tree for: $GUID"
echo ""

# Extract title
TITLE=$(grep -m 1 '^# ' "$TECH_SPEC" | sed 's/^# //')
if [ -n "$TITLE" ]; then
    echo "Feature: $TITLE"
    echo ""
fi

# Function to extract dependencies from a section
extract_deps() {
    local SECTION=$1
    local MARKER=$2

    # Find section, extract GUIDs (12 hex chars in backticks)
    awk "/^### $SECTION/,/^###/ {print}" "$TECH_SPEC" | \
        grep -o '`ybs-spec_[a-f0-9]\{12\}`' | \
        sed 's/`ybs-spec_\([^`]*\)`/\1/' | \
        while read dep_guid; do
            # Try to get title from that spec's technical file
            DEP_FILE="$SPECS_DIR/technical/ybs-spec_${dep_guid}.md"
            if [ -f "$DEP_FILE" ]; then
                DEP_TITLE=$(grep -m 1 '^# ' "$DEP_FILE" | sed 's/^# //')
                echo "  $MARKER $dep_guid  # $DEP_TITLE"
            else
                echo "  $MARKER $dep_guid  # (spec not found)"
            fi
        done
}

# Check if Dependencies section exists
if ! grep -q "^## Dependencies" "$TECH_SPEC"; then
    echo "No dependencies section found in technical spec."
    echo ""
    echo "Add a '## Dependencies' section to define:"
    echo "  - Required dependencies (must implement first)"
    echo "  - Optional dependencies (nice-to-have)"
    echo "  - Conflicts (mutually exclusive)"
    echo "  - Dependents (what depends on this)"
    exit 0
fi

# Extract each type of dependency
echo "Required Dependencies (must implement first):"
REQUIRED=$(extract_deps "Required" "└─")
if [ -n "$REQUIRED" ]; then
    echo "$REQUIRED"
else
    echo "  (none)"
fi
echo ""

echo "Optional Dependencies (nice-to-have):"
OPTIONAL=$(extract_deps "Optional" "└─")
if [ -n "$OPTIONAL" ]; then
    echo "$OPTIONAL"
else
    echo "  (none)"
fi
echo ""

echo "Conflicts (mutually exclusive):"
CONFLICTS=$(extract_deps "Conflicts" "└─")
if [ -n "$CONFLICTS" ]; then
    echo "$CONFLICTS"
else
    echo "  (none)"
fi
echo ""

echo "Dependents (features that depend on this):"
DEPENDENTS=$(extract_deps "Dependents" "└─")
if [ -n "$DEPENDENTS" ]; then
    echo "$DEPENDENTS"
else
    echo "  (none)"
fi
echo ""

echo "Use './list-specs.sh $GUID' to see all spec types for this feature."
