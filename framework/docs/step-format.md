# Step File Format Specification

**Version**: 0.1.0
**Last Updated**: 2026-01-17

📍 **You are here**: YBS Framework > Documentation > Step Format
**↑ Parent**: [Documentation Hub](README.md)
📚 **Quick Links**: [README](../README.md) | [Glossary](glossary.md) | [Step Template](../templates/step-template.md)

---

## Overview

This document specifies the complete format for YBS step files. Step files guide AI agents through building systems autonomously with clear objectives, instructions, verification, and traceability.

---

## File Naming

### Format
```
ybs-step_<guid>.md
```

### Components
- **Prefix**: `ybs-step_` (fixed)
- **GUID**: 12-character hexadecimal identifier (lowercase)
- **Extension**: `.md` (Markdown)

### Examples
```
ybs-step_000000000000.md  # Step 0 (configuration)
ybs-step_478a8c4b0cef.md  # Step 1
ybs-step_c5404152680d.md  # Step 2
ybs-step_89b9e6233da5.md  # Step 3
```

### Special: Step 0
- **GUID**: Always `000000000000` (twelve zeros)
- **Purpose**: Configuration collection (BUILD_CONFIG.json generation)
- **Must run first**: Prerequisites for all other steps

---

## File Structure

### Required Sections

Every step file MUST contain these sections in order:

1. **Title** (H1 heading)
2. **Version** (metadata)
3. **Overview**
4. **Step Objectives**
5. **Prerequisites**
6. **Configurable Values**
7. **Traceability**
8. **Instructions**
9. **Verification**
10. **Documentation**
11. **Success Criteria**

### Optional Sections

May include:
- **Common Issues** - Known problems and solutions
- **Next Steps** - What comes after this step
- **Version History** - Change log
- **Notes** - Additional context

---

## Section Specifications

### 1. Title (Required)

```markdown
# Step NNNNNN: [Step Title]
```

- **H1 heading** with step number and descriptive title
- **Step number**: For humans (000001, 000002, etc.)
- **Title**: Action-oriented, describes what step accomplishes

**Examples**:
- `# Step 000000: Collect Build Configuration`
- `# Step 000001: Initialize Build Workspace`
- `# Step 000002: Set Up Project Environment`

---

### 2. Version (Required)

```markdown
**Version**: 0.1.0
```

- **Format**: Semantic versioning (major.minor.patch)
- **Starting version**: 0.1.0 for new steps
- **Increment**: Minor version for changes (0.1.0 → 0.2.0)
- **Major version**: Locked at 0.x.x (never go to 1.0.0)

---

### 3. Overview (Required)

```markdown
## Overview

[Brief description of what this step accomplishes and why it's needed.]
```

- **Purpose**: High-level summary for humans
- **Length**: 1-3 sentences
- **Content**: What, why, and context

---

### 4. Step Objectives (Required)

```markdown
## Step Objectives

1. [Objective 1]
2. [Objective 2]
3. [Objective 3]
```

- **Format**: Numbered list of specific outcomes
- **Count**: 3-7 objectives typical
- **Style**: Action-oriented (verb phrases)

**Examples**:
- "Create project directory structure"
- "Initialize build tools and package manager"
- "Verify build environment works"

---

### 5. Prerequisites (Required)

```markdown
## Prerequisites

- Previous step: ybs-step_<guid> must be completed
- BUILD_CONFIG.json must exist (Step 0 completed)
- [Other prerequisites]
```

- **Always include**: Previous step completion
- **Step 0 dependency**: Explicit if using CONFIG values
- **Other**: Tools, files, or conditions required

---

### 6. Configurable Values (Required)

**If step has CONFIG markers**:

```markdown
## Configurable Values

**This step uses the following configuration values:**

- `{{CONFIG:key|type|description|default}}` - [Where/how used]
- `{{CONFIG:key2|type|description|default}}` - [Where/how used]
```

**If step has no CONFIG markers**:

```markdown
## Configurable Values

This step has no configurable values.
```

See [CONFIG Markers](config-markers.md) for syntax specification.

---

### 7. Traceability (Required)

```markdown
## Traceability

**Implements**: [Which spec sections this step implements]
- ybs-spec.md Section X.Y (Feature Name)
- ybs-spec.md Section A.B (Component Name)

**References**: [Which architectural decisions are relevant]
- D## (Decision Name)
- D## (Decision Name)
```

**For infrastructure steps** (not implementing spec features):

```markdown
## Traceability

Infrastructure step - no spec implementation.
```

---

### 8. Instructions (Required)

```markdown
## Instructions

### Before Starting

**Record start time**: Note the current timestamp (ISO 8601: YYYY-MM-DD HH:MM UTC)

### 1. [First Sub-Step Title]

[Detailed instructions]

**Commands**:
\```bash
[commands]
\```

**Files to create/modify**:
- path/to/file

### 2. [Second Sub-Step Title]

[Instructions]
```

**Format**:
- **"Before Starting"**: Always record start time first
- **Numbered sub-steps**: Sequential (1, 2, 3, ...)
- **Clear instructions**: Executable by AI agent
- **Code blocks**: For commands and examples
- **File lists**: What files are affected

---

### 9. Verification (Required)

```markdown
## Verification

**This step is complete when**:
- [ ] [Verification check 1]
- [ ] [Verification check 2]
- [ ] [Verification check 3]

**Verification Commands**:
\```bash
[commands to verify success]
\```

**Expected Output**:
\```
[what successful verification should show]
\```

**Retry Policy**:
- If verification fails, analyze the error and fix the issue
- Maximum 3 attempts allowed
- After 3 failures, STOP and report to user

**Verification Tracking**:
- Attempt 1: [timestamp] - [result]
- Attempt 2 (if needed): [timestamp] - [result]
- Attempt 3 (if needed): [timestamp] - [result]
```

**Requirements**:
- **Checklist**: Specific, testable criteria
- **Commands**: Executable verification steps
- **Expected output**: What success looks like
- **Retry policy**: Always include 3-attempt limit
- **Tracking**: Template for recording attempts

---

### 10. Documentation (Required)

```markdown
## Documentation

### Update BUILD_STATUS.md

[Instructions for updating build status]

### Create Completion Documentation

**Record end time**: Note the completion timestamp (ISO 8601)

**Calculate duration**: End time - Start time

Create `builds/SYSTEMNAME/docs/build-history/ybs-step_<guid>-DONE.txt`:

\```
STEP ybs-step_<guid>: [Title]
STARTED: [start timestamp]
COMPLETED: [end timestamp]
DURATION: [human-readable duration]

OBJECTIVES:
- [objectives]

ACTIONS TAKEN:
- [actions]

VERIFICATION RESULTS:
✓ [passed checks]

VERIFICATION ATTEMPTS: [1-3]

ISSUES ENCOUNTERED:
[none or issues and resolutions]

FILES CREATED:
- [files]

FILES MODIFIED:
- [files]

NEXT STEP: ybs-step_<next-guid> ([Next Step Title])

TIMING SUMMARY:
- Start: [timestamp]
- End: [timestamp]
- Duration: [duration]
\```
```

**Requirements**:
- **End time**: Record after verification passes
- **Duration**: Calculate and format human-readable
- **DONE file**: Complete documentation of step execution
- **Timing**: Start, end, and duration in DONE file

---

### 11. Success Criteria (Required)

```markdown
## Success Criteria

This step is successful when:
1. All verification checks pass (within 3 attempts)
2. All required files are created/modified
3. Documentation is complete with timing information
4. BUILD_STATUS.md is updated
5. DONE file is created
```

**Purpose**: Final checklist before marking step complete

---

## Optional Sections

### Common Issues

```markdown
## Common Issues

### Issue: [Problem Name]
**Symptom**: [How it manifests]
**Solution**: [How to fix it]
```

### Next Steps

```markdown
## Next Steps

After completing this step, proceed to:
- **Next step**: ybs-step_<guid> ([Title])
```

### Version History

```markdown
## Version History

### 0.2.0 (YYYY-MM-DD)
- [Change description]

### 0.1.0 (YYYY-MM-DD)
- Initial version
```

---

## Timing Requirements

All steps must track timing:

1. **Start time**: Recorded at beginning of Instructions
2. **End time**: Recorded after verification passes
3. **Duration**: Calculated (end - start)
4. **Format**: ISO 8601 for timestamps, human-readable for duration

**Example timing**:
```
STARTED: 2026-01-17 10:30 UTC
COMPLETED: 2026-01-17 10:45 UTC
DURATION: 15 minutes
```

---

## Best Practices

### For Step Authors

1. **Clear instructions**: Executable by AI agent without ambiguity
2. **Testable verification**: Commands that confirm success
3. **Traceability**: Link to specs and decisions
4. **Error handling**: Include Common Issues section
5. **Timing**: Always require timing tracking

### For AI Agents Executing Steps

1. **Record start time**: Very first action
2. **Follow sequentially**: Don't skip or reorder instructions
3. **Track attempts**: Record each verification attempt
4. **Record end time**: After verification succeeds
5. **Calculate duration**: Include in DONE file
6. **Complete documentation**: All sections of DONE file

---

## Validation Checklist

Before publishing a step file:

- [ ] Title follows format: `# Step NNNNNN: [Title]`
- [ ] Version specified (0.1.0 for new)
- [ ] All required sections present and in order
- [ ] Configurable Values section correct (declares CONFIG or states "none")
- [ ] Traceability links to specs/decisions
- [ ] Instructions include "Before Starting" with timing
- [ ] Verification has checklist, commands, retry policy, tracking
- [ ] Documentation includes timing requirements
- [ ] Success Criteria complete
- [ ] Filename matches format: `ybs-step_<12-hex-guid>.md`

---

## See Also

- [Step Template](../templates/step-template.md) - Complete template file
- [CONFIG Markers](config-markers.md) - Configuration syntax
- [Glossary](glossary.md) - YBS terminology

---

**Version**: 0.1.0
**Created**: 2026-01-17
