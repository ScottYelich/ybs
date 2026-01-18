# Security BASE Specification: Bootstrap

**System**: Bootstrap (Swift AI Chat Tool)
**Version**: 1.0.0
**Last Updated**: 2026-01-17

## Security Model

### Security Principles

1. **User Data Privacy**: All data stored locally
2. **API Key Security**: Store in macOS Keychain
3. **Sandboxing**: Full App Sandbox enabled
4. **Minimal Permissions**: Only required entitlements

## API Key Management

### Storage

- **Location**: macOS Keychain
- **Access**: App-only (kSecAttrAccessibleAfterFirstUnlock)
- **Service**: "com.bootstrap.api-key"

```swift
// Store API key
let keychain = KeychainManager()
try keychain.save(apiKey, forKey: "anthropic_api_key")

// Retrieve API key
let apiKey = try keychain.retrieve(key: "anthropic_api_key")
```

### Never Store in UserDefaults

- API keys MUST use Keychain
- No plaintext storage
- No logging of API keys

## Sandboxing

### Required Entitlements

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

### Restricted Access

- No access to user's files (except user-selected)
- Network access limited to API endpoints
- No camera/microphone access

## Data Protection

### Conversation Data

- **Storage**: `~/Library/Application Support/Bootstrap/`
- **Format**: JSON (encrypted at file system level via macOS FileVault)
- **Permissions**: User read/write only

### No Data Transmission

- Conversations stored locally only
- No analytics tracking
- No crash reporting without user consent

## Input Validation

### User Input

- Validate message length (max 100,000 chars)
- Sanitize for logging (no PII in logs)
- No code execution from user input

### Configuration File

- Validate JSON schema
- Whitelist allowed config keys
- Sanitize file paths

## Network Security

- **API Communication**: HTTPS only (TLS 1.3+)
- **Certificate Pinning**: Optional (for Anthropic API)
- **Timeout**: 30s per request
- **Rate Limiting**: Client-side (respect API limits)
