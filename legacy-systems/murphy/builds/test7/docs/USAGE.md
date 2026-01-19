# Using test7

**Version**: 0.1.0

## Basic Usage

```bash
test7 [options]
```

## Options

*(To be filled in as features are implemented)*

- `--help`: Show help message
- `--version`: Show version
- (more options to come)

## Examples

*(To be filled in as features are implemented)*

### Example 1: Starting a Chat Session

```bash
test7
```

This will start an interactive chat session with the default LLM provider (Ollama).

### Example 2: Using a Specific Model

```bash
test7 --model llama2
```

### Example 3: Using OpenAI

```bash
test7 --provider openai --model gpt-4
```

## Configuration

Configuration will be via JSON file at `~/.config/test7/config.json`.

Example configuration:
```json
{
  "provider": "ollama",
  "model": "llama2",
  "endpoint": "http://localhost:11434",
  "apiKey": ""
}
```

Configuration system to be implemented in later steps.

## Environment Variables

- `TEST7_CONFIG`: Override config file location
- `TEST7_LOG_LEVEL`: Set log level (debug, info, warn, error)

## Keyboard Shortcuts

*(To be filled in as features are implemented)*

- `Ctrl+C`: Exit chat session
- `Ctrl+D`: Send message

---

**Last updated**: 2026-01-18T02:09:31Z
