# YBS Specifications

**Version**: 1.0.0

This directory contains all specifications for the Yelich Build System (YBS) and systems built with it.

## Structure

### System-Wide Documentation (`system/`)

Master documents covering the entire YBS system:
- **ybs-spec.md** - Complete technical specification
- **ybs-decisions.md** - Architectural Decision Records (ADRs)
- **ybs-lessons-learned.md** - Implementation checklist and best practices

These documents describe YBS as a whole, not individual features.

### Feature Specifications (by type)

Each feature gets a **12-hex GUID** and specifications across multiple dimensions:

```
<guid>  # Same GUID used across all spec types for one feature
├── business/<guid>.md      # Business value, user stories, metrics
├── functional/<guid>.md    # Features, behavior, workflows
├── technical/<guid>.md     # Implementation, APIs, algorithms
├── testing/<guid>.md       # Test plans, acceptance criteria
├── security/<guid>.md      # Security requirements, threat model
├── operations/<guid>.md    # Deployment, monitoring, runbooks
└── architecture/<guid>.md  # Design decisions, diagrams
```

**Format**: `ybs-spec_<12hex>.md` (e.g., `ybs-spec_a1b2c3d4e5f6.md`)

### Categories

#### Core (always present)
1. **business/** - Business requirements, user stories, ROI, success metrics
2. **functional/** - Features, user workflows, behavior specifications
3. **technical/** - Implementation details, APIs, data models, algorithms
4. **testing/** - Test plans, test cases, acceptance criteria

#### Supplemental (as needed)
5. **security/** - Security requirements, threat models, vulnerability assessments
6. **operations/** - Deployment, monitoring, logging, SRE requirements
7. **architecture/** - Architectural Decision Records, system diagrams

## Traceability

**Same GUID = One Feature across all perspectives**

Example: Configuration System (`ybs-spec_a1b2c3d4e5f6`)
- `business/ybs-spec_a1b2c3d4e5f6.md` - Why we need configuration
- `functional/ybs-spec_a1b2c3d4e5f6.md` - What config features to expose
- `technical/ybs-spec_a1b2c3d4e5f6.md` - How to implement config system
- `testing/ybs-spec_a1b2c3d4e5f6.md` - How to test configuration

## Dependencies

**Technical specs include dependency metadata:**

```markdown
## Dependencies

### Required (Must implement first)
- `ybs-spec_478a8c4b0cef`  # File System Utilities
- `ybs-spec_b2c3d4e5f6a7`  # JSON Parser

### Optional (Nice-to-have)
- `ybs-spec_c3d4e5f6a7b8`  # Schema Validation

### Conflicts (Mutually exclusive)
- `ybs-spec_e5f6a7b8c9d0`  # YAML Configuration

### Dependents (What depends on this)
- `ybs-spec_f6a7b8c9d0e1`  # LLM Provider Selection
```

This enables:
- **Build order**: Know what to implement first
- **Impact analysis**: See what breaks when changing a feature
- **Dependency graphs**: Visualize system architecture
- **Validation**: Check if dependencies are implemented

## Helper Scripts

**Location**: All helper scripts are centralized in `bin/` at repository root.

### View all specs for a feature
```bash
../../bin/list-specs.sh a1b2c3d4e5f6
```

Shows all spec types (business, functional, technical, etc.) for that GUID.

### Show dependency tree
```bash
../../bin/deps.sh a1b2c3d4e5f6
```

Shows required/optional dependencies and dependents.

### Validate specs
```bash
../../bin/validate-specs.sh
```

Checks:
- All referenced dependencies exist
- No circular dependencies
- All features have required spec types

## Creating New Specs

1. **Generate GUID**: `uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-12`
2. **Create files**: Create `ybs-spec_<guid>.md` in appropriate categories
3. **Add dependencies**: In technical spec, list required/optional dependencies
4. **Cross-reference**: Link from steps (if implementing this feature)

## Relationship to Build Steps

Build steps (`systems/SYSTEMNAME/steps/ybs-step_<guid>.md`) implement specifications:

```markdown
# Step: Implement Configuration System

**Step GUID**: xyz123abc456
**Implements**:
- `ybs-spec_a1b2c3d4e5f6` (Configuration System)
```

A step can implement one or more spec GUIDs.

---

**Last updated**: 2026-01-16
