# Build from Scratch Instructions

**Version**: 0.4.0

This directory contains step-by-step instructions for building software systems from scratch using the YBS framework. The current steps guide building a Swift-based LLM chat tool (the "bootstrap"), but the framework is designed to guide building any type of system.

## Purpose

Each step file is a single build step with complete instructions. Steps use GUID-based naming for flexible ordering (insert, branch, loop).

## Structure

- **steps/** - Directory containing all step files
  - **STEPS_ORDER.txt** - Defines step sequence (GUID-based)
  - **ybs-step_<guid>.md** - Individual step files (12-hex GUID)
- **CLAUDE.md** - Guide for Claude Code on how to use these instructions
- **README.md** - This file (for humans)

**Helper Scripts**: Located in `../../bin/` at repository root:
- **list-steps.sh** - View steps in numbered order

## Work Area

All build work happens in the `builds/` directory at the repository root (sibling to `docs/`). Each build gets its own named subdirectory.

## How to Use

1. View steps: Run `../../bin/list-steps.sh` to see ordered list
2. Start with first step: `steps/ybs-step_478a8c4b0cef.md` (Initialize)
3. Follow steps in order defined in `steps/STEPS_ORDER.txt`
4. Each step verifies completion before moving to next
5. Build history tracked in `builds/SYSTEMNAME/docs/build-history/`

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
