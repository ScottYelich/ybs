# Step Planning Process

**Version**: 1.0.0
**Last Updated**: 2026-01-17

## Overview

This document describes the **reusable process** for breaking a technical specification into executable build steps. Use this when planning implementation of any system in YBS.

## The Problem

**LLM Context Collapse**: As code grows, AI agents lose understanding → make mistakes → introduce bugs → system degrades.

**Solution**: Break implementation into small, incremental steps where each step is:
- Small enough for an LLM to fully comprehend (~100-200 lines)
- Independently testable and verifiable
- Has clear dependencies on previous steps
- Produces a working checkpoint

## The Process

### Phase 1: Extract & Analyze

**Input**: Technical specification (e.g., `systems/SYSTEMNAME/specs/technical/ybs-spec.md`)

**Steps**:

1. **Read technical spec** - Understand what needs to be built
   - What is the end goal?
   - What are the major components?
   - What technologies/patterns are used?

2. **List all components** - Extract every feature, tool, system, module
   - Create exhaustive list
   - Include infrastructure (config, errors, logging)
   - Include user-facing features
   - Include internal utilities

3. **Identify dependencies** - What needs what?
   - Component A requires Component B
   - Feature X uses Module Y
   - Draw dependency arrows

4. **Find integration points** - Where do things connect?
   - How do components communicate?
   - What are the interfaces?
   - What data flows between them?

### Phase 2: Layer & Sequence

**Goal**: Organize components into dependency layers

5. **Group into layers** - Foundation → Core → Features → Polish

   **Layer Strategy**:
   - **Foundation**: Base infrastructure everyone depends on (config, errors, models)
   - **Core**: Essential functionality the system can't work without (agent loop, LLM client)
   - **Features**: User-facing capabilities (tools, commands)
   - **Polish**: Quality-of-life improvements (UX, optimization)

6. **Order by dependency** - Within each layer, sequence by dependencies
   - If A depends on B, B comes first
   - Minimize cross-layer dependencies
   - Keep related features together

7. **Check for cycles** - No circular dependencies
   - A → B → C → A is bad
   - Refactor to break cycles
   - Extract interfaces if needed

### Phase 3: Break Into Steps

**Goal**: Convert each component into an executable step

8. **Size each step** - Target constraints:
   - **Time**: 1-2 hours of work
   - **Code**: ~100-200 lines (80-250 acceptable)
   - **Complexity**: Single responsibility, clear scope
   - **Testability**: Can be verified independently

   **Too large?** Split into sub-steps:
   - Step N: Core implementation
   - Step N+1: Extensions/variants
   - Step N+2: Integration with rest of system

   **Too small?** Combine with related step:
   - Avoids excessive overhead
   - But prefer small over large

9. **Make testable** - Each step has clear verification
   - **Unit test**: For logic/algorithms
   - **Integration test**: For components working together
   - **Manual verification**: Run command, observe output
   - **Example**: "Run `ybs --version`, verify it prints correctly"

10. **Ensure independence** - Step N fully works before Step N+1 starts
    - Step output is a working checkpoint
    - Can stop after any step
    - System degrades gracefully (later features missing)
    - No "WIP, doesn't work yet" steps

### Phase 4: Document

**Goal**: Create step documents for execution

11. **Generate step docs** - Use `framework/templates/step-template.md`
    - One file per step: `ybs-step_<guid>.md`
    - Generate GUID: `uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-12`

12. **Link dependencies** - Reference previous steps
    ```markdown
    ## Dependencies

    ### Required Steps (must complete first)
    - `ybs-step_478a8c4b0cef` - Project Skeleton
    - `ybs-step_c5404152680d` - Configuration System

    ### Optional Steps (nice-to-have)
    - None
    ```

13. **Add verification** - How to test this step
    ```markdown
    ## Verification

    ### Build Verification
    ```bash
    swift build
    # Should complete without errors
    ```

    ### Functional Verification
    ```bash
    swift run ybs --version
    # Should print: ybs version 0.1.0
    ```

    ### Test Verification
    ```bash
    swift test
    # All tests pass
    ```
    ```

## Layering Strategy

### Typical Layers

**Layer 1: Foundation** (Always first)
- Configuration loading
- Core data models
- Error handling
- Logging
- CLI argument parsing

**Layer 2: Infrastructure** (Support for core)
- HTTP client
- File I/O utilities
- JSON parsing
- String utilities

**Layer 3: Core Logic** (The heart)
- Main agent loop
- LLM client
- Tool execution framework
- Context management

**Layer 4: Features** (Build on core)
- Individual tools (read_file, write_file, etc.)
- External tool system
- Advanced features

**Layer 5: Safety** (Secure the system)
- Confirmation prompts
- Sandboxing
- Path validation
- Command blocking

**Layer 6: Performance** (Optimize)
- Context compaction
- Token counting
- Repo maps
- Caching

**Layer 7: Polish** (UX)
- Colored output
- Progress indicators
- Error recovery
- Retry logic

## Dependency Rules

### Valid Dependencies

✅ **Forward dependencies**: Step N depends on Step N-X (earlier)
✅ **Same-layer dependencies**: Step N depends on Step N-1 (previous in layer)
✅ **Cross-layer dependencies**: Layer 3 depends on Layer 1 (lower layer)

### Invalid Dependencies

❌ **Backward dependencies**: Step N depends on Step N+X (later)
❌ **Circular dependencies**: A → B → C → A
❌ **Upward dependencies**: Layer 1 depends on Layer 3 (higher layer)

## Step Numbering

**Format**: `ybs-step_<12-hex-guid>.md`

**Not sequential** - Use GUIDs, not step_001, step_002
- Allows inserting steps later
- Avoids renumbering
- Globally unique

**Execution order** - Use `## Prerequisites` section to define dependencies

## Example: Breaking Down "LLM Client"

**Component**: LLM Client (communicate with AI)

**Analysis**:
- Needs HTTP client (dependency)
- Needs data models (Message, ToolCall)
- Needs streaming support
- Needs error handling

**Breakdown**:
- **Step A**: HTTP Client with streaming
- **Step B**: LLM request/response types
- **Step C**: LLM Client (send/receive)
- **Step D**: Tool call parsing

**Why split?**
- Step A: General HTTP (reusable)
- Step B: Data models (testable independently)
- Step C: Core functionality
- Step D: Advanced feature

**Size check**:
- Step A: ~150 lines ✓
- Step B: ~80 lines ✓
- Step C: ~120 lines ✓
- Step D: ~100 lines ✓

**Verification**:
- Step A: Make test HTTP request
- Step B: Encode/decode types
- Step C: Chat with LLM
- Step D: Parse tool call from response

## When to Stop Planning

**Don't over-plan!**

Write steps in batches:
- Write 3-5 steps
- Execute them
- Verify they work
- Learn from execution
- Write next 3-5 steps

**Why?**
- Specs become stale if you plan too far ahead
- Execution teaches you what works
- Requirements change during implementation
- Rigid plans don't adapt

## Anti-Patterns

**❌ Waterfall Steps**
- Step 1: Design everything
- Step 2: Implement everything
- Step 3: Test everything

**Why bad?** No incremental progress, no checkpoints, all-or-nothing

**✅ Incremental Steps**
- Step 1: Config loading + verify
- Step 2: Data models + verify
- Step 3: CLI parsing + verify

**Why good?** Working system after each step

---

**❌ God Steps**
- Step 1: Implement entire agent loop with tools, error handling, context management, and UI (1000 lines)

**Why bad?** Too complex, LLM gets confused, hard to debug

**✅ Focused Steps**
- Step 10: Agent loop (basic, no tools)
- Step 11: Add tool calling
- Step 12: Add context management

**Why good?** Each step is comprehensible and testable

---

**❌ Circular Dependencies**
- Step A needs Step B
- Step B needs Step C
- Step C needs Step A

**Why bad?** Can't start anywhere, deadlock

**✅ Acyclic Dependencies**
- Step A (no dependencies)
- Step B (depends on A)
- Step C (depends on B)

**Why good?** Clear execution order

## Tools & Helpers

### Generate GUID
```bash
uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-12
```

### List all steps
```bash
ls systems/SYSTEMNAME/steps/ybs-step_*.md | sort
```

### Check dependencies
```bash
framework/tools/deps.sh <guid>
```

### Visualize dependency graph
```bash
framework/tools/graph-deps.sh > deps.dot
dot -Tpng deps.dot > deps.png
```

## Summary Checklist

Before writing steps, verify:

- [ ] Listed all components from spec
- [ ] Identified all dependencies
- [ ] Organized into layers (foundation → polish)
- [ ] Each step is 100-200 lines
- [ ] Each step has verification
- [ ] No circular dependencies
- [ ] Foundation layer comes first
- [ ] Steps build on each other
- [ ] Can stop after any step (checkpoint)

---

## References

- **Template**: `framework/templates/step-template.md`
- **Example**: `systems/bootstrap/steps/` (Steps 0-3 completed)
- **Methodology**: `framework/methodology/writing-steps.md`

**Next**: See system-specific step plans (e.g., `systems/bootstrap/STEP_PLAN.md`)
