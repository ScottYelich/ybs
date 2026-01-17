# Building test4

**Version**: 0.1.0

## Prerequisites

- Swift 5.9+ (included with Xcode 15+ or Swift toolchain)
- macOS 14+ (Sonoma or later)
- Git (for dependency management)

## Build Steps

### Development Build

```bash
swift build
```

This builds the project in debug mode with:
- Debug symbols included
- Optimizations disabled
- Faster compilation

Output: `.build/debug/test4`

### Release Build

```bash
swift build -c release
```

This builds the project in release mode with:
- Optimizations enabled
- Debug symbols stripped
- Smaller binary size
- Better performance

Output: `.build/release/test4`

### Clean Build

```bash
rm -rf .build/
swift build
```

This removes all build artifacts and rebuilds from scratch.

## Running

### During Development

```bash
swift run test4
```

This builds (if needed) and runs the executable in one command.

### Running Built Binary

After building, you can run the binary directly:

```bash
# Debug build
.build/debug/test4

# Release build
.build/release/test4
```

## Dependencies

Dependencies are managed by Swift Package Manager and declared in `Package.swift`:

- **swift-argument-parser** (~1.3.0) - CLI argument parsing
- **async-http-client** (~1.20.0) - HTTP client for LLM APIs

Dependencies are automatically fetched during the first build.

## Troubleshooting

### Common Issues

- **Issue**: Build fails with "unable to resolve dependencies"
  - **Solution**: Run `swift package resolve` to manually resolve dependencies

- **Issue**: Build takes a long time on first run
  - **Solution**: This is normal - Swift Package Manager is fetching and compiling dependencies

- **Issue**: "command not found: swift"
  - **Solution**: Install Xcode 15+ or Swift toolchain from swift.org

## Build Configuration

Build settings are in `Package.swift`:
- Minimum platform: macOS 14
- Swift tools version: 5.9
- Target name: test4

---

**Last updated**: 2026-01-16 23:05 UTC
