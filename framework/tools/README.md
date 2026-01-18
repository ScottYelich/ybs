# Framework Tools

Helper scripts for working with YBS systems.

**Location**: `framework/tools/`

---

## Tools Overview

### list-specs.sh - List Specification Files
Lists all specification files for a system.

**Usage**:
```bash
./list-specs.sh [SYSTEM]
```

**Example**:
```bash
./list-specs.sh bootstrap
```

**What it does**: Scans the specs directory and lists all .md files with their titles and sizes.

**Output**:
```
Specifications for system 'bootstrap':

  ✓ README.md                              12K  Bootstrap System Specifications

Total: 1 specification file(s)
```

---

### list-steps.sh - List Build Steps
Displays build steps in execution order from STEPS_ORDER.txt.

**Usage**:
```bash
./list-steps.sh [SYSTEM] [--full] [--verbose]
```

**Options**:
- `--full` - Show complete file paths
- `--verbose` or `-v` - Show step objectives (summary of what each step does)

**Examples**:
```bash
# List steps with titles (one per line, greppable)
./list-steps.sh bootstrap

# Show step objectives
./list-steps.sh bootstrap --verbose

# Show full file paths
./list-steps.sh bootstrap --full
```

**What it does**: Reads STEPS_ORDER.txt and extracts step information (number, GUID, title, objectives).

**Output (default)**:
```
Build Steps for system 'bootstrap' (from STEPS_ORDER.txt):

000001 ybs-step_000000000000  Initialize Build Workspace
000002 ybs-step_478a8c4b0cef  Project Skeleton and Dependencies
...
```

**Output (--verbose)**:
```
000001 ybs-step_000000000000  Initialize Build Workspace
       - Read system name from BUILD_CONFIG.json
       - Create the builds/ directory structure
       - Create the system-specific workspace
       ...
```

---

### deps.sh - Show Dependency Tree
Shows dependency relationships between specifications.

**Usage**:
```bash
./deps.sh [SYSTEM] <guid>
```

**Example**:
```bash
./deps.sh bootstrap a1b2c3d4e5f6
```

**What it does**: Parses technical spec files for dependency sections and shows:
- Required dependencies (must implement first)
- Optional dependencies (nice-to-have)
- Conflicts (mutually exclusive)
- Dependents (what depends on this)

**Note**: This tool is designed for GUID-based spec organization. Bootstrap uses descriptive names instead, so this tool may not be applicable to all systems.

**Output**:
```
Dependency Tree for: a1b2c3d4e5f6

Feature: Example Feature

Required Dependencies (must implement first):
  └─ b2c3d4e5f6a7  # Foundation Feature
  └─ c3d4e5f6a7b8  # Core Feature

Optional Dependencies (nice-to-have):
  (none)

Conflicts (mutually exclusive):
  (none)

Dependents (features that depend on this):
  └─ d4e5f6a7b8c9  # Advanced Feature
```

---

### list-changelogs.sh - List Session Changelogs
Lists and filters session-based changelogs from framework development.

**Usage**:
```bash
./list-changelogs.sh [OPTIONS]
```

**Options**:
- `--date YYYY-MM-DD` - Show changelogs for specific date
- `--recent N` - Show N most recent changelogs
- `--session GUID` - Show specific session by GUID
- `--summary` - Show summary view (date, session, type only)

**Examples**:
```bash
# List all changelogs
./list-changelogs.sh

# Last 5 changelogs
./list-changelogs.sh --recent 5

# Changelogs for specific date
./list-changelogs.sh --date 2026-01-16

# Specific session
./list-changelogs.sh --session 6faac907b15b

# Summary view
./list-changelogs.sh --summary
```

**What it does**: Provides access to historical session changelogs from framework development work.

**Note**: As of 2026-01-18, changelogs are NOT actively maintained. They were used during initial framework development (last updated 2026-01-16). Current workflow uses git commits instead.

**Status**: Historical reference only.

---

### check-traceability.sh - Verify Code-to-Spec Traceability
Verifies that all source files include traceability comments linking back to specifications.

**Usage**:
```bash
./check-traceability.sh SYSTEM BUILDNAME
```

**Example**:
```bash
./check-traceability.sh bootstrap test7
```

**What it does**: Scans all source files in the build directory for traceability comments (e.g., `// Implements: ybs-spec.md § 3.1`), calculates coverage percentage, and reports untraced files.

**Output**:
```
Traceability Check for bootstrap/test7
======================================

Summary:
--------
Status:      ✓ PASS
Total files: 33
Traced:      33
Untraced:    0
Coverage:    100%

Build directory: systems/bootstrap/builds/test7
File extensions: .swift
```

**Thresholds**:
- ✅ **PASS**: ≥80% files traced
- ⚠️ **WARN**: 60-79% files traced
- ✗ **FAIL**: <60% files traced

**When to use**:
- Before marking build steps as complete
- During code review
- When verifying Feature Addition Protocol compliance
- To detect unspecified features

**Traceability Comment Format**:
```swift
// Implements: ybs-spec.md § 3.1 (read_file tool)
// Brief description of file's purpose
import Foundation

class ReadFileTool { ... }
```

**Why it matters**:
- Enforces "every line traces to spec" principle
- Detects unspecified features automatically
- Makes code review easier (instantly see what each file implements)
- Enables automated quality gates

**See also**: [Feature Addition Protocol](../methodology/feature-addition-protocol.md), [Writing Steps](../methodology/writing-steps.md)

---

## Environment Variables

All tools support the `YBS_ROOT` environment variable to override repository root location:

```bash
# Use custom YBS location
YBS_ROOT=/path/to/ybs ./list-specs.sh bootstrap

# Default behavior (auto-detect from script location)
./list-specs.sh bootstrap
```

**When to use YBS_ROOT**:
- Running tools from outside the repository
- Symlinking tools to your PATH
- Working with multiple YBS repositories

---

## Usage Patterns

### Quick Step Reference
```bash
# Show all steps with titles (one per line)
./list-steps.sh bootstrap

# Grep for specific step
./list-steps.sh bootstrap | grep "Tool"

# Show what each step does
./list-steps.sh bootstrap --verbose
```

### System Overview
```bash
# List all specs
./list-specs.sh bootstrap

# List all steps
./list-steps.sh bootstrap

# Count total steps
./list-steps.sh bootstrap | tail -5
```

### Build Verification
```bash
# Check traceability coverage before completing a step
./check-traceability.sh bootstrap test7

# Verify after adding new features
./check-traceability.sh bootstrap test7 | grep "FAIL\|WARN"
```

### From Anywhere
```bash
# Add to your shell profile (e.g., ~/.zshrc)
export YBS_ROOT=/Users/you/ybs
export PATH="$YBS_ROOT/framework/tools:$PATH"

# Then use from any directory
cd /tmp
list-specs.sh bootstrap
list-steps.sh bootstrap --verbose
```

---

## Tool Development

All tools follow these conventions:

1. **Bash scripts** - Portable, no dependencies (except curl/jq where noted)
2. **YBS_ROOT support** - Can override repository location
3. **Help text** - Usage instructions when run with wrong arguments
4. **Error messages** - Clear errors when files/directories not found
5. **Auto-detect** - Calculate paths from script location by default

---

## See Also

- **[Framework README](../README.md)** - YBS framework overview
- **[Methodology](../methodology/)** - How to write specs and steps
- **[Glossary](../docs/glossary.md)** - Standard YBS terminology

---

**Version**: 1.0.0
**Last Updated**: 2026-01-18
