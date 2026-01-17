# Session Changelogs

**Purpose**: Track changes made during each work session with support for parallel sessions.

---

## Overview

This directory contains session-based changelogs. Each session gets its own dated changelog file with a unique session ID, allowing multiple contributors or parallel work streams to track changes independently.

## File Naming Convention

```
YYYY-MM-DD_<session-guid>.md
```

**Format**:
- `YYYY-MM-DD` - Date of the session (e.g., 2026-01-16)
- `<session-guid>` - 12-hex character unique identifier (e.g., 6faac907b15b)
- Extension: `.md` (Markdown)

**Examples**:
- `2026-01-16_dc8754dc8ce4.md` - Session on Jan 16, 2026
- `2026-01-16_6faac907b15b.md` - Different session, same day
- `2026-01-17_a1b2c3d4e5f6.md` - Session on Jan 17, 2026

## Why Session-Based?

### Supports Parallel Sessions
Multiple people (or AI agents) can work simultaneously without conflicts:
```
2026-01-16_dc8754dc8ce4.md  # Claude agent: Documentation restructuring
2026-01-16_6faac907b15b.md  # Claude agent: Script reorganization
2026-01-16_f1e2d3c4b5a6.md  # Human developer: Feature implementation
```

### Clear Session Boundaries
Each file represents one logical work session with clear:
- Start time (date)
- Session identity (GUID)
- Scope (what was worked on)
- Outcomes (what changed)

### Easy Aggregation
- View all changes: `ls -lt` (sorted by date)
- View specific date: `ls 2026-01-16_*.md`
- Helper script: `../../bin/list-changelogs.sh`

## Session File Format

Each session changelog should follow this structure:

```markdown
# Session Changelog

**Date**: YYYY-MM-DD
**Session ID**: <12-hex-guid>
**Type**: <session-type>
**Contributors**: <names/agents>

---

## Summary

Brief 1-3 sentence overview of what was accomplished in this session.

---

## Changes

### Category 1
- Change 1
- Change 2

### Category 2
- Change 1
- Change 2

---

## Files Modified

List of files changed:
- path/to/file1
- path/to/file2

---

## Impact

- Who/what is affected by these changes
- Any breaking changes
- Migration notes if needed

---

## Notes

Any additional context, issues encountered, or follow-up items.
```

## Session Types

Common session types:
- **Documentation**: Changes to docs, specs, READMEs
- **Feature Implementation**: New functionality
- **Bug Fix**: Fixing issues
- **Refactoring**: Code/structure improvements
- **Build System**: Changes to build scripts, CI/CD
- **Testing**: Adding/updating tests
- **Repository Organization**: File moves, renames, structure changes

## Creating a New Session Changelog

### 1. Generate Session ID
```bash
uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-12
```

### 2. Create File
```bash
touch docs/changelogs/$(date +%Y-%m-%d)_<session-guid>.md
```

### 3. Fill Template
Copy the format above and fill in:
- Date (current date)
- Session ID (generated GUID)
- Type (session type)
- Contributors (your name or "Claude Sonnet 4.5")
- Summary, Changes, Files, Impact, Notes

### 4. Update Throughout Session
Add changes as you make them, don't wait until the end.

## Viewing Changelogs

### List All Sessions
```bash
ls -lt docs/changelogs/*.md
```

### List Sessions by Date
```bash
ls docs/changelogs/2026-01-16_*.md
```

### View Specific Session
```bash
cat docs/changelogs/2026-01-16_dc8754dc8ce4.md
```

### Use Helper Script
```bash
../../bin/list-changelogs.sh              # All sessions
../../bin/list-changelogs.sh --date 2026-01-16  # Specific date
../../bin/list-changelogs.sh --recent 5         # Last 5 sessions
```

## Aggregating Changes

To see all changes across sessions:
```bash
# Concatenate all changelogs
cat docs/changelogs/*.md > /tmp/all-changes.md

# View by date range
cat docs/changelogs/2026-01-{16,17}_*.md
```

## Best Practices

### Do:
- ✅ Create one changelog per logical work session
- ✅ Update as you make changes (not just at the end)
- ✅ Use descriptive summaries
- ✅ List all modified files
- ✅ Note any breaking changes or impacts
- ✅ Generate unique session IDs (don't reuse)

### Don't:
- ❌ Edit old session changelogs (create new ones instead)
- ❌ Use same session ID for different sessions
- ❌ Forget to document breaking changes
- ❌ Mix unrelated work in one session
- ❌ Create sessions with future dates

## Relationship to Git Commits

Session changelogs complement (don't replace) git commit messages:

| Purpose | Git Commits | Session Changelogs |
|---------|-------------|-------------------|
| **What** | Individual atomic changes | Logical work sessions |
| **When** | Every save point | Per session |
| **Detail** | Terse, technical | Detailed, explanatory |
| **Audience** | Developers | Developers + Users + AI agents |
| **Format** | Command line | Markdown documentation |

**Use both**:
- Commit frequently with clear messages
- Document sessions with context and impact

## Migration from Single CHANGELOG.md

Old approach (single file):
```
docs/CHANGELOG.md  # All changes in one file, conflicts on merge
```

New approach (session-based):
```
docs/changelogs/
├── README.md                      # This file
├── 2026-01-16_dc8754dc8ce4.md   # Session 1
├── 2026-01-16_6faac907b15b.md   # Session 2 (parallel)
└── 2026-01-17_a1b2c3d4e5f6.md   # Session 3
```

**Benefits**:
- No merge conflicts
- Parallel work support
- Clear session boundaries
- Easy to find changes by date/session
- Scales to many contributors

---

**Last updated**: 2026-01-16
