# YBS Framework Dependencies

**Version**: 0.1.0

This document lists ALL dependencies required by the YBS framework itself (the step files and build system), NOT the dependencies of systems you build with YBS.

## Required System Tools

These tools MUST be installed on the system running YBS build steps:

### Core Tools

- **bash** (or zsh) - Shell for executing commands
  - Version: Any modern version (4.0+)
  - Why: All step instructions use bash commands
  - Install: Pre-installed on macOS/Linux

- **jq** - JSON query processor
  - Version: 1.6+
  - Why: Reading values from BUILD_CONFIG.json
  - Install:
    - macOS: `brew install jq`
    - Linux: `apt-get install jq` or `yum install jq`
    - Check: `jq --version`

- **git** - Version control
  - Version: 2.0+
  - Why: Repository management, commit/push operations
  - Install:
    - macOS: `xcode-select --install` or `brew install git`
    - Linux: `apt-get install git` or `yum install git`
    - Check: `git --version`

### Standard Unix Tools

These are typically pre-installed but may need verification:

- **mkdir** - Create directories
- **cat** - Read files
- **grep** - Search text
- **echo** - Output text
- **test** - File/condition testing
- **ls** - List files

## Language-Specific Tools

These are ONLY required if building a system in that language. They are NOT YBS dependencies.

NOT listed here:
- Swift, Python, Go, Rust, TypeScript, Node, npm, cargo, etc.
- These are dependencies of the SYSTEM YOU BUILD, not YBS itself

## Optional Tools

- **ripgrep** (rg) - Faster alternative to grep
  - Not required, but recommended for large codebases
  - Install: `brew install ripgrep` or `cargo install ripgrep`

## Verification Script

To check if all required YBS dependencies are installed:

```bash
#!/bin/bash
echo "Checking YBS Framework Dependencies..."
echo ""

# Check bash
if command -v bash &> /dev/null; then
    echo "✓ bash: $(bash --version | head -n1)"
else
    echo "✗ bash: NOT FOUND"
fi

# Check jq
if command -v jq &> /dev/null; then
    echo "✓ jq: $(jq --version)"
else
    echo "✗ jq: NOT FOUND (REQUIRED - install with 'brew install jq')"
fi

# Check git
if command -v git &> /dev/null; then
    echo "✓ git: $(git --version)"
else
    echo "✗ git: NOT FOUND"
fi

echo ""
echo "Standard Unix tools (should be pre-installed):"
for tool in mkdir cat grep echo test ls; do
    if command -v $tool &> /dev/null; then
        echo "✓ $tool"
    else
        echo "✗ $tool: NOT FOUND"
    fi
done
```

## Dependency Changes

### Why jq?

- **Previous**: Used `python3` with inline JSON parsing
- **Current**: Use `jq` - standard JSON processor
- **Reason**: `jq` is the de-facto standard for command-line JSON querying
- **Changed**: 2026-01-17 (v0.7.0)

## Installation Quick Start

### macOS

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install jq
brew install jq

# Verify
jq --version
git --version
```

### Linux (Debian/Ubuntu)

```bash
# Install jq
sudo apt-get update
sudo apt-get install -y jq

# Verify
jq --version
git --version
```

### Linux (RHEL/CentOS)

```bash
# Install jq
sudo yum install -y jq

# Verify
jq --version
git --version
```

---

**Last updated**: 2026-01-17 06:33 UTC
