# Step NNNNNN: [Step Title]

**Version**: 0.1.0

## Overview

[Brief description of what this step accomplishes and why it's needed.]

## What This Step Builds

[Detailed explanation of what will be created or implemented in this step.]

## Step Objectives

1. [Objective 1]
2. [Objective 2]
3. [Objective 3]
...

## Prerequisites

[List any steps that must be completed before this one, or any conditions that must be met.]

- Previous step: ybs-step_[guid] must be completed
- [Other prerequisites]

## Traceability

**Implements**: [Which spec sections this step implements]
- Example: `ybs-spec.md Section 2.3 (Configuration Loading)`

**References**: [Which architectural decisions are relevant]
- Example: `D04 (Hybrid Tool Architecture), D08 (Edit Format)`

## Instructions

### Before Starting

**Record start time**: Note the current timestamp (ISO 8601: YYYY-MM-DD HH:MM UTC)

### 1. [First Sub-Step Title]

[Detailed instructions for the first sub-step.]

**Commands**:
```bash
[command examples if applicable]
```

**Files to create/modify**:
- `path/to/file1`
- `path/to/file2`

### 2. [Second Sub-Step Title]

[Detailed instructions for the second sub-step.]

### N. [Final Sub-Step Title]

[Instructions for final sub-step.]

## Verification

**This step is complete when**:
- [ ] [Verification check 1]
- [ ] [Verification check 2]
- [ ] [Verification check 3]

**Verification Commands**:
```bash
[commands to verify the step completed successfully]
```

**Expected Output**:
```
[what successful verification should show]
```

**Retry Policy**:
- If verification fails, analyze the error and fix the issue
- Maximum 3 attempts allowed
- After 3 failures, STOP and report to user

**Verification Tracking**:
- Attempt 1: [timestamp] - [result]
- Attempt 2 (if needed): [timestamp] - [result]
- Attempt 3 (if needed): [timestamp] - [result]

## Documentation

### Update BUILD_STATUS.md

Add or update relevant sections in `builds/SYSTEMNAME/BUILD_STATUS.md`:

```markdown
**Current Step**: ybs-step_[guid]
**Status**: completed
**Last Updated**: [end timestamp]

## [Section Title if applicable]
- [Information about what was added/changed]
```

### Create Completion Documentation

**Record end time**: Note the completion timestamp (ISO 8601: YYYY-MM-DD HH:MM UTC)

**Calculate duration**: End time - Start time

Create `builds/SYSTEMNAME/docs/build-history/ybs-step_[guid]-DONE.txt`:

```
STEP ybs-step_[guid]: [Step Title]
STARTED: [start timestamp]
COMPLETED: [end timestamp]
DURATION: [human-readable duration, e.g., "15 minutes" or "1 hour 23 minutes"]

OBJECTIVES:
- [objective 1]
- [objective 2]

ACTIONS TAKEN:
- [action 1]
- [action 2]

VERIFICATION RESULTS:
✓ [check 1 passed]
✓ [check 2 passed]
[If applicable: ✗ Attempt 1 failed: reason]
[If applicable: ✓ Attempt 2 succeeded after fixing: explanation]

VERIFICATION ATTEMPTS: [1, 2, or 3]

ISSUES ENCOUNTERED:
[none or list issues and resolutions]

FILES CREATED:
- path/to/file1
- path/to/file2

FILES MODIFIED:
- path/to/file3
- builds/SYSTEMNAME/BUILD_STATUS.md

NEXT STEP: ybs-step_[next-guid] ([Next Step Title])

TIMING SUMMARY:
- Start: [start timestamp]
- End: [end timestamp]
- Duration: [duration]
```

## Success Criteria

This step is successful when:
1. All verification checks pass (within 3 attempts)
2. All required files are created/modified
3. Documentation is complete with timing information
4. BUILD_STATUS.md is updated
5. DONE file is created

## Common Issues

### Issue: [Common Problem 1]
**Symptom**: [How it manifests]
**Solution**: [How to fix it]

### Issue: [Common Problem 2]
**Symptom**: [How it manifests]
**Solution**: [How to fix it]

## Next Steps

After completing this step, proceed to:
- **Next step**: ybs-step_[next-guid] ([Next Step Title])

---

## Template Usage Notes

**For step authors**:
1. Replace all `[placeholders]` with actual content
2. Replace `NNNNNN` with step number (e.g., 000004)
3. Replace `[guid]` with actual 12-hex GUID (e.g., a1b2c3d4e5f6)
4. Update version when making changes (0.1.0 → 0.2.0)
5. Ensure traceability section links to specs and decisions
6. Provide clear, executable instructions
7. Include verification commands with expected output
8. List common issues and solutions

**For Claude executing steps**:
1. Record start time at beginning
2. Follow instructions sequentially
3. Track verification attempts (max 3)
4. Record end time after verification passes
5. Calculate and document duration
6. Include all timing in DONE file

---

**Version**: 0.1.0
**Created**: 2026-01-17
**Last Updated**: 2026-01-17
