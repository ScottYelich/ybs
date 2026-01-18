# Security BASE Specification

**System**: [System Name]
**Version**: 1.0.0
**Last Updated**: [YYYY-MM-DD]

## Overview

This BASE spec defines **system-wide security model** including authentication, authorization, encryption standards, and threat model.

## Security Model

### Security Principles

1. **Defense in Depth**: Multiple layers of security
2. **Least Privilege**: Minimum access required
3. **Fail Secure**: Failures default to deny access
4. **Separation of Duties**: No single point of compromise
5. **Auditability**: All security events logged

## Authentication

### Authentication Methods

**Primary**: [JWT tokens | OAuth 2.0 | Other]

**Token Lifecycle**:
- Access token expiration: 1 hour
- Refresh token expiration: 30 days
- Token rotation: On refresh
- Token revocation: Immediate (check blacklist)

### Multi-Factor Authentication (MFA)

**Supported Methods**:
- TOTP (Time-based One-Time Password)
- SMS (optional, less secure)
- Hardware keys (FIDO2/WebAuthn)

**Policy**:
- Optional for regular users
- Required for admin users
- Required for sensitive operations

### Password Requirements

**Minimum Requirements**:
- Length: 12 characters
- Complexity: Mix of uppercase, lowercase, numbers, symbols
- No common passwords (check against breach database)
- No personal info (name, email, birthdate)

**Password Storage**:
- Algorithm: bcrypt
- Cost factor: 12
- Salt: Per-password (automatic with bcrypt)

### Session Management

- Session timeout: 1 hour of inactivity
- Concurrent sessions: Allowed (track all sessions)
- Logout: Invalidate token immediately
- Remember me: Extended refresh token (90 days)

## Authorization

### Access Control Model

**Model**: Role-Based Access Control (RBAC)

**Roles**:
| Role | Permissions | Description |
|------|-------------|-------------|
| Admin | All | Full system access |
| User | Read, Write | Standard user access |
| Guest | Read | Limited read-only access |

### Permission Checking

**Always check**:
- On every API request
- Before displaying UI elements
- Before database operations
- On client AND server

**Never trust client**:
- Client-side checks are UX only
- Always enforce on server

## Encryption

### Data at Rest

**Encryption Standard**: AES-256-GCM

**What to Encrypt**:
- User credentials
- Personal Identifiable Information (PII)
- Payment information
- Sensitive business data

**Key Management**:
- Store keys in secure vault (AWS KMS, HashiCorp Vault)
- Rotate keys annually
- Use separate keys per environment (dev/staging/prod)

### Data in Transit

**Encryption Standard**: TLS 1.3+

**Requirements**:
- All API traffic over HTTPS
- Valid SSL certificate (no self-signed in production)
- HTTP Strict Transport Security (HSTS) enabled
- Certificate pinning (mobile apps)

### End-to-End Encryption

**Use When**: User-to-user sensitive data (messages, files)

**Implementation**:
- Client-side encryption/decryption
- Server never sees plaintext
- Key exchange: Diffie-Hellman or similar

## Secrets Management

### Secrets Policy

**Never**:
- Commit secrets to version control
- Log secrets
- Display secrets in error messages
- Store secrets in code

**Always**:
- Use environment variables or vault
- Rotate secrets regularly (90 days)
- Use different secrets per environment
- Audit secret access

### Secret Types

| Type | Storage | Rotation | Access |
|------|---------|----------|--------|
| API Keys | Vault | 90 days | Service accounts only |
| Database Passwords | Vault | 90 days | App + DBA |
| Encryption Keys | HSM/KMS | 365 days | App only |
| Certificates | Cert store | 365 days | Public |

## Input Validation

### Validation Rules

**Always Validate**:
- On server (never trust client)
- Before database operations
- Before external API calls
- Before file operations

**Validation Types**:
- Type checking (string, number, boolean)
- Format checking (email, URL, phone)
- Range checking (min/max values)
- Whitelist checking (allowed values)

### Sanitization

**Output Encoding**:
- HTML: Encode `<`, `>`, `&`, `"`, `'`
- JavaScript: Use JSON.stringify
- SQL: Use parameterized queries
- URLs: Use URL encoding

**Never**:
- Use string concatenation for SQL
- Use eval() with user input
- Trust user input in HTML

## Common Vulnerabilities (OWASP Top 10)

### 1. Injection (SQL, NoSQL, Command)

**Prevention**:
- Use parameterized queries
- Use ORM/query builder
- Validate and sanitize input
- Principle of least privilege (database user)

### 2. Broken Authentication

**Prevention**:
- Implement MFA
- Rate limit login attempts
- Use strong password policy
- Secure session management

### 3. Sensitive Data Exposure

**Prevention**:
- Encrypt data at rest and in transit
- Don't log sensitive data
- Use HTTPS everywhere
- Implement proper access controls

### 4. XML External Entities (XXE)

**Prevention**:
- Disable XML external entity processing
- Use JSON instead of XML where possible
- Validate and sanitize XML input

### 5. Broken Access Control

**Prevention**:
- Deny by default
- Check permissions on every request
- Don't expose object IDs (use UUIDs)
- Test authorization thoroughly

### 6. Security Misconfiguration

**Prevention**:
- Harden configurations
- Disable unnecessary features
- Keep software updated
- Use security headers

### 7. Cross-Site Scripting (XSS)

**Prevention**:
- Encode output
- Use Content Security Policy (CSP)
- Sanitize user input
- Use frameworks with auto-escaping

### 8. Insecure Deserialization

**Prevention**:
- Avoid deserializing untrusted data
- Use JSON over native serialization
- Validate deserialized objects
- Implement integrity checks

### 9. Using Components with Known Vulnerabilities

**Prevention**:
- Keep dependencies updated
- Monitor security advisories
- Run security scanners (npm audit, etc.)
- Remove unused dependencies

### 10. Insufficient Logging & Monitoring

**Prevention**:
- Log all authentication events
- Log all authorization failures
- Monitor for anomalies
- Alert on security events

## Security Headers

### Required HTTP Headers

```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
Content-Security-Policy: default-src 'self'
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

## Rate Limiting

### Rate Limit Policies

| Endpoint Type | Limit | Window | Response |
|---------------|-------|--------|----------|
| Authentication | 5 attempts | 15 minutes | 429 Too Many Requests |
| API (authenticated) | 100 requests | 1 minute | 429 with Retry-After |
| API (unauthenticated) | 10 requests | 1 minute | 429 with Retry-After |
| File upload | 10 uploads | 1 hour | 429 with quota info |

### Rate Limit Headers

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 87
X-RateLimit-Reset: 1642528800
Retry-After: 60
```

## Audit Logging

### What to Log

**Always Log**:
- Authentication attempts (success/failure)
- Authorization failures
- Data access (who accessed what, when)
- Configuration changes
- Privilege escalations
- Security events (suspicious activity)

### Log Format

```json
{
  "timestamp": "2026-01-17T16:30:00.000Z",
  "level": "SECURITY",
  "event": "authentication_failure",
  "user": "user@example.com",
  "ip": "192.168.1.100",
  "reason": "invalid_password",
  "attempts": 3
}
```

### Log Protection

- Encrypt sensitive logs
- Restrict log access (admin only)
- Retain logs for [duration] (e.g., 1 year)
- Backup logs off-site
- Monitor for log tampering

## Incident Response

### Incident Response Plan

1. **Detection**: Identify security incident
2. **Containment**: Limit damage, isolate affected systems
3. **Eradication**: Remove threat, patch vulnerabilities
4. **Recovery**: Restore services, verify security
5. **Lessons Learned**: Document incident, improve defenses

### Security Contacts

| Role | Contact | Responsibility |
|------|---------|----------------|
| Security Lead | [Email] | Coordinate response |
| DevOps Lead | [Email] | Infrastructure security |
| Legal | [Email] | Legal/compliance issues |

### Breach Notification

- Notify affected users within 72 hours (GDPR)
- Document breach details
- Report to authorities if required
- Offer remediation (credit monitoring, etc.)

---

## Usage in Feature Specs

Feature specs reference this BASE spec:

```markdown
## Security Requirements

**Extends**: $ref:security/_BASE.md#authentication

### Feature-Specific Security
- Requires MFA for this operation
- Additional authorization check: [description]
- Sensitive data encryption: [fields]
```

---

**Related BASE Specs**:
- `technical/_BASE.md` - Error handling, logging
- `operations/_BASE.md` - Security monitoring
- `testing/_BASE.md` - Security testing
