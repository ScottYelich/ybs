# Creating External Systems

**Version**: 2.0.0
**Last Updated**: 2026-01-18

**Recommended approach**: Keep your systems in separate repositories from the YBS framework.

---

## Why External Systems?

**Benefits of separate repositories**:
- ✅ **Independent versioning**: YBS v1.2.3, your-system v0.5.0
- ✅ **Separate git history**: Framework changes don't mix with system changes
- ✅ **Team ownership**: Different repos, different access controls
- ✅ **Clean separation**: Framework development vs. system development
- ✅ **Scalability**: N systems don't bloat framework repo

**Industry standard**: Same pattern as Rails, Django, Next.js, etc.

See: [Repository Architecture Decision](../scratch/ybs-repository-architecture-recommendation.md)

---

## Quick Start

### 1. Install YBS Framework

**Option A: Clone and add to PATH**
```bash
git clone https://github.com/USER/ybs.git ~/tools/ybs
echo 'export PATH="$PATH:$HOME/tools/ybs/framework/tools"' >> ~/.bashrc
source ~/.bashrc
```

**Option B: Install script** (future)
```bash
curl -sSL https://ybs.dev/install.sh | bash
```

**Verify installation**:
```bash
list-specs.sh --version
# Should show YBS v2.0.0
```

### 2. Create System Repository

```bash
mkdir ~/my-system
cd ~/my-system
git init
```

### 3. Initialize YBS Structure

```bash
# Create directories
mkdir -p specs/contracts steps builds docs .ybs

# Add YBS configuration
cat > .ybs/config.json << 'EOF'
{
  "ybs_version": "2.0.0",
  "framework_repo": "https://github.com/USER/ybs.git",
  "system_name": "my-system",
  "created": "2026-01-18"
}
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
builds/*/
.DS_Store
SESSION.md
scratch/
EOF

# Initial commit
git add .ybs/ .gitignore
git commit -m "Initial commit: YBS system structure"
```

### 4. Create Specifications

```bash
# Copy template
cp ~/tools/ybs/framework/templates/spec-template.md specs/my-system-spec.md

# Edit spec with your requirements
vim specs/my-system-spec.md

# Commit
git add specs/
git commit -m "Add system specification"
```

### 5. Create Build Steps

```bash
# Step 0: Build configuration
cp ~/tools/ybs/framework/templates/step-template.md steps/my-step_000000000000.md
# Edit: Set up build config questions

# Additional steps
# ... create more steps following methodology

git add steps/
git commit -m "Add build steps"
```

### 6. Execute Build

```bash
mkdir -p builds/build1
cd builds/build1

# Read Step 0
cat ../../steps/my-step_000000000000.md

# Execute steps sequentially
# ... (AI agent or manual execution)
```

---

## System Repository Structure

### Minimal Structure

```
my-system/
├── .ybs/
│   └── config.json                    # YBS configuration
├── .gitignore                         # Git ignore patterns
├── README.md                          # System overview
├── specs/                             # Specifications
│   └── my-system-spec.md
├── steps/                             # Build steps
│   ├── my-step_000000000000.md        # Step 0 (config)
│   └── my-step_478a8c4b0cef.md        # Step 1...
├── builds/                            # Build outputs (gitignored)
│   └── build1/
└── docs/                              # Additional documentation
```

### Full Structure (with contracts)

```
my-system/
├── .ybs/
│   └── config.json
├── .gitignore
├── README.md
├── specs/
│   ├── my-system-spec.md
│   ├── architecture/
│   │   └── decisions.md               # Architectural decisions
│   ├── contracts/                     # Interface contracts
│   │   ├── api-v1.md
│   │   └── message-bus-v1.md
│   └── testing/
│       └── test-requirements.md
├── steps/
│   ├── my-step_000000000000.md
│   ├── my-step_478a8c4b0cef.md
│   └── ...
├── builds/
│   ├── build1/
│   └── build2/
└── docs/
    ├── architecture.md
    ├── security.md
    └── usage.md
```

---

## Using YBS Tools

### From Your System Repository

All YBS tools work from your system repo:

```bash
cd ~/my-system

# List specifications
list-specs.sh .

# List steps
list-steps.sh .

# Check traceability
check-traceability.sh . build1

# Check dependencies
deps.sh .
```

### Tool Detection

**Smart path detection**:
- If `.ybs/config.json` exists → use current directory
- Else → assume framework repo (use examples/)

**This means**:
```bash
# From system repo (auto-detects)
cd ~/my-system
list-specs.sh .

# From framework repo (specify example)
cd ~/tools/ybs
list-specs.sh examples/calculator
```

---

## Version Management

### Tracking YBS Version

**In `.ybs/config.json`**:
```json
{
  "ybs_version": "2.0.0",
  "framework_repo": "https://github.com/USER/ybs.git",
  "system_name": "my-system",
  "created": "2026-01-18",
  "last_ybs_update": "2026-01-18"
}
```

### Upgrading YBS

```bash
# 1. Update YBS framework
cd ~/tools/ybs
git pull
git checkout v2.1.0

# 2. Test tools still work
list-specs.sh --version

# 3. Update your system's reference
cd ~/my-system
vim .ybs/config.json
# Change: "ybs_version": "2.1.0"
# Change: "last_ybs_update": "2026-01-XX"

git add .ybs/config.json
git commit -m "Upgrade to YBS v2.1.0"

# 4. Test your system still builds
cd builds/build1
# Re-run verification...
```

### Version Pinning

**Pin to specific version for stability**:

```json
{
  "ybs_version": "2.0.0",
  "framework_repo": "https://github.com/USER/ybs.git",
  "framework_commit": "a8f64c2",
  "notes": "Pinned to v2.0.0 for stability during production release"
}
```

```bash
# Use specific commit
cd ~/tools/ybs
git checkout a8f64c2
```

---

## Multiple Systems Pattern

### Pattern 1: Independent Systems

**Each system is completely independent**:

```
~/projects/
├── payment-system/                    # Independent
│   ├── .ybs/config.json
│   ├── specs/
│   └── steps/
│
├── auth-system/                       # Independent
│   ├── .ybs/config.json
│   ├── specs/
│   └── steps/
│
└── reporting-system/                  # Independent
    ├── .ybs/config.json
    ├── specs/
    └── steps/
```

**When to use**:
- Systems are unrelated
- Different teams own each system
- No shared contracts or interfaces

---

### Pattern 2: Modular System with Contracts

**One contracts repo + N module repos**:

```
~/projects/
├── my-contracts/                      # Contract specifications
│   ├── .ybs/config.json
│   └── specs/contracts/
│       ├── message-bus-v1.md
│       ├── payment-api-v1.md
│       └── auth-api-v1.md
│
├── payment-module/                    # Implements payment-api
│   ├── .ybs/config.json
│   ├── specs/contracts/               # Copy from my-contracts
│   │   └── payment-api-v1.md
│   ├── steps/
│   └── builds/
│
├── auth-module/                       # Implements auth-api
│   ├── .ybs/config.json
│   ├── specs/contracts/               # Copy from my-contracts
│   │   └── auth-api-v1.md
│   ├── steps/
│   └── builds/
│
└── message-bus-module/                # Implements message-bus
    ├── .ybs/config.json
    ├── specs/contracts/               # Copy from my-contracts
    │   └── message-bus-v1.md
    ├── steps/
    └── builds/
```

**When to use**:
- Modular system with defined interfaces
- Multiple teams implementing different modules
- Need contract versioning and evolution
- Want to enforce interface compliance

See: [Practical Modular Approach](../scratch/ybs-practical-modular-approach.md)

---

## Contract Propagation Workflow

### Scenario: Update Contract in Implementation

**Step 1: Change starts in module**
```bash
cd ~/projects/payment-module

# Update contract locally
vim specs/contracts/payment-api-v1.md
# Make changes to contract

# Implement changes in module
# ... execute YBS build steps

# Verify implementation
swift test
check-traceability.sh . build1
```

**Step 2: Propagate to contracts repo**
```bash
# Copy updated contract to contracts repo
cp specs/contracts/payment-api-v1.md ../my-contracts/specs/contracts/

cd ../my-contracts
git add specs/contracts/payment-api-v1.md
git commit -m "Update payment-api-v1 contract (from payment-module implementation)"
git tag v1.1.0
```

**Step 3: Update other modules**
```bash
# Any other module using this contract
cd ../other-module

# Copy latest contract
cp ../my-contracts/specs/contracts/payment-api-v1.md specs/contracts/

git add specs/contracts/payment-api-v1.md
git commit -m "Update to payment-api-v1 (latest contract)"

# Update implementation to match new contract
# ... execute YBS build steps
```

### Scenario: Update Contract Centrally

**Step 1: Change starts in contracts repo**
```bash
cd ~/projects/my-contracts

# Update contract centrally
vim specs/contracts/payment-api-v1.md
# Make changes

git add specs/contracts/payment-api-v1.md
git commit -m "Update payment-api-v1: Add refund endpoint"
git tag v1.2.0
```

**Step 2: Propagate to modules**
```bash
# Payment module (owner of this contract)
cd ../payment-module
cp ../my-contracts/specs/contracts/payment-api-v1.md specs/contracts/
git add specs/contracts/
git commit -m "Update to payment-api-v1 v1.2.0 (add refund endpoint)"

# Implement new endpoint
# ... execute YBS build steps

# Other modules using this contract
cd ../consumer-module
cp ../my-contracts/specs/contracts/payment-api-v1.md specs/contracts/
git add specs/contracts/
git commit -m "Update to payment-api-v1 v1.2.0"
# Update usage as needed
```

---

## Advanced Patterns

### Pattern: Shared Libraries

**If modules share common code**:

```
~/projects/
├── my-contracts/                      # Contracts
├── my-shared-lib/                     # Shared library (NOT YBS)
│   ├── src/
│   ├── tests/
│   └── package.json
├── payment-module/                    # Uses my-shared-lib
│   ├── .ybs/config.json
│   ├── specs/
│   ├── BUILD_CONFIG.json              # References my-shared-lib version
│   └── ...
└── auth-module/                       # Uses my-shared-lib
    ├── .ybs/config.json
    └── BUILD_CONFIG.json              # References my-shared-lib version
```

**Note**: Shared library is NOT a YBS system - it's a dependency.

---

### Pattern: Monorepo (Multiple Systems)

**If you prefer monorepo**:

```
my-company-systems/                    # Monorepo
├── .ybs/
│   └── workspace.json                 # Multi-system config
├── contracts/
│   ├── .ybs/config.json
│   └── specs/contracts/
├── payment-module/
│   ├── .ybs/config.json
│   ├── specs/
│   └── steps/
├── auth-module/
│   ├── .ybs/config.json
│   ├── specs/
│   └── steps/
└── scripts/
    ├── build-all.sh
    └── test-all.sh
```

**When to use**:
- Small number of systems (< 5)
- Same team maintains all systems
- Want atomic commits across systems
- Shared CI/CD pipeline

**Trade-offs**:
- ❌ Can't version systems independently
- ❌ Git history mixed together
- ❌ Slower git operations as repo grows
- ✅ Easier cross-system refactoring

---

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/ybs-build.yml
name: YBS Build

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout system repo
        uses: actions/checkout@v3

      - name: Clone YBS framework
        run: |
          git clone https://github.com/USER/ybs.git ~/ybs
          echo "$HOME/ybs/framework/tools" >> $GITHUB_PATH

      - name: Verify YBS version
        run: |
          YBS_VERSION=$(jq -r '.ybs_version' .ybs/config.json)
          cd ~/ybs && git checkout "v$YBS_VERSION"

      - name: Check specs
        run: list-specs.sh .

      - name: Check steps
        run: list-steps.sh .

      - name: Execute build
        run: |
          mkdir -p builds/ci-build
          cd builds/ci-build
          # Execute YBS steps (AI agent or script)

      - name: Run tests
        run: |
          cd builds/ci-build
          # Run test suite

      - name: Check traceability
        run: check-traceability.sh . ci-build
```

---

## Troubleshooting

### Issue: Tools Not Found

**Symptom**: `list-specs.sh: command not found`

**Solutions**:
```bash
# Check PATH
echo $PATH

# Add YBS tools to PATH
export PATH="$PATH:$HOME/tools/ybs/framework/tools"

# Make permanent
echo 'export PATH="$PATH:$HOME/tools/ybs/framework/tools"' >> ~/.bashrc
source ~/.bashrc
```

### Issue: Tool Can't Find Config

**Symptom**: `Error: Not in YBS framework or system repo`

**Solutions**:
```bash
# Verify .ybs/config.json exists
ls -la .ybs/

# Create if missing
mkdir -p .ybs
cat > .ybs/config.json << 'EOF'
{
  "ybs_version": "2.0.0",
  "framework_repo": "https://github.com/USER/ybs.git",
  "system_name": "my-system"
}
EOF
```

### Issue: Version Mismatch

**Symptom**: Tools behave unexpectedly or steps fail

**Solutions**:
```bash
# Check system's YBS version
cat .ybs/config.json | jq '.ybs_version'

# Check installed YBS version
cd ~/tools/ybs
git describe --tags

# Sync versions
git checkout v2.0.0  # Match system's version
```

---

## Best Practices

### 1. Keep System Repos Focused

**DO**:
- ✅ One system per repository
- ✅ Clear system purpose and scope
- ✅ Self-contained (all specs, steps, docs)

**DON'T**:
- ❌ Mix multiple unrelated systems in one repo
- ❌ Scatter specs/steps across multiple repos
- ❌ Depend on external specs not in repo

### 2. Version Your Contracts

**DO**:
```
specs/contracts/
├── payment-api-v1.md                  # Current version
├── payment-api-v2.md                  # Next version (breaking changes)
└── archive/
    └── payment-api-v0.md              # Deprecated
```

**Track in git tags**:
```bash
git tag v1.0.0  # Initial payment-api-v1
git tag v1.1.0  # Added refund endpoint
git tag v2.0.0  # Breaking changes (v2)
```

### 3. Document Dependencies

**In BUILD_CONFIG.json**:
```json
{
  "system_name": "payment-module",
  "dependencies": {
    "my-shared-lib": "1.2.3",
    "database": "postgresql-14",
    "contracts": {
      "payment-api": "v1.1.0",
      "message-bus": "v1.0.0"
    }
  }
}
```

### 4. Test Contract Compliance

**Create contract compliance tests**:
```python
# tests/test_contract_compliance.py
def test_payment_api_v1_compliance():
    """Verify implementation matches payment-api-v1 contract."""
    # Load contract spec
    contract = load_spec("specs/contracts/payment-api-v1.md")

    # Verify all required endpoints exist
    assert has_endpoint("/api/payment/create")
    assert has_endpoint("/api/payment/refund")

    # Verify response formats match contract
    response = call_endpoint("/api/payment/create", {...})
    assert matches_contract_schema(response, contract)
```

---

## Next Steps

### For New Users
1. ✅ Complete [getting-started.md](getting-started.md) tutorial
2. ✅ Study examples: [01-hello-world](../examples/01-hello-world/), [02-calculator](../examples/02-calculator/)
3. ✅ Create your first external system (follow Quick Start above)

### For Advanced Users
1. ✅ Implement modular system with contracts pattern
2. ✅ Set up CI/CD integration
3. ✅ Create contract compliance tests
4. ✅ Contribute improvements to YBS framework

---

## References

- **Getting Started**: [getting-started.md](getting-started.md)
- **Framework Overview**: [../framework/README.md](../framework/README.md)
- **Repository Architecture**: [../scratch/ybs-repository-architecture-recommendation.md](../scratch/ybs-repository-architecture-recommendation.md)
- **Modular Approach**: [../scratch/ybs-practical-modular-approach.md](../scratch/ybs-practical-modular-approach.md)
- **Writing Specs**: [../framework/methodology/writing-specs.md](../framework/methodology/writing-specs.md)
- **Writing Steps**: [../framework/methodology/writing-steps.md](../framework/methodology/writing-steps.md)

---

## Version History

- **2.0.0** (2026-01-18): Initial external systems guide for standalone framework structure
