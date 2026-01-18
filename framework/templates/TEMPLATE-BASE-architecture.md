# Architecture BASE Specification

**System**: [System Name]
**Version**: 1.0.0
**Last Updated**: [YYYY-MM-DD]

## Overview

This BASE spec defines **system-wide architectural principles**, patterns, and decisions that guide all feature development.

## Architectural Principles

### 1. Simplicity First
- Start with the simplest solution that works
- Add complexity only when necessary
- Prefer boring, proven technology over new and exciting
- Delete code rather than comment it out

### 2. Modularity
- Break system into independent, loosely coupled components
- Each component has a single, well-defined responsibility
- Components communicate through defined interfaces
- Easy to replace or upgrade individual components

### 3. Testability
- Design for testability from the start
- Inject dependencies (don't use globals)
- Separate business logic from framework code
- Mock external dependencies

### 4. Performance
- Design for performance, optimize when measured
- Set performance budgets (response time, payload size)
- Use caching strategically
- Optimize the critical path

### 5. Security by Design
- Secure by default
- Validate all inputs
- Fail securely
- Principle of least privilege

### 6. Scalability
- Design for horizontal scaling
- Stateless application servers
- Shared state in database/cache
- Use async processing for heavy work

### 7. Observability
- Log meaningful events
- Track key metrics
- Distributed tracing
- Make debugging easy

### 8. Resilience
- Expect failures, design for them
- Use timeouts and retries
- Circuit breakers for external dependencies
- Graceful degradation

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────┐
│                     Clients                          │
│  (Web Browser, Mobile App, API Consumer)            │
└──────────────────┬──────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────┐
│              Load Balancer / CDN                     │
└──────────────────┬──────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────┐
│             Application Servers                      │
│        (Horizontally Scalable)                       │
└───────┬────────────────────────────┬─────────────────┘
        │                            │
        ↓                            ↓
┌──────────────────┐       ┌──────────────────┐
│    Database      │       │   Cache Layer    │
│  (Primary)       │←──────│   (Redis)        │
│   + Replicas     │       └──────────────────┘
└──────────────────┘                 │
        │                            │
        ↓                            ↓
┌──────────────────────────────────────────────────────┐
│           External Services / APIs                    │
└──────────────────────────────────────────────────────┘
```

### Technology Stack

| Layer | Technology | Justification |
|-------|------------|---------------|
| Frontend | [Framework] | [Why chosen] |
| Backend | [Language/Framework] | [Why chosen] |
| Database | [DBMS] | [Why chosen] |
| Cache | [Cache system] | [Why chosen] |
| Queue | [Queue system] | [Why chosen] |
| Search | [Search engine] | [Why chosen] |

## Architectural Patterns

### 1. Layered Architecture

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│  (Controllers, Views, API)          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Business Logic Layer           │
│  (Services, Domain Models)          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Data Access Layer              │
│  (Repositories, DAOs)               │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Database                    │
└─────────────────────────────────────┘
```

**Rules**:
- Each layer only depends on the layer below
- Business logic independent of presentation
- Data access abstracted behind repositories

### 2. Dependency Injection

**Use DI for**:
- External services
- Database connections
- Configuration
- Logging

**Benefits**:
- Easier testing (mock dependencies)
- Loose coupling
- Configuration flexibility

### 3. Repository Pattern

**Purpose**: Abstract data access

```
interface UserRepository {
    findById(id: string): User | null
    findByEmail(email: string): User | null
    save(user: User): void
    delete(id: string): void
}

class DatabaseUserRepository implements UserRepository {
    // Implementation using database
}

class MockUserRepository implements UserRepository {
    // Implementation for testing
}
```

### 4. Service Layer Pattern

**Purpose**: Encapsulate business logic

```
class UserService {
    constructor(
        private userRepo: UserRepository,
        private emailService: EmailService
    ) {}

    async registerUser(data: RegistrationData): Promise<User> {
        // Business logic here
        // - Validate input
        // - Check if user exists
        // - Hash password
        // - Save user
        // - Send welcome email
        // - Return user
    }
}
```

### 5. API Design Pattern

**Style**: RESTful API

**Conventions**:
- Use nouns for resources (`/users`, not `/getUsers`)
- Use HTTP verbs correctly (GET, POST, PUT, PATCH, DELETE)
- Use plural nouns (`/users/123`, not `/user/123`)
- Nest resources for relationships (`/users/123/posts`)
- Version APIs (`/api/v1/users`)

**Response Format**:
```json
{
  "data": { /* resource */ },
  "meta": {
    "requestId": "req_abc123",
    "timestamp": "2026-01-17T16:30:00Z"
  }
}
```

**Error Format**:
```json
{
  "error": {
    "code": 2001,
    "message": "Validation failed",
    "details": [ /* field errors */ ]
  }
}
```

### 6. Event-Driven Architecture

**When to Use**:
- Async operations (email, notifications)
- Decoupled communication
- Audit trail

**Pattern**:
```
Service A → Publish Event → Event Bus → Subscribe → Service B
```

### 7. Caching Strategy

**Cache Levels**:
1. **Browser Cache**: Static assets (CSS, JS, images)
2. **CDN**: Geographically distributed content
3. **Application Cache**: Frequently accessed data (Redis)
4. **Database Cache**: Query result caching

**Cache Invalidation**:
- Time-based (TTL)
- Event-based (on update)
- Manual (cache clear API)

## Data Architecture

### Database Schema Design

**Principles**:
- Normalize to 3NF (eliminate redundancy)
- Denormalize for performance (when measured)
- Use foreign keys for referential integrity
- Index frequently queried columns
- Use UUIDs for public IDs (not sequential integers)

### Data Migration Strategy

**Process**:
1. Write migration (up + down)
2. Test in development
3. Review migration (destructive changes?)
4. Test on copy of production data
5. Run in staging
6. Run in production during low-traffic window
7. Verify data integrity

### Data Retention Policy

| Data Type | Retention | Deletion Method |
|-----------|-----------|-----------------|
| User data | Until account deleted + 30 days | Soft delete, then hard delete |
| Logs | 30 days (all), 90 days (errors) | Automated deletion |
| Backups | 30 days | Automated deletion |
| Analytics | 1 year (aggregated) | Aggregation + deletion |

## Security Architecture

See: $ref:security/_BASE.md

**Key Architectural Decisions**:
- Authentication: Token-based (JWT)
- Authorization: RBAC
- Encryption: TLS 1.3+ in transit, AES-256 at rest
- Secrets: Environment variables + vault

## Quality Attributes

### Performance Targets

| Metric | Target | Measured How |
|--------|--------|--------------|
| Page Load Time | < 2s | Lighthouse |
| API Response Time | < 500ms | APM tool |
| Database Query Time | < 100ms | Query logs |

### Availability Targets

**SLA**: 99.9% uptime (8.76 hours downtime per year)

**Strategies**:
- Load balancing (multi-instance)
- Database replication (read replicas)
- Automated failover
- Health checks and monitoring

### Scalability Limits

| Resource | Current | Max Capacity | Scale Strategy |
|----------|---------|--------------|----------------|
| Users | [Current] | [Max] | Horizontal scaling |
| Requests/sec | [Current] | [Max] | Load balancing |
| Storage | [Current] | [Max] | Vertical + archival |

## Technology Decisions

### ADR Template

Use this template for significant architectural decisions:

```markdown
# ADR [NUMBER]: [Title]

**Date**: [YYYY-MM-DD]
**Status**: [Proposed | Accepted | Deprecated | Superseded]
**Deciders**: [List of people involved]

## Context
What situation requires a decision?

## Decision
What did we decide?

## Rationale
Why did we decide this?

## Alternatives Considered
1. **Alternative 1**: Why not chosen
2. **Alternative 2**: Why not chosen

## Consequences
**Benefits**: What we gain
**Costs**: What we lose
**Risks**: What could go wrong

## Implementation Notes
How to implement this decision
```

### Key ADRs

1. **ADR-001: Choose [Language/Framework]**
   - Status: Accepted
   - Decision: Use [technology]
   - Rationale: [reasons]

2. **ADR-002: Database Selection**
   - Status: Accepted
   - Decision: Use [database]
   - Rationale: [reasons]

## Evolution & Technical Debt

### Roadmap

**Phase 1** (Current - [Date]):
- [Current features]

**Phase 2** ([Date] - [Date]):
- [Planned features]

**Phase 3** ([Date]+):
- [Future vision]

### Known Technical Debt

| Debt Item | Impact | Priority | Plan to Address |
|-----------|--------|----------|-----------------|
| [Item 1] | [Impact] | [Priority] | [When/How] |
| [Item 2] | [Impact] | [Priority] | [When/How] |

**Debt Servicing**:
- Allocate 20% of sprint capacity to tech debt
- Track debt in backlog
- Review quarterly

---

## Usage in Feature Specs

Feature specs reference this BASE spec:

```markdown
## Architecture

**Extends**: $ref:architecture/_BASE.md#architectural-patterns

### Feature Architecture
[Feature-specific architecture diagram]

### Architectural Decisions
**ADR-XXX**: [Decision specific to this feature]
```

---

**Related BASE Specs**:
- `technical/_BASE.md` - Technical standards
- `security/_BASE.md` - Security architecture
- `operations/_BASE.md` - Infrastructure
