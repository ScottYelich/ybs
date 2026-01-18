# Technical BASE Specification

**System**: [System Name]
**Version**: 1.0.0
**Last Updated**: [YYYY-MM-DD]

## Overview

This BASE spec defines **system-wide technical standards** that apply to all features unless explicitly overridden.

## Design Tokens (UI)

### Colors

```json
{
  "color": {
    "primary": "#007AFF",
    "secondary": "#5856D6",
    "background": {
      "primary": "#FFFFFF",
      "secondary": "#F2F2F7"
    },
    "text": {
      "primary": "#000000",
      "secondary": "#3C3C43",
      "tertiary": "#3C3C4399"
    },
    "semantic": {
      "success": "#34C759",
      "warning": "#FF9500",
      "error": "#FF3B30",
      "info": "#007AFF"
    }
  }
}
```

### Typography

```json
{
  "typography": {
    "fontFamily": {
      "primary": "System",
      "monospace": "SF Mono"
    },
    "fontSize": {
      "xs": "11px",
      "sm": "13px",
      "base": "15px",
      "lg": "17px",
      "xl": "20px",
      "2xl": "24px",
      "3xl": "28px"
    },
    "fontWeight": {
      "regular": "400",
      "medium": "500",
      "semibold": "600",
      "bold": "700"
    },
    "lineHeight": {
      "tight": "1.2",
      "normal": "1.5",
      "relaxed": "1.75"
    }
  }
}
```

### Spacing

```json
{
  "spacing": {
    "xs": "4px",
    "sm": "8px",
    "md": "16px",
    "lg": "24px",
    "xl": "32px",
    "2xl": "48px"
  }
}
```

### Platform-Specific Guidelines

#### SwiftUI
- Use native controls when possible
- Follow Apple HIG (Human Interface Guidelines)
- Use SF Symbols for icons
- Support Dynamic Type
- Support Dark Mode

#### Web (React/HTML)
- Use semantic HTML
- Support responsive breakpoints: 320px, 768px, 1024px, 1440px
- Use CSS Grid/Flexbox for layouts
- Follow WCAG 2.1 Level AA

## Error Handling Standards

### Error Code Ranges

| Range | Category | Description |
|-------|----------|-------------|
| 1000-1999 | System Errors | Infrastructure, environment, dependencies |
| 2000-2999 | Validation Errors | User input validation, format errors |
| 3000-3999 | Business Logic Errors | Rule violations, state conflicts |
| 4000-4999 | Integration Errors | External API, service failures |
| 5000-5999 | Security Errors | Auth failures, permission denied |
| 9000-9999 | Unknown Errors | Unexpected failures, uncaught exceptions |

### Error Message Templates

```markdown
**User-Facing**:
[Action] failed: [Reason]. [Recovery suggestion]

Example: "Save failed: File is read-only. Try saving to a different location."

**Internal/Log**:
[ErrorCode] [Component].[Operation]: [Detail] | Context: [JSON]

Example: "2001 ConfigParser.load: Invalid JSON at line 42 | Context: {file: config.json, user: scott}"
```

### Error Response Format

```json
{
  "error": {
    "code": 2001,
    "message": "Validation failed: Email format is invalid",
    "details": {
      "field": "email",
      "value": "notanemail",
      "constraint": "RFC 5322 format"
    },
    "recovery": "Please enter a valid email address (e.g., user@example.com)",
    "timestamp": "2026-01-17T16:30:00Z",
    "requestId": "req_abc123"
  }
}
```

### Retry Strategies

| Error Category | Retry? | Max Attempts | Backoff |
|----------------|--------|--------------|---------|
| Network timeout | Yes | 3 | Exponential (1s, 2s, 4s) |
| Rate limit | Yes | 5 | Linear (60s intervals) |
| Validation | No | 0 | N/A |
| Auth failure | No | 0 | N/A |
| Server error (5xx) | Yes | 3 | Exponential (2s, 4s, 8s) |

## Internationalization (i18n) Framework

### Supported Languages

- **Default**: en-US (English, United States)
- **Supported**:
  - en-GB (English, UK)
  - es-ES (Spanish, Spain)
  - fr-FR (French, France)
  - de-DE (German, Germany)
  - ja-JP (Japanese, Japan)

### String Management

**Format**: Use ICU MessageFormat for all localized strings

```json
{
  "welcome.message": "Welcome, {name}!",
  "item.count": "{count, plural, =0 {No items} one {1 item} other {# items}}",
  "date.format": "{date, date, medium}"
}
```

**File structure**:
```
locales/
├── en-US.json
├── es-ES.json
├── fr-FR.json
└── ja-JP.json
```

### Date/Time Formatting

- Use ISO 8601 for storage: `2026-01-17T16:30:00Z`
- Use locale-aware formatting for display
- Always store in UTC, display in user's timezone

**Examples**:
- en-US: "January 17, 2026 at 4:30 PM"
- en-GB: "17 January 2026 at 16:30"
- ja-JP: "2026年1月17日 16:30"

### Number Formatting

```json
{
  "en-US": {
    "decimal": ".",
    "thousands": ",",
    "currency": "$#,##0.00"
  },
  "de-DE": {
    "decimal": ",",
    "thousands": ".",
    "currency": "#.##0,00 €"
  }
}
```

### Right-to-Left (RTL) Support

- Support RTL languages (Arabic, Hebrew) if needed
- Use logical properties (start/end instead of left/right)
- Mirror UI layouts appropriately

## Data Formats

### API Request/Response

- **Format**: JSON
- **Content-Type**: `application/json`
- **Character Encoding**: UTF-8

### Date/Time
- **Storage**: ISO 8601 in UTC
- **API**: ISO 8601 strings
- **Display**: Locale-aware formatting

### File Formats
- **Configuration**: JSON (with comments via JSON5 if needed)
- **Data Exchange**: JSON or CSV
- **Logs**: Structured JSON

## Performance Standards

### Response Time Targets

| Operation Type | Target | Maximum |
|----------------|--------|---------|
| UI Interaction | < 100ms | 300ms |
| API Request | < 500ms | 2s |
| Background Job | N/A | 30s |
| Batch Process | N/A | 5min |

### Resource Limits

- **Memory**: < 500MB per process
- **CPU**: < 50% sustained
- **Storage**: Log file rotation at 100MB

## Security Standards

### Authentication
- Use secure token-based authentication
- Tokens expire after 1 hour (access) / 30 days (refresh)
- Support MFA (Multi-Factor Authentication)

### Encryption
- **At Rest**: AES-256
- **In Transit**: TLS 1.3+
- **Passwords**: bcrypt (cost factor 12)

### Secrets Management
- NEVER commit secrets to version control
- Use environment variables or secure vault
- Rotate secrets every 90 days

## Logging Standards

### Log Levels

- **DEBUG**: Development only, verbose details
- **INFO**: Normal operations, significant events
- **WARN**: Recoverable issues, degraded performance
- **ERROR**: Failures requiring attention
- **FATAL**: Critical failures, system shutdown

### Log Format

```json
{
  "timestamp": "2026-01-17T16:30:00.123Z",
  "level": "INFO",
  "component": "ComponentName",
  "message": "Operation completed successfully",
  "context": {
    "userId": "user_123",
    "requestId": "req_abc123"
  },
  "duration": 145
}
```

## Testing Standards

### Code Coverage
- **Target**: 80% line coverage
- **Minimum**: 70% line coverage
- **Critical paths**: 100% coverage required

### Test Naming Convention

```
test_[functionality]_[scenario]_[expectedResult]

Examples:
- test_login_validCredentials_returnsToken
- test_saveFile_readOnlyDirectory_throwsError
```

## Configuration Standards

### Configuration File Format

```json
{
  "version": "1.0.0",
  "environment": "production",
  "feature": {
    "enabled": true,
    "option": "value"
  }
}
```

### Environment Variables

**Naming**: UPPERCASE_SNAKE_CASE

Examples:
- `DATABASE_URL`
- `API_KEY`
- `LOG_LEVEL`

## Dependencies

### Version Management
- Use semantic versioning (semver)
- Lock dependency versions in production
- Review security advisories monthly

### Approved Libraries

| Purpose | Library | Version | Notes |
|---------|---------|---------|-------|
| HTTP Client | [Library] | [Version] | [Notes] |
| JSON Parser | [Library] | [Version] | [Notes] |
| Date/Time | [Library] | [Version] | [Notes] |

---

## Usage in Feature Specs

Feature specs reference this BASE spec:

```markdown
## Design Tokens

**Extends**: $ref:technical/_BASE.md#design-tokens

### Overrides
- Primary color: #FF6B6B (feature-specific brand color)

### Feature-Specific Tokens
[Additional tokens unique to this feature]
```

---

**Related BASE Specs**:
- `functional/_BASE.md` - UX patterns, accessibility
- `security/_BASE.md` - Security model
- `operations/_BASE.md` - Deployment infrastructure
