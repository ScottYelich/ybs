#!/bin/bash
#
# list-changelogs.sh - List and filter session changelogs
#
# Usage: ./list-changelogs.sh [--date YYYY-MM-DD] [--recent N] [--session GUID]
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOGS_DIR="$SCRIPT_DIR/../docs/changelogs"

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "List session changelogs with optional filtering."
    echo ""
    echo "Options:"
    echo "  --date YYYY-MM-DD    Show changelogs for specific date"
    echo "  --recent N           Show N most recent changelogs"
    echo "  --session GUID       Show specific session by GUID"
    echo "  --summary            Show summary (date, session, type only)"
    echo "  --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                          # List all changelogs"
    echo "  $0 --date 2026-01-16        # Changelogs for Jan 16, 2026"
    echo "  $0 --recent 5               # Last 5 changelogs"
    echo "  $0 --session 6faac907b15b   # Specific session"
    echo "  $0 --summary                # Summary view of all"
}

list_all() {
    local SUMMARY=$1
    echo "All Session Changelogs:"
    echo ""

    # Find all changelog files, sort by date (filename)
    local FILES=$(find "$CHANGELOGS_DIR" -name "*.md" ! -name "README.md" | sort -r)

    if [ -z "$FILES" ]; then
        echo "No changelogs found."
        return
    fi

    for file in $FILES; do
        local BASENAME=$(basename "$file" .md)
        local DATE=$(echo "$BASENAME" | cut -d'_' -f1)
        local SESSION=$(echo "$BASENAME" | cut -d'_' -f2)

        if [ "$SUMMARY" = true ]; then
            # Extract type from file
            local TYPE=$(grep "^\*\*Type\*\*:" "$file" | sed 's/\*\*Type\*\*: //' | xargs)
            printf "%s  %s  %s\n" "$DATE" "$SESSION" "$TYPE"
        else
            # Extract title/summary
            local TITLE=$(grep "^## Summary" "$file" -A 2 | tail -1 | xargs)
            printf "%s  %s\n" "$BASENAME" "$TITLE"
            echo "    $file"
        fi
    done
    echo ""
}

list_by_date() {
    local TARGET_DATE=$1
    local SUMMARY=$2

    echo "Changelogs for $TARGET_DATE:"
    echo ""

    local FILES=$(find "$CHANGELOGS_DIR" -name "${TARGET_DATE}_*.md" | sort)

    if [ -z "$FILES" ]; then
        echo "No changelogs found for $TARGET_DATE."
        return
    fi

    for file in $FILES; do
        local BASENAME=$(basename "$file" .md)
        local SESSION=$(echo "$BASENAME" | cut -d'_' -f2)

        if [ "$SUMMARY" = true ]; then
            local TYPE=$(grep "^\*\*Type\*\*:" "$file" | sed 's/\*\*Type\*\*: //' | xargs)
            printf "  %s  %s\n" "$SESSION" "$TYPE"
        else
            local TITLE=$(grep "^## Summary" "$file" -A 2 | tail -1 | xargs)
            printf "  %s  %s\n" "$SESSION" "$TITLE"
            echo "    $file"
        fi
    done
    echo ""
}

list_recent() {
    local COUNT=$1
    local SUMMARY=$2

    echo "Last $COUNT changelogs:"
    echo ""

    # Find all, sort by date descending, take first N
    local FILES=$(find "$CHANGELOGS_DIR" -name "*.md" ! -name "README.md" | sort -r | head -n "$COUNT")

    if [ -z "$FILES" ]; then
        echo "No changelogs found."
        return
    fi

    for file in $FILES; do
        local BASENAME=$(basename "$file" .md)
        local DATE=$(echo "$BASENAME" | cut -d'_' -f1)
        local SESSION=$(echo "$BASENAME" | cut -d'_' -f2)

        if [ "$SUMMARY" = true ]; then
            local TYPE=$(grep "^\*\*Type\*\*:" "$file" | sed 's/\*\*Type\*\*: //' | xargs)
            printf "%s  %s  %s\n" "$DATE" "$SESSION" "$TYPE"
        else
            local TITLE=$(grep "^## Summary" "$file" -A 2 | tail -1 | xargs)
            printf "%s  %s\n" "$BASENAME" "$TITLE"
            echo "    $file"
        fi
    done
    echo ""
}

show_session() {
    local SESSION_GUID=$1

    # Find file with this session GUID
    local FILE=$(find "$CHANGELOGS_DIR" -name "*_${SESSION_GUID}.md")

    if [ -z "$FILE" ]; then
        echo "Error: Session $SESSION_GUID not found."
        return 1
    fi

    echo "Session: $SESSION_GUID"
    echo ""
    cat "$FILE"
}

# Parse arguments
DATE_FILTER=""
RECENT_COUNT=""
SESSION_GUID=""
SUMMARY_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --date)
            DATE_FILTER="$2"
            shift 2
            ;;
        --recent)
            RECENT_COUNT="$2"
            shift 2
            ;;
        --session)
            SESSION_GUID="$2"
            shift 2
            ;;
        --summary)
            SUMMARY_MODE=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Execute based on filters
if [ -n "$SESSION_GUID" ]; then
    show_session "$SESSION_GUID"
elif [ -n "$DATE_FILTER" ]; then
    list_by_date "$DATE_FILTER" "$SUMMARY_MODE"
elif [ -n "$RECENT_COUNT" ]; then
    list_recent "$RECENT_COUNT" "$SUMMARY_MODE"
else
    list_all "$SUMMARY_MODE"
fi
