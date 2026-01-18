# YBS Spec System Research: Cross-Cutting Concerns and Base/Override Patterns

**Date**: 2026-01-17
**Author**: Claude (Research Agent)
**Purpose**: Comprehensive analysis and recommendations for handling cross-cutting concerns (UI, UX, Accessibility, i18n, Error Handling) and base+override patterns in YBS

---

## Executive Summary

This document analyzes how YBS should handle cross-cutting concerns like Accessibility (AX), User Experience (UX), User Interface (UI), Error Handling, and Internationalization (i18n), and proposes a comprehensive system for base specifications with overrides.

**Key Recommendations**:
1. **Cross-cutting concerns fit within existing spec types** - No new spec types needed
2. **Introduce BASE specs with inheritance** - `_BASE` suffix for system-wide defaults
3. **Make specs contextually required** - Not all specs needed for all features
4. **Follow W3C Design Tokens pattern** - Proven inheritance/override model

---

## Table of Contents

1. [Current YBS Spec System](#1-current-ybs-spec-system)
2. [Research Findings](#2-research-findings)
3. [Cross-Cutting Concerns Analysis](#3-cross-cutting-concerns-analysis)
4. [Base + Override Pattern Design](#4-base--override-pattern-design)
5. [Required vs Optional Guidelines](#5-required-vs-optional-guidelines)
6. [Concrete Examples](#6-concrete-examples)
7. [Implementation Plan](#7-implementation-plan)
8. [References](#8-references)

---

## 1. Current YBS Spec System

### 1.1 Existing Structure

YBS currently uses a **multi-perspective specification system** with 7 types:

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

### 1.2 Current Categorization

- **Core (always present)**: business, functional, technical, testing
- **Supplemental (as needed)**: security, operations, architecture

### 1.3 Problems to Solve

**User's Questions:**
1. Where do cross-cutting concerns (AX, UX, UI, Error Handling, i18n) belong?
2. Should every step require entries in ALL spec files?
3. Should there be BASE specs with common/default values?

---

## 2. Research Findings

### 2.1 Industry Practices for Cross-Cutting Concerns

#### Design Systems (2026)

**Source**: [Accessibility in Design Systems - Supernova.io](https://www.supernova.io/blog/accessibility-in-design-systems-a-comprehensive-approach-through-documentation-and-assets)

Modern design systems in 2026 treat accessibility as a **fundamental, cross-cutting concern** embedded directly into specifications:

- **Accessibility moves from compliance checkbox to core design principle**
- Design systems embed ARIA standards, keyboard navigation, screen reader compatibility as defaults
- **Accessibility and localization propagate by default** when patterns are built correctly
- Unified design systems function as ecosystems encompassing accessibility guidelines, motion principles, content strategy, and cross-platform patterns

**Key Insight**: Cross-cutting concerns are NOT separate systems but embedded in existing specifications.

#### Design Tokens (W3C Specification 2025.10)

**Source**: [Design Tokens Format Module 2025.10](https://www.designtokens.org/tr/drafts/format/)

**Source**: [Design Tokens Specification - Stable Version](https://designzig.com/design-tokens-specification-reaches-first-stable-version-with-w3c-community-group/)

The W3C Design Tokens specification provides a proven model for **base + override patterns**:

```json
{
  "$type": "color",
  "$value": "#FF0000",
  "$extensions": {
    "org.example.accessibility": {
      "contrastRatio": "4.5:1",
      "wcagLevel": "AA"
    }
  }
}
```

**Key Features**:
- **Group extension with deep merge behavior**: Local properties override inherited properties at same path
- **$extends property**: Tokens/groups can reference base definitions
- **Theming and multi-brand support**: Light/dark modes, accessibility variants, brand themes without file duplication
- **Cascade model**: Changes at foundation level automatically cascade through all references

**Key Insight**: Inheritance works through reference + deep merge, not file duplication.

#### Configuration Management (2025-2026)

**Source**: [Hierarchical Configuration Inheritance Pattern](https://configcraft.readthedocs.io/en/latest/01-Hierarchy-Configuration-Inheritance-Pattern/index.html)

**Source**: [Configuration Management Best Practices - Navvia](https://navvia.com/blog/configuration-management-best-practices)

Modern configuration management uses **layered structures**:

- **Base configuration baseline** for wide range of systems
- **Refining with additional configuration baselines** for specific contexts
- **Child configurations inherit properties** of parent but can add additional criteria
- **Hierarchical organization** allows flexible overrides per environment

**Key Insight**: Base + refinement model avoids duplication while maintaining flexibility.

### 2.2 Accessibility Compliance (WCAG 2026)

**Source**: [2026 WCAG & ADA Website Compliance](https://www.accessibility.works/blog/wcag-ada-website-compliance-standards-requirements/)

**Source**: [WCAG 2.2: What You Need to Know in 2026 - accessiBe](https://accessibe.com/blog/knowledgebase/wcag-two-point-two)

**Mandatory requirements by April 2026**:
- State/local governments must comply with **WCAG 2.1 Level AA**
- **4 principles**: Perceivable, Operable, Understandable, Robust
- **13 guidelines** with testable success criteria at 3 levels (A, AA, AAA)
- **Documentation requirements**: Audit reports, remediation tracking, accessibility statements, VPATs

**Key Insight**: Accessibility is not optional - it's a compliance requirement that must be systematically addressed.

### 2.3 Error Handling Patterns

**Source**: [Error Handling for Business Information Systems - Pattern Language](http://www.eso.org/~almamgr/AlmaAcs/OnlineDocs/ARCUSErrorHandling.pdf)

**Source**: [Error Handling in SOA Design - InfoQ](https://www.infoq.com/articles/error-handling-soa-design/)

**Pattern recommendations**:
- **System-wide decisions**: Handle domain errors (business logic) and technical errors (platform/programming) differently
- **Separate mechanisms**: Expected errors handled in code, unexpected errors handled by system
- **Standards established early**: Error handling patterns defined during analysis/design phase
- **Consistent handling**: Standard patterns across all features

**Key Insight**: Error handling requires system-wide standards, not feature-by-feature decisions.

### 2.4 Spec-Driven Development (2026)

**Source**: [Spec Driven Development - InfoQ](https://www.infoq.com/articles/spec-driven-development/)

**Emerging pattern**: Specifications become **executable and authoritative**
- Declared intent validated through implementation
- Specification as primary artifact
- Contract-centric control plane

**Key Insight**: Specifications should be complete enough to drive implementation without ambiguity.

---

## 3. Cross-Cutting Concerns Analysis

### 3.1 Accessibility (AX)

#### Nature of Concern
- **Regulatory requirement** (WCAG 2.1 Level AA by April 2026)
- **Cross-cutting**: Affects ALL user-facing features
- **Testable**: Specific success criteria and measurements
- **Systemic**: Requires consistent patterns across entire system

#### Where It Belongs in YBS

**PRIMARY LOCATION**: `functional/<guid>.md` - User-facing behavior

Add **Accessibility Requirements** section:
```markdown
## Accessibility Requirements

### WCAG Compliance
- **Level**: AA (2.1)
- **Principles**: [List applicable principles]

### Keyboard Navigation
- **Tab order**: [specification]
- **Shortcuts**: [list]
- **Focus indicators**: [requirements]

### Screen Readers
- **ARIA labels**: [requirements]
- **Semantic HTML**: [requirements]
- **Alt text**: [requirements]

### Color & Contrast
- **Contrast ratios**: [values with WCAG compliance]
- **Color independence**: [requirements]

### Assistive Technology
- **Voice control**: [requirements]
- **Switch control**: [requirements]
```

**SECONDARY LOCATIONS**:
- `testing/<guid>.md` - Accessibility test cases
- `operations/<guid>.md` - Accessibility monitoring/reporting
- `architecture/<guid>.md` - System-wide accessibility architecture (in BASE specs)

#### Recommendation
**DO NOT create separate accessibility/ spec type**. Accessibility is a dimension of functional requirements, not a separate concern.

### 3.2 User Experience (UX)

#### Nature of Concern
- **Design discipline**: How users accomplish goals
- **Workflow-focused**: User journeys, task flows, mental models
- **Already covered**: Current functional specs include workflows

#### Where It Belongs in YBS

**PRIMARY LOCATION**: `functional/<guid>.md` - User Workflows section (ALREADY EXISTS)

Current functional template includes:
```markdown
## User Workflows

### Workflow 1: [Primary Use Case]
**Goal**: What the user wants to accomplish
**Steps**: [User actions and system responses]
**Success Criteria**: How to know it worked
```

**SECONDARY LOCATIONS**:
- `business/<guid>.md` - User stories, target users, acceptance criteria
- `architecture/<guid>.md` - UX patterns, interaction models (in BASE specs)

#### Recommendation
**NO CHANGE NEEDED**. UX is already covered by existing functional + business specs. Consider adding UX-specific sections to BASE specs for system-wide patterns.

### 3.3 User Interface (UI)

#### Nature of Concern
- **Visual implementation**: Colors, fonts, layouts, components
- **Platform-specific**: SwiftUI, buttons, spacing, typography
- **Highly variant**: Changes between features but follows system patterns

#### Where It Belongs in YBS

**NEW APPROACH**: Use **Design Tokens pattern** in BASE specs

**For BASE specifications** (`technical/_BASE.md`):
```markdown
## UI Design Tokens

### Colors
```json
{
  "color": {
    "primary": { "$value": "#007AFF", "$type": "color" },
    "secondary": { "$value": "#5856D6", "$type": "color" },
    "text": {
      "primary": { "$value": "#000000", "$type": "color" },
      "secondary": { "$value": "#3C3C43", "$type": "color" }
    }
  }
}
```

### Typography
- **Heading 1**: SF Pro Display, 34pt, Bold
- **Heading 2**: SF Pro Display, 28pt, Bold
- **Body**: SF Pro Text, 17pt, Regular

### Spacing
- **Base unit**: 8px
- **Scale**: 4, 8, 12, 16, 24, 32, 48, 64px

### Components
- **Button styles**: Primary, Secondary, Tertiary
- **Input fields**: Standard patterns
- **Navigation**: System-wide patterns
```

**For FEATURE specifications** (`technical/<guid>.md`):
```markdown
## UI Implementation

### Visual Design
- **Extends**: $ref:technical/_BASE.md#ui-design-tokens
- **Overrides**:
  - Button style: Primary (from base)
  - Custom accent color: #FF6B6B (feature-specific)

### Components Used
- NavigationView (base)
- CustomDataGrid (feature-specific)
- StandardButton (base)

### Layout
[Feature-specific layout description]
```

**ALSO IN**:
- `functional/<guid>.md` - UI mockups, screen descriptions
- `architecture/<guid>.md` - UI architecture decisions

#### Recommendation
**DO NOT create separate UI/ spec type**. Instead:
1. Define UI design tokens in BASE technical specs
2. Reference base tokens in feature technical specs
3. Override only when feature requires customization

### 3.4 Error Handling

#### Nature of Concern
- **System-wide pattern**: Consistent error handling across all features
- **Multiple levels**: Domain errors vs technical errors
- **Operational concern**: Logging, monitoring, alerting

#### Where It Belongs in YBS

**NEW APPROACH**: Define in BASE specs, reference in features

**For BASE specifications** (`technical/_BASE.md`):
```markdown
## Error Handling Standards

### Error Categories

#### Domain Errors (Expected)
- **Nature**: Business logic validation failures
- **Handling**: Return error to user with actionable message
- **Logging**: Info level
- **Examples**: Invalid input, business rule violation

#### Technical Errors (Unexpected)
- **Nature**: Platform/programming errors
- **Handling**: Generic error to user, detailed log for developers
- **Logging**: Error level with stack trace
- **Examples**: Network failure, database error

### Error Response Format
```json
{
  "error": {
    "code": "ERR_VALIDATION_FAILED",
    "message": "User-facing description",
    "details": {},
    "timestamp": "2026-01-17T10:00:00Z"
  }
}
```

### Retry Strategies
- **Idempotent operations**: Safe to retry
- **At-least-once execution**: Guarantee delivery
- **Exponential backoff**: [parameters]

### Error Codes
- **Range 1000-1999**: Authentication/Authorization
- **Range 2000-2999**: Validation
- **Range 3000-3999**: Business logic
- **Range 4000-4999**: External service
- **Range 5000-5999**: Internal server
```

**For FEATURE specifications** (`technical/<guid>.md`):
```markdown
## Error Handling

### Extends Base
- **Reference**: $ref:technical/_BASE.md#error-handling-standards

### Feature-Specific Errors
- **ERR_2045**: File not found - "The specified file does not exist"
- **ERR_2046**: Invalid format - "File format not supported"

### Recovery Procedures
[Feature-specific recovery steps]
```

**ALSO IN**:
- `operations/<guid>.md` - Error monitoring, alerting, incident response
- `testing/<guid>.md` - Error condition test cases

#### Recommendation
**DO NOT create separate error-handling/ spec type**. Define system-wide patterns in BASE technical specs, reference in features.

### 3.5 Internationalization (i18n) / Localization

#### Nature of Concern
- **System-wide capability**: Not all features need localization
- **Infrastructure**: String management, locale handling, formatting
- **Content**: Translated strings, regional formats

#### Where It Belongs in YBS

**For BASE specifications** (`technical/_BASE.md`):
```markdown
## Internationalization Framework

### Supported Locales
- **Primary**: en-US
- **Secondary**: es-ES, fr-FR, de-DE
- **Future**: [planned locales]

### String Management
- **Format**: ICU MessageFormat
- **Storage**: JSON resource bundles
- **Loading**: Lazy loading per locale
- **Fallback**: en-US

### Locale-Sensitive Formatting
- **Dates**: Date.FormatStyle.long
- **Numbers**: NumberFormatter with locale
- **Currency**: CurrencyFormatter with locale
- **Measurements**: MeasurementFormatter

### Content Guidelines
- **No hardcoded strings**: All UI text in resource bundles
- **Pluralization**: ICU plural rules
- **Gender**: Neutral language preferred
- **RTL support**: Layout mirrors for RTL languages
```

**For FEATURE specifications** (`functional/<guid>.md`):
```markdown
## Localization Requirements

### Extends Base
- **Reference**: $ref:technical/_BASE.md#internationalization-framework

### Localizable Strings
- Feature needs localization: YES / NO
- **String count**: ~50 strings
- **Context**: [usage context for translators]

### Regional Variations
- Date format: Use base formatter
- Number format: Use base formatter
- Custom formats: [if any]
```

**ALSO IN**:
- `testing/<guid>.md` - i18n test cases (pseudo-localization, RTL testing)
- `operations/<guid>.md` - Translation workflow, locale deployment

#### Recommendation
**DO NOT create separate i18n/ spec type**. Define framework in BASE specs, declare usage in functional specs.

### 3.6 Summary Table

| Concern | Primary Location | BASE Spec? | Feature Spec? | Notes |
|---------|------------------|------------|---------------|-------|
| **Accessibility** | `functional/` | System-wide patterns in BASE | Specific requirements per feature | Mandatory for user-facing features |
| **User Experience** | `functional/` | UX patterns in BASE architecture | Workflows per feature | Already covered by existing templates |
| **User Interface** | `technical/` | Design tokens in BASE | UI implementation per feature | Use W3C design tokens pattern |
| **Error Handling** | `technical/` | Standards in BASE | Feature-specific errors | System-wide consistency required |
| **Internationalization** | `technical/` + `functional/` | Framework in BASE | Localization needs per feature | Not all features need i18n |

**CONCLUSION**: All cross-cutting concerns fit within existing 7 spec types. No new types needed.

---

## 4. Base + Override Pattern Design

### 4.1 Concept

**BASE specifications** define system-wide defaults, patterns, and standards that apply across ALL features. Feature specifications **reference** and **override** base specs as needed.

### 4.2 Naming Convention

```
specs/
├── business/_BASE.md           # System-wide business context
├── functional/_BASE.md         # System-wide UX patterns
├── technical/_BASE.md          # System-wide tech standards (design tokens, error handling, i18n)
├── testing/_BASE.md            # System-wide test infrastructure
├── security/_BASE.md           # System-wide security model
├── operations/_BASE.md         # System-wide ops infrastructure
├── architecture/_BASE.md       # System-wide architecture principles
│
├── business/<guid>.md          # Feature-specific business specs
├── functional/<guid>.md        # Feature-specific functional specs
├── technical/<guid>.md         # Feature-specific technical specs
└── ...
```

**Naming**: Use `_BASE.md` suffix (sorts first in directory listings, clearly indicates purpose)

### 4.3 Reference Syntax

Inspired by W3C Design Tokens and JSON Schema:

```markdown
## Error Handling

### Extends Base
**Reference**: $ref:technical/_BASE.md#error-handling-standards

### Overrides
- Error code range: 2000-2099 (validation errors for this feature)
- Custom retry logic: [description]

### Feature-Specific Additions
[New error codes, recovery procedures specific to this feature]
```

**Syntax**:
- `$ref:TYPE/_BASE.md#SECTION` - Reference a section in a BASE spec
- `$override:PROPERTY` - Explicitly mark overrides
- `$extends:TYPE/_BASE.md` - Inherit entire BASE spec

### 4.4 Inheritance Rules

Following W3C Design Tokens pattern:

1. **Deep Merge Behavior**: Local properties override inherited properties at same path
2. **Additive**: Features can add new properties not in BASE
3. **Explicit Override**: Use `$override` to clearly mark when changing base behavior
4. **No Deletion**: Features cannot remove base requirements (only override or extend)

**Example**:

BASE spec defines:
```json
{
  "color": {
    "primary": "#007AFF",
    "secondary": "#5856D6"
  }
}
```

Feature spec overrides:
```json
{
  "color": {
    "primary": "#FF6B6B",  // Override
    "accent": "#00C7BE"    // Add
  }
  // "secondary" inherited unchanged
}
```

**Result** (deep merge):
```json
{
  "color": {
    "primary": "#FF6B6B",   // From feature (override)
    "secondary": "#5856D6", // From base (inherited)
    "accent": "#00C7BE"     // From feature (added)
  }
}
```

### 4.5 Validation Rules

**Tool support needed** (future enhancement):

```bash
# Validate that all $ref references exist
$ ybs validate-specs

Checking references...
✓ technical/ybs-spec_a1b2c3d4e5f6.md references technical/_BASE.md#error-handling-standards - FOUND
✗ functional/ybs-spec_b2c3d4e5f6a7.md references functional/_BASE.md#nonexistent - NOT FOUND

Checking inheritance...
✓ All overrides are valid
✓ No circular references

2 specs validated, 1 error found
```

### 4.6 Benefits

1. **DRY (Don't Repeat Yourself)**: Define patterns once, reference everywhere
2. **Consistency**: System-wide standards enforced through base specs
3. **Flexibility**: Features can override when needed
4. **Traceability**: Clear inheritance chain from base to feature
5. **Maintainability**: Change base spec, all features inherit (unless overridden)
6. **Documentation**: Base specs serve as system-wide design documentation

---

## 5. Required vs Optional Guidelines

### 5.1 Current Problem

Current YBS categorization:
- **Core (always present)**: business, functional, technical, testing
- **Supplemental (as needed)**: security, operations, architecture

**Issue**: "Always present" is too rigid. Not every feature needs every spec type.

### 5.2 Proposed Approach: Context-Driven Requirements

**Principle**: Specs are required based on **feature characteristics**, not arbitrary rules.

### 5.3 Requirement Matrix

| Spec Type | Required When | Optional When | Never Required |
|-----------|---------------|---------------|----------------|
| **Business** | Feature affects users or business metrics | Internal refactoring only | Pure technical debt fixes |
| **Functional** | Feature has user-facing behavior | Backend-only changes | Infrastructure setup |
| **Technical** | Any code implementation | Documentation-only changes | Process changes |
| **Testing** | Any code implementation | Removing code only | Documentation updates |
| **Security** | Handles sensitive data, auth, external input | Internal utilities with no external exposure | UI-only changes with no data |
| **Operations** | Affects deployment, monitoring, or runtime | Local development tools | Build-time-only changes |
| **Architecture** | Introduces new patterns or makes significant design decisions | Follows established patterns | Trivial changes |

### 5.4 Feature Classification

#### Class A: User-Facing Features
**Examples**: New UI screen, API endpoint, user workflow

**Required**:
- ✅ Business (user value, success metrics)
- ✅ Functional (user workflows, behavior)
- ✅ Technical (implementation)
- ✅ Testing (test cases)

**Likely Needed**:
- ⚠️ Security (if handles user data)
- ⚠️ Operations (if affects production)
- ⚠️ Architecture (if new pattern)

#### Class B: Backend Features
**Examples**: Internal service, data processing, background job

**Required**:
- ✅ Technical (implementation)
- ✅ Testing (test cases)

**Likely Needed**:
- ⚠️ Business (if affects metrics/costs)
- ⚠️ Functional (if affects user-visible behavior)
- ⚠️ Security (if handles sensitive data)
- ⚠️ Operations (monitoring, alerting)
- ⚠️ Architecture (if new pattern)

#### Class C: Infrastructure/Tooling
**Examples**: Build script, development tool, CI/CD pipeline

**Required**:
- ✅ Technical (how it works)

**Likely Needed**:
- ⚠️ Operations (if affects deployment)
- ⚠️ Architecture (if affects build architecture)

**Rarely Needed**:
- ❌ Business (unless affects dev velocity significantly)
- ❌ Functional (no user-facing behavior)
- ❌ Testing (unless complex logic)
- ❌ Security (unless security tool)

#### Class D: Documentation/Process
**Examples**: README update, process improvement, style guide

**Required**:
- ✅ NONE (no code implementation)

**Alternative**:
- Use ADR (Architectural Decision Record) format for process decisions
- Use plain documentation for informational updates

### 5.5 Required Specs Per Step

**Question**: Should EVERY build step require entries in ALL spec files?

**Answer**: **NO** - Steps should reference only the specs needed for that step's scope.

**Example**:

**Step 1: Project Skeleton**
- Creates directory structure
- Sets up build configuration
- No business logic yet

**Required Specs**:
- ✅ technical/_BASE.md (defines project structure standards)
- ✅ technical/<step-guid>.md (implementation details for this step)
- ✅ architecture/<step-guid>.md (if establishing architectural patterns)

**NOT Required**:
- ❌ business/ (no user-facing features yet)
- ❌ functional/ (no user workflows yet)
- ❌ testing/ (no logic to test yet)
- ❌ security/ (no security-sensitive code yet)
- ❌ operations/ (nothing to deploy yet)

**Step 3: Implement User Authentication**
- User-facing login screen
- Password handling
- Session management

**Required Specs**:
- ✅ business/<step-guid>.md (user value of authentication)
- ✅ functional/<step-guid>.md (login workflow)
- ✅ technical/<step-guid>.md (implementation)
- ✅ testing/<step-guid>.md (test cases)
- ✅ security/<step-guid>.md (password storage, session security)
- ✅ operations/<step-guid>.md (deployment of auth service)

**NOT Required**:
- ❌ architecture/ (if follows established auth patterns from BASE)

### 5.6 Decision Framework

**For each feature/step, ask**:

1. **Does this affect users?** → business + functional needed
2. **Does this involve code?** → technical + testing needed
3. **Does this handle sensitive data or external input?** → security needed
4. **Does this run in production?** → operations needed
5. **Does this introduce new patterns?** → architecture needed

**If answer is NO**, spec is NOT required.

### 5.7 Enforcement Strategy

**Option 1: Validation Tool** (recommended for future)
```bash
$ ybs validate-step ybs-step_a1b2c3d4e5f6.md

Analyzing step scope...
Feature classification: CLASS A (User-Facing Feature)

Required specs:
✓ business/ybs-spec_a1b2c3d4e5f6.md - FOUND
✓ functional/ybs-spec_a1b2c3d4e5f6.md - FOUND
✓ technical/ybs-spec_a1b2c3d4e5f6.md - FOUND
✓ testing/ybs-spec_a1b2c3d4e5f6.md - FOUND

Recommended specs:
⚠ security/ybs-spec_a1b2c3d4e5f6.md - MISSING (feature handles user input)
✓ operations/ybs-spec_a1b2c3d4e5f6.md - FOUND

Step validation: PASSED with warnings
```

**Option 2: Template Checklist** (current approach)

Add to step template:
```markdown
## Specification Checklist

Does this step:
- [ ] Affect users? → business/ + functional/ needed
- [ ] Involve code implementation? → technical/ + testing/ needed
- [ ] Handle sensitive data or external input? → security/ needed
- [ ] Run in production? → operations/ needed
- [ ] Introduce new patterns? → architecture/ needed

**Required Specifications**:
- [List spec files needed for this step]

**Rationale**:
[Why these specs are sufficient for this step]
```

---

## 6. Concrete Examples

### 6.1 Example: Configuration System Feature

#### BASE Specifications

**`technical/_BASE.md`** (excerpt):
```markdown
## Configuration Management Standards

### Configuration Layers
1. **Defaults**: Hardcoded in application
2. **System**: /etc/app/config.json
3. **User**: ~/.app/config.json
4. **Environment**: Environment variables
5. **Runtime**: Command-line arguments

Priority: Runtime > Environment > User > System > Defaults

### Configuration Format
```json
{
  "version": "1.0",
  "feature": {
    "enabled": true,
    "option": "value"
  }
}
```

### Configuration Security
- No secrets in config files
- Use environment variables for sensitive values
- Validate all config on load
```

**`security/_BASE.md`** (excerpt):
```markdown
## Secrets Management

### Storage
- Development: .env files (gitignored)
- Production: Environment variables or secrets manager

### Access
- Secrets loaded at startup only
- Never logged or displayed
- Rotate credentials quarterly
```

#### Feature Specification

**`technical/ybs-spec_478a8c4b0cef.md`** (Configuration System):
```markdown
# Technical Specification: Configuration System

**GUID**: 478a8c4b0cef

## Configuration Management

### Extends Base
**Reference**: $ref:technical/_BASE.md#configuration-management-standards

### Feature-Specific Configuration

#### Provider Selection
```json
{
  "llm": {
    "provider": "ollama",
    "model": "deepseek-r1:8b",
    "options": {
      "temperature": 0.7,
      "stream": true
    }
  }
}
```

### Overrides
**$override**: Configuration file location
- **Base**: ~/.app/config.json
- **This feature**: ~/.bootstrap/config.json
- **Rationale**: Bootstrap is standalone tool, needs isolated config

### Validation Rules
- Provider must be "ollama" or "anthropic"
- Model string must be non-empty
- Temperature between 0.0 and 1.0
- API key required for anthropic provider
```

**`security/ybs-spec_478a8c4b0cef.md`** (Configuration System):
```markdown
# Security Specification: Configuration System

**GUID**: 478a8c4b0cef

## Secrets Management

### Extends Base
**Reference**: $ref:security/_BASE.md#secrets-management

### API Key Handling

#### Storage
- Follows base secrets management standards
- API keys in environment variable: ANTHROPIC_API_KEY
- Never stored in config file

#### Validation
- Key format: sk-[alphanumeric]
- Key presence checked on provider initialization
- Fail fast with clear error if missing

### Overrides
**$override**: None - fully complies with base standards
```

### 6.2 Example: User Interface Component

#### BASE Specifications

**`technical/_BASE.md`** (excerpt):
```markdown
## UI Design Tokens

### Color Palette
```json
{
  "color": {
    "primary": { "$value": "#007AFF", "$type": "color" },
    "secondary": { "$value": "#5856D6", "$type": "color" },
    "destructive": { "$value": "#FF3B30", "$type": "color" },
    "text": {
      "primary": { "$value": "#000000", "$type": "color" },
      "secondary": { "$value": "#3C3C43", "$type": "color" },
      "tertiary": { "$value": "#3C3C4399", "$type": "color" }
    },
    "background": {
      "primary": { "$value": "#FFFFFF", "$type": "color" },
      "secondary": { "$value": "#F2F2F7", "$type": "color" }
    }
  }
}
```

### Typography
- **Title 1**: SF Pro Display, 34pt, Bold
- **Title 2**: SF Pro Display, 28pt, Bold
- **Headline**: SF Pro Display, 17pt, Semibold
- **Body**: SF Pro Text, 17pt, Regular
- **Caption**: SF Pro Text, 12pt, Regular

### Spacing Scale
- **xs**: 4px
- **sm**: 8px
- **md**: 16px
- **lg**: 24px
- **xl**: 32px
- **2xl**: 48px

### Component Standards

#### Button
- **Height**: 44pt (touch target size)
- **Corner radius**: 8pt
- **Padding**: 16pt horizontal, 12pt vertical
- **Typography**: Headline

#### Text Input
- **Height**: 44pt
- **Corner radius**: 8pt
- **Border**: 1pt, secondary color
- **Padding**: 12pt horizontal
```

**`functional/_BASE.md`** (excerpt):
```markdown
## Accessibility Standards

### Touch Targets
- Minimum size: 44x44 points
- Spacing between targets: 8pt minimum

### Color Contrast
- Text: 4.5:1 minimum (WCAG AA)
- Large text (18pt+): 3:1 minimum
- UI components: 3:1 minimum

### Keyboard Navigation
- All interactive elements must be keyboard accessible
- Visible focus indicators required
- Logical tab order

### Screen Reader Support
- All images require alt text
- Buttons have descriptive labels
- Form inputs have labels
- Error messages announced
```

#### Feature Specification

**`functional/ybs-spec_c5404152680d.md`** (Settings Screen):
```markdown
# Functional Specification: Settings Screen

**GUID**: c5404152680d

## User Interface

### Extends Base
**Reference**: $ref:technical/_BASE.md#ui-design-tokens
**Reference**: $ref:functional/_BASE.md#accessibility-standards

### Screen Layout

#### Navigation
- NavigationView with title "Settings"
- Back button (system standard)

#### Content
- List of settings grouped by category
- Each setting: label + control (toggle, picker, or button)

#### Component Usage (from base)
- Text: Body style
- Section headers: Caption style
- Buttons: Standard button component
- Toggles: System Toggle

### Overrides
**None** - Fully uses base design tokens

### Accessibility

#### Keyboard Navigation
- Settings list: VoiceOver rotor support
- Tab through interactive controls
- Return key activates buttons/toggles

#### Screen Reader
- Section announcements: "General Settings, 3 items"
- Toggle announcements: "Dark mode, toggle button, currently on"
- Button announcements: "About, button"

#### Color Contrast
- All text meets WCAG AA (verified with base tokens)
- Focus indicators use primary color (4.5:1 on background)
```

**`technical/ybs-spec_c5404152680d.md`** (Settings Screen):
```markdown
# Technical Specification: Settings Screen

**GUID**: c5404152680d

## UI Implementation

### Extends Base
**Reference**: $ref:technical/_BASE.md#ui-design-tokens

### SwiftUI Implementation

#### View Structure
```swift
struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("General") {
                    Toggle("Dark Mode", isOn: $settings.darkMode)
                    Picker("Language", selection: $settings.language) {
                        // ...
                    }
                }

                Section("About") {
                    Button("Version Info") { showVersionInfo() }
                    Button("Licenses") { showLicenses() }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
```

#### Styling
- Uses base color tokens: `Color.primary`, `Color.secondary`
- Uses base typography: `.font(.body)`, `.font(.caption)`
- Uses base spacing: `.padding(.md)` (16pt)

### Overrides
**None** - Standard settings screen using all base patterns
```

### 6.3 Example: Error Handling in File Upload Feature

#### BASE Specifications

**`technical/_BASE.md`** (excerpt):
```markdown
## Error Handling Standards

### Error Categories

#### Domain Errors (Expected)
- HTTP status: 400-499
- User-facing message: Clear, actionable
- Logging: Info level
- Retry: No automatic retry

#### Technical Errors (Unexpected)
- HTTP status: 500-599
- User-facing message: Generic error + support contact
- Logging: Error level with full context
- Retry: Exponential backoff (3 attempts)

### Error Response Format
```json
{
  "error": {
    "code": "ERR_XXXX_YYYY",
    "message": "User-facing message",
    "details": {
      "field": "Additional context"
    },
    "timestamp": "ISO-8601",
    "requestId": "uuid"
  }
}
```

### Error Code Ranges
- 1000-1999: Authentication/Authorization
- 2000-2999: Validation
- 3000-3999: Business Logic
- 4000-4999: External Services
- 5000-5999: Internal Server

### Retry Strategy
- Idempotent operations only
- Exponential backoff: 1s, 2s, 4s
- Maximum 3 attempts
- Jitter: ±20%
```

#### Feature Specification

**`technical/ybs-spec_89b9e6233da5.md`** (File Upload):
```markdown
# Technical Specification: File Upload Feature

**GUID**: 89b9e6233da5

## Error Handling

### Extends Base
**Reference**: $ref:technical/_BASE.md#error-handling-standards

### Feature-Specific Error Codes

#### Validation Errors (2000 range)
- **ERR_2100_FILE_TOO_LARGE**: File exceeds 10MB limit
  - Message: "File size exceeds maximum of 10MB"
  - Recovery: User selects smaller file

- **ERR_2101_INVALID_FORMAT**: File format not supported
  - Message: "Supported formats: .txt, .md, .json"
  - Recovery: User converts or selects different file

- **ERR_2102_FILE_EMPTY**: File has no content
  - Message: "File is empty"
  - Recovery: User selects different file

#### External Service Errors (4000 range)
- **ERR_4100_UPLOAD_FAILED**: Storage service unavailable
  - Message: "Upload failed. Please try again."
  - Recovery: Automatic retry with exponential backoff

- **ERR_4101_QUOTA_EXCEEDED**: Storage quota reached
  - Message: "Storage quota exceeded. Delete files or upgrade plan."
  - Recovery: User action required

### Overrides
**$override**: Retry behavior for ERR_4100
- Base: 3 retries with exponential backoff
- This feature: 5 retries (upload interruptions common)
- Rationale: Network issues more likely with large file transfers

### Error Flow
```
User selects file
    ↓
Validation (sync)
    ├─ ERR_2100/2101/2102 → Show error immediately, no retry
    ↓
Upload (async)
    ├─ ERR_4100 → Retry 5x with backoff
    ├─ ERR_4101 → Show error, no retry
    ↓
Success → Update UI
```
```

**`functional/ybs-spec_89b9e6233da5.md`** (File Upload):
```markdown
# Functional Specification: File Upload Feature

**GUID**: 89b9e6233da5

## Error Conditions

### User-Facing Error Messages

#### File Too Large
- **Display**: Alert dialog
- **Title**: "File Too Large"
- **Message**: "The selected file is [size]. Maximum file size is 10MB."
- **Actions**: "Choose Different File" (primary), "Cancel" (secondary)

#### Invalid Format
- **Display**: Alert dialog
- **Title**: "Unsupported Format"
- **Message**: "This file format is not supported. Please select .txt, .md, or .json files."
- **Actions**: "Choose Different File" (primary), "Cancel" (secondary)

#### Upload Failed
- **Display**: Toast notification with retry button
- **Message**: "Upload failed. Retrying..." (during retry)
- **Message**: "Upload failed after 5 attempts. Check your connection." (after all retries)
- **Actions**: "Retry" (manual retry), "Cancel"

### Accessibility
- Error alerts announced by screen reader immediately
- Error focus moved to primary action button
- Error colors meet WCAG contrast requirements (base standards)
```

**`testing/ybs-spec_89b9e6233da5.md`** (File Upload):
```markdown
# Testing Specification: File Upload Feature

**GUID**: 89b9e6233da5

## Error Condition Tests

### Validation Error Tests

#### Test: File Too Large
- **Setup**: Create 15MB test file
- **Action**: Attempt upload
- **Expected**: ERR_2100, error dialog shown, no upload attempted
- **Verify**: Error message matches functional spec

#### Test: Invalid Format
- **Setup**: Select .exe file
- **Action**: Attempt upload
- **Expected**: ERR_2101, error dialog shown, no upload attempted
- **Verify**: Supported formats listed in message

### External Service Error Tests

#### Test: Upload Failure with Retry
- **Setup**: Mock storage service to fail 3 times, then succeed
- **Action**: Upload file
- **Expected**:
  - 3 automatic retries
  - Exponential backoff delays observed (1s, 2s, 4s)
  - Upload succeeds on 4th attempt
  - User sees "Retrying..." toast during attempts

#### Test: Upload Failure Exhausted Retries
- **Setup**: Mock storage service to always fail
- **Action**: Upload file
- **Expected**:
  - 5 automatic retries (override from base 3)
  - Final error message after all retries
  - Manual retry button available
```

### 6.4 Example: Internationalization in Welcome Screen

#### BASE Specifications

**`technical/_BASE.md`** (excerpt):
```markdown
## Internationalization Framework

### Supported Locales
- **Primary**: en-US (English - United States)
- **Phase 1**: es-ES (Spanish - Spain), fr-FR (French - France)
- **Phase 2**: de-DE (German - Germany), ja-JP (Japanese - Japan)
- **Phase 3**: ar-SA (Arabic - Saudi Arabia, RTL)

### String Management

#### Format
- ICU MessageFormat
- Supports: pluralization, gender, select, numbers, dates

#### Storage
```
Resources/
├── en-US/
│   └── Localizable.strings
├── es-ES/
│   └── Localizable.strings
└── fr-FR/
    └── Localizable.strings
```

#### Loading
- Lazy loading per locale
- Fallback chain: requested → en-US → hardcoded key

### Locale-Sensitive Formatting

#### Dates
```swift
// Base standard
let formatter = Date.FormatStyle.dateTime
    .year().month().day()
    .locale(Locale.current)
```

#### Numbers
```swift
// Base standard
let formatter = NumberFormatter()
formatter.numberStyle = .decimal
formatter.locale = Locale.current
```

### Content Guidelines
- **No hardcoded strings**: All UI text in Localizable.strings
- **Context comments**: Every string has translator context
- **Avoid concatenation**: Use ICU format for complex strings
- **Neutral language**: Avoid gendered language where possible
- **RTL support**: Use leading/trailing instead of left/right
```

#### Feature Specification

**`functional/ybs-spec_abc123def456.md`** (Welcome Screen):
```markdown
# Functional Specification: Welcome Screen

**GUID**: abc123def456

## Localization Requirements

### Extends Base
**Reference**: $ref:technical/_BASE.md#internationalization-framework

### Localizable Content

#### Strings Needed
- **welcome.title**: "Welcome to Bootstrap"
- **welcome.subtitle**: "Your AI coding assistant"
- **welcome.get_started**: "Get Started"
- **welcome.learn_more**: "Learn More"
- **welcome.features.title**: "Features"
- **welcome.features.item1**: "Chat with AI"
- **welcome.features.item2**: "Execute commands"
- **welcome.features.item3**: "Edit files"

**Total**: 8 strings

#### Context for Translators
- welcome.title: Main heading, app name "Bootstrap" should remain in English
- welcome.subtitle: Short description, conversational tone
- welcome.get_started: Primary action button, imperative
- welcome.features.itemN: Short feature descriptions, bullet points

### Regional Variations

#### Date/Time
- No dates displayed on welcome screen

#### Numbers
- No numbers displayed on welcome screen

#### Cultural Considerations
- **es-ES**: Use formal "usted" form
- **fr-FR**: Use informal "tu" form
- **ar-SA**: RTL layout, text right-aligned

### Overrides
**None** - Follows all base i18n standards
```

**`technical/ybs-spec_abc123def456.md`** (Welcome Screen):
```markdown
# Technical Specification: Welcome Screen

**GUID**: abc123def456

## Internationalization Implementation

### Extends Base
**Reference**: $ref:technical/_BASE.md#internationalization-framework

### String Implementation

#### Resources/en-US/Localizable.strings
```
/* Main heading on welcome screen */
"welcome.title" = "Welcome to Bootstrap";

/* Short description below title */
"welcome.subtitle" = "Your AI coding assistant";

/* Primary action button */
"welcome.get_started" = "Get Started";

/* Secondary action button */
"welcome.learn_more" = "Learn More";

/* Features section heading */
"welcome.features.title" = "Features";

/* Feature list items */
"welcome.features.item1" = "Chat with AI";
"welcome.features.item2" = "Execute commands";
"welcome.features.item3" = "Edit files";
```

#### SwiftUI Implementation
```swift
struct WelcomeView: View {
    var body: some View {
        VStack(spacing: .lg) {
            Text("welcome.title")
                .font(.title1)

            Text("welcome.subtitle")
                .font(.headline)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: .md) {
                Text("welcome.features.title")
                    .font(.headline)

                Label("welcome.features.item1", systemImage: "message")
                Label("welcome.features.item2", systemImage: "terminal")
                Label("welcome.features.item3", systemImage: "doc.text")
            }

            HStack {
                Button("welcome.get_started") { onGetStarted() }
                    .buttonStyle(.borderedProminent)

                Button("welcome.learn_more") { onLearnMore() }
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .environment(\\.locale, .current) // Respects system locale
    }
}
```

### RTL Support
- Uses `.leading`/`.trailing` instead of `.left`/`.right`
- Layout automatically mirrors for RTL locales
- No hardcoded directional offsets

### Overrides
**None** - Standard implementation using base framework
```

**`testing/ybs-spec_abc123def456.md`** (Welcome Screen):
```markdown
# Testing Specification: Welcome Screen

**GUID**: abc123def456

## Localization Tests

### String Presence Tests

#### Test: All Strings Present in All Locales
- **Given**: App built with all supported locales
- **When**: Switch to each locale (en-US, es-ES, fr-FR)
- **Then**:
  - No strings show as keys (e.g., "welcome.title")
  - All 8 strings have translations
  - No missing translation warnings in console

### Pseudo-Localization Test

#### Test: Pseudo-Locale (for string expansion)
- **Given**: App in pseudo-locale mode (strings replaced with "~ẄḚḶĊṎṀḚ ŦṎ ḄṎṎŦṠŦṚÂṖ~")
- **When**: View welcome screen
- **Then**:
  - All strings show pseudo-localized version
  - No text truncation
  - No layout overflow
  - UI remains usable

### RTL Layout Test

#### Test: Arabic Locale (RTL)
- **Given**: App in ar-SA locale
- **When**: View welcome screen
- **Then**:
  - Layout mirrors (buttons on left, alignment right)
  - Text right-aligned
  - Icons remain on correct side
  - No hardcoded LTR layouts

### Cultural Appropriateness

#### Test: Manual Review by Native Speakers
- **Process**: Send screenshots to native speakers
- **Verify**:
  - Translations sound natural
  - Tone matches context (formal vs informal)
  - Cultural references appropriate
```

---

## 7. Implementation Plan

### 7.1 Phase 1: Introduce BASE Specs (Immediate)

**Goal**: Create BASE specifications for existing YBS bootstrap system

**Tasks**:
1. Create `_BASE.md` files in each spec type directory
2. Extract system-wide patterns from existing specs
3. Define inheritance syntax (`$ref`, `$override`, `$extends`)
4. Update existing feature specs to reference BASE specs

**Files to Create**:
- `systems/bootstrap/specs/technical/_BASE.md`
- `systems/bootstrap/specs/functional/_BASE.md`
- `systems/bootstrap/specs/security/_BASE.md`
- `systems/bootstrap/specs/architecture/_BASE.md`

**Content for BASE Specs**:
- UI design tokens (colors, typography, spacing)
- Error handling standards
- i18n framework
- Accessibility patterns
- Security model
- Configuration management

**Success Criteria**:
- All cross-cutting concerns documented in BASE specs
- At least 3 feature specs updated to reference BASE
- Consistency improved across feature specs

### 7.2 Phase 2: Update Framework Templates (Short-term)

**Goal**: Update YBS framework templates to include BASE spec guidance

**Tasks**:
1. Add BASE spec guidance to `framework/methodology/writing-specs.md`
2. Create BASE spec templates in `framework/templates/`
3. Update existing spec templates with `$ref` syntax examples
4. Document inheritance rules

**Files to Create**:
- `framework/templates/TEMPLATE-_BASE-business.md`
- `framework/templates/TEMPLATE-_BASE-functional.md`
- `framework/templates/TEMPLATE-_BASE-technical.md`
- (etc. for each spec type)

**Files to Update**:
- `framework/methodology/writing-specs.md` - Add BASE specs section
- All `framework/templates/TEMPLATE-*.md` - Add reference syntax examples

**Success Criteria**:
- Complete documentation of BASE spec pattern
- Templates include inheritance examples
- Clear guidance on when to use BASE vs feature specs

### 7.3 Phase 3: Update Requirement Guidelines (Short-term)

**Goal**: Document context-driven spec requirements

**Tasks**:
1. Update `framework/methodology/writing-specs.md` with requirement matrix
2. Add feature classification section
3. Create spec requirement checklist
4. Update step template with spec checklist

**Content to Add**:
- Feature classification (Class A/B/C/D)
- Requirement matrix (when each spec type is needed)
- Decision framework (questions to ask)

**Success Criteria**:
- Clear guidance on when specs are required
- Feature classification system documented
- Step template includes spec checklist

### 7.4 Phase 4: Build Validation Tools (Medium-term)

**Goal**: Automate validation of spec references and requirements

**Tasks**:
1. Create `ybs validate-specs` command
2. Check `$ref` references exist
3. Validate inheritance (no circular refs)
4. Suggest missing specs based on feature classification

**Tools to Create**:
- `framework/tools/validate-specs.sh` - Reference validation
- `framework/tools/suggest-specs.sh` - Requirement suggestions
- `framework/tools/show-inheritance.sh` - Inheritance tree visualization

**Success Criteria**:
- Can validate all spec references
- Detects circular dependencies
- Suggests required specs for steps

### 7.5 Phase 5: Migrate Bootstrap System (Medium-term)

**Goal**: Fully migrate bootstrap system to BASE+feature spec model

**Tasks**:
1. Create comprehensive BASE specs for bootstrap
2. Refactor all feature specs to reference BASE
3. Remove duplication from feature specs
4. Validate all references

**Files to Refactor**:
- All existing feature specs in `systems/bootstrap/specs/*/`
- Update to reference BASE specs where applicable
- Add explicit overrides where needed

**Success Criteria**:
- Zero duplication of system-wide patterns
- All feature specs reference BASE
- All references validated

### 7.6 Phase 6: Cross-Cutting Concern Documentation (Long-term)

**Goal**: Create comprehensive BASE specs for all cross-cutting concerns

**Tasks**:
1. Create accessibility BASE spec section
2. Create UI design tokens BASE spec section
3. Create error handling BASE spec section
4. Create i18n BASE spec section
5. Document patterns in `systems/bootstrap/docs/`

**Files to Create**:
- `systems/bootstrap/docs/accessibility-standards.md` (detailed WCAG compliance)
- `systems/bootstrap/docs/design-system.md` (UI design tokens)
- `systems/bootstrap/docs/error-handling-patterns.md` (error standards)
- `systems/bootstrap/docs/internationalization.md` (i18n framework)

**Content**:
- WCAG 2.1 AA compliance checklist
- Complete design token library
- Error code registry
- Localization workflow

**Success Criteria**:
- All cross-cutting concerns have comprehensive BASE documentation
- Patterns are reusable across future YBS systems
- Bootstrap system validates all patterns

---

## 8. References

### Industry Standards and Specifications

1. **W3C Design Tokens Specification (2025.10)**
   - [Design Tokens Format Module](https://www.designtokens.org/tr/drafts/format/)
   - [First Stable Version Announcement](https://designzig.com/design-tokens-specification-reaches-first-stable-version-with-w3c-community-group/)

2. **WCAG 2.1/2.2 Accessibility Standards**
   - [WCAG 2 Overview - W3C](https://www.w3.org/WAI/standards-guidelines/wcag/)
   - [2026 WCAG & ADA Compliance](https://www.accessibility.works/blog/wcag-ada-website-compliance-standards-requirements/)
   - [WCAG 2.2 Checklist 2026](https://theclaymedia.com/wcag-2-2-accessibility-checklist-2026/)

3. **Error Handling Patterns**
   - [Error Handling - OWASP Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html)
   - [Error Handling in SOA Design - InfoQ](https://www.infoq.com/articles/error-handling-soa-design/)

4. **Configuration Management**
   - [Hierarchical Configuration Inheritance Pattern](https://configcraft.readthedocs.io/en/latest/01-Hierarchy-Configuration-Inheritance-Pattern/index.html)
   - [Configuration Management Best Practices](https://navvia.com/blog/configuration-management-best-practices)

### Design Systems and Component Architecture

5. **Design System Patterns**
   - [Accessibility in Design Systems - Supernova.io](https://www.supernova.io/blog/accessibility-in-design-systems-a-comprehensive-approach-through-documentation-and-assets)
   - [Design System Accessibility - UXPin](https://www.uxpin.com/studio/blog/design-system-accessibility/)
   - [Schema 2025: Design Systems for a New Era - Figma](https://www.figma.com/blog/schema-2025-design-systems-recap/)

6. **Component Variants**
   - [Create and Use Variants - Figma](https://help.figma.com/hc/en-us/articles/360056440594-Create-and-use-variants)
   - [Component Variants to Scale Design System - Penpot](https://penpot.app/blog/how-to-use-component-variants-to-scale-your-design-system/)

### Software Architecture Patterns

7. **Spec-Driven Development**
   - [Spec Driven Development - InfoQ](https://www.infoq.com/articles/spec-driven-development/)

8. **Internationalization**
   - [UI Design Guidelines - Localization and Internationalization](https://www.linkedin.com/advice/0/how-do-you-handle-localization-internationalization)

### YBS Framework Documents

9. **Current YBS Documentation**
   - `framework/methodology/writing-specs.md` - Current spec writing guide
   - `framework/templates/TEMPLATE-*.md` - Existing spec templates
   - `systems/bootstrap/specs/README.md` - Bootstrap spec organization

---

## Appendix A: Glossary

**BASE Spec**: System-wide specification defining defaults, patterns, and standards that apply across all features.

**Feature Spec**: Specification for a specific feature that references and optionally overrides BASE specs.

**Cross-Cutting Concern**: Aspect of a system that affects multiple features/components (e.g., security, i18n, accessibility).

**Design Tokens**: Named entities storing visual design attributes (colors, typography, spacing) in a platform-agnostic format.

**Deep Merge**: Inheritance strategy where local properties override inherited properties at the same path, but other inherited properties remain.

**$ref**: Reference syntax to inherit a section from another spec.

**$override**: Explicit marker indicating a feature is changing a BASE spec value.

**$extends**: Inherit an entire BASE spec.

**WCAG**: Web Content Accessibility Guidelines - international standard for web accessibility.

**i18n**: Internationalization - designing software to support multiple languages/regions.

**ICU MessageFormat**: International Components for Unicode message formatting standard.

**ADR**: Architectural Decision Record - documents why a design choice was made.

---

## Appendix B: Decision Summary

### Decision 1: Cross-Cutting Concerns Use Existing Spec Types
**Status**: Recommended

**Rationale**:
- Industry research shows cross-cutting concerns are embedded in specifications, not separate
- All identified concerns fit naturally within existing 7 spec types
- Adding new spec types increases complexity without benefit
- Design tokens, accessibility, i18n all successfully managed within existing spec structures

**Implementation**:
- Accessibility → functional/ (requirements) + testing/ (test cases)
- UX → functional/ (workflows) + business/ (user stories)
- UI → technical/ (design tokens) + functional/ (mockups)
- Error Handling → technical/ (standards) + operations/ (monitoring)
- i18n → technical/ (framework) + functional/ (localization needs)

### Decision 2: Introduce BASE Specs with Inheritance
**Status**: Recommended

**Rationale**:
- W3C Design Tokens specification provides proven model
- Configuration management systems successfully use base+override pattern
- Eliminates duplication while maintaining flexibility
- Clear inheritance chain improves maintainability and traceability
- Aligns with industry best practices (2025-2026)

**Implementation**:
- Create `_BASE.md` files in each spec type directory
- Use `$ref:TYPE/_BASE.md#SECTION` syntax for references
- Use `$override:PROPERTY` to mark explicit overrides
- Follow deep merge behavior (local overrides inherited at same path)

### Decision 3: Context-Driven Spec Requirements
**Status**: Recommended

**Rationale**:
- Current "always present" categorization too rigid
- Different features have different specification needs
- Industry practice: requirements based on feature characteristics
- Reduces unnecessary documentation while maintaining quality
- Better aligns with actual development practices

**Implementation**:
- Feature classification system (Class A/B/C/D)
- Requirement matrix (when each spec type needed)
- Decision framework (questions to ask)
- Validation tools to suggest required specs

### Decision 4: No New Spec Types for Cross-Cutting Concerns
**Status**: Recommended

**Rationale**:
- Would fragment related information
- Cross-cutting concerns are aspects of existing specs, not separate entities
- Industry research shows embedding works better than separating
- Current 7 types proven sufficient through bootstrap system development

**Implementation**:
- Document cross-cutting concerns in BASE specs
- Reference BASE specs from feature specs
- Use existing spec types with additional sections as needed

---

## Appendix C: Next Actions

### Immediate (This Week)
1. ✅ Complete this research document
2. ⬜ Review with user
3. ⬜ Create first BASE spec (`technical/_BASE.md`) for bootstrap
4. ⬜ Update one feature spec to reference BASE

### Short-term (Next 2 Weeks)
1. ⬜ Complete all BASE specs for bootstrap system
2. ⬜ Update `framework/methodology/writing-specs.md` with BASE spec guidance
3. ⬜ Create BASE spec templates in `framework/templates/`
4. ⬜ Update existing spec templates with reference syntax

### Medium-term (Next Month)
1. ⬜ Build validation tools (`validate-specs.sh`)
2. ⬜ Migrate all bootstrap feature specs to BASE+feature model
3. ⬜ Create comprehensive cross-cutting concern documentation
4. ⬜ Test pattern with new feature implementation

### Long-term (Future)
1. ⬜ Build advanced validation (circular reference detection)
2. ⬜ Create inheritance visualization tool
3. ⬜ Develop spec requirement suggestion tool
4. ⬜ Validate pattern across multiple YBS systems

---

**Document Status**: Complete
**Last Updated**: 2026-01-17
**Review Status**: Awaiting user feedback

---

**End of Document**
