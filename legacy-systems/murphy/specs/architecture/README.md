# Architecture Specifications

This directory contains architectural documentation and Architectural Decision Records (ADRs) for the bootstrap system.

## Purpose

Architecture specifications describe **why** and **how** the system is designed at a high level, including:
- Architectural Decision Records (ADRs)
- System context and component architecture
- Data architecture and flow
- Integration points and API design
- Deployment architecture
- Quality attributes (performance, scalability, availability, etc.)
- Technology stack decisions
- Technical constraints and trade-offs
- Risk analysis and evolution plans

## Template

Use `framework/templates/TEMPLATE-architecture.md` for architectural overviews with embedded ADRs, or `framework/templates/adr-template.md` for individual decision records.

## Files in This Directory

- **`ybs-decisions.md`** - Architectural Decision Records for the bootstrap system (15 ADRs covering core design decisions)

## Related Specification Types

- **Technical** (`../technical/`) - Detailed implementation specifications
- **Business** (`../business/`) - Business value and justification
- **Functional** (`../functional/`) - User-facing features and workflows
- **Testing** (`../testing/`) - Test strategies
- **Security** (`../security/`) - Security architecture and threat models
- **Operations** (`../operations/`) - Deployment and operational architecture

## Naming Convention

Architecture specifications should follow the pattern:
```
ybs-spec_<12-hex-guid>.md
```

Individual ADRs (if separated) can use:
```
adr-<number>-<slug>.md
```

Example: `adr-001-use-swift-for-bootstrap.md`

## ADR Format

Each ADR should include:
- Status (Proposed | Accepted | Deprecated | Superseded)
- Context and problem statement
- Decision drivers
- Considered options with pros/cons
- Decision outcome and rationale
- Consequences (positive and negative)
- Risks and mitigation
- Implementation notes
- Validation criteria

## When to Create an ADR

Create an ADR for:
- Major technology choices (language, framework, database)
- Architectural patterns (monolith vs microservices, event-driven vs request-response)
- Infrastructure decisions (cloud provider, deployment strategy)
- Significant trade-offs affecting multiple components
- Decisions that are hard to reverse

Don't create ADRs for:
- Small implementation details
- Routine technical choices
- Easily reversible decisions
- Personal coding preferences

---

**See also**: [Bootstrap Specifications Overview](../README.md)
