# Writing Build Steps

**Version**: 0.3.0
**Last Updated**: 2026-01-18

📍 **You are here**: YBS Framework > Methodology > Writing Build Steps
**↑ Parent**: [Framework](../README.md)
📚 **Related**: [Executing Builds](executing-builds.md) | [Writing Specs](writing-specs.md) | [Glossary](../docs/glossary.md)

---

## Overview

This guide explains how to write effective build steps for the YBS framework. Build steps are the "HOW" that guides AI agents through building a system autonomously.

**Purpose**: Enable AI agents to build systems from specifications without human intervention

**Key Principle**: Provide sufficient detail for autonomous execution, but not so much that it's overwhelming

---

## What is a Build Step?

A build step is a single unit of work with:
- Clear objectives (what to accomplish)
- Detailed instructions (how to do it)
- Verification criteria (how to confirm success)
- Traceability (which specs it implements)

**File Format**: `ybs-step_<12-hex-guid>.md`
**Location**: `systems/SYSTEMNAME/steps/`
**Ordering**: Defined in `STEPS_ORDER.txt`

---

## Step Anatomy

### Required Sections

Every step MUST have:

1. **Title and Version**
   ```markdown
   # Step NNNNNN: Clear Descriptive Title

   **Version**: 0.1.0
   ```

2. **Overview** - What and why (1-2 paragraphs)

3. **Step Objectives** - Numbered list of goals

4. **Prerequisites** - What must exist before starting

5. **Configurable Values** - All `{{CONFIG:...}}` markers

6. **Traceability** - Specs implemented and ADRs referenced

7. **Instructions** - Detailed, actionable steps

8. **Verification** - Explicit success criteria

### Optional Sections

- **What This Step Builds** - For complex steps, detailed explanation
- **Before Starting** - Special setup requirements
- **After Completion** - Next steps or important notes
- **Common Issues** - Known problems and solutions

---

## Writing Effective Objectives

### Good Objectives

✅ **Clear and Measurable**:
- "Create Package.swift with dependencies for swift-argument-parser and AsyncHTTPClient"
- "Implement read_file tool with path sandboxing"
- "Write unit tests for Config loader with 95% coverage"

✅ **Actionable**:
- Each objective is a specific task
- AI agent knows exactly what to build
- Success is verifiable

### Bad Objectives

❌ **Vague**:
- "Set up the project" (too broad)
- "Make it work" (not measurable)
- "Improve performance" (not specific)

❌ **Multiple tasks combined**:
- "Create tools, implement agent loop, and write tests" (should be 3 steps)

---

## Using Configuration Markers

### Syntax

```markdown
{{CONFIG:key_name|type|description|default}}
```

### Available Types

| Type | Example | Usage |
|------|---------|-------|
| `string` | `system_name` | Free text |
| `choice[A,B,C]` | `language` | Single selection |
| `multichoice[A,B]` | `features` | Multiple selections |
| `boolean` | `enable_tests` | True/false |
| `integer` | `max_retries` | Whole number |
| `float` | `timeout` | Decimal number |
| `color` | `primary_color` | Hex color code |
| `url` | `api_endpoint` | URL |
| `email` | `contact` | Email address |
| `path` | `install_dir` | File system path |

### Examples

```markdown
## Configurable Values

This step uses the following configuration values:

- `{{CONFIG:system_name|string|Name of the system|myapp}}` - Used in Package.swift name field
- `{{CONFIG:language|choice[Swift,Python,Go,Rust]|Programming language|Swift}}` - Determines project structure
- `{{CONFIG:enable_tests|boolean|Include test framework|true}}` - Whether to create Tests/ directory
- `{{CONFIG:max_threads|integer|Maximum concurrent threads|4}}` - Used in ThreadPool initialization

**Available types**: string, choice[opts], multichoice[opts], boolean, integer, float, color, url, email, path
```

### When to Use CONFIG

Use `{{CONFIG:...}}` for:
- System names, identifiers
- Technology choices (language, platform, database)
- Feature flags (enable/disable optional features)
- Numeric parameters (ports, timeouts, limits)
- User preferences (colors, layouts, formats)

Don't use CONFIG for:
- Architecture decisions (use specs/ADRs)
- Security settings (hardcode secure defaults)
- Implementation details (let AI agent decide)

### How Step 0 Works with BUILD_CONFIG.json

**Step 0 is smart: it reads from BUILD_CONFIG.json if it exists.**

**When writing Step 0, implement this logic:**

1. **Check if BUILD_CONFIG.json exists** in the build directory
2. **If file exists**:
   - Read all configuration from file
   - Skip all user questions (zero interaction)
   - Validate config contains all required keys
   - Proceed to mark Step 0 complete
3. **If file does NOT exist**:
   - Scan all steps for `{{CONFIG:...}}` markers
   - Ask user for all values (using AskUserQuestion)
   - Save to BUILD_CONFIG.json
   - Proceed to mark Step 0 complete

**This enables:**
- **First build**: Ask questions once, save config
- **Subsequent builds**: Read config, ask NOTHING (zero interaction)
- **Machine-updated builds**: Script updates config → agent reads → new build (fully automated)
- **CI/CD integration**: Config changes committed → automated rebuild
- **Batch generation**: Update config 10 ways → generate 10 builds automatically

**Example Step 0 logic:**
```markdown
## Instructions

1. **Check for existing configuration**
   ```bash
   if [ -f BUILD_CONFIG.json ]; then
     echo "✓ BUILD_CONFIG.json exists - reading configuration"
     # Read and validate config
     # Skip to step 4
   else
     echo "○ BUILD_CONFIG.json not found - collecting configuration"
     # Proceed to step 2
   fi
   ```

2. **Scan all steps for CONFIG markers** (only if config doesn't exist)
3. **Ask user for all values** (only if config doesn't exist)
4. **Validate configuration** (all builds)
5. **Mark Step 0 complete**
```

---

## Writing Clear Instructions

### Structure

Break instructions into numbered sub-steps:

```markdown
## Instructions

### Before Starting

**Record start time**: Note the current timestamp (ISO 8601: YYYY-MM-DD HH:MM UTC)

### 1. Create Project Directory Structure

Create the following directories in `systems/{{CONFIG:system_name}}/builds/build1/`:

```bash
mkdir -p Sources/{{CONFIG:system_name}}
mkdir -p Tests/{{CONFIG:system_name}}Tests
```

**Result**: Directory structure exists for Swift package

### 2. Create Package.swift Manifest

Create `Package.swift` with the following content:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "{{CONFIG:system_name}}",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "{{CONFIG:system_name}}",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
```

**Result**: Package.swift file created and saved

### 3. Verify Package Configuration

Run the following command to verify:

```bash
cd systems/{{CONFIG:system_name}}/builds/build1/
swift package resolve
```

**Expected output**: Package dependencies resolved successfully
```

### Best Practices

1. **One task per sub-step** - Don't combine multiple operations
2. **Include expected results** - Agent knows if it worked
3. **Provide code snippets** - Don't just describe, show the actual code
4. **Use CONFIG markers** - Replace hardcoded values with configuration
5. **Specify file paths** - Always show exact location

---

## Verification Criteria

### Explicit Checks

Every step MUST have verification section:

```markdown
## Verification

**This step is complete when**:
- [ ] Package.swift file exists at expected path
- [ ] Package.swift contains correct dependencies
- [ ] `swift package resolve` completes without errors
- [ ] Sources/ directory structure created
- [ ] Tests/ directory structure created

**Verification Commands**:
```bash
# Check file exists
test -f Package.swift && echo "✓ Package.swift exists" || echo "✗ Package.swift missing"

# Verify package compiles
swift build && echo "✓ Build successful" || echo "✗ Build failed"
```

**Expected Output**:
```
✓ Package.swift exists
Building for debugging...
Build complete!
✓ Build successful
```

**Retry Policy**:
- If verification fails, analyze the error and fix the issue
- Maximum 3 attempts allowed
- After 3 failures, STOP and report to user with full error details
```

### Verification Best Practices

1. **Automate where possible** - Use commands, not manual checks
2. **Test actual functionality** - Not just "file exists"
3. **Include expected output** - Agent knows what success looks like
4. **Be explicit about retry policy** - Always include it

---

## Traceability

### Purpose

Every step must trace back to specifications. This ensures:
- All specs get implemented
- Implementation matches requirements
- Changes to specs trigger review of affected steps

### Format

```markdown
## Traceability

**Implements**: [Which spec sections this step implements]
- systems/SYSTEMNAME/specs/technical-spec.md Section 2.3 (Configuration Loading)
- systems/SYSTEMNAME/specs/technical-spec.md Section 4.1 (Tool Interface)
- systems/SYSTEMNAME/specs/architectural-spec.md Section 1.2 (Package Structure)

**References**: [Which architectural decisions are relevant]
- systems/SYSTEMNAME/specs/decisions.md D04 (Hybrid Tool Architecture)
- systems/SYSTEMNAME/specs/decisions.md D08 (Edit Format)
- systems/SYSTEMNAME/specs/decisions.md D12 (Stateless Design)

**Note**: Every implementation decision in this step traces to one of the above specifications.
```

### When Specs Don't Apply

For pure infrastructure steps (directory creation, dependency installation):

```markdown
## Traceability

**Implements**: Infrastructure step - no direct spec implementation

**References**:
- systems/SYSTEMNAME/specs/technical-spec.md Section 1.0 (Project Setup)
- Provides foundation for spec implementation in subsequent steps
```

### Code-Level Traceability (REQUIRED)

**All source files MUST include traceability comments linking back to specs.**

At the top of each source file, add a comment indicating what it implements:

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
- Optional second line: Brief description of the file's purpose
- Spec reference can be: `ybs-spec.md § X.Y`, `Step N (Title)`, or both

**Examples**:

```swift
// Implements: Step 7 (Error Handling & Logging)
// Defines YBSError enum with all error categories
import Foundation

enum YBSError: Error { ... }
```

```python
# Implements: spec.md § 4.2 (External Tool Discovery)
# Scans configured directories for executable tools

class ToolDiscovery:
    ...
```

```go
// Implements: spec.md § 6.1 (Agent Loop) + Step 14 (Basic Agent Loop)
// Main agent loop with tool calling and context management

package agent

type AgentLoop struct { ... }
```

**Why This Matters**:
- ✅ Makes code review easier (instantly see what each file implements)
- ✅ Detects unspecified features (files without comments)
- ✅ Enables automated traceability checking
- ✅ Documents intent at the code level

**Enforcement**:

Use `framework/tools/check-traceability.sh` to verify all files have comments:

```bash
$ ./framework/tools/check-traceability.sh bootstrap test7

Traceability Check for bootstrap/test7
======================================

Summary:
--------
Status:      ✓ PASS
Total files: 33
Traced:      33
Untraced:    0
Coverage:    100%
```

**Thresholds**:
- ✅ **PASS**: ≥80% files traced
- ⚠️ **WARN**: 60-79% files traced
- ✗ **FAIL**: <60% files traced

**When to Add Comments**:
- BEFORE committing new files
- During code review
- When refactoring existing code

---

## Step Ordering and Dependencies

### STEPS_ORDER.txt Format

```
# Build steps in execution order
# Format: NNNNNN ybs-step_<guid>

# Special: Step 0 MUST be first (Build Configuration)
000000 ybs-step_000000000000

# Regular steps
000001 ybs-step_478a8c4b0cef  # Initialize Build Workspace
000002 ybs-step_c5404152680d  # Define Architecture
000003 ybs-step_89b9e6233da5  # Set Up Project Environment
```

### Choosing Step Numbers

- **000000**: Always Step 0 (Build Configuration)
- **000001-000099**: Foundation (project setup, dependencies)
- **000100-000199**: Core implementation
- **000200-000299**: Features and functionality
- **000300-000399**: Testing and verification
- **000400+**: Documentation and polish

### Prerequisites

Always specify prerequisites explicitly:

```markdown
## Prerequisites

- **Step 0** (ybs-step_000000000000) must be completed
  - BUILD_CONFIG.json must exist
  - All configuration values collected
- **Previous step** (ybs-step_478a8c4b0cef) must be completed
  - Build workspace directory structure created
  - Initial README.md and CLAUDE.md written
- **System requirements**:
  - Swift 5.9+ installed
  - macOS 14+ (for this system)
```

---

## Common Patterns

### Pattern 1: File Creation

```markdown
### Create Main Entry Point

Create `Sources/{{CONFIG:system_name}}/main.swift`:

```swift
import Foundation

print("{{CONFIG:system_name}} - LLM Coding Assistant")
print("Version: 0.1.0")
```

**Why this approach**: Simple entry point that can be extended in future steps
**Verification**: File compiles and runs without errors
```

### Pattern 2: Dependency Installation

```markdown
### Add Dependencies to Package.swift

Add the following to the `dependencies` array in Package.swift:

```swift
.package(url: "https://github.com/swift-server/async-http-client", from: "1.20.0"),
```

**Why**: AsyncHTTPClient provides HTTP client functionality for LLM API calls
**Verification**: `swift package resolve` completes successfully
```

### Pattern 3: Test Writing

```markdown
### Write Unit Tests

Create `Tests/{{CONFIG:system_name}}Tests/ConfigTests.swift`:

```swift
import XCTest
@testable import {{CONFIG:system_name}}

final class ConfigTests: XCTestCase {
    func testConfigLoadsDefaults() {
        let config = Config()
        XCTAssertEqual(config.provider, "ollama")
        XCTAssertEqual(config.model, "qwen2.5-coder:14b")
    }
}
```

**Why**: Ensures Config loader works before other components depend on it
**Verification**: `swift test` passes all tests
```

---

## Versioning Steps

### Initial Version

```markdown
**Version**: 0.1.0
```

### When to Increment

- **0.1.0 → 0.2.0**: Content changes (new instructions, different approach)
- **0.2.0 → 0.2.1**: Typo fixes, clarifications (no functional changes)
- **0.x.x → 1.0.0**: DO NOT increment to 1.0 yet (reserved for future)

### Version History

Add at bottom of step file:

```markdown
## Version History

- **0.2.0** (2026-01-17): Added verification for test directory creation
- **0.1.0** (2026-01-16): Initial step creation
```

---

## Quality Checklist

Before finalizing a step, verify:

- [ ] **Clear title** - Describes what step accomplishes
- [ ] **Objectives listed** - Numbered, measurable goals
- [ ] **Prerequisites stated** - Dependencies explicit
- [ ] **CONFIG markers used** - All configurable values marked
- [ ] **Traceability complete** - Specs and ADRs referenced
- [ ] **Instructions detailed** - AI agent can follow autonomously
- [ ] **Code provided** - Not just descriptions, actual code snippets
- [ ] **Verification explicit** - Commands and expected output
- [ ] **Retry policy included** - 3 attempts, then stop
- [ ] **Version tracked** - 0.1.0 format with history

---

## Example: Complete Step

See the [step template](../templates/step-template.md) for a complete example of a well-formed step file.

**Real examples** (from bootstrap system):
- Step 0: `systems/bootstrap/steps/ybs-step_000000000000.md` - Build Configuration
- Step 1: `systems/bootstrap/steps/ybs-step_478a8c4b0cef.md` - Initialize Build Workspace
- Step 2: `systems/bootstrap/steps/ybs-step_c5404152680d.md` - Define Architecture
- Step 3: `systems/bootstrap/steps/ybs-step_89b9e6233da5.md` - Set Up Project Environment

---

## Testing Your Steps

### Manual Test

Have an AI agent (like Claude) execute your step:
1. Provide the step file
2. Observe if agent can complete it autonomously
3. Check if verification criteria are met
4. Note any ambiguities or missing information

### Peer Review

Have another human read the step:
- Can they understand what to build?
- Are instructions clear and complete?
- Would an AI agent have enough detail?
- Are there any ambiguous terms?

### Validation

After building:
- Does the result match specifications?
- Do verification checks actually work?
- Are there edge cases not covered?
- Could this step be clearer?

---

## Tips for Writing Great Steps

### DO

✅ **Provide actual code** - Don't just describe, show the exact code
✅ **Use CONFIG markers** - Enable different configurations
✅ **Include "why"** - Explain architectural decisions
✅ **Test verification** - Ensure checks actually work
✅ **Be specific** - "Create file X at path Y with content Z"
✅ **Link to specs** - Maintain traceability
✅ **Consider AI agents** - They follow instructions literally

### DON'T

❌ **Assume knowledge** - AI agents don't have context
❌ **Skip verification** - Every step needs explicit checks
❌ **Combine too much** - One step, one focus
❌ **Use vague language** - "Set up the system" is too broad
❌ **Forget CONFIG** - Hardcoded values prevent reuse
❌ **Ignore traceability** - Steps must link to specs
❌ **Write novels** - Be thorough but concise

---

## Common Mistakes

### Mistake 1: Vague Instructions

❌ **Bad**:
```markdown
### Set Up the Project

Create the necessary files and directories for the project.
```

✅ **Good**:
```markdown
### Create Project Directory Structure

Create the following directories:
```bash
mkdir -p Sources/myapp
mkdir -p Tests/myappTests
mkdir -p docs
```

**Result**: Three directories created at specified paths
```

### Mistake 2: Missing CONFIG Markers

❌ **Bad**:
```markdown
name: "myapp"
```

✅ **Good**:
```markdown
name: "{{CONFIG:system_name|string|Name of the system|myapp}}"
```

### Mistake 3: Weak Verification

❌ **Bad**:
```markdown
- [ ] Step completed successfully
```

✅ **Good**:
```markdown
- [ ] Package.swift exists and is valid JSON
- [ ] `swift build` completes without errors
- [ ] Executable runs and prints version
```

### Mistake 4: No Traceability

❌ **Bad**:
```markdown
(No traceability section)
```

✅ **Good**:
```markdown
## Traceability

**Implements**:
- systems/bootstrap/specs/technical/ybs-spec.md Section 3.2 (Package Configuration)

**References**:
- systems/bootstrap/specs/architecture/ybs-decisions.md D01 (Swift as Implementation Language)
```

---

## Maintaining Steps After Initial Build

**Steps are living documents.**

After a system is built and tested, you may discover:
- **Bugs** that need fixing
- **Features** that should be added
- **Enhancements** to improve existing functionality
- **Modifications** to change behavior

**These changes must flow back into steps**, or future builds will repeat the same problems.

### When to Update Steps

**Always update steps when**:
- Bug found in testing → Fix the step that caused the bug
- New feature requested → Create new step or update existing
- Enhancement needed → Update the step that implements the feature
- Behavior changes → Update the step with new behavior

### How to Update Steps

Follow the **Change Management Workflow**:

1. **Update specs first** (specs are source of truth)
2. **Update the step** to match updated specs
3. **Add test requirements** to prevent regression
4. **Add changelog note** at top of step
5. **Verify** by building from scratch with updated step

**See**: [change-management.md](change-management.md) for complete workflow covering all change types (new features, enhancements, bugs, modifications).

### Step Changelog Format

Add changelog at top of step (after front matter):

```markdown
---
## Changelog

### v1.1 (2026-01-18)
- **Fixed**: [Bug description]
- **Changed**: [What behavior changed]
- **Added**: [New functionality or requirements]

### v1.0 (2026-01-17)
- Initial version

---
[rest of step]
```

**Version numbers** (optional but recommended):
- v1.0: Initial version
- v1.1: Minor update (bug fix, enhancement)
- v2.0: Major rewrite (rare)

### Example: Updating Step After Bug Fix

**Bug Found**: "Readline fails over SSH"

**Update Step 44**:
1. Add changelog at top
2. Correct Phase 2: `enableReadline: Bool = false` (was `true`)
3. Add Phase 7: SSH detection code
4. Add Phase 8: SSH detection tests

**Result**: Next build (test8) won't have the bug.

**See**: [change-management.md Appendix A](change-management.md#appendix-a-readline-bug-fix-walkthrough) for complete walkthrough.

### Testing Updated Steps

**After updating a step, verify**:
1. Build new system from scratch using updated steps
2. Verify bug doesn't reoccur (if bug fix)
3. Verify feature is present (if new feature)
4. All tests pass
5. No regression of existing functionality

**Don't assume the update is correct** - always verify with a fresh build.

---

## References

- **Step Template**: [../templates/step-template.md](../templates/step-template.md)
- **Change Management**: [change-management.md](change-management.md) - How to update steps after bugs/changes
- **Executing Builds**: [executing-builds.md](executing-builds.md)
- **Writing Specs**: [writing-specs.md](writing-specs.md)
- **Glossary**: [../docs/glossary.md](../docs/glossary.md)
- **Bootstrap Examples**: [../../systems/bootstrap/steps/](../../systems/bootstrap/steps/)

---

## Version History

- **0.3.0** (2026-01-18): Added "Maintaining Steps After Initial Build" section and change management workflow
- **0.2.1** (2026-01-17): Minor improvements and clarifications
- **0.2.0** (2026-01-17): Added comprehensive examples and common mistakes
- **0.1.0** (2026-01-17): Initial version

