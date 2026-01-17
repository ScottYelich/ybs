# Build Instructions for Claude Code

**Version**: 0.6.0

This directory contains step-by-step instructions for building software systems using the YBS framework. The current steps guide building a Swift-based LLM chat tool (the "bootstrap"), but the framework can be adapted for building any type of system.

## Step Identification System

**Steps use 12-hex GUIDs with `ybs-step_` prefix.**

- Step files: `ybs-step_478a8c4b0cef.md`, `ybs-step_c5404152680d.md`, etc.
- Order defined in: `steps/STEPS_ORDER.txt`
- View ordered list: `../../bin/list-steps.sh`

**Format: `ybs-step_<12-hex>.md`**
- `ybs-` = Yelich Build System (branded prefix)
- `step_` = identifies as a step file
- 12 hex chars = 281 trillion combinations (zero collision risk)

**Why GUIDs?**
- Insert new steps anywhere without cascading renames
- Support branching (if/else paths based on language, platform)
- Support loops (repeat steps for each tool/component)
- Support optional steps
- Stable identity (GUID never changes)

**Example:**
```bash
$ ../../bin/list-steps.sh
000001 ybs-step_478a8c4b0cef  # Initialize Build Workspace
000002 ybs-step_c5404152680d  # Define Architecture
000003 ybs-step_89b9e6233da5  # Set Up Project Environment
```

## Documentation Versioning

**CRITICAL RULE**: All documentation uses semantic versioning (major.minor.patch).

### Versioning Policy (LOCKED)
- **Format**: major.minor.patch (e.g., 0.1.0, 0.2.0, 0.3.0)
- **Starting version**: 0.1.0
- **Increment rule**: ONLY increment minor version (0.1.0 → 0.2.0 → 0.3.0)
- **Major version**: LOCKED at 0.x.x - do NOT increment to 1.0.0
- **Decision on 1.0.0**: To be made much later (not now)
- **Patch version**: Use for typo fixes only (0.2.0 → 0.2.1)

### What Gets Versioned
- ✓ ybs-step_<guid>.md files (each has its own version)
- ✓ CLAUDE.md (this file)
- ✓ README.md
- ✓ STEPS_ORDER.txt
- ✓ BUILD_STATUS.md in builds/SYSTEMNAME/
- ✓ All generated documentation

### Version Header Format
Every document must have a version header near the top:
```markdown
**Version**: 0.1.0
```

### When to Increment Version
- **Minor version** (0.1.0 → 0.2.0): Any content change, new instructions, workflow changes
- **Patch version** (0.2.0 → 0.2.1): Typo fixes, formatting only, no content changes
- **Major version** (0.x.x → 1.0.0): PROHIBITED until later decision

### Version in BUILD_STATUS.md
BUILD_STATUS.md must include:
```markdown
**Document Version**: 0.1.0
**Last Updated**: [timestamp]
```

## How This Works

### Instruction Files
Each `steps/ybs-step_<guid>.md` file contains complete instructions for a single build step. Each step file has its own version. Read and execute steps in the order defined in `STEPS_ORDER.txt`.

**Location**: All step files are in the `steps/` subdirectory.
**Order**: Defined in `steps/STEPS_ORDER.txt`
**Helper**: Use `../../bin/list-steps.sh` to see numbered order

### Work Area
All build work happens in `builds/SYSTEMNAME/` at the repository root:
- `builds/` - Created at same level as `docs/`
- `builds/SYSTEMNAME/` - Specific build workspace (name chosen in first step)
- `builds/SYSTEMNAME/docs/build-history/` - Completed step documentation

### Build Tracking

Each build maintains a status file at:
```
builds/SYSTEMNAME/BUILD_STATUS.md
```

This file tracks:
- Current step GUID
- Current step status (in_progress, completed, blocked)
- Issues encountered
- Next step GUID

### Workflow

1. **Find next step**: Check STEPS_ORDER.txt or BUILD_STATUS.md for next step GUID
   - **If no next step exists**: Report "All steps completed" - do NOT make up or propose steps
2. **Read step file**: Read `steps/ybs-step_<guid>.md` completely
3. **Record start time**: Note the step start timestamp in ISO 8601 format (YYYY-MM-DD HH:MM UTC)
4. **Create todo list**: Use TodoWrite tool to track sub-tasks for the step
5. **Execute instructions**: Follow all instructions in the step
6. **Write tests**: For code steps, write unit tests before or during implementation
7. **Verify completion**: Run verification checks specified in the step (including tests)
   - **Retry limit**: If verification fails, retry up to 3 times total
   - **After 3 failures**: STOP and report to user - do NOT continue attempting
   - **Track attempts**: Document each attempt and what failed
8. **Record end time**: Note the step completion timestamp
9. **Calculate duration**: Compute total time taken for the step
10. **Document results**: Create `builds/SYSTEMNAME/docs/build-history/ybs-step_<guid>-DONE.txt` (include timing)
11. **Update status**: Update `BUILD_STATUS.md` with completion and next step GUID
12. **Proceed**: Move to next step in STEPS_ORDER.txt

### Step Documentation Format

When a step is complete, create documentation at:
```
builds/SYSTEMNAME/docs/build-history/ybs-step_<guid>-DONE.txt
```

Include:
- Step GUID and title
- **Start time**: When step execution began (ISO 8601: YYYY-MM-DD HH:MM UTC)
- **End time**: When step completed (ISO 8601: YYYY-MM-DD HH:MM UTC)
- **Duration**: Total time taken (e.g., "15 minutes", "1 hour 23 minutes")
- What was accomplished
- Verification results
- **Verification attempts**: Number of attempts if verification was retried (1-3)
- Any issues encountered and resolutions
- Next step GUID

### Important Rules

- **NEVER MAKE UP STEPS**: Steps are defined in STEPS_ORDER.txt ONLY. Do NOT invent, propose, or suggest what future steps should be. If all steps are completed, state that clearly.
- **One step at a time**: Do not skip ahead or combine steps
- **Track timing**: Record start time, end time, and calculate duration for EVERY step
- **Use todo lists**: Create TodoWrite list for each step to track progress
- **Write tests**: For code implementation steps, write unit tests
- **Verify before proceeding**: Each step must pass verification (including tests)
- **Retry limit**: If verification fails, retry up to 3 times total, then STOP
- **Document everything**: Every completed step gets a DONE file with timing information
- **Update status file**: Keep BUILD_STATUS.md current
- **Reference specs**: Use `../../specs/system/ybs-spec.md` and related specs as reference

### Starting Point

Begin with `steps/step_000000.md` which will:
1. Ask for system name
2. Create `builds/SYSTEMNAME/` structure
3. Initialize BUILD_STATUS.md
4. Create build-history directory
5. Set up initial documentation

### Testing Requirements

For steps that involve code implementation:
- **Write tests first or during development** (TDD or concurrent testing)
- **Unit tests**: Test individual functions/classes in isolation
- **Integration tests**: Test components working together
- **Verification**: All tests must pass before marking step complete
- **Test location**: Tests go in language-specific test directory (Tests/, tests/, etc.)

### Build Status File Format

```markdown
# Build Status

**Version**: 0.1.0
**System Name**: [name]
**Current Step**: ybs-step_<guid>
**Step Version**: [step version]
**Status**: [in_progress | completed | blocked]
**Last Updated**: [timestamp]

## Current Step Details
- **Title**: [step title]
- **Status**: [status]
- **Issues**: [any issues or "none"]

## Next Action
[What needs to be done next]

## Progress Summary
- Steps completed: N
- Steps remaining: [estimated]
- Overall status: [percentage or description]
```

### Error Handling

**Retry Policy for Verification Failures**:
- **Attempt 1**: Run verification as specified in step
- **If fails**: Analyze error, fix issue, retry (attempt 2)
- **If fails again**: Re-analyze, fix, retry (attempt 3)
- **If fails 3rd time**: STOP - report to user

**After 3 failed attempts**:
1. Document ALL failure attempts in BUILD_STATUS.md
2. Document what was tried and why it failed
3. Do NOT create a DONE file
4. Do NOT proceed to next step
5. Set status to "blocked"
6. Report to user with detailed failure information
7. Wait for user guidance

**On successful verification** (within 3 attempts):
1. Document number of attempts in DONE file
2. Document what failed and how it was resolved
3. Proceed with normal workflow

### Reference Documentation

Core specifications are in:
- `../../specs/system/ybs-spec.md` - Technical specification
- `../../specs/system/ybs-decisions.md` - Architectural decisions
- `../../specs/system/ybs-lessons-learned.md` - Implementation checklist

### Step-to-Spec Traceability

**Critical**: Steps and specs must stay synchronized.

**Each step file should include:**
- **Implements**: Which YBS spec sections this step implements
  - Example: `Implements: ybs-spec.md Section 2 (Configuration System)`
- **References**: Which architectural decisions are relevant
  - Example: `References: D04 (Hybrid Tool Architecture), D08 (Edit Format)`

**When creating new steps:**
1. Reference which spec sections you're implementing
2. If the spec is incomplete, note what needs to be added
3. Update the spec before or during step creation

**When updating specs:**
1. Check which steps are affected
2. Update those step files to match
3. Add new steps if new functionality is specified

This ensures:
- All specs have corresponding implementation steps
- All steps trace back to specifications
- Changes in one trigger updates in the other

### Example Session

```
1. User: "Execute step 478a8c4b0cef"
2. Claude reads: docs/build-from-scratch/steps/ybs-step_478a8c4b0cef.md
3. Claude creates: TodoWrite list for step sub-tasks
4. Claude asks: "What should we name this system?"
5. User: "myproject"
6. Claude creates: builds/myproject/ structure
7. Claude verifies: All directories and files created
8. Claude documents: builds/myproject/docs/build-history/ybs-step_478a8c4b0cef-DONE.txt
9. Claude updates: builds/myproject/BUILD_STATUS.md
10. Claude reports: "Step complete. Next: ybs-step_c5404152680d"
```

## Directory Structure After Step 0

```
repository-root/
├── docs/
│   ├── specs/                   # YBS specifications (reference)
│   │   ├── system/              # System-wide specs
│   │   ├── business/            # Business specs per feature
│   │   ├── functional/          # Functional specs per feature
│   │   ├── technical/           # Technical specs per feature
│   │   └── testing/             # Testing specs per feature
│   └── build-from-scratch/      # Instructions (this directory)
│       ├── CLAUDE.md           # This file
│       ├── README.md           # Human-readable overview
│       └── steps/              # All step files
│           ├── STEPS_ORDER.txt # Step sequence definition
│           ├── ybs-step_478a8c4b0cef.md  # Initialize
│           ├── ybs-step_c5404152680d.md  # Architecture
│           └── ybs-step_89b9e6233da5.md  # Project Setup
└── builds/
    └── SYSTEMNAME/             # Created by first step (OUTPUT)
        ├── BUILD_STATUS.md     # Current build status
        ├── README.md           # System overview
        ├── CLAUDE.md           # System-specific Claude guidance
        └── docs/
            └── build-history/  # Completed step documentation
                ├── ybs-step_478a8c4b0cef-DONE.txt
                └── ybs-step_c5404152680d-DONE.txt
```

## Working with Multiple Builds

You can have multiple builds in parallel:
```
builds/
├── swiftcoder/
├── experimental-v2/
└── minimal-prototype/
```

Each maintains its own BUILD_STATUS.md and build-history.

---

## Version History

### 0.6.0 (2026-01-17)
- **CRITICAL RULE ADDED**: Never make up or propose steps - steps are defined in STEPS_ORDER.txt ONLY
- Updated workflow step 1 to check if next step exists
- Added this rule as FIRST in Important Rules section (highest priority)

### 0.5.0 (2026-01-17)
- **Added retry limit policy**: Maximum 3 attempts for failed verifications
- **Added timing requirements**: Track start time, end time, and duration for all steps
- Updated workflow to include timing tracking (steps 3, 8, 9)
- Updated step documentation format to include timing and retry attempts
- Enhanced error handling section with detailed retry policy
- Updated important rules to include timing and retry requirements

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
- Renamed docs/misc → docs/ybs-spec

### 0.2.0 (2026-01-16)
- Moved step files into steps/ subdirectory
- Added todo list requirement for each step
- Added testing requirements (unit tests, integration tests)
- Updated all references to steps/ location

### 0.1.0 (2026-01-16)
- Initial version
- Documented workflow, status tracking, build history format
- Established versioning policy (locked at 0.x.x)

---

**Ready to start?** Run `../../bin/list-steps.sh` to see steps, then read the first step file.
