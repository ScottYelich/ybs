# General System Documentation

This directory contains general system documentation that doesn't fit into specific specification types.

## Purpose

General documentation includes:
- Implementation checklists and lessons learned
- Cross-cutting concerns
- Project guidelines and conventions
- Development workflows
- Troubleshooting guides
- FAQ and common issues
- Historical context and background
- Any other system-wide documentation

## Files in This Directory

- **`ybs-lessons-learned.md`** - Implementation checklist and lessons learned from building the bootstrap system

## When to Use This Directory

Use this directory for documentation that:
- Spans multiple specification types
- Provides meta-information about the system
- Documents process or workflow (not just specifications)
- Captures tribal knowledge or lessons learned
- Doesn't fit cleanly into business, functional, technical, architecture, testing, security, or operations categories

## Related Specification Types

For focused specifications, use the appropriate type-specific directory:
- **Technical** (`../technical/`) - Implementation details
- **Architecture** (`../architecture/`) - Architectural decisions
- **Business** (`../business/`) - Business value and ROI
- **Functional** (`../functional/`) - User workflows
- **Testing** (`../testing/`) - Test strategies
- **Security** (`../security/`) - Security requirements
- **Operations** (`../operations/`) - Deployment procedures

## Naming Convention

Files in this directory can use descriptive names:
```
<system-name>-<topic>.md
```

Examples:
- `ybs-lessons-learned.md`
- `ybs-conventions.md`
- `ybs-troubleshooting.md`
- `ybs-faq.md`

---

**See also**: [Bootstrap Specifications Overview](../README.md)
