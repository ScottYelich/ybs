# Build from Scratch Instructions

**Version**: 0.8.0

This directory contains step-by-step instructions for building software systems from scratch using the YBS framework. The current steps guide building a Swift-based LLM chat tool (the "bootstrap"), but the framework is designed to guide building any type of system.

## Purpose

Each step file is a single build step with complete instructions. Steps use GUID-based naming for flexible ordering (insert, branch, loop).

## Structure

- **steps/** - Directory containing all step files
  - **STEPS_ORDER.txt** - Defines step sequence (GUID-based)
  - **ybs-step_<guid>.md** - Individual step files (12-hex GUID)
- **CLAUDE.md** - Guide for Claude Code on how to use these instructions
- **STEP_TEMPLATE.md** - Template for creating new step files
- **README.md** - This file (for humans)

**Helper Scripts**: Located in `../../bin/` at repository root:
- **list-steps.sh** - View steps in numbered order

## Work Area

All build work happens in the `builds/` directory at the repository root (sibling to `docs/`). Each build gets its own named subdirectory.

## How to Use

1. View steps: Run `../../bin/list-steps.sh` to see ordered list
2. **Start with Step 0**: `steps/ybs-step_000000000000.md` (Build Configuration) - **MUST be first**
3. Follow remaining steps in order defined in `steps/STEPS_ORDER.txt`
4. Each step verifies completion before moving to next
5. Build history tracked in `builds/SYSTEMNAME/docs/build-history/`

**NEW: Configuration-First Approach**
- Step 0 collects ALL configurable values upfront
- Generates BUILD_CONFIG.json with all settings
- Subsequent steps read from config (no user prompts)
- Enables fully autonomous execution after Step 0

## Dependencies

**YBS framework requires these system tools to be installed:**
- **bash** (or zsh) - Shell
- **jq** - JSON processor (install: `brew install jq` or `apt-get install jq`)
- **git** - Version control
- Standard Unix tools: mkdir, cat, grep, echo, test, ls

See **DEPENDENCIES.md** for complete dependency documentation and installation instructions.

**Note**: Language-specific tools (Swift, Python, Go, etc.) are NOT YBS dependencies - they're only needed if you build a system in that language.

## For Claude Code

If you're Claude Code reading this, see **CLAUDE.md** in this directory for detailed instructions.

---

**Note**: These instructions reference the foundational specifications in `docs/specs/system/` but create a separate, independent build in the `builds/` directory.

## Versioning

All documentation in this directory uses semantic versioning (major.minor.patch):
- **Current policy**: Versions remain at 0.x.x (pre-1.0)
- Start: 0.1.0
- Increment: 0.2.0, 0.3.0, 0.4.0, etc. (minor version only)
- **Major version 1.0.0 will be decided later**
- Each document tracks its own version independently

## Version History

### 0.8.0 (2026-01-17)
- **CRITICAL TIMING FIX**: Clarified that timing must reflect actual elapsed time
- **Updated Step 2 (ybs-step_c5404152680d)**: Added CONFIG markers (v0.3.0) - reads from BUILD_CONFIG.json
- **Switched from python3 to jq**: All JSON queries now use jq (standard tool)
- **Added DEPENDENCIES.md**: Complete YBS framework dependency documentation
- **Added Dependencies section**: To README with quick reference
- Updated CLAUDE.md to version 0.8.0 with timing clarifications
- Updated Step 1 to use jq instead of python3

### 0.7.0 (2026-01-17)
- **Added Step 0 (Build Configuration)**: Collects all configurable values upfront
- **Added `{{CONFIG:...}}` syntax**: Mark configurable values in steps
- **Added BUILD_CONFIG.json**: Central configuration file
- **Added Progress Metrics**: Track completion percentage and time estimates
- **Added Spec-to-Step Traceability**: Mandatory in all steps
- **Added Multi-Agent Coordination**: Single-agent only (forbid parallel)
- Updated CLAUDE.md to version 0.7.0
- Updated STEP_TEMPLATE.md with new sections
- Updated Step 1 as example of new format

### 0.6.0 (2026-01-17)
- **CRITICAL RULE ADDED**: Never make up or propose steps - steps defined in STEPS_ORDER.txt ONLY
- Updated CLAUDE.md to version 0.6.0 with this rule as highest priority
- Workflow now explicitly checks if next step exists before proceeding

### 0.5.0 (2026-01-17)
- **Added STEP_TEMPLATE.md**: Template for creating new step files
- Added timing requirements: all steps must track start time, end time, and duration
- Added retry limit policy: maximum 3 attempts for failed verifications
- Updated CLAUDE.md to version 0.5.0 with new timing and retry requirements

### 0.4.0 (2026-01-17)
- Clarified that framework can build ANY system (not just LLM assistants)
- Updated description to emphasize YBS methodology
- Improved clarity around framework being general-purpose

### 0.3.0 (2026-01-16)
- Changed step naming to ybs-step_<12hex> format (GUID-based)
- Added STEPS_ORDER.txt for flexible step sequencing
- Added list-steps.sh helper script
- Support for branching, loops, optional steps
- Renamed all yds → ybs (Yelich Build System)

### 0.2.0 (2026-01-16)
- Moved step files into steps/ subdirectory
- Updated references to new location

### 0.1.0 (2026-01-16)
- Initial version
