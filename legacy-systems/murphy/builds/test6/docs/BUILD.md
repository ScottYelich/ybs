# Building test6

**Version**: 0.1.0

## Prerequisites

- Swift: 5.9 or later
- macOS: 14.0 (Sonoma) or later
- Xcode Command Line Tools (for Swift compiler)

## Build Steps

### Development Build

```bash
swift build
```

This will:
- Download dependencies (ArgumentParser, AsyncHTTPClient)
- Compile all sources
- Create executable at `.build/debug/test6`

### Release Build

```bash
swift build -c release
```

This creates an optimized executable at `.build/release/test6`

### Clean Build

```bash
swift package clean
swift build
```

## Troubleshooting

### Common Issues

- **Issue**: Swift not found
  - **Solution**: Install Xcode Command Line Tools: `xcode-select --install`

- **Issue**: Dependency resolution fails
  - **Solution**: Check internet connection, or run `swift package reset`

- **Issue**: Build errors after updating dependencies
  - **Solution**: Clean and rebuild: `swift package clean && swift build`

## Build Configuration

Build configuration is managed by `Package.swift`:
- Target platform: macOS 14.0+
- Swift tools version: 5.9
- Dependencies: ArgumentParser, AsyncHTTPClient

---

**Last updated**: 2026-01-17 14:35 UTC
