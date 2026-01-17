# ADR-###: [Decision Title]

**Status**: [Proposed | Accepted | Deprecated | Superseded]
**Date**: [YYYY-MM-DD]
**Decision Makers**: [Names or roles]
**GUID**: [12-hex-guid]

---

## Context and Problem Statement

[Describe the context and problem statement in free form. What is the issue we're facing that motivates this decision? What are the forces at play?]

**Key questions**:
- What problem are we trying to solve?
- Why does this problem exist?
- What constraints do we have?
- What are the business/technical drivers?

---

## Decision Drivers

[List the factors that influence this decision]

- **Driver 1**: [Description] (Priority: [High/Medium/Low])
- **Driver 2**: [Description] (Priority: [High/Medium/Low])
- **Driver 3**: [Description] (Priority: [High/Medium/Low])

**Common drivers**:
- Performance requirements
- Security concerns
- Development speed
- Maintainability
- Team expertise
- Cost constraints
- User experience
- Scalability needs

---

## Considered Options

### Option 1: [Option Name]

**Description**: [Describe this option]

**Pros**:
- ✅ Pro 1: [Advantage]
- ✅ Pro 2: [Advantage]
- ✅ Pro 3: [Advantage]

**Cons**:
- ❌ Con 1: [Disadvantage]
- ❌ Con 2: [Disadvantage]

**Trade-offs**:
- [Trade-off 1]
- [Trade-off 2]

**Examples/References**: [Links to similar implementations, documentation, etc.]

---

### Option 2: [Option Name]

**Description**: [Describe this option]

**Pros**:
- ✅ Pro 1: [Advantage]
- ✅ Pro 2: [Advantage]

**Cons**:
- ❌ Con 1: [Disadvantage]
- ❌ Con 2: [Disadvantage]

**Trade-offs**:
- [Trade-off 1]
- [Trade-off 2]

**Examples/References**: [Links]

---

### Option 3: [Option Name]

**Description**: [Describe this option]

**Pros**:
- ✅ Pro 1: [Advantage]
- ✅ Pro 2: [Advantage]

**Cons**:
- ❌ Con 1: [Disadvantage]
- ❌ Con 2: [Disadvantage]

**Trade-offs**:
- [Trade-off 1]

**Examples/References**: [Links]

---

## Decision Outcome

**Chosen option**: [Option Name]

**Rationale**: [Explain why this option was chosen over the others. Address the decision drivers and how this option satisfies them better than alternatives.]

**Implementation details**:
- [Detail 1 about how to implement]
- [Detail 2 about how to implement]
- [Detail 3 about how to implement]

---

## Consequences

### Positive Consequences

- ✅ Benefit 1: [What we gain]
- ✅ Benefit 2: [What we gain]
- ✅ Benefit 3: [What we gain]

### Negative Consequences

- ❌ Cost 1: [What we lose or must accept]
- ❌ Cost 2: [Technical debt or limitations]

### Mitigations

[If there are negative consequences, how can we mitigate them?]

- **Negative 1**: Mitigated by [action/approach]
- **Negative 2**: Accepted because [reason]

---

## Risks and Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | [High/Medium/Low] | [High/Medium/Low] | [How to mitigate] |
| [Risk 2] | [High/Medium/Low] | [High/Medium/Low] | [How to mitigate] |

---

## Implementation Notes

### Files/Components Affected

- Component 1: [How it's affected]
- Component 2: [How it's affected]
- Config: [Changes needed]

### Dependencies

[What needs to be in place before implementing this decision?]

- Dependency 1: [Description]
- Dependency 2: [Description]

### Migration Plan

[If this replaces existing functionality]

1. [Step 1: Preparation]
2. [Step 2: Implementation]
3. [Step 3: Migration]
4. [Step 4: Cleanup]

---

## Validation

### Success Criteria

[How will we know this decision was successful?]

- [ ] Criterion 1: [Measurable outcome]
- [ ] Criterion 2: [Measurable outcome]
- [ ] Criterion 3: [Measurable outcome]

### Metrics

[What metrics will we track to validate this decision?]

- **Metric 1**: [What to measure] - Target: [value]
- **Metric 2**: [What to measure] - Target: [value]

### Review Date

**Next review**: [YYYY-MM-DD]

[When should we revisit this decision to evaluate if it's still appropriate?]

---

## Alternatives Not Chosen

### Why [Option 2] was not chosen

[Specific reasons this option was rejected]

- Reason 1
- Reason 2

### Why [Option 3] was not chosen

[Specific reasons this option was rejected]

- Reason 1
- Reason 2

---

## Related Decisions

- **ADR-###**: [Related decision title] - [How it relates]
- **ADR-###**: [Related decision title] - [How it relates]

**Supersedes**: [ADR-### if this replaces a previous decision]

**Superseded by**: [ADR-### if this decision has been replaced]

---

## References

- [Link 1: Relevant documentation]
- [Link 2: Research/article]
- [Link 3: Prior art/examples]
- [Link 4: Specifications]

---

## Notes and Discussion

[Additional context, discussion points, or notes that don't fit elsewhere]

---

## Approval

| Role | Name | Date | Decision |
|------|------|------|----------|
| Architect | [Name] | [Date] | [Approve/Reject] |
| Tech Lead | [Name] | [Date] | [Approve/Reject] |
| Stakeholder | [Name] | [Date] | [Approve/Reject] |

---

## Version History

### [YYYY-MM-DD] - Status: [Status]
- [Change description]

### [YYYY-MM-DD] - Status: Proposed
- Initial proposal

---

## Template Usage Notes

**ADR (Architectural Decision Record)** documents significant architectural decisions, their context, and consequences.

**When to use**:
- Major technology choices (language, framework, database)
- Architectural patterns (monolith vs microservices, REST vs GraphQL)
- Infrastructure decisions (cloud provider, deployment strategy)
- Significant trade-offs affecting multiple components

**When NOT to use**:
- Small implementation details
- Routine technical choices
- Decisions easily reversible
- Personal coding preferences

**Numbering**:
- Use sequential numbers: ADR-001, ADR-002, etc.
- Or use GUID for global uniqueness
- Maintain an index of all ADRs

**Status lifecycle**:
1. **Proposed**: Under discussion
2. **Accepted**: Approved and being/has been implemented
3. **Deprecated**: No longer recommended but not yet replaced
4. **Superseded**: Replaced by a newer decision (link to it)

**Tips**:
- Be concise but thorough
- Focus on "why" more than "what"
- Document options you considered (not just the winner)
- Include concrete examples
- Make consequences explicit
- Link to related specifications
- Update status as situation changes

**Related templates**:
- [Specification Template](spec-template.md) - For detailed feature specs
- [Technical Specification](TEMPLATE-technical.md) - For implementation details

---

**Format inspired by**: [MADR](https://adr.github.io/madr/), [Michael Nygard's ADR](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions)

**Template Version**: 0.1.0
**Created**: 2026-01-17
