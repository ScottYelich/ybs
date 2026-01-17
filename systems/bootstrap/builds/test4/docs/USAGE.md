# Using test4

**Version**: 0.1.0

## Basic Usage

```bash
swift run test4 [options]
```

Or if you've built the binary:
```bash
./build/release/test4 [options]
```

## Options

*(To be filled in as features are implemented)*

- `--help`: Show help message
- `--version`: Show version
- (more options to come)

## Examples

*(To be filled in as features are implemented)*

### Example 1: Basic Chat

```bash
# Future: Start interactive chat session
# test4 chat
```

### Example 2: Execute with Configuration

```bash
# Future: Use custom config file
# test4 --config ~/.test4-custom.json
```

### Example 3: One-shot Command

```bash
# Future: Execute single command
# test4 run "create a hello world function"
```

## Configuration

Configuration will be via JSON file (to be implemented in later steps).

Expected configuration file locations (in order of precedence):
1. `--config <path>` (command-line override)
2. `./.ybs.json` (project-specific)
3. `~/.ybs.json` (user home)
4. `~/.config/ybs/config.json` (user defaults)
5. `/etc/ybs/config.json` (system-wide)

## Environment Variables

*(To be defined as features are implemented)*

## Troubleshooting

*(To be filled in as common issues are discovered)*

---

**Last updated**: 2026-01-16 23:05 UTC
