# Configuration System

**Version**: 0.1.0
**Last Updated**: 2026-01-17

📍 **You are here**: YBS Framework > Documentation > Configuration System
**↑ Parent**: [Documentation Hub](README.md)
📚 **Related**: [security-model.md](security-model.md) | [bootstrap-principles.md](bootstrap-principles.md)

> **Canonical Reference**: This is the single source of truth for YBS configuration.
> All other documents should link here rather than duplicating this content.

---

## Overview

Systems built with YBS typically use **layered configuration** where later sources override earlier ones. This allows system-wide defaults, user preferences, and project-specific overrides.

**Pattern**: Defaults → System → User → Project → CLI

---

## Configuration Layers (Bootstrap Implementation)

The Swift/macOS bootstrap uses this hierarchy:

### 1. Built-In Defaults
**Location**: Compiled into agent binary
**Priority**: Lowest (always overridden)
**Purpose**: Ensure agent works without any config file

**Example defaults**:
```swift
let defaults = Config(
    provider: "ollama",
    model: "qwen2.5-coder:14b",
    endpoint: "http://localhost:11434",
    apiKey: nil,
    maxTokens: 4096,
    temperature: 0.7
)
```

---

### 2. System-Wide Config
**Location**: `/etc/ybs/config.json`
**Priority**: Low
**Purpose**: Enterprise or system administrator defaults

**Example**:
```json
{
  "provider": "ollama",
  "endpoint": "http://llm-server.company.internal:11434",
  "security": {
    "allowed_paths": ["/home"],
    "blocked_paths": ["/etc", "/root"]
  }
}
```

**Use case**: IT department configures all workstations to use internal LLM server

---

### 3. User Defaults
**Location**: `~/.config/ybs/config.json`
**Priority**: Medium
**Purpose**: User's personal preferences

**Example**:
```json
{
  "provider": "anthropic",
  "model": "claude-sonnet-4.5",
  "apiKey": "sk-ant-...",
  "theme": "dark",
  "confirmations": {
    "write_file": true,
    "run_shell": true
  }
}
```

**Use case**: User prefers Claude over Ollama, saves API key

---

### 4. User Home Config
**Location**: `~/.ybs.json`
**Priority**: Medium-High
**Purpose**: Alternative to `~/.config/` (simpler path)

**Example**:
```json
{
  "provider": "openai",
  "model": "gpt-4-turbo",
  "apiKey": "sk-..."
}
```

**Use case**: Quick config without creating `~/.config/ybs/` directory

---

### 5. Project-Specific Config
**Location**: `./.ybs.json` (current directory)
**Priority**: High
**Purpose**: Override settings for specific project

**Example**:
```json
{
  "provider": "ollama",
  "model": "codellama:13b",
  "context_files": [
    "docs/architecture.md",
    "README.md"
  ],
  "tools": {
    "external_path": "./.ybs/tools"
  }
}
```

**Use case**: Project uses specialized model, has custom tools

---

### 6. CLI Override
**Location**: Command-line argument
**Priority**: Highest (always wins)
**Purpose**: One-off overrides

**Example**:
```bash
ybs --config /tmp/test-config.json
ybs --model gpt-4-turbo --provider openai
```

**Use case**: Testing different configuration without changing files

---

## Configuration Schema

### Full Example (Bootstrap)

```json
{
  "version": "0.1.0",

  "llm": {
    "provider": "ollama",
    "model": "qwen2.5-coder:14b",
    "endpoint": "http://localhost:11434",
    "apiKey": null,
    "maxTokens": 4096,
    "temperature": 0.7,
    "streaming": true
  },

  "security": {
    "level": "balanced",
    "allowed_paths": [
      "{{CWD}}",
      "/tmp"
    ],
    "blocked_paths": [
      "~/.ssh",
      "~/.aws",
      "~/.config"
    ],
    "require_confirmation": [
      "write_file",
      "run_shell"
    ],
    "command_blocklist": [
      "rm -rf /",
      "sudo",
      "chmod 777"
    ]
  },

  "tools": {
    "external_paths": [
      "~/.config/ybs/tools",
      "./.ybs/tools"
    ],
    "timeout": 30,
    "max_output_size": 10240
  },

  "context": {
    "max_tokens": 100000,
    "auto_compact": true,
    "compact_at": 95,
    "repo_map": true,
    "repo_map_tokens": 1000
  },

  "agent": {
    "max_iterations": 25,
    "repetition_threshold": 3,
    "stateless": true
  },

  "ui": {
    "theme": "auto",
    "color": true,
    "markdown": true
  },

  "logging": {
    "level": "info",
    "file": "~/.config/ybs/logs/ybs.log",
    "security_log": "~/.config/ybs/logs/security.log"
  }
}
```

---

## Configuration Merging

When multiple config files exist, they're **merged deeply** (not replaced):

**Example**:

User config (`~/.config/ybs/config.json`):
```json
{
  "llm": {
    "provider": "openai",
    "temperature": 0.8
  },
  "security": {
    "level": "balanced"
  }
}
```

Project config (`./.ybs.json`):
```json
{
  "llm": {
    "model": "gpt-4-turbo"
  },
  "tools": {
    "external_paths": ["./.ybs/tools"]
  }
}
```

**Merged result**:
```json
{
  "llm": {
    "provider": "openai",        // from user
    "model": "gpt-4-turbo",       // from project (added)
    "temperature": 0.8,           // from user
    "endpoint": "...",            // from defaults
    "apiKey": null,               // from defaults
    "maxTokens": 4096,            // from defaults
    "streaming": true             // from defaults
  },
  "security": {
    "level": "balanced",          // from user
    "allowed_paths": [...],       // from defaults
    "blocked_paths": [...],       // from defaults
    "require_confirmation": [...]  // from defaults
  },
  "tools": {
    "external_paths": ["./.ybs/tools"], // from project
    "timeout": 30,                // from defaults
    "max_output_size": 10240      // from defaults
  }
}
```

---

## Special Variables

Config files can use variables that are expanded at runtime:

- `{{CWD}}` - Current working directory
- `{{HOME}}` - User home directory
- `{{USER}}` - Current username
- `{{HOSTNAME}}` - Machine hostname

**Example**:
```json
{
  "security": {
    "allowed_paths": [
      "{{CWD}}",
      "{{HOME}}/projects"
    ]
  },
  "logging": {
    "file": "{{HOME}}/.config/ybs/logs/{{HOSTNAME}}.log"
  }
}
```

---

## Provider-Specific Configuration

### Ollama (Local LLM)

```json
{
  "llm": {
    "provider": "ollama",
    "model": "qwen2.5-coder:14b",
    "endpoint": "http://localhost:11434",
    "apiKey": null
  }
}
```

**Notes**:
- No API key required
- Must have Ollama running locally
- Pull model first: `ollama pull qwen2.5-coder:14b`

---

### OpenAI (Cloud)

```json
{
  "llm": {
    "provider": "openai",
    "model": "gpt-4-turbo",
    "endpoint": "https://api.openai.com/v1",
    "apiKey": "sk-..."
  }
}
```

**Notes**:
- API key required (get from platform.openai.com)
- Costs money per token
- Requires internet connection

---

### Anthropic (Cloud)

```json
{
  "llm": {
    "provider": "anthropic",
    "model": "claude-sonnet-4.5",
    "endpoint": "https://api.anthropic.com",
    "apiKey": "sk-ant-..."
  }
}
```

**Notes**:
- API key required (get from console.anthropic.com)
- Uses different API format (agent handles translation)
- Excellent for coding tasks

---

### OpenAI-Compatible (LocalAI, LM Studio, etc.)

```json
{
  "llm": {
    "provider": "openai-compatible",
    "model": "codellama",
    "endpoint": "http://localhost:1234/v1",
    "apiKey": null
  }
}
```

**Notes**:
- Works with any OpenAI-compatible API
- LocalAI, LM Studio, vLLM, Ollama (with `/v1` endpoint)
- No API key usually required for local servers

---

## Configuration Validation

Agent validates configuration at startup:

```
✓ Config file found: ./.ybs.json
✓ Valid JSON
✓ Schema valid
✓ Provider 'ollama' supported
✓ Model 'qwen2.5-coder:14b' format valid
✓ Endpoint reachable: http://localhost:11434
✓ Security settings valid
⚠ Warning: API key not set (using Ollama default)

Configuration loaded successfully.
```

**Validation checks**:
- JSON syntax
- Schema compliance
- Provider support
- Path existence
- Endpoint reachability (optional)
- Security settings consistency

---

## Best Practices

### 1. Use Project Configs for Project-Specific Settings
```bash
# Create project config
$ cd ~/projects/myapp
$ echo '{"llm": {"model": "codellama:13b"}}' > .ybs.json
$ git add .ybs.json
$ git commit -m "Add YBS config for specialized model"
```

### 2. Keep API Keys in User Config, Not Project Config
```bash
# ✓ Good: User config (not committed)
~/.config/ybs/config.json: {"apiKey": "sk-..."}

# ✗ Bad: Project config (might be committed)
./.ybs.json: {"apiKey": "sk-..."}
```

### 3. Use Environment Variables for CI/CD
```bash
export YBS_API_KEY="sk-..."
export YBS_PROVIDER="openai"
ybs --model gpt-4-turbo
```

### 4. Document Project Config Requirements
```markdown
# README.md

## Setup

1. Install YBS
2. Create `.ybs.json` with project settings (see `.ybs.json.example`)
3. Add your API key to `~/.config/ybs/config.json`
```

---

## References

- **Bootstrap spec**: [../specs/ybs-spec.md](../specs/ybs-spec.md) Section 2 (Configuration)
- **Architectural decision**: [../specs/ybs-decisions.md](../specs/ybs-decisions.md) D05 (Configuration System)
- **Security implications**: [security-model.md](security-model.md)

---

**Version History**:
- 0.1.0 (2026-01-17): Initial canonical reference extracted from distributed documentation
