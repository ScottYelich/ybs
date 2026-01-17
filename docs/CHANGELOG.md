# Documentation Changelog

This file tracks major structural changes to the documentation organization.

---

## 2026-01-16 - Major Restructuring: Specs Organization

### Summary
Reorganized specification structure from flat to categorized with GUID-based traceability system.

### Changes

#### Directory Restructuring
- **Renamed**: `docs/misc/` → `docs/ybs-spec/` → `docs/specs/system/`
- **Created**: `docs/specs/` with 7 category subdirectories:
  - `system/` - System-wide specifications (moved existing content here)
  - `business/` - Business requirements per feature (new)
  - `functional/` - Functional specifications per feature (new)
  - `technical/` - Technical implementations per feature (new)
  - `testing/` - Test plans per feature (new)
  - `security/` - Security requirements per feature (new)
  - `operations/` - Deployment and operations per feature (new)
  - `architecture/` - Architectural decisions per feature (new)

#### File Changes
- **Renamed**: All `yds-*` files → `ybs-*` (Yelich Build System)
  - `yds-spec.md` → `ybs-spec.md`
  - `yds-decisions.md` → `ybs-decisions.md`
  - `yds-lessons-learned.md` → `ybs-lessons-learned.md`
- **Moved**: All system-wide specs from root to `specs/system/`

#### New Documentation
- `docs/specs/README.md` - Complete guide to new structure
- `docs/specs/list-specs.sh` - Helper to view all specs for a GUID
- `docs/specs/deps.sh` - Helper to visualize dependency tree
- 7 complete spec templates with detailed sections

#### Templates Created
- `TEMPLATE-business.md` - Business value, user stories, ROI
- `TEMPLATE-functional.md` - Features, workflows, UI/API specs
- `TEMPLATE-technical.md` - Architecture, APIs, dependencies
- `TEMPLATE-testing.md` - Test strategy, cases, acceptance criteria
- `TEMPLATE-security.md` - Threat model, OWASP analysis, checklist
- `TEMPLATE-operations.md` - Deployment, monitoring, runbooks, SLOs
- `TEMPLATE-architecture.md` - ADRs, diagrams, technology decisions

#### Reference Updates
Updated all documentation references from old paths to new:
- `/CLAUDE.md`
- `/README.md`
- `/docs/README.md`
- `/docs/build-from-scratch/CLAUDE.md`
- `/docs/build-from-scratch/README.md`

### Rationale

**Problem**:
- `misc/` was unclear directory name
- No relationship between specs and features
- No way to track feature across different perspectives
- No dependency management between features

**Solution**:
- Categorize specs by type (business, functional, technical, etc.)
- Use 12-hex GUIDs for feature identity across all spec types
- Same GUID across categories enables traceability
- Dependency metadata in technical specs (Required/Optional/Conflicts/Dependents)

### Key Concepts

#### GUID-Based Traceability
Each feature gets ONE 12-hex GUID used across all spec types:
```
a1b2c3d4e5f6 (Configuration System)
├── business/ybs-spec_a1b2c3d4e5f6.md      # Why we need it
├── functional/ybs-spec_a1b2c3d4e5f6.md    # What it does
├── technical/ybs-spec_a1b2c3d4e5f6.md     # How it works
└── testing/ybs-spec_a1b2c3d4e5f6.md       # How to test it
```

#### Dependency Management
Technical specs include dependency metadata:
- **Required**: Must implement before this feature
- **Optional**: Nice-to-have dependencies
- **Conflicts**: Mutually exclusive features
- **Dependents**: Features that depend on this one

This enables:
- Build order planning (implement dependencies first)
- Impact analysis (see what breaks when changing a feature)
- Dependency visualization (generate graphs)
- Validation (check all dependencies exist)

#### Helper Scripts
- `./list-specs.sh <guid>` - Show all spec types for a feature
- `./list-specs.sh --all` - List all features with spec counts
- `./deps.sh <guid>` - Show dependency tree for a feature

### Migration Notes

**Old paths** → **New paths**:
- `docs/misc/yds-spec.md` → `docs/specs/system/ybs-spec.md`
- `docs/misc/yds-decisions.md` → `docs/specs/system/ybs-decisions.md`
- `docs/misc/yds-lessons-learned.md` → `docs/specs/system/ybs-lessons-learned.md`

**System-wide vs Feature specs**:
- System-wide specs stay in `specs/system/` (architecture of YBS itself)
- Feature specs go in category directories (individual features/capabilities)

### Impact

This change affects:
- ✅ All documentation files (references updated)
- ✅ CLAUDE.md guidance files (updated)
- ✅ README files (updated)
- ✅ Build step instructions (updated)
- ⚠️ Any external links to old paths (will break)
- ⚠️ Bookmarks to old docs (need updating)

### Usage

**Creating a new feature spec**:
1. Generate GUID: `uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-12`
2. Create `ybs-spec_<guid>.md` in relevant categories (business, functional, technical, testing)
3. Add dependencies in technical spec
4. Use helper scripts to view: `./list-specs.sh <guid>`

**Viewing dependencies**:
```bash
cd docs/specs
./deps.sh <guid>
```

**Listing all features**:
```bash
cd docs/specs
./list-specs.sh --all
```

---

## Future Changes

Document future major restructuring here.
