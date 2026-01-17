# Building test3

**Version**: 0.1.0

## Prerequisites

- **Swift**: 5.9 or later
- **macOS**: 14+ (Sonoma or later)
- **Xcode Command Line Tools**: Install with `xcode-select --install`

## Build Steps

### Development Build

```bash
cd builds/test3
swift build
```

This builds the debug version in `.build/debug/test3`.

### Release Build

```bash
cd builds/test3
swift build -c release
```

This builds the optimized release version in `.build/release/test3`.

### Clean Build

```bash
cd builds/test3
swift package clean
swift build
```

Removes all build artifacts and rebuilds from scratch.

## Running the Build

### Development Build

```bash
swift run test3
```

Or directly:
```bash
.build/debug/test3
```

### Release Build

```bash
.build/release/test3
```

## Troubleshooting

### Common Issues

- **Issue**: `swift: command not found`
  - **Solution**: Install Xcode Command Line Tools: `xcode-select --install`

- **Issue**: `'Package.swift' manifest parsing error`
  - **Solution**: Verify Swift version is 5.9+ with `swift --version`

- **Issue**: Dependency resolution failures
  - **Solution**: Clear package cache: `swift package reset` then rebuild

- **Issue**: Build errors after git pull
  - **Solution**: Clean and rebuild: `swift package clean && swift build`

## Build Configuration

### Dependencies

Managed via `Package.swift`:
- **swift-argument-parser**: ^1.3.0 - CLI argument parsing
- **async-http-client**: ^1.20.0 - HTTP client for LLM APIs

### Platform Requirements

- Minimum macOS version: 14.0 (specified in Package.swift)
- Swift tools version: 5.9 (specified in Package.swift)

### Build Modes

- **Debug** (default): Includes debugging symbols, no optimizations
- **Release** (`-c release`): Full optimizations, no debugging symbols

---

**Last updated**: 2026-01-17 06:32 UTC
