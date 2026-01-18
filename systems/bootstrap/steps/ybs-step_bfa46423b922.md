# Step 000007: CLI Argument Parsing

**GUID**: bfa46423b922
**Version**: 0.1.0
**Layer**: 1 - Foundation
**Estimated Size**: ~80 lines of code

## Overview

This step implements command-line argument parsing for YBS. It defines all CLI flags, integrates with Swift ArgumentParser, and merges CLI arguments with loaded configuration.

This completes the Foundation layer - after this step, the basic infrastructure (config, models, errors, logging, CLI) is in place for building the core agent.

## What This Step Builds

**CLI Interface**:
- Parse command-line arguments using Swift ArgumentParser
- Support flags: `--config`, `--model`, `--provider`, `--endpoint`, `--help`, `--version`, `--dry-run`
- Merge CLI flags with loaded configuration (CLI overrides config files)
- Validate arguments
- Display help and version information

**Integration**:
- Connects Step 4 (Config) with application entry point
- Provides final merged configuration to the system

## Step Objectives

1. Add Swift ArgumentParser dependency
2. Define CLI command struct with all arguments
3. Implement argument parsing
4. Merge CLI args with config from Step 4
5. Add version and help output
6. Create main entry point (`main.swift`)
7. Test CLI with various flag combinations

## Prerequisites

**Required Steps**:
- ✅ `ybs-step_3a85545f660c` - Configuration (config loading)
- ✅ `ybs-step_7f35a5c547a7` - Core Data Models
- ✅ `ybs-step_f8e87d9f1423` - Error Handling & Logging

**Required Conditions**:
- Swift project compiles
- Configuration system works

## Configurable Values

**This step defines CLI flags that override configuration**:

- `--config <path>` - Path to config file
- `--model <name>` - Override `llm.model`
- `--provider <name>` - Override `llm.provider`
- `--endpoint <url>` - Override `llm.endpoint`
- `--dry-run` - Don't execute tools (show what would happen)
- `--no-color` - Disable colored output
- `--version` - Print version and exit
- `--help` - Show help and exit

## Traceability

**Implements**:
- `ybs-spec.md` Section 2.2 (Command Line Interface)
- `ybs-spec.md` Section 2.1 (Config Resolution - CLI overrides)

**References**:
- D07 (Config Resolution: CLI has highest priority)
- D14 (Dependencies: ArgumentParser)

## Instructions

### Before Starting

1. **Record start time**: `date -u +"%Y-%m-%d %H:%M UTC"`
2. **Verify prerequisites**: Steps 4-6 complete
3. **Check dependencies**: Ensure Swift ArgumentParser can be added

### 1. Add ArgumentParser Dependency

Update Package.swift to include Swift ArgumentParser.

**File to modify**: `Package.swift`

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YBS",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "ybs",
            targets: ["YBS"])
    ],
    dependencies: [
        // Add ArgumentParser
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "YBS",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "YBSTests",
            dependencies: ["YBS"]
        )
    ]
)
```

### 2. Define CLI Command

Create the CLI command structure.

**File to create**: `Sources/YBS/CLI/YBSCommand.swift`

```swift
import Foundation
import ArgumentParser

@main
struct YBSCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ybs",
        abstract: "YBS - AI-powered coding assistant",
        version: "0.1.0"
    )

    @Option(name: .shortAndLong, help: "Path to configuration file")
    var config: String?

    @Option(name: .shortAndLong, help: "Override LLM model")
    var model: String?

    @Option(name: .shortAndLong, help: "Override LLM provider (ollama, openai, anthropic)")
    var provider: String?

    @Option(help: "Override LLM API endpoint URL")
    var endpoint: String?

    @Flag(name: .long, help: "Show what would happen without executing")
    var dryRun: Bool = false

    @Flag(name: .long, help: "Disable colored output")
    var noColor: Bool = false

    @Flag(name: .long, help: "Disable sandboxing (DANGEROUS)")
    var noSandbox: Bool = false

    @Flag(name: .long, help: "Show token usage statistics")
    var showTokens: Bool = false

    @Flag(name: .long, help: "Show tool calls in output")
    var showTools: Bool = false

    func run() throws {
        // Load base configuration from files
        var config = ConfigLoader.loadStandard()

        // Apply CLI overrides
        if let model = model {
            config.llm.model = model
        }

        if let provider = provider {
            config.llm.provider = provider
        }

        if let endpoint = endpoint {
            config.llm.endpoint = endpoint
        }

        if noColor {
            config.ui.color = false
        }

        if noSandbox {
            config.safety.sandboxEnabled = false
        }

        if showTokens {
            config.ui.showTokenUsage = true
        }

        if showTools {
            config.ui.showToolCalls = true
        }

        // Create logger with color setting
        let logger = Logger(component: "YBS", useColor: config.ui.color)

        if dryRun {
            logger.info("DRY RUN MODE: No tools will be executed")
        }

        // Print configuration summary
        logger.info("YBS Starting")
        logger.debug("Provider: \(config.llm.provider)")
        logger.debug("Model: \(config.llm.model)")
        logger.debug("Endpoint: \(config.llm.endpoint)")
        logger.debug("Sandbox: \(config.safety.sandboxEnabled ? "enabled" : "disabled")")

        // TODO: Start agent loop (Step 13)
        logger.warn("Agent loop not yet implemented")
        logger.info("Configuration loaded successfully. Ready for implementation.")
    }
}
```

### 3. Remove old main.swift (if exists)

If there's an old `Sources/YBS/main.swift` from the skeleton, remove it since YBSCommand is now the entry point.

```bash
# The @main attribute on YBSCommand makes it the entry point
# No separate main.swift needed
```

### 4. Build and Test

Verify CLI parsing works.

**Commands**:
```bash
# Fetch dependencies
swift package resolve

# Build
swift build

# Test help
swift run ybs --help

# Test version
swift run ybs --version

# Test with arguments
swift run ybs --model gpt-4 --provider openai --dry-run
```

### 5. Create Manual Test Script

Create a script to test various CLI combinations.

**File to create**: `test-cli.sh`

```bash
#!/bin/bash

echo "=== Testing YBS CLI ==="

echo -e "\n1. Test --help"
swift run ybs --help

echo -e "\n2. Test --version"
swift run ybs --version

echo -e "\n3. Test with model override"
swift run ybs --model gpt-4 --dry-run

echo -e "\n4. Test with provider override"
swift run ybs --provider anthropic --model claude-3.5-sonnet --dry-run

echo -e "\n5. Test with endpoint override"
swift run ybs --endpoint https://api.example.com --dry-run

echo -e "\n6. Test with no-color"
swift run ybs --no-color --dry-run

echo -e "\n7. Test with multiple flags"
swift run ybs --model gpt-4 --provider openai --show-tokens --show-tools --dry-run

echo -e "\n=== All tests complete ==="
```

Make it executable:
```bash
chmod +x test-cli.sh
```

## Verification

### Build Verification

```bash
cd systems/bootstrap/builds/test6
swift build
# Expected: Build succeeds, dependencies fetched
```

### Help Output Verification

```bash
swift run ybs --help
```

**Expected Output**:
```
OVERVIEW: YBS - AI-powered coding assistant

USAGE: ybs [<options>]

OPTIONS:
  -c, --config <config>   Path to configuration file
  -m, --model <model>     Override LLM model
  -p, --provider <provider>
                          Override LLM provider (ollama, openai, anthropic)
  --endpoint <endpoint>   Override LLM API endpoint URL
  --dry-run               Show what would happen without executing
  --no-color              Disable colored output
  --no-sandbox            Disable sandboxing (DANGEROUS)
  --show-tokens           Show token usage statistics
  --show-tools            Show tool calls in output
  --version               Show the version.
  -h, --help              Show help information.
```

### Version Output Verification

```bash
swift run ybs --version
```

**Expected Output**:
```
0.1.0
```

### Argument Override Verification

```bash
swift run ybs --model test-model --provider test-provider --dry-run
```

**Expected Output** (should show overridden values):
```
[timestamp] [YBS] [INFO] DRY RUN MODE: No tools will be executed
[timestamp] [YBS] [INFO] YBS Starting
[timestamp] [YBS] [DEBUG] Provider: test-provider
[timestamp] [YBS] [DEBUG] Model: test-model
[timestamp] [YBS] [WARN] Agent loop not yet implemented
[timestamp] [YBS] [INFO] Configuration loaded successfully. Ready for implementation.
```

### CLI Test Script Verification

```bash
./test-cli.sh
# Should run all test cases without errors
```

## Completion Checklist

When this step is complete, verify:

- [ ] ArgumentParser dependency added to Package.swift
- [ ] YBSCommand defined in `Sources/YBS/CLI/YBSCommand.swift`
- [ ] CLI flags defined (config, model, provider, endpoint, dry-run, etc.)
- [ ] CLI flags override configuration correctly
- [ ] `swift build` succeeds
- [ ] `--help` shows all options
- [ ] `--version` shows version number
- [ ] Argument overrides work correctly
- [ ] Colored output can be disabled with `--no-color`
- [ ] Logger integration works

## After Completion

**Record completion**:
1. Note completion timestamp
2. Create DONE file: `docs/build-history/ybs-step_bfa46423b922-DONE.txt`
3. Update BUILD_STATUS.md

**DONE file contents**:
```
Step: ybs-step_bfa46423b922
Title: CLI Argument Parsing
Status: COMPLETED
Started: [timestamp]
Completed: [timestamp]
Duration: [duration]

Changes:
- Updated Package.swift with ArgumentParser dependency
- Created Sources/YBS/CLI/YBSCommand.swift
- Implemented CLI argument parsing
- Merged CLI args with config
- Added version and help output
- All tests passing

Verification:
✓ Build succeeds
✓ --help works
✓ --version works
✓ Argument overrides work
✓ Config merging works
```

**Commit**:
```bash
git add -A
git commit -m "Step 7: Implement CLI argument parsing

- Add Swift ArgumentParser dependency
- Define YBSCommand with @main entry point
- Support CLI flags: config, model, provider, endpoint, dry-run, etc.
- Merge CLI arguments with config (CLI overrides)
- Add version and help output
- Integrate with config system from Step 4

Foundation Layer Complete: Config, Models, Errors, Logging, CLI all ready

Implements: ybs-spec.md Section 2.2

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Next Steps

**Foundation Layer Complete!** 🎉

All 4 foundation steps (4-7) are now done:
- ✅ Step 4: Configuration loading
- ✅ Step 5: Core data models
- ✅ Step 6: Error handling & logging
- ✅ Step 7: CLI argument parsing

**Proceed to**: Layer 2 - Basic Tools (Steps 8-10)

**Next step**: `ybs-step_[next-guid]` - Step 8: read_file Tool

**Milestone**: The foundation is solid. Ready to build tools and the agent loop!
