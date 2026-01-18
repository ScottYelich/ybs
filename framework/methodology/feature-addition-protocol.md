# Feature Addition Protocol

**Version**: 0.2.0
**Status**: CRITICAL RULE - MUST FOLLOW
**Last Updated**: 2026-01-18

---

## Purpose

This protocol ensures all new features are properly specified before implementation, preventing duplicate features and maintaining system integrity.

---

## CRITICAL RULE: Spec-First Feature Addition

### When ANY new feature is requested:

**MUST follow this process - NO EXCEPTIONS:**

### 1. **SCAN EXISTING SPECS** (MANDATORY)

Before ANY implementation:

```bash
# Search for existing similar features
grep -ri "feature_keyword" systems/SYSTEMNAME/specs/
grep -ri "feature_keyword" systems/SYSTEMNAME/steps/
```

**Check for**:
- ✅ Exact duplicate (DENY: Feature already exists)
- ✅ Similar feature (ASK: Clarify how this differs)
- ✅ Overlapping functionality (ASK: Should we extend existing?)
- ✅ Conflicting feature (ASK: How to resolve conflict?)

### 2. **UPDATE SPECS FIRST** (MANDATORY)

**NEVER implement before updating specs!**

Add feature to appropriate spec files:
- `systems/SYSTEMNAME/specs/technical/SYSTEM-spec.md` - Technical specification
- `systems/SYSTEMNAME/specs/architecture/SYSTEM-decisions.md` - Architectural decisions (if applicable)
- `systems/SYSTEMNAME/specs/general/SYSTEM-lessons-learned.md` - Implementation checklist (if applicable)

**Required sections in spec**:
```markdown
### Feature Name

**Purpose**: What problem does this solve?

**Specification**:
- API/Interface definition
- Parameters and return values
- Error handling
- Configuration options

**Implementation Requirements**:
- CRITICAL requirements (must-haves)
- Working directory handling (if applicable)
- Security considerations
- Performance requirements

**Test Requirements**:
```swift
// Pseudo-code test showing expected behavior
func testFeatureBehavior() {
    // Given: setup
    // When: action
    // Then: expected result
}
```
```

### 3. **UPDATE OR CREATE STEP** (MANDATORY)

**Check existing steps FIRST**:

```bash
# List all steps
cat systems/SYSTEMNAME/steps/STEPS_ORDER.txt

# Search step content
grep -l "related_feature" systems/SYSTEMNAME/steps/*.md
```

**Decision tree**:
- ✅ **Feature fits in existing step** → UPDATE that step
- ✅ **Feature is standalone** → CREATE new step
- ✅ **Feature extends multiple steps** → UPDATE multiple steps + add integration step

**Step requirements**:
- Clear objectives
- Implementation instructions
- Verification criteria
- Dependencies listed
- References to spec sections

### 4. **IMPLEMENT** (After 1-3 complete)

Only after specs and steps are updated:
- Write code according to spec
- Follow step instructions
- Implement all CRITICAL requirements
- **Write tests BEFORE or DURING implementation** (NOT after)
- **Add traceability comments to ALL source files** (see below)

**CRITICAL: Test Coverage Requirements**:
- **Minimum 60% line coverage** (REQUIRED for step completion)
- **Target 80% line coverage** (RECOMMENDED)
- **100% coverage for critical paths** (security, data loss, etc.)

**Required tests**:
- ✅ Unit tests for each function/method
- ✅ Integration tests for component interactions
- ✅ Error case tests (not just happy path)
- ✅ Edge case tests (empty input, max values, etc.)

**CRITICAL: Traceability Requirements**:

All source files MUST include traceability comments linking to specs:

```swift
// Implements: ybs-spec.md § 3.1 (read_file tool)
// Reads file contents with path validation and sandboxing
import Foundation

class ReadFileTool: ToolProtocol {
    // ...
}
```

**Format**:
- First line: `// Implements: <spec-reference>`
- Spec reference: `ybs-spec.md § X.Y`, `Step N (Title)`, or both
- Optional second line: Brief description of file's purpose

**Why**:
- Makes code review easier (instantly see what each file implements)
- Detects unspecified features (files without traceability comments)
- Enables automated checking with `check-traceability.sh`

**NO STEP IS COMPLETE WITHOUT TESTS AND TRACEABILITY!**

### 5. **VERIFY** (MANDATORY)

- ✅ **Tests written and passing** (REQUIRED - step cannot complete without this)
- ✅ **Test coverage ≥ 60%** (REQUIRED - measure with coverage tools)
- ✅ **Traceability coverage ≥ 80%** (REQUIRED - all files have traceability comments)
- ✅ Spec requirements met
- ✅ Step verification criteria satisfied
- ✅ No duplicate functionality created
- ✅ All error cases handled

**Verification Commands**:
```bash
# Run tests
swift test  # (or equivalent for language)

# Check test coverage (if tooling available)
# Coverage must be ≥ 60% to pass verification

# Check traceability coverage (REQUIRED)
./framework/tools/check-traceability.sh SYSTEMNAME BUILDNAME
# Coverage must be ≥ 80% to pass verification (≥ 60% = warning)
```

**If tests fail, test coverage < 60%, or traceability < 80%**:
- ❌ Step is NOT complete
- ❌ Do NOT proceed to next step
- ❌ Fix tests/add coverage/add traceability comments first

---

## Decision Matrix: Duplicate Feature Handling

| Scenario | Action |
|----------|--------|
| **Exact duplicate** | DENY → "Feature X already exists at [location]" |
| **Similar feature** | ASK → "Feature Y exists. How does your request differ?" |
| **Subset of existing** | SUGGEST → "Feature Z does this. Can we extend it?" |
| **Conflicting feature** | ASK → "Feature conflicts with A. How should we resolve?" |
| **Truly new** | PROCEED → Follow steps 2-5 |

---

## Example: Bad vs Good Process

### ❌ BAD (What NOT to do):

```
User: "Add ability to reload tools during chat"
AI: "Sure! Let me implement that..."
[Writes code directly]
[No spec update]
[No step created]
[Doesn't check if feature exists]
```

**Problems**:
- No specification written
- May duplicate existing feature
- Future builds won't include it
- No test requirements documented

### ✅ GOOD (Correct process):

```
User: "Add ability to reload tools during chat"

AI: "Let me check for existing functionality..."
[Searches specs for "reload", "rescan", "tools", "dynamic"]

AI: "I found tool discovery at startup (Step 24).
     Your request is for RUNTIME rescanning - this is NEW.

     Let me:
     1. Update ybs-spec.md § 5.2 to add runtime rescanning
     2. Document /reload-tools meta-command requirement
     3. Add test requirement for rescanning
     4. Consider: new step vs extending Step 35 (Meta Commands)?
     5. Then implement with test"

[Updates specs]
[Updates steps]
[Implements code]
[Adds test]
[Commits: "spec update → implementation"]
```

---

## Enforcement

### For AI Agents:

**BEFORE implementing ANY feature request**:

1. Say: "Let me check existing specs for similar features..."
2. Search specs and steps
3. Report findings to user
4. If duplicate/similar: ASK for clarification
5. If new: Update specs FIRST, then implement

**DURING implementation**:

6. Add traceability comments to ALL new source files
7. Run `check-traceability.sh` before marking step complete
8. Ensure traceability coverage ≥ 80% (minimum 60%)

**NEVER**:
- Implement without updating specs
- Skip duplicate checking
- Create redundant features
- Add features not documented in specs
- Omit traceability comments from source files
- Skip traceability verification

### For Humans:

When requesting features:
- Check existing features first
- Be specific about how request differs from existing
- Accept "similar feature exists" responses gracefully
- Approve spec updates before implementation

---

## Templates

### Spec Addition Template

```markdown
### [Feature Name]

**Purpose**: [One sentence: what problem does this solve?]

**Specification**:
[API/Interface definition]

**Implementation Requirements**:
- CRITICAL: [Must-have requirement]
- [Other requirements]

**Test Requirements**:
[Test pseudo-code or description]
```

### Step Update Template

```markdown
## Modified: [Date]

### New Feature: [Name]

**Added to this step**: [Brief description]

**Implementation**:
[Code/instructions]

**Verification**:
- [ ] [New verification criterion]
```

---

## Why This Matters

**Without this protocol**:
- ❌ Duplicate features waste effort
- ❌ Features not in specs → lost in future builds
- ❌ Inconsistent implementation
- ❌ No test requirements → bugs slip through
- ❌ Spec drift → specs become obsolete
- ❌ Untraced code → no spec-to-code linkage

**With this protocol**:
- ✅ Specs remain source of truth
- ✅ No duplicate work
- ✅ Features persist across builds
- ✅ Tests documented upfront
- ✅ Clear implementation path
- ✅ Every line traces to spec (enforceable)
- ✅ Unspecified features are immediately detectable

---

## Quick Reference

```
Feature Request
    ↓
[1] SCAN specs/steps for duplicates
    ↓
Duplicate? → DENY/ASK/SUGGEST
    ↓
[2] UPDATE specs (add feature spec)
    ↓
[3] UPDATE/CREATE step (add instructions)
    ↓
[4] IMPLEMENT (write code)
    ↓
[5] VERIFY (tests + criteria)
    ↓
Done ✓
```

---

**Remember**: Specs first, implementation second. Always.

---

**See also**:
- [framework/methodology/writing-specs.md](writing-specs.md)
- [framework/methodology/writing-steps.md](writing-steps.md)
- [framework/docs/glossary.md](../docs/glossary.md)
