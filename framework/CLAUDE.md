# CLAUDE.md - YBS Framework

**Version**: 0.2.0
**Last Updated**: 2026-01-18

📍 **You are here**: YBS Framework > AI Agent Guide
📚 **See also**: [Framework README](README.md) | [Repository CLAUDE.md](../CLAUDE.md)

---

This file provides guidance to Claude Code when working on the **YBS framework itself**.

## What Are You Doing?

### → Working on Framework Methodology

You're improving how YBS works (not building a specific system):

**Examples**:
- Updating methodology guides (writing-specs.md, writing-steps.md, etc.)
- Creating new templates
- Improving helper tools
- Refining documentation
- Adding new framework patterns

**Working directory**: `framework/`

**Remember**: Changes here affect ALL systems built with YBS.

---

### → NOT Framework Work

If you're doing any of these, you're in the wrong place:

- ❌ **Building a system** → See `systems/SYSTEMNAME/CLAUDE.md`
- ❌ **Executing build steps** → See `systems/SYSTEMNAME/builds/BUILDNAME/CLAUDE.md`
- ❌ **Writing system specs** → See `systems/SYSTEMNAME/specs/`
- ❌ **Creating build steps** → See `systems/SYSTEMNAME/steps/`

**Framework work** = improving the methodology itself, not using it.

---

## Framework Structure

```
framework/
├── README.md                          # Framework overview
├── CLAUDE.md                          # This file - AI agent guide
│
├── methodology/                       # How YBS works
│   ├── overview.md                    # Complete YBS methodology
│   ├── writing-specs.md               # How to write specifications
│   ├── writing-steps.md               # How to write build steps
│   ├── executing-builds.md            # How to execute builds
│   └── feature-addition-protocol.md   # Process for adding features
│
├── templates/                         # Reusable templates
│   ├── spec-template.md
│   ├── step-template.md
│   ├── adr-template.md
│   └── build-config-template.json
│
├── docs/                              # Framework reference docs
│   ├── glossary.md                    # Standard terminology
│   ├── step-format.md                 # Step file format specification
│   └── config-markers.md              # CONFIG marker syntax
│
├── tools/                             # Helper scripts
│   ├── list-specs.sh
│   ├── list-steps.sh
│   ├── deps.sh
│   ├── check-traceability.sh
│   └── README.md
│
└── changelogs/                        # Historical (no longer maintained)
```

---

## Common Tasks

### Task: Update Methodology Documentation

**When**: Improving how-to guides, adding best practices, clarifying processes

**Files**: `framework/methodology/*.md`

**Process**:
1. Read existing methodology file
2. Identify gaps, ambiguities, or improvements
3. Update with clear, actionable guidance
4. Add examples where helpful
5. Update version number (minor increment: 1.0.0 → 1.1.0)
6. Test: Have another AI agent read and verify clarity
7. Commit with descriptive message

**Example**:
```bash
# Updating writing-steps.md to clarify verification criteria
vim framework/methodology/writing-steps.md
# Make changes, update version to 1.1.0
git add framework/methodology/writing-steps.md
git commit -m "Clarify verification criteria in writing-steps.md"
```

---

### Task: Create New Template

**When**: Adding reusable patterns for system builders

**Files**: `framework/templates/*.md`

**Process**:
1. Identify pattern that's repeated across systems
2. Extract common structure
3. Create template with clear placeholders
4. Add usage instructions at top of template
5. Reference template from relevant methodology docs
6. Commit

**Example**:
```bash
# Creating new tool specification template
vim framework/templates/tool-spec-template.md
# Add template content
git add framework/templates/tool-spec-template.md
# Update writing-specs.md to reference new template
git add framework/methodology/writing-specs.md
git commit -m "Add tool specification template"
```

---

### Task: Improve Helper Tools

**When**: Enhancing scripts in `framework/tools/`

**Files**: `framework/tools/*.sh`

**Process**:
1. Read existing tool
2. Identify improvement (bug fix, new feature, better UX)
3. Update script
4. Test tool against real systems (e.g., bootstrap)
5. Update `framework/tools/README.md` if interface changed
6. Commit

**Example**:
```bash
# Adding --verbose flag to list-steps.sh
vim framework/tools/list-steps.sh
# Test it
./framework/tools/list-steps.sh bootstrap --verbose
# Update docs
vim framework/tools/README.md
git add framework/tools/list-steps.sh framework/tools/README.md
git commit -m "Add --verbose flag to list-steps.sh"
```

---

### Task: Update Framework Overview

**When**: Major structural changes, new principles, architecture updates

**Files**: `framework/README.md`, `framework/methodology/overview.md`

**Process**:
1. Identify what changed at high level
2. Update README.md (keep high-level)
3. Update overview.md (detailed explanation)
4. Ensure consistency between docs
5. Update version numbers
6. Commit

**Important**: Avoid redundancy - differentiate purpose of README vs overview.

---

## Important Rules for Framework Work

### 1. Language-Agnostic

**Framework must work for ANY programming language**

When writing methodology:
- ✅ Use abstract terms ("source files", "test files")
- ✅ Provide examples in multiple languages when helpful
- ❌ Don't assume Swift, Python, or any specific language
- ❌ Don't hardcode language-specific paths or tools

**Example**:
```markdown
✅ GOOD: "Create test files for each module"
❌ BAD: "Create *.test.ts files in tests/ directory"
```

### 2. System-Agnostic

**Framework must work for ANY system type**

When writing methodology:
- ✅ Use abstract examples
- ✅ Reference "systems/SYSTEMNAME/" not specific systems
- ❌ Don't hardcode references to bootstrap or specific systems
- ❌ Don't assume CLI tools, web apps, or any specific type

**Example**:
```markdown
✅ GOOD: "Reference specs at systems/SYSTEMNAME/specs/"
❌ BAD: "Reference systems/bootstrap/specs/ybs-spec.md"
```

### 3. Maintain Traceability

**Framework changes should reference issues or needs**

When updating framework:
- Document WHY change was made
- Reference system that exposed the gap
- Add to version history
- Consider if change is backward-compatible

### 4. Test Changes

**Validate framework changes work in practice**

Before committing methodology changes:
- Have another AI agent read updated docs
- Test tools against real systems (bootstrap)
- Verify examples are accurate
- Check all cross-references still work

### 5. Versioning

**All framework docs use semantic versioning**

- Format: major.minor.patch (e.g., 1.0.0, 1.1.0, 1.1.1)
- Minor: Content changes, new sections (1.0.0 → 1.1.0)
- Patch: Typo fixes, formatting only (1.1.0 → 1.1.1)
- Major: Breaking changes to methodology (rare)

**Update version in**:
- The doc being changed
- Version history section at end

---

## Methodology Improvements

### How to Identify Gaps

**Sources of gaps**:
1. AI agent gets stuck following methodology
2. User reports confusion or ambiguity
3. System builder requests clarification
4. New pattern emerges from multiple systems

**Process**:
1. Identify specific ambiguity or gap
2. Research: How did other systems handle this?
3. Synthesize: What's the general pattern?
4. Document: Add to relevant methodology doc
5. Test: Validate with another AI agent

---

### How to Add New Patterns

**When**: Common solution used across multiple systems

**Process**:
1. Extract pattern from specific implementation
2. Generalize (remove system-specific details)
3. Add to relevant methodology doc
4. Create template if reusable
5. Reference from multiple places if cross-cutting

**Example**:
- Pattern observed: "All systems need error handling standards"
- Generalized: Error code ranges, message formats, retry strategies
- Add to: methodology/writing-specs.md § Cross-Cutting Concerns
- Create: templates/error-handling-template.md
- Reference: From writing-steps.md, executing-builds.md

---

## Tool Development

### Tool Philosophy

**Framework tools should**:
- Be simple (one purpose, well)
- Work for any system
- Provide clear output
- Have usage examples
- Support YBS_ROOT environment variable

### Testing Tools

**Always test against real systems**:

```bash
# Test list-steps.sh
./framework/tools/list-steps.sh bootstrap
./framework/tools/list-steps.sh bootstrap --verbose

# Test check-traceability.sh
./framework/tools/check-traceability.sh bootstrap test7

# Verify output is helpful
```

### Tool Documentation

**Update tools/README.md when**:
- Adding new tool
- Changing tool interface (flags, arguments)
- Fixing significant bug
- Adding new feature

---

## Cross-Document Consistency

### Avoiding Redundancy

**Problem**: Same content in multiple docs creates maintenance burden

**Solution**: Single source of truth + references

**Pattern**:
- README.md: High-level overview, links to details
- overview.md: Complete methodology, canonical reference
- executing-builds.md: Execution-specific details, references overview
- writing-steps.md: Step-writing specific, references overview

**When adding content**:
1. Ask: Where is the CANONICAL location?
2. Write complete explanation there
3. Other docs: Brief summary + link to canonical

**Example**:
```markdown
## Configuration System

(Brief 2-3 sentence summary)

For complete details, see [overview.md § Configuration System](methodology/overview.md#configuration-system).
```

---

### Updating Multiple Docs

**When changing something referenced in multiple places**:

1. Update canonical location first
2. Search for all references:
   ```bash
   grep -r "CONFIG marker" framework/
   ```
3. Update references to match
4. Verify consistency

---

## Common Pitfalls

### Pitfall 1: System-Specific Contamination

**Problem**: Framework docs reference specific systems

**Example**:
```markdown
❌ BAD: "See systems/bootstrap/specs/ybs-spec.md for example"
✅ GOOD: "See systems/SYSTEMNAME/specs/ for specifications"
```

**Fix**: Use abstract placeholders (SYSTEMNAME, BUILDNAME)

---

### Pitfall 2: Language Assumptions

**Problem**: Framework assumes one programming language

**Example**:
```markdown
❌ BAD: "Create Package.swift with dependencies"
✅ GOOD: "Create package manifest with dependencies"
```

**Fix**: Use language-agnostic terminology

---

### Pitfall 3: Tool Path Confusion

**Problem**: Helper scripts referenced with wrong path

**Example**:
```markdown
❌ BAD: "Run ../../bin/list-steps.sh"
✅ GOOD: "Run framework/tools/list-steps.sh"
```

**Fix**: Always use `framework/tools/` path

---

### Pitfall 4: Outdated References

**Problem**: Docs reference files or features that changed

**Example**:
```markdown
❌ BAD: "See changelogs/ for history" (no longer maintained)
✅ GOOD: "See git log for change history"
```

**Fix**: Regular audits, remove outdated references

---

## Quality Checklist

Before committing framework changes:

- [ ] Language-agnostic? (No Swift/Python/etc. assumptions)
- [ ] System-agnostic? (No bootstrap/specific system references)
- [ ] Tested? (Tools tested, docs reviewed by another AI)
- [ ] Versioned? (Version number updated)
- [ ] Consistent? (No contradictions with other docs)
- [ ] Referenced? (Other docs point to this if canonical)
- [ ] Examples? (Clear examples provided where helpful)
- [ ] Clear? (Another AI agent could follow this)

---

## Committing Changes

### Commit Message Format

**For methodology changes**:
```
<type>: <short summary>

<detailed explanation of what changed and why>

Affected files:
- framework/methodology/writing-steps.md (v1.0.0 → v1.1.0)
- framework/templates/step-template.md

Why: <reason for change, problem solved>

Tested: <how you verified it works>
```

**Types**:
- `docs:` - Documentation improvements
- `feat:` - New framework feature/pattern
- `fix:` - Bug fix in methodology or tools
- `refactor:` - Restructure without changing meaning
- `tools:` - Helper script improvements

**Example**:
```
docs: Clarify CONFIG marker syntax in writing-steps.md

Added detailed explanation of type system for CONFIG markers,
including all supported types and validation rules.

Affected files:
- framework/methodology/writing-steps.md (v1.0.0 → v1.1.0)
- framework/docs/config-markers.md (created)

Why: Multiple system builders confused about choice[...] syntax

Tested: Reviewed by Claude, validated against bootstrap system
```

---

## Workflow Summary

**Typical framework improvement session**:

1. **Identify issue**:
   - Read user report / AI agent confusion
   - Identify gap in methodology

2. **Research**:
   - Check existing systems for patterns
   - Review current framework docs

3. **Plan**:
   - Determine canonical location for content
   - Identify all docs needing updates

4. **Implement**:
   - Update methodology docs
   - Create/update templates
   - Improve tools if needed
   - Update cross-references

5. **Test**:
   - Have another AI agent review
   - Test tools against real systems
   - Verify examples are accurate

6. **Commit**:
   - Update version numbers
   - Write clear commit message
   - Push to repository

---

## Getting Help

**If stuck on framework work**:

1. Read this CLAUDE.md again
2. Check [Repository CLAUDE.md](../CLAUDE.md) for general guidance
3. Review [Framework README](README.md) for high-level architecture
4. Look at git history for similar changes:
   ```bash
   git log --oneline framework/
   ```

---

## Version History

- **0.2.0** (2026-01-18): Initial framework CLAUDE.md - guidance for AI agents working on framework itself

---

## References

- **Framework Overview**: [README.md](README.md)
- **Complete Methodology**: [methodology/overview.md](methodology/overview.md)
- **Repository Guide**: [../CLAUDE.md](../CLAUDE.md)
- **Tool Documentation**: [tools/README.md](tools/README.md)
