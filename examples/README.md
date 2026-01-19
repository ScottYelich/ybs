# YBS Framework Examples

**Learn YBS through progressive examples, from trivial to complex.**

---

## Learning Path

**New to YBS?** Start here:

### 1. Hello World (01-hello-world/)
- **Time**: 20 minutes
- **Complexity**: Trivial (5 steps)
- **Learn**: Basic YBS workflow
- **Build**: Simple Python script
- **Status**: 🚧 Coming soon (placeholder)

### 2. Calculator (02-calculator/)
- **Time**: 1 hour
- **Complexity**: Simple (10 steps)
- **Learn**: Multiple modules, testing, traceability
- **Build**: CLI calculator
- **Status**: 🚧 Coming soon (placeholder)

### 3. REST API (03-rest-api/)
- **Time**: 2-3 hours
- **Complexity**: Moderate (20 steps)
- **Learn**: Multi-tier systems, persistence, API design
- **Build**: Todo list REST API
- **Status**: 🚧 Coming soon (placeholder)

### 4. Claude Chat (04-claude-chat/)
- **Time**: Study over several sessions
- **Complexity**: Complex (44+ steps)
- **Learn**: Production patterns, advanced features, framework stress test
- **Build**: Full-featured AI chat CLI
- **Status**: 🚧 Coming soon (will be migrated from legacy-systems/bootstrap)

---

## Using Examples

Each example is a complete YBS system with:
- `specs/` - Specifications (what to build)
- `steps/` - Build steps (how to build)
- `builds/demo/` - Example build output
- `docs/` - Additional documentation
- `README.md` - Example overview

**To study an example**:
1. Read `specs/` to understand requirements
2. Read `steps/` to understand implementation approach
3. Execute build: Follow steps sequentially
4. Examine `builds/demo/` to see expected output

**To execute an example build**:
```bash
cd examples/02-calculator
# Read Step 0 to understand config
cat steps/calc-step_000000000000.md
# Create new build
mkdir -p builds/my-build
cd builds/my-build
# Execute steps in order...
```

---

## Creating Your Own System

Once comfortable with examples, create your own system:

See: [docs/getting-started.md](../docs/getting-started.md)

**External system** (recommended):
```bash
mkdir ~/my-awesome-project
cd ~/my-awesome-project
# Initialize YBS structure
# Reference YBS framework tools
```

See: [docs/external-systems.md](../docs/external-systems.md)

---

## Example Complexity

| Example | Steps | Files | Concepts | Status |
|---------|-------|-------|----------|--------|
| Hello World | 5 | 1 source | Basics | 🚧 Placeholder |
| Calculator | 10 | 3 modules | Testing, traceability | 🚧 Placeholder |
| REST API | 20 | 10+ files | Multi-tier, database | 🚧 Placeholder |
| Claude Chat | 44+ | 20+ files | Production patterns | 🚧 Placeholder |

**Start simple, work up!**

---

## Current Status

**Note**: This examples/ directory is newly created as part of YBS v2.0.0 restructure.

- **Legacy systems**: See `legacy-systems/bootstrap/` for the original bootstrap implementation
- **Future examples**: Will be created based on progressive learning path
- **Your feedback**: Help us prioritize which examples to create first!

---

## References

- **Framework Overview**: [../framework/README.md](../framework/README.md)
- **Getting Started**: [../docs/getting-started.md](../docs/getting-started.md)
- **External Systems**: [../docs/external-systems.md](../docs/external-systems.md)
- **Methodology**: [../framework/methodology/overview.md](../framework/methodology/overview.md)
