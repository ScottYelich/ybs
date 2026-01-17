#!/bin/bash
#
# list-specs.sh - Show all spec types for a given GUID
#
# Usage: ./list-specs.sh <guid>
#        ./list-specs.sh --all

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECS_DIR="$SCRIPT_DIR/../docs/specs"

# Spec categories in order
CATEGORIES=("business" "functional" "technical" "testing" "security" "operations" "architecture")

show_specs_for_guid() {
    local GUID=$1
    local FOUND=false

    echo "Specifications for GUID: $GUID"
    echo ""

    for category in "${CATEGORIES[@]}"; do
        SPEC_FILE="$SPECS_DIR/$category/ybs-spec_${GUID}.md"
        if [ -f "$SPEC_FILE" ]; then
            FOUND=true
            # Extract title from file (look for # Title on first non-empty line)
            TITLE=$(grep -m 1 '^# ' "$SPEC_FILE" | sed 's/^# //')
            if [ -z "$TITLE" ]; then
                TITLE="(no title)"
            fi
            printf "  ✓ %-15s %s\n" "$category" "$TITLE"
            echo "    $SPEC_FILE"
        else
            printf "  - %-15s (not found)\n" "$category"
        fi
    done

    if [ "$FOUND" = false ]; then
        echo "  No specifications found for GUID: $GUID"
        return 1
    fi

    echo ""
}

list_all_specs() {
    echo "All Specifications (by GUID):"
    echo ""

    # Find all unique GUIDs across all categories
    local GUIDS=$(find "$SPECS_DIR"/{business,functional,technical,testing,security,operations,architecture} \
        -name "ybs-spec_*.md" 2>/dev/null | \
        sed 's/.*ybs-spec_\([^.]*\)\.md/\1/' | \
        sort -u)

    if [ -z "$GUIDS" ]; then
        echo "No specifications found."
        return
    fi

    for guid in $GUIDS; do
        # Count how many spec types exist for this GUID
        local COUNT=0
        for category in "${CATEGORIES[@]}"; do
            if [ -f "$SPECS_DIR/$category/ybs-spec_${guid}.md" ]; then
                COUNT=$((COUNT + 1))
            fi
        done

        printf "%s  (%d/%d spec types)\n" "$guid" "$COUNT" "${#CATEGORIES[@]}"
    done

    echo ""
    echo "Use './list-specs.sh <guid>' to see details for a specific feature."
}

# Main
if [ $# -eq 0 ]; then
    echo "Usage: $0 <guid>"
    echo "       $0 --all"
    echo ""
    echo "Example: $0 a1b2c3d4e5f6"
    echo "         $0 --all"
    exit 1
fi

if [ "$1" == "--all" ] || [ "$1" == "-a" ]; then
    list_all_specs
else
    show_specs_for_guid "$1"
fi
