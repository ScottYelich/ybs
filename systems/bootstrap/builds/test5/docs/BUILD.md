# Building test5

**Version**: 0.1.0

## Prerequisites

- Swift 5.9+ (Xcode 15+ or Swift toolchain from swift.org)
- macOS 14+ (Sonoma or later)
- Git (for dependency resolution)

## Build Steps

### Development Build

```bash
cd builds/test5
swift build
```

This creates a debug build at `.build/debug/test5`.

### Release Build

```bash
swift build -c release
```

This creates an optimized build at `.build/release/test5` with:
- Full optimizations enabled
- Smaller binary size
- No debug symbols

### Clean Build

```bash
rm -rf .build
swift build
```

## Troubleshooting

### Common Issues

- **Issue**: "error: no such module 'ArgumentParser'" or similar dependency errors
  - **Solution**: Run `swift package resolve` to fetch dependencies, then try building again

- **Issue**: "error: Swift does not support the SDK" or version mismatch
  - **Solution**: Ensure you're running Swift 5.9+ with `swift --version`. Update Xcode or install latest Swift toolchain.

- **Issue**: Build hangs during dependency resolution
  - **Solution**: Check network connectivity. Dependencies are fetched from GitHub.

## Build Configuration

### Dependencies

Managed in `Package.swift`:
- `swift-argument-parser` ~1.3.0 (CLI argument parsing)
- `async-http-client` ~1.20.0 (HTTP client for LLM APIs)

### Compiler Flags

Default flags are in Package.swift. To add custom flags:

```bash
swift build -Xswiftc -warnings-as-errors
```

## Dependency Management

### Update Dependencies

```bash
swift package update
```

### Resolve Dependencies

```bash
swift package resolve
```

### View Dependency Graph

```bash
swift package show-dependencies
```

---

**Last updated**: 2026-01-17 07:41 UTC
