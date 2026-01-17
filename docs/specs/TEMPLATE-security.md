# Security Specification: [Feature Name]

**GUID**: [12-hex-guid]
**Version**: 0.1.0
**Status**: [Draft | Review | Approved | Implemented]
**Last Updated**: [YYYY-MM-DD]

## Overview

What security implications does this feature have?

## Security Requirements

### Authentication
- How does this feature authenticate users/systems?
- What authentication mechanisms are used?

### Authorization
- What permissions are required?
- How are access controls enforced?

### Data Protection
- What sensitive data is handled?
- How is data protected at rest?
- How is data protected in transit?

## Threat Model

### Assets
What needs protection?
1. **Asset 1**: Description, sensitivity level
2. **Asset 2**: Description, sensitivity level

### Threat Actors
Who might attack this?
- **Actor 1**: Motivation, capabilities
- **Actor 2**: Motivation, capabilities

### Attack Vectors
How could this be attacked?

#### Vector 1: [Attack Type]
- **Description**: How the attack works
- **Likelihood**: [Low | Medium | High]
- **Impact**: [Low | Medium | High]
- **Mitigation**: How we prevent/detect/respond

#### Vector 2: [Attack Type]
- **Description**: How the attack works
- **Likelihood**: [Low | Medium | High]
- **Impact**: [Low | Medium | High]
- **Mitigation**: How we prevent/detect/respond

## Vulnerabilities

### OWASP Top 10 Analysis

1. **Injection**: Applicable? Mitigation?
2. **Broken Authentication**: Applicable? Mitigation?
3. **Sensitive Data Exposure**: Applicable? Mitigation?
4. **XML External Entities**: Applicable? Mitigation?
5. **Broken Access Control**: Applicable? Mitigation?
6. **Security Misconfiguration**: Applicable? Mitigation?
7. **Cross-Site Scripting (XSS)**: Applicable? Mitigation?
8. **Insecure Deserialization**: Applicable? Mitigation?
9. **Using Components with Known Vulnerabilities**: Applicable? Mitigation?
10. **Insufficient Logging & Monitoring**: Applicable? Mitigation?

## Input Validation

What inputs need validation?
- **Input 1**: Validation rules, sanitization method
- **Input 2**: Validation rules, sanitization method

## Secrets Management

What secrets does this feature use?
- **Secret 1**: How stored, how accessed, rotation policy
- **Secret 2**: How stored, how accessed, rotation policy

## Cryptography

What cryptographic operations are performed?
- **Algorithm**: Which algorithm, why chosen
- **Key Management**: How keys are generated, stored, rotated
- **Randomness**: Source of entropy

## Audit & Logging

What security events are logged?
- Authentication attempts
- Authorization failures
- Data access
- Configuration changes
- [Other events]

**Log Format**: What information is captured
**Log Storage**: Where logs go, retention period
**Log Protection**: How logs are secured

## Incident Response

If this feature is compromised:
1. **Detection**: How to detect breach
2. **Containment**: Immediate actions
3. **Investigation**: What to analyze
4. **Recovery**: How to restore
5. **Lessons**: What to learn

## Compliance

Does this feature need to comply with:
- [ ] GDPR
- [ ] CCPA
- [ ] HIPAA
- [ ] PCI DSS
- [ ] SOC 2
- [ ] Other: [specify]

**Requirements**: What compliance requirements apply

## Security Testing

How should this be security tested?
- [ ] Static analysis (SAST)
- [ ] Dynamic analysis (DAST)
- [ ] Dependency scanning
- [ ] Penetration testing
- [ ] Code review
- [ ] Threat modeling session

## Security Checklist

Before release:
- [ ] All inputs validated
- [ ] All outputs encoded
- [ ] Authentication implemented
- [ ] Authorization enforced
- [ ] Secrets properly managed
- [ ] Crypto reviewed
- [ ] Logging implemented
- [ ] Security tests pass
- [ ] Code reviewed for security
- [ ] Threat model updated

## Related Specifications

- **Business**: `business/ybs-spec_[guid].md`
- **Functional**: `functional/ybs-spec_[guid].md`
- **Technical**: `technical/ybs-spec_[guid].md`
- **Testing**: `testing/ybs-spec_[guid].md`

---

**Security Review**: Required before production deployment
