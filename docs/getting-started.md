# Getting Started with YBS

**Version**: 2.0.0
**Last Updated**: 2026-01-18

---

## What is YBS?

YBS (Yelich Build System) is a framework for building software systems using AI-driven specification-based development.

**Core concepts**:
- **Specifications first**: Define what to build before how to build
- **Step-by-step builds**: Break complex systems into manageable steps
- **AI agent execution**: Autonomous AI agents execute build steps
- **Configuration-first**: All decisions made upfront (Step 0)
- **Traceability**: Every line of code traces back to specifications

---

## Learn YBS (Examples)

**Recommended learning path**:

### 1. Read Methodology
Start with the framework documentation:
- [Framework Overview](../framework/README.md)
- [YBS Methodology](../framework/methodology/overview.md)

### 2. Study Examples
Progress through examples by complexity:

**Level 1: Hello World** ([examples/01-hello-world/](../examples/01-hello-world/))
- Time: 20 minutes
- Complexity: Trivial (5 steps)
- Learn: Basic YBS workflow

**Level 2: Calculator** ([examples/02-calculator/](../examples/02-calculator/))
- Time: 1 hour
- Complexity: Simple (10 steps)
- Learn: Multiple modules, testing, traceability

**Level 3: REST API** ([examples/03-rest-api/](../examples/03-rest-api/))
- Time: 2-3 hours
- Complexity: Moderate (20 steps)
- Learn: Multi-tier systems, persistence, API design

### 3. Build Your Own
Create your first system:
- See [Create Your First System](#create-your-first-system) below
- Follow [external-systems.md](external-systems.md) for detailed guide

---

## Create Your First System

Once comfortable with examples, create your own system.

### Option A: Study Examples First (Recommended)

```bash
# Navigate to examples
cd ybs/examples/02-calculator

# Study structure
ls -la
cat README.md
cat specs/calculator-spec.md
cat steps/calc-step_000000000000.md

# Understand YBS workflow before creating your own
```

### Option B: Create External System Immediately

See: [external-systems.md](external-systems.md) for complete guide.

**Quick start**:

```bash
# 1. Clone YBS framework (if not already done)
git clone https://github.com/USER/ybs.git ~/tools/ybs
export PATH="$PATH:$HOME/tools/ybs/framework/tools"

# 2. Create your system directory
mkdir ~/my-awesome-project
cd ~/my-awesome-project

# 3. Initialize YBS structure
mkdir -p specs/contracts steps builds docs .ybs

# 4. Add YBS configuration
cat > .ybs/config.json << 'EOF'
{
  "ybs_version": "2.0.0",
  "framework_repo": "https://github.com/USER/ybs.git",
  "system_name": "my-awesome-project",
  "created": "2026-01-18"
}
EOF

# 5. Create .gitignore
cat > .gitignore << 'EOF'
builds/*/
.DS_Store
SESSION.md
scratch/
EOF

# 6. Initialize git
git init
git add .ybs/ .gitignore
git commit -m "Initial commit: YBS system structure"

# 7. Create specification
cp ~/tools/ybs/framework/templates/spec-template.md specs/my-system-spec.md
# Edit spec with your requirements

# 8. Create Step 0 (build configuration)
cp ~/tools/ybs/framework/templates/step-template.md steps/my-step_000000000000.md
# Edit: Set up build config questions

# 9. Create additional steps
# ... follow methodology for creating build steps

# 10. Execute build
mkdir -p builds/build1
cd builds/build1
# Execute steps sequentially
```

---

## YBS Workflow

### High-Level Process

```
1. Write Specifications (specs/)
   ↓
2. Create Build Steps (steps/)
   ↓
3. Execute Step 0 (BUILD_CONFIG.json)
   ↓
4. Execute Steps 1..N (autonomous)
   ↓
5. Verify (tests pass, traceability ≥80%)
   ↓
6. Deploy (system complete)
```

### Detailed Workflow

**Phase 1: Specification**
1. Create system specification in `specs/`
2. Define requirements, success criteria
3. Optional: Create contracts for interfaces

See: [framework/methodology/writing-specs.md](../framework/methodology/writing-specs.md)

**Phase 2: Step Creation**
1. Break system into build steps
2. Start with Step 0 (build configuration)
3. Create steps for each major component
4. Each step: Context + Instructions + Verification

See: [framework/methodology/writing-steps.md](../framework/methodology/writing-steps.md)

**Phase 3: Execution**
1. Create build directory: `builds/build1/`
2. AI agent reads Step 0, generates BUILD_CONFIG.json
3. AI agent executes steps 1..N autonomously
4. Each step verified before proceeding
5. If failure: Retry up to 3 times, then stop

See: [framework/methodology/executing-builds.md](../framework/methodology/executing-builds.md)

**Phase 4: Verification**
1. All tests pass
2. Code coverage ≥60% (required), ≥80% (recommended)
3. Traceability ≥80% (all source files have `// Implements:` comments)
4. No blocking issues

---

## Using YBS Tools

YBS provides helper tools in `framework/tools/`:

### List Specifications
```bash
# From framework repo
./framework/tools/list-specs.sh examples/calculator

# From your system repo
cd ~/my-system
list-specs.sh .
```

### List Steps
```bash
# From framework repo
./framework/tools/list-steps.sh examples/calculator

# From your system repo
cd ~/my-system
list-steps.sh .
```

### Check Traceability
```bash
# Verify source files have traceability comments
cd ~/my-system
check-traceability.sh . build1

# Required thresholds:
# ✅ PASS: ≥80% files traced
# ⚠️ WARN: 60-79% files traced
# ✗ FAIL: <60% files traced
```

### Check Dependencies
```bash
# Show step dependencies
cd ~/my-system
deps.sh .
```

---

## Common Patterns

### Pattern 1: Single System

```
my-system/
├── .ybs/config.json
├── specs/
│   └── my-system-spec.md
├── steps/
│   ├── my-step_000000000000.md
│   └── ...
└── builds/
    └── build1/
```

### Pattern 2: Modular System with Contracts

**Contracts repository** (specifications only):
```
my-contracts/
├── .ybs/config.json
└── specs/contracts/
    ├── message-bus-v1.md
    └── payment-api-v1.md
```

**Module repositories** (implementations):
```
payment-module/
├── .ybs/config.json
├── specs/contracts/           # Copied from my-contracts
│   └── payment-api-v1.md
├── steps/
└── builds/

auth-module/
├── .ybs/config.json
├── specs/contracts/           # Copied from my-contracts
│   └── message-bus-v1.md
├── steps/
└── builds/
```

**Contract propagation**:
```bash
# Update contract in implementation
cd payment-module
vim specs/contracts/payment-api-v1.md

# Propagate back to contracts repo
cp specs/contracts/payment-api-v1.md ../my-contracts/specs/contracts/

# Update other modules
cd ../other-module
cp ../my-contracts/specs/contracts/payment-api-v1.md specs/contracts/
```

See: [Practical Modular Approach](../scratch/ybs-practical-modular-approach.md)

---

## Key Concepts

### 1. Configuration-First (Step 0)

**Step 0 collects ALL questions upfront**:
- Generates BUILD_CONFIG.json with all decisions
- Subsequent steps read from config (no prompts)
- Enables fully autonomous execution

**Example Step 0 questions**:
```markdown
## Questions

### Q1: System Name
**Prompt**: What is the system name?
**Type**: text
**Default**: my-system
**CONFIG**: system_name

### Q2: Programming Language
**Prompt**: Which programming language?
**Type**: choice[python,javascript,swift]
**Default**: python
**CONFIG**: language
```

### 2. Autonomous Execution

**After Step 0, no user interaction needed**:
- AI agent reads BUILD_CONFIG.json
- Executes steps 1..N automatically
- Only stops for critical errors or 3x verification failures

### 3. Traceability

**Every source file links back to specifications**:

```python
# Implements: my-system-spec.md § 3.2 User Authentication
# - Verify username/password against database
# - Return JWT token on success
def authenticate_user(username, password):
    # ...
```

Verified with: `check-traceability.sh . build1`

### 4. Verification-Driven

**Every step has explicit verification criteria**:
- Tests must pass
- Code builds successfully
- Traceability comments present
- Retry limit (3 attempts) prevents infinite loops

---

## Next Steps

### For Learners
1. ✅ Read [Framework Overview](../framework/README.md)
2. ✅ Study [01-hello-world](../examples/01-hello-world/)
3. ✅ Build [02-calculator](../examples/02-calculator/)
4. ✅ Build [03-rest-api](../examples/03-rest-api/)

### For System Builders
1. ✅ Read [Writing Specs](../framework/methodology/writing-specs.md)
2. ✅ Read [Writing Steps](../framework/methodology/writing-steps.md)
3. ✅ Create your first system (follow Option B above)
4. ✅ Study [external-systems.md](external-systems.md) for advanced patterns

### For Framework Contributors
1. ✅ Read [Framework CLAUDE.md](../framework/CLAUDE.md)
2. ✅ Understand [Glossary](../framework/docs/glossary.md)
3. ✅ Improve methodology, templates, tools
4. ✅ Test with diverse system types

---

## Troubleshooting

### Issue: AI Agent Gets Stuck

**Symptom**: Agent repeatedly fails verification or makes no progress

**Solutions**:
1. Check step instructions are clear and unambiguous
2. Verify BUILD_CONFIG.json has all required values
3. Check verification criteria are achievable
4. Review SESSION.md for error patterns
5. Manually fix blocking issue, update step if needed

### Issue: Traceability Check Fails

**Symptom**: `check-traceability.sh` reports <80% traced

**Solutions**:
1. Add `// Implements:` comments to source files
2. Link to specific spec sections: `my-spec.md § 3.2 Feature Name`
3. Run check again: `check-traceability.sh . build1`
4. Aim for ≥80% (required for step completion)

### Issue: Tests Failing

**Symptom**: Step verification fails due to test failures

**Solutions**:
1. Review test output in build logs
2. Fix implementation to satisfy tests
3. Update tests if requirements changed
4. Ensure BUILD_CONFIG.json has correct test settings
5. Retry step (up to 3 attempts)

### Issue: Version Mismatch

**Symptom**: Tools don't work or steps fail unexpectedly

**Solutions**:
1. Check `.ybs/config.json` for YBS version
2. Ensure YBS framework is up to date:
   ```bash
   cd ~/tools/ybs
   git pull
   git checkout v2.0.0
   ```
3. Update system's YBS version reference if needed

---

## References

- **Framework Overview**: [../framework/README.md](../framework/README.md)
- **Methodology**: [../framework/methodology/overview.md](../framework/methodology/overview.md)
- **Examples**: [../examples/README.md](../examples/README.md)
- **External Systems**: [external-systems.md](external-systems.md)
- **Glossary**: [../framework/docs/glossary.md](../framework/docs/glossary.md)
- **Repository Guide**: [../CLAUDE.md](../CLAUDE.md)

---

## Version History

- **2.0.0** (2026-01-18): Initial getting-started guide for standalone framework structure
