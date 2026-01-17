# Building test2

**Version**: 0.1.0

## Prerequisites

- Swift 5.9+
- macOS 14+
- Xcode Command Line Tools (includes Swift toolchain)

## Build Steps

### Development Build

```bash
swift build
```

This creates a debug build in `.build/debug/test2`.

### Release Build

```bash
swift build -c release
```

This creates an optimized release build in `.build/release/test2`.

### Clean Build

```bash
rm -rf .build
swift build
```

This removes all build artifacts and rebuilds from scratch.

## Troubleshooting

### Common Issues

- **Issue**: "error: unable to resolve dependencies"
  - **Solution**: Check internet connection. Dependencies are fetched from GitHub.

- **Issue**: "error: could not find module 'ArgumentParser'"
  - **Solution**: Run `swift package resolve` to fetch dependencies.

- **Issue**: Build warnings about test files
  - **Solution**: This is expected if test files haven't been created yet. The warning can be ignored.

## Build Configuration

The build is configured in `Package.swift`:
- Target platform: macOS 14+
- Swift tools version: 5.9
- Dependencies:
  - swift-argument-parser (1.3.0+)
  - async-http-client (1.20.0+)

---

**Last updated**: 2026-01-17
