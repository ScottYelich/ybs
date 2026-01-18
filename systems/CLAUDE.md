# CLAUDE.md - Systems Directory

**Version**: 0.2.0
**Last Updated**: 2026-01-18

📍 **You are here**: YBS Repository > Systems > AI Agent Guide
📚 **See also**: [README.md](README.md) | [Repository CLAUDE.md](../CLAUDE.md) | [Framework](../framework/README.md)

---

This file provides guidance to Claude Code when working on systems in this directory.

## What Are You Doing?

### → Building a System

You're executing build steps to create a system:

**Working directory**: `systems/SYSTEMNAME/builds/BUILDNAME/`

**Steps**:
1. **Read**: systems/SYSTEMNAME/CLAUDE.md
2. **Execute**: Step 0 (Build Configuration)
3. **Continue**: Autonomously through Steps 1-N
4. **Track**: Progress in BUILD_STATUS.md
5. **Recover**: From SESSION.md if interrupted

**Remember**: You're building ONE specific system, not working on framework or defining systems.

---

### → Defining a New System

You're creating specifications and build steps for a new system:

**Working directory**: `systems/NEWSYSTEM/`

**Steps**:
1. **Read**: ../framework/methodology/writing-specs.md
2. **Read**: ../framework/methodology/writing-steps.md
3. **Create**: specs/ directory with specifications
4. **Create**: steps/ directory with build steps
5. **Create**: README.md and CLAUDE.md
6. **Test**: Have AI agent execute build

**Remember**: System definitions are self-contained (specs + steps + docs).

---

### → NOT Systems Work

If you're doing any of these, you're in the wrong place:

- ❌ **Working on framework** → See ../framework/CLAUDE.md
- ❌ **Repository-level work** → See ../CLAUDE.md
- ❌ **Building bootstrap specifically** → See bootstrap/CLAUDE.md

---

## Systems Directory Structure

```
systems/
├── README.md                          # This directory overview
├── CLAUDE.md                          # This file - AI agent guide
│
└── SYSTEMNAME/                        # Specific system definition
    ├── README.md                      # System overview
    ├── CLAUDE.md                      # System-specific AI agent guide
    │
    ├── specs/                         # Specifications (WHAT)
    │   ├── technical/
    │   ├── architecture/
    │   ├── general/
    │   ├── business/
    │   ├── functional/
    │   ├── testing/
    │   ├── security/
    │   └── operations/
    │
    ├── steps/                         # Build steps (HOW)
    │   ├── STEPS_ORDER.txt
    │   └── SYSTEM-step_*.md
    │
    ├── docs/                          # System documentation
    │
    └── builds/                        # Build workspaces (WHERE)
        └── BUILDNAME/
            ├── BUILD_CONFIG.json
            ├── BUILD_STATUS.md
            ├── SESSION.md
            └── [build artifacts]
```

---

## Common Tasks

### Task: Build a System (Execute Steps)

**When**: You're an AI agent building a system from specs/steps

**Location**: `systems/SYSTEMNAME/`

**Process**:
1. **Read system guide**: `systems/SYSTEMNAME/CLAUDE.md`
2. **Read Step 0**: `systems/SYSTEMNAME/steps/SYSTEM-step_000000000000.md`
3. **Execute Step 0**:
   - Check if BUILD_CONFIG.json exists
   - If yes: Read config, skip questions
   - If no: Ask questions, create config
4. **Continue through steps**:
   - Read STEPS_ORDER.txt
   - Execute each step in order
   - Verify after each step
   - Update BUILD_STATUS.md
   - Update SESSION.md regularly
5. **Complete**: When all steps pass verification

**Example**:
```bash
cd systems/bootstrap/
cat CLAUDE.md                          # Read system guidance
cat steps/ybs-step_000000000000.md    # Read Step 0
# Execute Step 0 (in builds/testN/)
# Continue through Steps 1-N autonomously
```

---

### Task: Define a New System

**When**: Creating specs and steps for a new system to build

**Location**: Create new `systems/NEWSYSTEM/` directory

**Process**:
1. **Create directory structure**:
   ```bash
   mkdir -p systems/NEWSYSTEM/{specs,steps,docs,builds}
   cd systems/NEWSYSTEM
   ```

2. **Write specifications**:
   - Read: ../../framework/methodology/writing-specs.md
   - Create: specs/technical/, specs/architecture/, etc.
   - Write: WHAT to build (requirements, architecture, decisions)

3. **Write build steps**:
   - Read: ../../framework/methodology/writing-steps.md
   - Create: steps/SYSTEM-step_000000000000.md (Step 0)
   - Create: steps/SYSTEM-step_<guid>.md (Steps 1-N)
   - Create: steps/STEPS_ORDER.txt

4. **Create documentation**:
   - Create: README.md (system overview)
   - Create: CLAUDE.md (AI agent guidance)
   - Document: Principles, architecture, design

5. **Test with AI agent**:
   - Have AI agent execute Step 0
   - Verify agent can build autonomously
   - Refine steps based on gaps

---

### Task: Refine Existing System

**When**: Improving specs or steps for an existing system

**Location**: `systems/SYSTEMNAME/`

**Process**:
1. **Identify issue**: What gap or ambiguity needs fixing?
2. **Update specs first**: Specs are source of truth
3. **Update steps if needed**: Reflect spec changes
4. **Test changes**: Have AI agent rebuild
5. **Verify improvement**: Agent doesn't get stuck anymore
6. **Update version**: Increment version numbers
7. **Document**: Note what was improved and why

---

## Important Rules

### 1. System Independence

**Each system is self-contained**

When defining systems:
- ✅ Keep all specs, steps, docs inside system directory
- ✅ Don't reference other systems (bootstrap, etc.)
- ❌ Don't create cross-system dependencies
- ❌ Don't assume specific languages or platforms (unless system-specific)

### 2. Specs as Source of Truth

**Specifications define reality**

When working on systems:
- ✅ Update specs FIRST, then code
- ✅ Every feature must have a spec reference
- ❌ Don't implement unspecified features
- ❌ Don't let specs drift from code

**Rule**: If it's not in specs, it doesn't exist. If code exists without specs, it's a bug.

### 3. Autonomous Execution

**Build steps must enable autonomy**

When writing steps:
- ✅ Provide sufficient detail for AI agents
- ✅ Step 0 collects ALL config upfront
- ✅ Steps 1-N execute with zero prompts
- ❌ Don't write steps that require human clarification

### 4. Traceability Required

**Every implementation traces to specs**

When building systems:
- ✅ Add `// Implements: spec § X.Y` comments
- ✅ Steps reference specs they implement
- ✅ Use check-traceability.sh to verify
- ❌ Don't write code without spec references

### 5. Verification Explicit

**Every step has verification criteria**

When writing steps:
- ✅ Explicit, automated verification where possible
- ✅ Tests must pass before proceeding
- ✅ 3x retry limit before failure
- ❌ No vague "make sure it works" verification

---

## Building Systems: Key Concepts

### Step 0: Build Configuration

**ALWAYS execute Step 0 first**

**Step 0 logic**:
1. Check if BUILD_CONFIG.json exists
2. **If exists**: Read config, skip questions, proceed
3. **If not exists**: Scan steps, ask questions, create config
4. Save to BUILD_CONFIG.json
5. Mark Step 0 complete

**Why**: Enables zero-interaction rebuilds and machine-updatable configs.

### Autonomous Execution

**Work continuously after Step 0**

**Rules**:
- ✅ Execute steps in STEPS_ORDER.txt order
- ✅ Verify after each step
- ✅ Update BUILD_STATUS.md progress
- ✅ Update SESSION.md regularly
- ✅ Only stop for critical errors or 3x verification failures
- ❌ Never ask "Should I proceed to next step?"
- ❌ Never prompt user during Steps 1-N

### Session Tracking

**Always maintain SESSION.md**

**Protocol**:
1. **Session start**: Check for SESSION.md
2. **If exists**: Resume from where it left off
3. **If not**: Create new SESSION.md
4. **During work**: Update after every significant action
5. **On completion**: Move to build-history/

**Why**: Claude crashes frequently. SESSION.md enables recovery.

### Verification

**Every step must verify**

**Verification types**:
- Compilation success
- Tests passing
- Files exist
- Commands execute successfully
- Output matches expected

**Failure handling**:
- Retry up to 3 times
- If still failing: Stop and report error
- Update BUILD_STATUS.md with failure

---

## System-Specific Guidance

### When You Navigate to a System

**Always read system-specific CLAUDE.md first**

Each system has:
- `systems/SYSTEMNAME/README.md` - System overview (for humans)
- `systems/SYSTEMNAME/CLAUDE.md` - AI agent guidance (for you!)

**Example**:
```bash
cd systems/bootstrap/
cat CLAUDE.md  # Read this FIRST before building bootstrap
```

---

## Quality Checklist

Before considering system definition complete:

**Specifications**:
- [ ] Technical specs written
- [ ] Architecture decisions documented
- [ ] All _BASE.md files created
- [ ] Specs are language-agnostic (unless system-specific)
- [ ] Specs define all features

**Build Steps**:
- [ ] Step 0 created (Build Configuration)
- [ ] Steps 1-N created
- [ ] STEPS_ORDER.txt defines order
- [ ] Each step has verification criteria
- [ ] Steps provide sufficient detail for autonomy

**Documentation**:
- [ ] README.md created (system overview)
- [ ] CLAUDE.md created (AI agent guide)
- [ ] Principles documented (if applicable)

**Testing**:
- [ ] AI agent can execute Step 0 successfully
- [ ] AI agent can build autonomously
- [ ] No gaps or ambiguities that cause agent to get stuck

---

## Common Pitfalls

### Pitfall 1: Insufficient Detail

**Problem**: Steps too vague, AI agent gets stuck

**Example**:
```markdown
❌ BAD: "Create the main application logic"
✅ GOOD: "Create Sources/bootstrap/main.swift with:
         - Import Foundation
         - Define main() function
         - Call runChatLoop()
         - Verify: swift build succeeds"
```

**Fix**: Provide specific, actionable instructions with verification.

---

### Pitfall 2: Unspecified Features

**Problem**: Code without corresponding specs

**Example**:
```swift
❌ BAD:
// No spec reference
func myFeature() { }

✅ GOOD:
// Implements: ybs-spec.md § 4.2.3 (Feature Name)
func myFeature() { }
```

**Fix**: Always add spec references. Use check-traceability.sh.

---

### Pitfall 3: Step 0 Prompts Every Time

**Problem**: Not checking for BUILD_CONFIG.json

**Fix**: Step 0 MUST check if config exists first:
```markdown
1. Check if BUILD_CONFIG.json exists
2. If yes: Read config, skip to verification
3. If no: Scan steps, ask questions, create config
```

---

### Pitfall 4: Cross-System Dependencies

**Problem**: System references another system

**Example**:
```markdown
❌ BAD: "See systems/bootstrap/specs/ybs-spec.md"
✅ GOOD: "See specs/SYSTEM-spec.md" (within same system)
```

**Fix**: Keep systems self-contained.

---

## Workflow Summary

**Building a system** (typical session):

1. **Navigate**: `cd systems/SYSTEMNAME/`
2. **Read**: `cat CLAUDE.md` (system-specific guidance)
3. **Check recovery**: `cat builds/BUILDNAME/SESSION.md` (if exists)
4. **Execute Step 0**: Read and execute build configuration
5. **Continue autonomously**: Follow STEPS_ORDER.txt
6. **Verify each step**: Before proceeding
7. **Update tracking**: BUILD_STATUS.md and SESSION.md
8. **Complete**: Mark all steps done
9. **Clean up**: Move SESSION.md to build-history/

---

## Getting Help

**If stuck on systems work**:

1. Read system-specific CLAUDE.md
2. Read system README.md
3. Review system specs/
4. Check Framework methodology docs:
   - ../framework/methodology/executing-builds.md (building)
   - ../framework/methodology/writing-specs.md (defining)
   - ../framework/methodology/writing-steps.md (defining)
5. Look at bootstrap as example:
   - systems/bootstrap/CLAUDE.md
   - systems/bootstrap/specs/
   - systems/bootstrap/steps/

---

## Version History

- **0.2.0** (2026-01-18): Initial systems directory CLAUDE.md

---

## References

- **Systems Overview**: [README.md](README.md)
- **Repository Guide**: [../CLAUDE.md](../CLAUDE.md)
- **Framework Guide**: [../framework/CLAUDE.md](../framework/CLAUDE.md)
- **Bootstrap Example**: [bootstrap/CLAUDE.md](bootstrap/CLAUDE.md)

---

*Build systems autonomously with YBS.*
