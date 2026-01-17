# Step 000002: Set Up Project Environment

**Version**: 0.2.0

## Overview

This step sets up the project structure and build environment for your chosen programming language. The specific instructions will vary based on the language you selected in step_000001.

**Before starting**: Read `builds/SYSTEMNAME/ARCHITECTURE.md` to see which language was chosen.

## Step Objectives

1. Read architecture decisions from ARCHITECTURE.md
2. Create language-specific project structure
3. Initialize build tools and package manager
4. Create initial project files
5. **Create project README.md** (for humans)
6. **Create project CLAUDE.md** (for AI agents)
7. **Create docs/ directory** with standard documentation
8. Verify build environment works
9. Document completion

## Instructions by Language

### Check Your Language Choice

First, check what language was chosen:

```bash
grep "^**Choice**:" builds/SYSTEMNAME/ARCHITECTURE.md | head -1
```

Then follow the appropriate section below.

---

## For Swift

### 1. Create Swift Package Structure

```bash
cd builds/SYSTEMNAME
mkdir -p Sources/SYSTEMNAME
mkdir -p Tests/SYSTEMNAMETests
```

### 2. Create Package.swift

Create `builds/SYSTEMNAME/Package.swift`:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SYSTEMNAME",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/swift-server/async-http-client", from: "1.20.0"),
    ],
    targets: [
        .executableTarget(
            name: "SYSTEMNAME",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ]
        ),
        .testTarget(
            name: "SYSTEMNAMETests",
            dependencies: ["SYSTEMNAME"]
        ),
    ]
)
```

### 3. Create main.swift

Create `builds/SYSTEMNAME/Sources/SYSTEMNAME/main.swift`:

```swift
import Foundation

print("SYSTEMNAME - LLM Coding Assistant")
print("Version: 0.1.0")
print("Build environment initialized successfully!")
```

### 4. Verify Swift Build

```bash
cd builds/SYSTEMNAME
swift build
swift run SYSTEMNAME
```

Expected output: Should build successfully and print the welcome message.

---

## For Python

### 1. Create Python Project Structure

```bash
cd builds/SYSTEMNAME
mkdir -p src/SYSTEMNAME
mkdir -p tests
touch src/SYSTEMNAME/__init__.py
touch tests/__init__.py
```

### 2. Create pyproject.toml

Create `builds/SYSTEMNAME/pyproject.toml`:

```toml
[build-system]
requires = ["setuptools>=68.0"]
build-backend = "setuptools.build_meta"

[project]
name = "SYSTEMNAME"
version = "0.1.0"
description = "LLM-powered coding assistant"
requires-python = ">=3.11"
dependencies = [
    "httpx>=0.25.0",
    "click>=8.1.0",
]

[project.scripts]
SYSTEMNAME = "SYSTEMNAME.main:main"

[tool.pytest.ini_options]
testpaths = ["tests"]
```

### 3. Create main.py

Create `builds/SYSTEMNAME/src/SYSTEMNAME/main.py`:

```python
#!/usr/bin/env python3
"""SYSTEMNAME - LLM Coding Assistant"""

def main():
    print("SYSTEMNAME - LLM Coding Assistant")
    print("Version: 0.1.0")
    print("Build environment initialized successfully!")

if __name__ == "__main__":
    main()
```

### 4. Create Virtual Environment and Verify

```bash
cd builds/SYSTEMNAME
python3 -m venv venv
source venv/bin/activate
pip install -e .
SYSTEMNAME
```

Expected output: Should install and run successfully.

---

## For Go

### 1. Initialize Go Module

```bash
cd builds/SYSTEMNAME
go mod init SYSTEMNAME
```

### 2. Create Go Project Structure

```bash
mkdir -p cmd/SYSTEMNAME
mkdir -p internal/agent
mkdir -p pkg/llm
```

### 3. Create main.go

Create `builds/SYSTEMNAME/cmd/SYSTEMNAME/main.go`:

```go
package main

import "fmt"

func main() {
    fmt.Println("SYSTEMNAME - LLM Coding Assistant")
    fmt.Println("Version: 0.1.0")
    fmt.Println("Build environment initialized successfully!")
}
```

### 4. Verify Go Build

```bash
cd builds/SYSTEMNAME
go build -o SYSTEMNAME ./cmd/SYSTEMNAME
./SYSTEMNAME
```

Expected output: Should build and run successfully.

---

## For Rust

### 1. Initialize Cargo Project

```bash
cd builds/SYSTEMNAME
cargo init --name SYSTEMNAME
```

### 2. Update Cargo.toml

Edit `builds/SYSTEMNAME/Cargo.toml`:

```toml
[package]
name = "SYSTEMNAME"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1.35", features = ["full"] }
clap = { version = "4.4", features = ["derive"] }
reqwest = { version = "0.11", features = ["json", "stream"] }
```

### 3. Update main.rs

Edit `builds/SYSTEMNAME/src/main.rs`:

```rust
fn main() {
    println!("SYSTEMNAME - LLM Coding Assistant");
    println!("Version: 0.1.0");
    println!("Build environment initialized successfully!");
}
```

### 4. Verify Rust Build

```bash
cd builds/SYSTEMNAME
cargo build
cargo run
```

Expected output: Should build and run successfully.

---

## For TypeScript/Node

### 1. Initialize NPM Project

```bash
cd builds/SYSTEMNAME
npm init -y
```

### 2. Install TypeScript and Dependencies

```bash
npm install --save-dev typescript @types/node ts-node
npm install commander axios
npx tsc --init
```

### 3. Create Project Structure

```bash
mkdir -p src
mkdir -p dist
mkdir -p tests
```

### 4. Update package.json

Edit `builds/SYSTEMNAME/package.json` to add:

```json
{
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "ts-node src/index.ts",
    "test": "echo \"No tests yet\""
  },
  "bin": {
    "SYSTEMNAME": "./dist/index.js"
  }
}
```

### 5. Create index.ts

Create `builds/SYSTEMNAME/src/index.ts`:

```typescript
#!/usr/bin/env node

console.log("SYSTEMNAME - LLM Coding Assistant");
console.log("Version: 0.1.0");
console.log("Build environment initialized successfully!");
```

### 6. Verify TypeScript Build

```bash
cd builds/SYSTEMNAME
npm run build
npm start
```

Expected output: Should compile and run successfully.

---

## Documentation Setup (All Languages)

After setting up your language-specific project structure, create the following documentation files. These are **required** regardless of language choice.

### Create Project README.md

Create `builds/SYSTEMNAME/README.md` (this will replace the placeholder from step 0):

```markdown
# SYSTEMNAME

**Version**: 0.1.0
**Language**: [Swift/Python/Go/Rust/TypeScript]
**Platform**: [chosen platform(s)]

An LLM-powered coding assistant built from scratch.

## Overview

This is an interactive command-line tool that provides AI-assisted coding through:
- Interactive chat interface
- Local tool execution (file operations, shell commands)
- Support for configurable LLM backends (Ollama, OpenAI, Anthropic, etc.)
- Conversation context management
- Security sandboxing

## Prerequisites

- [Language runtime/compiler]: [version requirements]
- [Build tool]: [version]
- Ollama (for local LLM, optional): https://ollama.ai

## Building

See `docs/BUILD.md` for detailed build instructions.

Quick start:
\```bash
[build command for your language]
\```

## Running

\```bash
[run command for your language]
\```

## Testing

See `docs/TESTING.md` for testing guidelines.

\```bash
[test command for your language]
\```

## Usage

See `docs/USAGE.md` for detailed usage instructions.

Basic usage:
\```bash
SYSTEMNAME --help
\```

## Development

- **Build status**: See BUILD_STATUS.md
- **Build history**: See docs/build-history/
- **Architecture**: See ARCHITECTURE.md
- **Claude guidance**: See CLAUDE.md

## Project Structure

[Describe your language-specific structure here]

## License

[TBD]

---

**Built with**: Step-by-step instructions from `../../docs/build-from-scratch/`
**Last updated**: [timestamp]
```

### Create Project CLAUDE.md

Create or update `builds/SYSTEMNAME/CLAUDE.md` (add to existing from step 0):

```markdown
# CLAUDE.md - SYSTEMNAME

**Version**: 0.2.0

This file provides guidance to Claude Code when working on this project.

## Project Context

**System Name**: SYSTEMNAME
**Language**: [language]
**Platform**: [platform(s)]
**Purpose**: LLM-powered coding assistant
**Build Method**: Following step-by-step instructions from `../../docs/build-from-scratch/`

## Quick Start for Claude

### Build Commands
- **Build**: \`[build command]\`
- **Run**: \`[run command]\`
- **Test**: \`[test command]\`
- **Clean**: \`[clean command if applicable]\`

### Project Structure

\```
SYSTEMNAME/
├── [language-specific source directory]
├── [language-specific test directory]
├── [build configuration file]
├── BUILD_STATUS.md
├── ARCHITECTURE.md
├── README.md
├── CLAUDE.md (this file)
└── docs/
    ├── BUILD.md
    ├── TESTING.md
    ├── USAGE.md
    └── build-history/
\```

### Development Workflow

1. **Check status**: Always read BUILD_STATUS.md first
2. **Read instructions**: Follow steps from `../../docs/build-from-scratch/steps/`
3. **Use todo lists**: Create TodoWrite for each step
4. **Write tests**: For code changes, write tests first or concurrently
5. **Verify**: Run tests and build before marking step complete
6. **Document**: Update build-history with DONE files

### Testing Requirements

- **Unit tests**: Test individual components in isolation
- **Integration tests**: Test components working together
- **All tests must pass**: Before marking any code step as complete
- **Test location**: [language-specific test directory]

### Important Notes

- This workspace is independent of specs (use specs as reference only)
- All implementation happens in builds/SYSTEMNAME/
- DO NOT modify anything in docs/ (instructions)
- Each step must complete verification before proceeding
- Follow language conventions for this project

### Documentation Versioning

All documentation uses semantic versioning (major.minor.patch):
- **Current version**: 0.2.0
- **Increment rule**: ONLY minor version (0.1.0 → 0.2.0 → 0.3.0)
- **Major version**: LOCKED at 0.x.x (do NOT go to 1.0.0)

---

**Last updated**: [timestamp]
```

### Create docs/ Directory

Create documentation directory with standard files:

\```bash
cd builds/SYSTEMNAME
mkdir -p docs
\```

Create `builds/SYSTEMNAME/docs/BUILD.md`:

\```markdown
# Building SYSTEMNAME

**Version**: 0.1.0

## Prerequisites

- [Language]: [version]
- [Build tool]: [version]
- [Other dependencies]

## Build Steps

### Development Build

\```bash
[development build command]
\```

### Release Build

\```bash
[release build command if different]
\```

### Clean Build

\```bash
[clean command]
[rebuild command]
\```

## Troubleshooting

### Common Issues

- **Issue**: [common build problem]
  - **Solution**: [how to fix]

## Build Configuration

[Explain any build configuration options]

---

**Last updated**: [timestamp]
\```

Create `builds/SYSTEMNAME/docs/TESTING.md`:

\```markdown
# Testing SYSTEMNAME

**Version**: 0.1.0

## Running Tests

### All Tests

\```bash
[command to run all tests]
\```

### Specific Test

\```bash
[command to run single test]
\```

### Test Coverage

\```bash
[command to check coverage if applicable]
\```

## Writing Tests

### Unit Tests

- Location: [test directory]
- Framework: [test framework for language]
- Convention: [naming convention]

Example:
\```[language]
[example test code]
\```

### Integration Tests

[Guidelines for integration tests]

## Test Requirements

- All new code must have tests
- All tests must pass before committing
- Aim for [X]% code coverage

---

**Last updated**: [timestamp]
\```

Create `builds/SYSTEMNAME/docs/USAGE.md`:

\```markdown
# Using SYSTEMNAME

**Version**: 0.1.0

## Basic Usage

\```bash
SYSTEMNAME [options]
\```

## Options

*(To be filled in as features are implemented)*

- `--help`: Show help message
- `--version`: Show version
- (more options to come)

## Examples

*(To be filled in as features are implemented)*

### Example 1

\```bash
[example command]
\```

## Configuration

Configuration will be via JSON file (to be implemented).

---

**Last updated**: [timestamp]
\```

---

## Common Steps (All Languages)

### Update BUILD_STATUS.md

Add build environment section:

```markdown
## Build Environment
- **Language**: [language]
- **Build tool**: [tool name]
- **Project structure**: Created
- **Build verified**: Yes
- **Last build check**: [timestamp]
```

Update status:
```markdown
**Current Step**: step_000002
**Step Version**: 0.1.0
**Status**: completed
**Last Updated**: [timestamp]

## Current Step Details
- **Title**: Set Up Project Environment
- **Status**: completed
- **Issues**: none

## Next Action
Ready to proceed to step_000003 (Implement configuration system).
```

### Document Completion

Create `builds/SYSTEMNAME/docs/build-history/step_000002-DONE.txt`:

```
STEP 000002: Set Up Project Environment
COMPLETED: [timestamp]

OBJECTIVES:
- Read architecture decisions from ARCHITECTURE.md
- Create language-specific project structure
- Initialize build tools and package manager
- Create initial project files
- Verify build environment works

ACTIONS TAKEN:
- Created [language]-specific project structure
- Initialized [build tool] with dependencies
- Created main entry point file
- Verified build completes successfully
- Verified program runs and produces expected output
- Updated BUILD_STATUS.md with build environment info

VERIFICATION RESULTS:
✓ Project structure created correctly
✓ Build tool initialized
✓ Dependencies configured
✓ Initial build succeeds
✓ Program runs and prints welcome message
✓ BUILD_STATUS.md updated

ISSUES ENCOUNTERED:
[None or list any issues and how they were resolved]

FILES CREATED:
[List language-specific files created]

FILES MODIFIED:
- builds/SYSTEMNAME/BUILD_STATUS.md

NEXT STEP: step_000003 (Implement configuration system)

BUILD ENVIRONMENT READY: Yes
```

### Report to User

```
✓ Step 000002 complete: Project environment set up

System: SYSTEMNAME
Language: [language]
Build tool: [tool]

Created:
  ✓ Project structure
  ✓ Build configuration
  ✓ Initial source files
  ✓ Build verified working

Status: ✓ READY FOR STEP 3

Next step: step_000003 (Implement configuration system)
```

## Verification Checklist

- [ ] ARCHITECTURE.md read to determine language
- [ ] Language-specific project structure created
- [ ] Build tool initialized with correct dependencies
- [ ] Initial source file created
- [ ] Build completes without errors
- [ ] Program runs and produces expected output
- [ ] BUILD_STATUS.md updated
- [ ] step_000002-DONE.txt created

## Success Criteria

1. Build environment is fully functional
2. Can build project without errors
3. Can run project and see output
4. All dependencies properly configured
5. Project structure follows language conventions

---

## Version History

### 0.1.0 (2026-01-16)
- Initial version
- Multi-language support (Swift, Python, Go, Rust, TypeScript)
- Language-specific instructions for each ecosystem

---

**Step completed?** Proceed to `step_000003.md`
