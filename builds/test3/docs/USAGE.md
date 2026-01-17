# Using test3

**Version**: 0.1.0

## Basic Usage

```bash
test3 [options]
```

## Options

*(To be filled in as features are implemented)*

- `--help`: Show help message
- `--version`: Show version information
- (more options to come)

## Examples

*(To be filled in as features are implemented)*

### Example 1: Get Help

```bash
test3 --help
```

Shows available commands and options.

### Example 2: Check Version

```bash
test3 --version
```

Displays the current version of test3.

## Configuration

Configuration will be via JSON file (to be implemented in a later step).

Expected configuration file locations (in order of precedence):
1. `./.test3.json` (project-specific)
2. `~/.test3.json` (user home directory)
3. `~/.config/test3/config.json` (XDG config directory)
4. `/etc/test3/config.json` (system-wide)

Configuration file format (to be implemented):
```json
{
  "provider": "ollama",
  "model": "qwen3:14b",
  "endpoint": "http://localhost:11434",
  "allowed_paths": ["."],
  "sandbox": true
}
```

## Features

*(To be filled in as features are implemented)*

### Interactive Chat

Start an interactive chat session with the LLM coding assistant.

### Tool Execution

Execute local tools for file operations, shell commands, etc.

### Context Management

Automatically manage conversation context and token budgets.

---

**Last updated**: 2026-01-17 06:32 UTC
