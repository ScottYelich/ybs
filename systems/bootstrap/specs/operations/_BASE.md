# Operations BASE Specification: Bootstrap

**System**: Bootstrap (Swift AI Chat Tool)
**Version**: 1.0.0
**Last Updated**: 2026-01-17

## Infrastructure

### Distribution

- **Method**: GitHub Releases + Homebrew
- **Format**: Signed .dmg file
- **Updates**: Manual download (future: auto-update)

### Environments

| Environment | Purpose | Build |
|-------------|---------|-------|
| Development | Local development | Debug build |
| Beta | Testing with users | TestFlight |
| Production | Public release | Release build |

## Deployment

### Build Process

```bash
# Build for release
xcodebuild -scheme Bootstrap \
           -configuration Release \
           -archivePath ./build/Bootstrap.xcarchive \
           archive

# Export as .app
xcodebuild -exportArchive \
           -archivePath ./build/Bootstrap.xcarchive \
           -exportPath ./build \
           -exportOptionsPlist ExportOptions.plist
```

### Code Signing

- **Developer ID**: Apple Developer account required
- **Notarization**: Submit to Apple for notarization
- **Gatekeeper**: Pass Gatekeeper requirements

### Release Checklist

- [ ] All tests pass
- [ ] Version number updated
- [ ] Changelog updated
- [ ] Build signed and notarized
- [ ] TestFlight beta test completed
- [ ] GitHub release created
- [ ] Homebrew cask updated

## Monitoring

### Crash Reporting

- **Tool**: Optional (with user consent)
- **Privacy**: Anonymize user data
- **Retention**: 30 days

### Logging

- **Location**: `~/Library/Logs/Bootstrap/bootstrap.log`
- **Rotation**: 10 MB max, keep 5 files
- **Level**: INFO (production), DEBUG (development)

### Metrics

- App launches (local count)
- Messages sent (local count)
- No user tracking
- No analytics service

## User Support

### Log Collection

```bash
# User can export logs for debugging
open ~/Library/Logs/Bootstrap/
```

### Diagnostics

- Include in "Help" menu
- "Export Diagnostics" option
- Sanitize before sharing (remove API keys, PII)

## Updates

### Version Checking

- Check GitHub releases API for new version
- Notify user if update available
- Manual download (no auto-install initially)

### Update Process

1. User downloads new .dmg
2. User drags to Applications (replace old)
3. Launch new version
4. Migrate config if needed
