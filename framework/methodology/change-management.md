# Change Management Workflow

**Version**: 1.0.0
**Last Updated**: 2026-01-18

> How to handle changes to system specifications and build steps after initial implementation

---

## Overview

**Problem**: You build a system, test it, find bugs or want to add features. How do those changes flow back into specs and steps so the next build doesn't repeat problems?

**Solution**: A systematic change management workflow that ensures specs and steps stay synchronized with reality.

---

## Core Principle

**Specs and steps must reflect reality, not just initial design.**

When you discover:
- A bug that needs fixing
- A feature that should be added
- An enhancement to improve existing functionality
- A modification to change behavior

These discoveries must flow back into specs and steps, or future builds will repeat the same issues.

---

## The Four Change Types

### 1. New Feature (Net New)

**Definition**: Adding something completely new that doesn't exist in the system.

**Examples**:
- Add web search capability (new tool)
- Add session persistence (new feature)
- Add cost tracking (new capability)

**When**: User requests new functionality, or you identify missing capability during testing.

---

### 2. Enhancement (Augmentation)

**Definition**: Improving or extending something that already exists.

**Examples**:
- Add cost estimation to existing `/stats` command
- Add pruning history to existing context management
- Add readline to existing input system

**When**: Existing feature works but could be better, or new requirements extend existing capability.

---

### 3. Bug Fix (Correction)

**Definition**: Fixing something broken or incorrect.

**Examples**:
- Readline fails over SSH (behavioral bug)
- JSON parsing fails on large output (implementation bug)
- Config doesn't load from all paths (logic bug)

**When**: Testing reveals incorrect behavior, crashes, or failures.

---

### 4. Modification (Behavioral Change)

**Definition**: Changing how existing functionality works (not broken, just different).

**Examples**:
- Change readline default from enabled to disabled
- Change context limit from 50 to 100 messages
- Change log level from info to debug

**When**: Design decision changes, requirements change, or better approach identified.

---

## Universal Change Workflow

**For ALL four change types, follow this workflow:**

### Step 1: Classify the Change

Determine which type:
- **New Feature**: Adding net new capability
- **Enhancement**: Extending existing feature
- **Bug Fix**: Correcting incorrect behavior
- **Modification**: Changing existing behavior

Also determine severity:
- **Critical**: Security, data loss, crashes, system unusable
- **Major**: Feature broken, significant UX issue, important functionality
- **Minor**: Edge case, cosmetic, non-critical issue

---

### Step 2: Update Specifications

**ALWAYS update specs first. Specs are source of truth.**

#### For New Features:
- Add new section to relevant spec file
- Define requirements clearly
- Specify test requirements
- Reference any ADRs if architectural

#### For Enhancements:
- Find existing spec section
- Add new requirements to that section
- Update test requirements
- Preserve existing requirements

#### For Bug Fixes:
- Find spec section describing broken behavior
- Correct the specification
- Add clarification to prevent misunderstanding
- Update test requirements (regression prevention)

#### For Modifications:
- Find spec section with old behavior
- Update to new behavior
- Add rationale (why changed)
- Update test requirements

**Critical Changes**: Create ADR (Architectural Decision Record) in `specs/architecture/SYSTEM-decisions.md`

---

### Step 3: Update Build Steps

**Steps must reflect current spec state.**

#### For New Features:
- Create new step (with new GUID)
- Write complete implementation instructions
- Define verification criteria
- Add to STEPS_ORDER.txt
- Reference the spec section

#### For Enhancements:
- Find step that implements the feature
- Add new instructions to existing step
- Update verification criteria
- Increment step version in comments (optional)
- Add changelog note at top of step

#### For Bug Fixes:
- Find step that has the bug
- Correct the implementation instructions
- Update verification to catch the bug
- Add test requirements
- Add note at top: "Fixed: [bug description] (2026-01-18)"

#### For Modifications:
- Find step with old behavior
- Update instructions with new behavior
- Update verification criteria
- Add rationale note at top

**Step Update Format**:
```markdown
---
## Changelog

### v1.1 (2026-01-18)
- Fixed: Readline fails over SSH - added SSH detection
- Changed: Default `enable_readline` from true to false
- Added: Test requirement for SSH detection

---
[rest of step]
```

---

### Step 4: Update Tests

**Every change needs test coverage.**

#### Test Requirements by Change Type:

**New Features**:
- Unit tests for new components
- Integration tests for feature interaction
- Minimum 60% coverage (REQUIRED)
- Target 80% coverage (RECOMMENDED)

**Enhancements**:
- Unit tests for new functionality
- Update existing tests if behavior changed
- Integration tests for new interactions

**Bug Fixes**:
- **Regression test** (REQUIRED): Test that specifically catches the bug
- Unit tests for fixed code
- Integration test if bug affects multiple components

**Modifications**:
- Update existing tests to match new behavior
- Add tests for edge cases of new behavior
- Remove tests for old behavior (if incompatible)

**Add test requirements to the step.** Example:

```markdown
### Phase 8: Testing

**Regression Test for SSH Detection**:
```swift
func testSSHDetectionDisablesReadline() {
    // Set SSH environment variable
    setenv("SSH_CONNECTION", "1", 1)

    // Create agent with readline enabled in config
    let config = createConfig(enableReadline: true)
    let agent = AgentLoop(config: config, logger: logger)

    // Verify readline is disabled due to SSH
    XCTAssertTrue(agent.usesPlainInput, "Readline should be disabled for SSH")

    // Cleanup
    unsetenv("SSH_CONNECTION")
}
```
\```
```

---

### Step 5: Update Lessons Learned (If Applicable)

If the change reveals a **pattern** or **best practice** that applies broadly:

Add to `specs/general/SYSTEM-lessons-learned.md`

**Examples of patterns**:
- Terminal compatibility issues (applies to readline, colors, escape codes)
- JSON parsing robustness (applies to all LLM responses)
- Context window management (applies to all agent loops)
- Security sandboxing (applies to all tool execution)

**Not patterns** (don't add to lessons learned):
- Bug specific to one feature
- One-time fix that won't apply elsewhere

---

### Step 6: Verify the Change

**Test the feedback loop:**

1. **Build from scratch** using updated steps
   - Example: If you fixed Step 44, build test8 from Step 0
   - Verify the change is present in new build
   - Verify the bug doesn't reoccur (if bug fix)

2. **Run tests**
   - All existing tests pass
   - New tests pass
   - Coverage meets requirements

3. **Check traceability**
   - Use `framework/tools/check-traceability.sh`
   - Verify ≥80% files have spec references

4. **Verify spec-step alignment**
   - Spec describes what's implemented
   - Step implements what spec describes
   - No drift between them

---

### Step 7: Document and Commit

**Commit changes in logical groups:**

**Commit 1: Spec Changes**
```bash
git add specs/
git commit -m "feat/fix: [Description] - update specs

- Updated specs/technical/SYSTEM-spec.md § X.Y
- [Describe spec changes]
- [Reference ticket if applicable]

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

**Commit 2: Step Changes**
```bash
git add steps/
git commit -m "feat/fix: [Description] - update steps

- Updated steps/SYSTEM-step_GUID.md
- [Describe step changes]
- Implements updated specs

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

**Commit 3: Implementation in Build** (if applicable)
```bash
cd builds/BUILDNAME
# (builds are in .gitignore, so these won't commit to main repo)
# But document in build-history/
```

**Commit 4: Framework/Lessons Learned** (if applicable)
```bash
git add specs/general/SYSTEM-lessons-learned.md
git commit -m "docs: Add [pattern] to lessons learned

- Added § X: [Pattern Name]
- [Describe pattern and when it applies]

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Detailed Workflows by Change Type

### Workflow 1: New Feature

**Scenario**: Add web search tool to system

**Steps**:
1. **Update Spec** → Add § 4.X "Web Search Tool"
   - Define tool purpose
   - Specify parameters
   - Define return format
   - Specify test requirements

2. **Create New Step** → `SYSTEM-step_<new-guid>.md`
   - Implementation instructions
   - Verification criteria
   - Test requirements
   - Add to STEPS_ORDER.txt

3. **Add Tests** → Update step with test requirements
   - Unit test: Tool parameter validation
   - Integration test: Tool execution
   - Coverage: 60% minimum

4. **Optional**: Add to lessons learned if introduces pattern

5. **Verify**: Build from scratch, feature present

6. **Commit**: Spec → Step → Lessons (separate commits)

---

### Workflow 2: Enhancement

**Scenario**: Add cost estimation to existing `/stats` command

**Steps**:
1. **Update Spec** → Modify existing § 6.4 "Context Statistics"
   - Add cost estimation to output format
   - Define calculation algorithm
   - Add test requirements

2. **Update Existing Step** → Modify Step 43
   - Add changelog note at top
   - Add cost calculation instructions
   - Update verification criteria
   - Add test requirements

3. **Add Tests** → Update step Phase 8
   - Unit test: Cost calculation
   - Integration test: Cost display in stats

4. **Optional**: Add pattern to lessons learned

5. **Verify**: Build from scratch, enhancement present

6. **Commit**: Spec → Step → Lessons (separate commits)

---

### Workflow 3: Bug Fix

**Scenario**: Readline fails over SSH

**Steps**:
1. **Update Spec** → Modify § 2.4 "Interactive Input"
   - Correct default value (false, not true)
   - Add SSH detection requirement
   - Update auto-disable conditions

2. **Update Step** → Modify Step 44
   - Add changelog: "Fixed: Readline fails over SSH (2026-01-18)"
   - Correct Phase 2: default = false
   - Add Phase 7: SSH detection code
   - Add Phase 8: SSH detection tests

3. **Add Regression Test** → Update Step 44 Phase 8
   - Test: SSH detection disables readline
   - Test: TERM validation works
   - Test: Fallback to plain input

4. **Add to Lessons Learned** → § 11 "Readline & Terminal Handling"
   - Pattern: Terminal compatibility checks
   - Checklist: SSH detection, TERM validation

5. **Verify**: Build test8 from scratch, bug not present

6. **Commit**: Spec → Step → Lessons (separate commits)

---

### Workflow 4: Modification

**Scenario**: Change context limit from 50 to 100 messages

**Steps**:
1. **Update Spec** → Modify § 2.3 "Configuration Schema"
   - Change `max_messages` default from 50 to 100
   - Add rationale: "Increased for better context retention"

2. **Update Step** → Modify relevant step (e.g., Step 5)
   - Add changelog: "Changed: Context limit 50 → 100 (2026-01-18)"
   - Update default value in instructions
   - Update verification to check new default

3. **Update Tests** → Modify test expectations
   - Change test: Expect 100, not 50
   - Test: Verify new default applied

4. **Optional**: Lessons learned only if reasoning applies broadly

5. **Verify**: Build from scratch, new default present

6. **Commit**: Spec → Step (separate commits)

---

## Critical Rules

### Rule 1: Specs First, Always
- **Never** implement a change without updating specs
- Specs are source of truth
- If implementation exists without spec, it's a bug

### Rule 2: Steps Must Match Specs
- Steps implement what specs describe
- If steps produce code that doesn't match specs, update steps
- Check alignment regularly

### Rule 3: Tests Prevent Regression
- Every bug fix **requires** regression test
- New features **require** test coverage
- Modifications **require** updated tests

### Rule 4: Changes Flow Back
- Changes in builds **must** flow back to specs/steps
- Don't let builds drift from specs
- Next build must not repeat fixed bugs

### Rule 5: Document Patterns
- If bug reveals a pattern → lessons learned
- If enhancement reveals best practice → lessons learned
- One-off fixes → just update spec/step

---

## Common Anti-Patterns

### Anti-Pattern 1: "I'll update specs later"
**Problem**: Specs drift from reality, next build broken

**Solution**: Update specs FIRST, before implementing

---

### Anti-Pattern 2: "Just fix it in the build"
**Problem**: Fix in test7, but test8 has same bug

**Solution**: Update step so test8 doesn't have bug

---

### Anti-Pattern 3: "Tests can wait"
**Problem**: Bug reintroduced later, no warning

**Solution**: Add regression test immediately

---

### Anti-Pattern 4: "This is too small to document"
**Problem**: Pattern repeats, knowledge lost

**Solution**: If it's a pattern, document it

---

### Anti-Pattern 5: "Just make a new step"
**Problem**: Steps accumulate, hard to follow

**Solution**: Update existing step for enhancements/fixes; new step only for new features

---

## Integration with Feature Addition Protocol

This change management workflow **integrates with** the Feature Addition Protocol (framework/methodology/feature-addition-protocol.md):

**Feature Addition Protocol**: Used when **planning** a new feature
**Change Management Workflow**: Used when **implementing** changes post-build

**Flow**:
```
Ticket Request →
  Feature Addition Protocol (scan for duplicates, plan) →
    Change Management Workflow (classify, update specs/steps, test) →
      Implementation →
        Verification →
          Commit
```

---

## Verification Checklist

Before considering a change complete, verify:

- [ ] **Spec updated**: Relevant section modified/added
- [ ] **Step updated**: Implementation instructions correct
- [ ] **Tests added**: Regression/unit/integration tests present
- [ ] **Lessons learned**: Pattern documented (if applicable)
- [ ] **Build verified**: Fresh build from specs/steps includes change
- [ ] **Tests pass**: All tests pass, coverage met
- [ ] **Traceability**: Code references specs (≥80%)
- [ ] **Committed**: Logical commits pushed to repository

---

## Example: Complete Readline Bug Fix

See **Appendix A** for a complete walkthrough of fixing the readline SSH bug using this workflow.

---

## Quick Reference

| Change Type | Update Spec | Update Step | New Step | Tests | Lessons Learned |
|-------------|-------------|-------------|----------|-------|-----------------|
| New Feature | Add new § | - | Create new | Yes | If pattern |
| Enhancement | Update existing § | Update existing | - | Yes | If pattern |
| Bug Fix | Correct existing § | Update existing | - | Regression test | If pattern |
| Modification | Update existing § | Update existing | - | Update tests | If reasoning applies |

---

## Appendix A: Readline Bug Fix Walkthrough

**Initial State**:
- Step 44 says: `enable_readline: true` (default enabled)
- Spec says: Default is `true`
- test7 built with readline enabled
- Testing reveals: Readline fails over SSH (character duplication, broken Ctrl+C)

**Change Type**: Bug Fix (Major severity)

**Step-by-Step**:

### 1. Classify
- Type: Bug Fix
- Severity: Major (UX broken over SSH)
- Pattern: Terminal compatibility (applies to other terminal features)

### 2. Update Spec
**File**: `specs/technical/ybs-spec.md`

**§ 2.3 Configuration Schema** (line 134):
```diff
- "enable_readline": true,
+ "enable_readline": false,  // Disabled by default due to SSH issues
```

**§ 2.4.2 Configuration** (line 219):
```diff
- `enable_readline` (bool, default: `true`): Enable readline functionality
+ `enable_readline` (bool, default: `false`): Enable readline functionality
+   - **Disabled by default** due to SSH compatibility issues
+   - Set to `true` for local terminal use
```

**§ 2.4.2 Configuration** (new section after line 226):
```markdown
**Automatic Disabling**:
Readline is automatically disabled even when `enable_readline: true` if:
- Input is not a TTY (piped input)
- `TERM` environment variable is unset or "dumb"
- SSH session detected (`SSH_CONNECTION`, `SSH_CLIENT`, or `SSH_TTY`)
```

### 3. Update Step
**File**: `steps/ybs-step_6efb3739001f.md`

**Add at top** (after front matter):
```markdown
---
## Changelog

### v1.1 (2026-01-18)
- **Fixed**: Readline fails over SSH due to raw mode issues
- **Changed**: Default `enable_readline` from `true` to `false`
- **Added**: SSH detection to automatically disable readline
- **Added**: Test requirements for SSH detection and fallback

---
```

**Update Phase 2** (line ~65):
```diff
  var enableReadline: Bool = true
+ var enableReadline: Bool = false  // Disabled by default
```

**Update Phase 7** (line ~200 in init section):
```markdown
**Add SSH Detection**:
```swift
// Detect SSH sessions (LineNoise often fails over SSH)
let isSSH = ProcessInfo.processInfo.environment["SSH_CONNECTION"] != nil ||
            ProcessInfo.processInfo.environment["SSH_CLIENT"] != nil ||
            ProcessInfo.processInfo.environment["SSH_TTY"] != nil

if config.ui.enableReadline && isTTY && hasValidTerm && !isSSH {
```
\```
```

**Update Phase 8 - Testing** (add new test):
```markdown
**Regression Test - SSH Detection**:
```swift
func testReadlineDisabledForSSH() {
    // Simulate SSH session
    setenv("SSH_CONNECTION", "192.168.1.1 22 192.168.1.2 55555", 1)

    var config = YBSConfig()
    config.ui.enableReadline = true  // User wants readline

    let agent = AgentLoop(config: config, logger: logger)

    // Should use PlainInputHandler despite enableReadline=true
    XCTAssertTrue(agent.inputHandler is PlainInputHandler)

    unsetenv("SSH_CONNECTION")
}
```
\```
```

### 4. Update Lessons Learned
**File**: `specs/general/ybs-lessons-learned.md`

**Add § 11** (new section):
```markdown
## 11. Readline & Terminal Handling

### 11.1 Terminal Detection
- [ ] **TTY detection alone insufficient**: Check TERM and SSH
- [ ] **Check TERM environment**: Reject "dumb" or empty
- [ ] **Detect SSH sessions**: Check SSH_* environment variables

### 11.8 Known Issues
**Issue**: LineNoise character duplication over SSH
- **Root cause**: Cannot enter raw mode over pseudo-TTY
- **Fix**: Detect SSH sessions, disable readline automatically
```

### 5. Verify
```bash
# Create new build from scratch
mkdir -p SYSTEMNAME/builds/new-build
cd SYSTEMNAME/builds/new-build

# Execute Step 0 (build config)
# Execute Steps 1-N in order

# When step executes:
# - Changes applied correctly ✓
# - Tests pass ✓
# - Tests include SSH detection ✓

# Result: test8 does NOT have readline SSH bug
```

### 6. Commit
```bash
# Commit 1: Spec
git add specs/technical/ybs-spec.md
git commit -m "fix: Update readline spec - disabled by default, SSH detection"

# Commit 2: Step
git add steps/ybs-step_6efb3739001f.md
git commit -m "fix: Update Step 44 - readline SSH fix and tests"

# Commit 3: Lessons learned
git add specs/general/ybs-lessons-learned.md
git commit -m "docs: Add readline terminal handling to lessons learned"

# Push
git push
```

### 7. Result
- ✅ Spec reflects correct behavior
- ✅ Step 44 updated with fix
- ✅ Tests prevent regression
- ✅ Lessons learned documents pattern
- ✅ Next build (test8) won't have bug

**The feedback loop is complete.**

---

## Version History

- **1.0.0** (2026-01-18): Initial version

---

## References

- [Feature Addition Protocol](feature-addition-protocol.md) - Planning new features
- [Writing Steps](writing-steps.md) - How to write build steps
- [Writing Specs](writing-specs.md) - How to write specifications
- [Executing Builds](executing-builds.md) - How to build systems

---

*Specs and steps must reflect reality, not just initial design.*
