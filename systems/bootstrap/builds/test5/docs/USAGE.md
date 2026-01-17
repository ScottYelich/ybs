# Using test5

**Version**: 0.1.0

## Basic Usage

```bash
test5 [options]
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
test5
# (interactive chat to be implemented)
```

### Example 2: With Custom Config

```bash
test5 --config ~/.config/test5/config.json
# (to be implemented)
```

## Configuration

Configuration will be via JSON file (to be implemented in later steps).

Expected location: `~/.config/test5/config.json` or `~/.test5.json`

Format (planned):
```json
{
  "provider": "ollama",
  "model": "qwen2.5-coder:14b",
  "endpoint": "http://localhost:11434",
  "api_key": null
}
```

## LLM Provider Setup

### Ollama (Recommended for Development)

1. Install Ollama: https://ollama.ai
2. Pull a model: `ollama pull qwen2.5-coder:14b`
3. Run test5: `test5` (will use Ollama by default)

### OpenAI

*(To be implemented - requires API key in config)*

### Anthropic

*(To be implemented - requires API key in config)*

---

**Last updated**: 2026-01-17 07:41 UTC
