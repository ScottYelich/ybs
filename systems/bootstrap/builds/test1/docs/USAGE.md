# Using test1

**Version**: 0.1.0

## Basic Usage

```bash
test1 [options]
```

## Options

*(To be filled in as features are implemented)*

- `--help`: Show help message
- `--version`: Show version
- (more options to come)

## Examples

*(To be filled in as features are implemented)*

### Example 1: Running the Assistant

```bash
test1
```

This will start the interactive coding assistant.

### Example 2: Getting Help

```bash
test1 --help
```

Shows available commands and options.

## Configuration

Configuration will be via JSON file (to be implemented).

Expected location: `~/.config/test1/config.json`

Example configuration:
```json
{
  "llm": {
    "provider": "ollama",
    "model": "codellama",
    "endpoint": "http://localhost:11434"
  },
  "sandbox": {
    "enabled": true,
    "allowedPaths": ["~/projects"]
  }
}
```

## Environment Variables

*(To be defined as features are implemented)*

## Troubleshooting

### Common Issues

- **Issue**: Connection to LLM fails
  - **Solution**: Ensure Ollama is running (`ollama serve`)

---

**Last updated**: 2026-01-16 19:20:00
