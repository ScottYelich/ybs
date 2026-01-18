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

### BASE Specifications

**BASE specs define system-wide defaults** that apply across all features:

```
specs/
├── business/_BASE.md      # System-wide business context
├── functional/_BASE.md    # System-wide UX patterns, accessibility standards
├── technical/_BASE.md     # Design tokens (UI), error codes, i18n framework
├── testing/_BASE.md       # Test infrastructure, tools, standards
├── security/_BASE.md      # Security model, threat model
├── operations/_BASE.md    # Deployment infrastructure, monitoring
└── architecture/_BASE.md  # Architectural principles, patterns
```

**Format**: `_BASE.md` (underscore prefix sorts first, clearly indicates purpose)

**Usage**: Feature specs **reference** BASE specs using `$ref` syntax:

```markdown
## Error Handling

**Extends**: $ref:technical/_BASE.md#error-handling-standards

### Overrides
- Error code range: 2000-2099 (validation errors for this feature)

### Feature-Specific
[Additional error codes specific to this feature]
```

**Benefits**:
- DRY: Define patterns once, reference everywhere
- Consistency: System-wide standards in one place
- Flexibility: Features can override when needed
- Maintainability: Update BASE, all features inherit

### Context-Driven Requirements

**Not all specs are needed for all features.** Requirements depend on feature characteristics:

| Feature Class | Required Specs | Example |
|---------------|----------------|---------|
| **Class A**: User-Facing | business, functional, technical, testing | Login screen, API endpoint |
| **Class B**: Backend | technical, testing (+ others as needed) | Data processor, background job |
| **Class C**: Infrastructure | technical only | Build script, dev tool |
| **Class D**: Documentation | None (use ADRs instead) | README update, process doc |

**Decision Framework** - Ask for each feature:
1. Does this affect users? → business + functional needed
2. Does this involve code? → technical + testing needed
3. Does this handle sensitive data? → security needed
4. Does this run in production? → operations needed
5. Does this introduce new patterns? → architecture needed

If answer is NO, spec is NOT required.

## Cross-Cutting Concerns

**Where do system-wide concerns like accessibility, UI, errors, and localization belong?**

### Accessibility (AX)

- **Primary**: `functional/<guid>.md` - Add "Accessibility Requirements" section
  - WCAG compliance level (AA/AAA)
  - Keyboard navigation, focus management
  - Screen reader support, ARIA labels
  - Color contrast ratios
- **Secondary**: `testing/<guid>.md` - Accessibility test cases
- **System-wide**: `functional/_BASE.md` - Accessibility standards for all features

### User Experience (UX)

- **Primary**: `functional/<guid>.md` - "User Workflows" section (already exists)
  - User goals, task flows, success criteria
- **Secondary**: `business/<guid>.md` - User stories, target users
- **System-wide**: `functional/_BASE.md` - UX patterns, interaction models

### User Interface (UI)

- **Primary**: `technical/_BASE.md` - Design tokens section
  - Colors, typography, spacing, icons
  - Component library references
  - Platform-specific guidelines (SwiftUI, React, etc.)
- **Secondary**: `functional/<guid>.md` - UI behavior specifications
- **Per-feature**: `technical/<guid>.md` - Feature-specific UI overrides

### Error Handling

- **Primary**: `technical/_BASE.md` - Error handling standards
  - Error code ranges by category
  - Error message templates
  - Retry strategies, fallback behaviors
- **Secondary**: `operations/<guid>.md` - Error monitoring, alerting
- **Per-feature**: `technical/<guid>.md` - Feature-specific error codes

### Localization (i18n)

- **Primary**: `technical/_BASE.md` - i18n framework
  - Supported languages, default language
  - String extraction process
  - Date/time/number formatting standards
- **Secondary**: `functional/<guid>.md` - User-visible text, content
- **Per-feature**: `technical/<guid>.md` - Feature-specific localization keys

**Key Principle**: Cross-cutting concerns are NOT separate spec types. They are sections within existing spec types, with system-wide standards in BASE specs.

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
