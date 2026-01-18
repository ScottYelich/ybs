# Operations BASE Specification

**System**: [System Name]
**Version**: 1.0.0
**Last Updated**: [YYYY-MM-DD]

## Overview

This BASE spec defines **system-wide operations standards** including deployment infrastructure, monitoring, alerting, and runbooks.

## Infrastructure

### Environments

| Environment | Purpose | URL | Deployment |
|-------------|---------|-----|------------|
| Development | Local development | localhost | Manual |
| Staging | Pre-production testing | staging.example.com | Automatic on merge to `develop` |
| Production | Live system | example.com | Manual approval after staging |

### Infrastructure as Code

**Tool**: [Terraform | CloudFormation | Pulumi | Other]

**Repository**: [Link to infra repo]

**Policy**:
- All infrastructure defined as code
- Changes via pull requests
- Peer review required
- Version controlled

## Deployment

### Deployment Strategy

**Method**: [Rolling | Blue-Green | Canary]

**Rolling Deployment**:
1. Deploy to 10% of servers
2. Monitor for 15 minutes
3. If healthy, deploy to 50%
4. Monitor for 15 minutes
5. If healthy, deploy to 100%

**Rollback Criteria**:
- Error rate > 5%
- Response time > 2x baseline
- Health check failures
- Manual trigger

### Deployment Process

**Pre-Deployment Checklist**:
- [ ] All tests pass
- [ ] Code review approved
- [ ] Staging deployment successful
- [ ] Database migrations tested
- [ ] Rollback plan documented
- [ ] Stakeholders notified

**Deployment Steps**:
```bash
1. Backup database
2. Run database migrations
3. Deploy application code
4. Run smoke tests
5. Monitor metrics
6. Verify health checks
```

**Post-Deployment**:
- Monitor for 30 minutes
- Check error logs
- Verify key user workflows
- Update deployment log

### Rollback Procedure

**When to Rollback**:
- Critical bugs in production
- Performance degradation
- Security vulnerability
- Data corruption

**How to Rollback**:
```bash
1. Stop deployment
2. Revert to previous version
3. Roll back database migrations (if needed)
4. Clear caches
5. Verify system health
6. Notify stakeholders
```

**RTO** (Recovery Time Objective): < 15 minutes
**RPO** (Recovery Point Objective): < 5 minutes

## Monitoring

### Health Checks

**Endpoint**: `/health` or `/healthz`

**Check Frequency**: Every 30 seconds

**Response Format**:
```json
{
  "status": "healthy",
  "version": "1.2.3",
  "timestamp": "2026-01-17T16:30:00Z",
  "checks": {
    "database": "healthy",
    "cache": "healthy",
    "external_api": "degraded"
  }
}
```

**Status Codes**:
- 200: Healthy
- 503: Unhealthy

### Metrics

**Required Metrics**:

| Metric | Type | Description | Threshold |
|--------|------|-------------|-----------|
| Requests/sec | Counter | Total requests | N/A |
| Error rate | Gauge | % of requests with errors | > 1% |
| Response time (p50) | Histogram | Median response time | > 500ms |
| Response time (p99) | Histogram | 99th percentile response time | > 2s |
| CPU usage | Gauge | % CPU utilization | > 80% |
| Memory usage | Gauge | % Memory utilization | > 85% |
| Disk usage | Gauge | % Disk utilization | > 90% |
| Active connections | Gauge | Number of active connections | > 1000 |

**Metrics Collection**:
- Tool: [Prometheus | Datadog | New Relic | Other]
- Retention: 90 days (detailed), 1 year (aggregated)
- Dashboard: [Link to dashboard]

### Logging

**Log Levels**:
- **DEBUG**: Development only (verbose)
- **INFO**: Normal operations (default in production)
- **WARN**: Recoverable issues
- **ERROR**: Failures requiring attention
- **FATAL**: Critical failures

**Structured Logging Format**:
```json
{
  "timestamp": "2026-01-17T16:30:00.123Z",
  "level": "ERROR",
  "component": "PaymentProcessor",
  "message": "Payment processing failed",
  "context": {
    "userId": "user_123",
    "orderId": "order_456",
    "amount": 99.99,
    "currency": "USD"
  },
  "error": {
    "type": "PaymentGatewayError",
    "code": 4001,
    "message": "Insufficient funds"
  },
  "requestId": "req_abc123",
  "duration": 1250
}
```

**Log Aggregation**:
- Tool: [ELK Stack | Splunk | CloudWatch | Other]
- Retention: 30 days (all logs), 90 days (ERROR/FATAL)
- Access: Ops team + on-call engineers

**What to Log**:
- Request/response (sanitize sensitive data)
- Authentication events
- Authorization failures
- Errors and exceptions
- Performance metrics
- Configuration changes
- Deployment events

**What NOT to Log**:
- Passwords
- API keys
- Credit card numbers
- Personal Identifiable Information (PII) - unless required and encrypted

### Alerting

**Alert Channels**:
- PagerDuty (critical)
- Slack #alerts (warnings)
- Email (non-urgent)

**Alert Policies**:

| Alert | Condition | Severity | Channel | Response Time |
|-------|-----------|----------|---------|---------------|
| Service Down | Health check fails for 2 minutes | Critical | PagerDuty | Immediate |
| High Error Rate | Error rate > 5% for 5 minutes | Critical | PagerDuty | 15 minutes |
| High Response Time | P99 > 5s for 10 minutes | High | Slack + Page | 30 minutes |
| High CPU | CPU > 80% for 15 minutes | Medium | Slack | 1 hour |
| Disk Space Low | Disk > 90% | Medium | Slack | 4 hours |
| Certificate Expiring | SSL cert expires in 7 days | Medium | Email | 1 day |

**Alert Format**:
```
[CRITICAL] Service Down: Production API

Environment: Production
Service: api-server
Issue: Health check failing
Duration: 3 minutes
Runbook: https://wiki.example.com/runbooks/service-down

[View Logs] [View Metrics] [Acknowledge]
```

## On-Call Rotation

### On-Call Schedule

- **Rotation**: Weekly
- **Escalation**: After 15 minutes, escalate to next level
- **Compensation**: On-call pay + overtime for incidents

### On-Call Responsibilities

- Respond to alerts within SLA
- Follow runbooks for common issues
- Escalate when needed
- Document incidents
- Participate in post-mortems

### On-Call Handoff

Weekly handoff includes:
- Current issues
- Recent incidents
- Upcoming deployments
- Known risks

## Runbooks

### Standard Runbooks

1. **Service Down**: [Link]
2. **High Error Rate**: [Link]
3. **Database Connection Issues**: [Link]
4. **High Memory Usage**: [Link]
5. **SSL Certificate Renewal**: [Link]

### Runbook Template

```markdown
# Runbook: [Issue Name]

## Symptoms
- What the on-call person will observe
- Alert that triggers
- User-visible impact

## Diagnosis
1. Check [metric/log]
2. Verify [condition]
3. Review [dashboard]

## Resolution
1. Step-by-step fix
2. Commands to run
3. Expected output

## Verification
- How to confirm issue is resolved
- Metrics to check
- User workflow to test

## Prevention
- Why this happened
- How to prevent recurrence
- Follow-up tasks

## Escalation
- When to escalate
- Who to contact
- Additional resources
```

## Backups

### Backup Strategy

**Database**:
- Frequency: Daily (full), hourly (incremental)
- Retention: 30 days
- Location: Off-site (different region)
- Encryption: AES-256

**Files/Assets**:
- Frequency: Daily
- Retention: 30 days
- Location: Object storage (S3, GCS)

**Configuration**:
- Frequency: On every change (version controlled)
- Retention: Indefinite (in git)

### Backup Testing

- Test restore monthly
- Measure restore time
- Verify data integrity
- Document restore procedure

### Disaster Recovery

**RTO**: 4 hours (maximum downtime)
**RPO**: 1 hour (maximum data loss)

**DR Plan**:
1. Identify disaster
2. Activate DR site
3. Restore from backup
4. Redirect traffic
5. Verify functionality
6. Notify stakeholders

## Scaling

### Horizontal Scaling

**Auto-Scaling Rules**:
- Scale up: CPU > 70% for 5 minutes
- Scale down: CPU < 30% for 10 minutes
- Min instances: 2
- Max instances: 10
- Cool down: 5 minutes

### Vertical Scaling

**When to Scale Up**:
- Consistent high resource usage
- Performance degradation
- Approaching instance limits

**Process**:
1. Schedule maintenance window
2. Test new instance size in staging
3. Create snapshot/backup
4. Resize instance
5. Verify performance
6. Monitor for 24 hours

### Capacity Planning

**Review Quarterly**:
- Current resource usage
- Growth trends
- Peak load patterns
- Cost optimization opportunities

## Security Operations

### Security Monitoring

**Monitor For**:
- Failed authentication attempts
- Authorization failures
- Unusual traffic patterns
- DDoS attacks
- Data exfiltration attempts

**Response**:
- Alert security team
- Rate limit source
- Block malicious IPs
- Review logs
- Document incident

### Vulnerability Management

**Process**:
1. Scan for vulnerabilities (weekly)
2. Prioritize by severity
3. Patch critical issues (within 7 days)
4. Patch high issues (within 30 days)
5. Verify patches
6. Document remediation

### Security Incident Response

See: $ref:security/_BASE.md#incident-response

---

## Usage in Feature Specs

Feature specs reference this BASE spec:

```markdown
## Operations Requirements

**Extends**: $ref:operations/_BASE.md#monitoring

### Feature-Specific Monitoring
- New metric: [description]
- Alert condition: [threshold]

## Deployment Notes
[Special deployment considerations for this feature]
```

---

**Related BASE Specs**:
- `security/_BASE.md` - Security operations
- `technical/_BASE.md` - Logging standards
- `architecture/_BASE.md` - Infrastructure architecture
