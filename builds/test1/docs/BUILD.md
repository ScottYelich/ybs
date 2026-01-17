# Building test1

**Version**: 0.1.0

## Prerequisites

- Swift: 5.9+
- macOS: 14+ (Sonoma)
- Swift Package Manager: Included with Swift
- Xcode Command Line Tools (optional but recommended)

## Build Steps

### Development Build

```bash
cd builds/test1
swift build
```

This creates a debug build in `.build/debug/test1`.

### Release Build

```bash
swift build -c release
```

This creates an optimized build in `.build/release/test1`.

### Clean Build

```bash
swift package clean
swift build
```

## Troubleshooting

### Common Issues

- **Issue**: `swift: command not found`
  - **Solution**: Install Xcode Command Line Tools: `xcode-select --install`

- **Issue**: Build fails with "minimum deployment target" error
  - **Solution**: Ensure you're running macOS 14+ (Sonoma)

- **Issue**: Dependency resolution timeout
  - **Solution**: Check network connection and try again. SPM caches dependencies locally after first fetch.

## Build Configuration

Swift Package Manager uses `Package.swift` for configuration. Key settings:

- **Minimum Swift version**: 5.9
- **Platform**: macOS 14+
- **Dependencies**:
  - swift-argument-parser (~1.3.0)
  - async-http-client (~1.20.0)

---

**Last updated**: 2026-01-16 19:20:00
