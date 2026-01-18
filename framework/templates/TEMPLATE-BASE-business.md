# Business BASE Specification

**System**: [System Name]
**Version**: 1.0.0
**Last Updated**: [YYYY-MM-DD]

## Overview

This BASE spec defines **system-wide business context** including target users, success metrics framework, and business priorities.

## System Mission

**Purpose**: [What problem does this system solve?]

**Vision**: [What is the long-term goal?]

**Success Definition**: [How do we know if the system is successful?]

## Target Users

### Primary Users
- **[User Persona 1]**: [Description, goals, pain points]
- **[User Persona 2]**: [Description, goals, pain points]

### Secondary Users
- **[User Persona 3]**: [Description, goals, pain points]

### User Characteristics
- **Technical proficiency**: [Beginner | Intermediate | Advanced]
- **Domain knowledge**: [Description]
- **Device usage**: [Desktop | Mobile | Both]
- **Accessibility needs**: [Description]

## Success Metrics Framework

### North Star Metric
**[Primary metric that indicates overall success]**

Example: Daily Active Users, Revenue, User Satisfaction Score

### Supporting Metrics

| Category | Metric | Target | Measurement |
|----------|--------|--------|-------------|
| Engagement | Daily Active Users | [Value] | [How measured] |
| Performance | Task Completion Rate | [Value] | [How measured] |
| Quality | Error Rate | [Value] | [How measured] |
| Business | Revenue/Cost Savings | [Value] | [How measured] |

### Feature Prioritization Framework

**Priority Levels**:
1. **Critical**: System cannot function without this
2. **High**: Significant user value, urgent business need
3. **Medium**: Important but not urgent
4. **Low**: Nice-to-have, future consideration

**Evaluation Criteria**:
- User impact (how many users affected?)
- Business value (revenue, cost savings, strategic importance)
- Technical complexity (effort required)
- Dependencies (what else needs this?)

## Business Constraints

### Budget
- Development budget: [Amount]
- Operational budget: [Amount]
- Cost per user target: [Amount]

### Timeline
- Launch target: [Date]
- Key milestones: [List]

### Resources
- Team size: [Number]
- Required skills: [List]
- External dependencies: [List]

## Regulatory & Compliance

### Required Compliance
- [ ] GDPR (EU users)
- [ ] CCPA (California users)
- [ ] WCAG 2.1 AA (Accessibility)
- [ ] [Other regulations]

### Data Governance
- Data retention policy: [Duration]
- Data deletion process: [Description]
- Privacy policy: [Link]

## Stakeholders

| Role | Name/Team | Interest | Influence |
|------|-----------|----------|-----------|
| Executive Sponsor | [Name] | [Interest] | High |
| Product Owner | [Name] | [Interest] | High |
| End Users | [Group] | [Interest] | Medium |
| Operations | [Team] | [Interest] | Medium |

## Competitive Landscape

### Direct Competitors
- **[Competitor 1]**: [Strengths, weaknesses, market share]
- **[Competitor 2]**: [Strengths, weaknesses, market share]

### Differentiation
What makes this system unique:
1. [Differentiator 1]
2. [Differentiator 2]
3. [Differentiator 3]

## Risk Management

### Business Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | [L/M/H] | [L/M/H] | [Strategy] |
| [Risk 2] | [L/M/H] | [L/M/H] | [Strategy] |

---

## Usage in Feature Specs

Feature specs reference this BASE spec:

```markdown
## Business Value

**Target Users**: $ref:business/_BASE.md#target-users

### Specific User Segment
This feature specifically targets [subset of users]

## Success Metrics

**Extends**: $ref:business/_BASE.md#success-metrics-framework

### Feature-Specific Metrics
- [Metric 1]: [Target]
- [Metric 2]: [Target]
```

---

**Related BASE Specs**:
- `functional/_BASE.md` - UX patterns
- `architecture/_BASE.md` - System strategy
