# YBS Usage Documentation

This directory will contain end-user documentation for installing, configuring, and using YBS.

## Status

**Current**: Empty - YBS not yet implemented

**Purpose**: Provide clear, practical guides for users who want to run YBS as their AI agent (reasoning + tool using LLM chat).

## Planned Content

### Installation Guide (`installation.md`)
- System requirements (macOS 14+, future Linux support)
- Installation methods:
  - Homebrew (planned)
  - Pre-built binaries from releases
  - Building from source
- Ollama setup for local LLM (recommended default)
- Verifying installation
- Uninstall instructions

### Quick Start Guide (`quickstart.md`)
- First run and configuration
- Basic chat session
- Your first tool call (reading a file)
- Making edits to code
- Common workflows:
  - Debugging a function
  - Implementing a feature
  - Refactoring code
  - Running tests
- Exiting and session management

### Configuration Reference (`configuration.md`)
- Configuration file locations and precedence
- Complete config.json schema reference
- Common configuration examples:
  - Using OpenAI instead of Ollama
  - Adjusting safety settings
  - Configuring custom tools
  - Setting context limits
  - Customizing UI appearance
- Environment variable overrides
- CLI argument reference
- Troubleshooting config issues

### CLI Commands Reference (`commands.md`)
- `ybs` - Basic interactive mode
- `ybs --config <file>` - Custom config
- `ybs --model <name>` - Override model
- `ybs --provider <name>` - Override provider
- `ybs --no-sandbox` - Disable sandboxing (dangerous)
- `ybs --dry-run` - Preview mode
- `ybs --version` - Version info
- `ybs --help` - Help text
- Interactive commands (within session):
  - `/help` - Show help
  - `/exit` - Exit session
  - `/config` - Show current config
  - `/reset` - Reset conversation context

### Tools Reference (`tools.md`)
- Overview of tool system
- Built-in tools documentation:
  - `read_file` - Usage, parameters, examples
  - `write_file` - Usage, parameters, examples
  - `edit_file` - Usage, parameters, examples
  - `list_files` - Usage, parameters, examples
  - `search_files` - Usage, parameters, examples
  - `run_shell` - Usage, parameters, examples
- External tools:
  - Installing external tools
  - Creating custom tools
  - Tool protocol specification
  - Example: web-search tool
  - Example: web-fetch tool
- Tool confirmation and safety
- Disabling specific tools

### Troubleshooting Guide (`troubleshooting.md`)
- Common issues and solutions:
  - Connection refused (Ollama not running)
  - Model not found
  - Permission denied errors
  - Sandbox violations
  - Config file not found
  - JSON parse errors
  - Tool execution timeouts
  - Context limit exceeded
  - Infinite loop detected
- Debug mode and logging
- Reporting bugs
- Getting help

### Advanced Usage (`advanced.md`)
- Multi-model workflows
- Custom system prompts
- Working with large codebases
- Context management strategies
- Git integration and auto-commit
- Security considerations
- Performance tuning
- Using YBS in CI/CD (with --dry-run)
- Session recording and replay

### Best Practices (`best-practices.md`)
- Effective prompting for code changes
- When to use which tools
- Managing context efficiently
- Security hygiene:
  - Reviewing destructive operations
  - When to use sandbox bypass
  - Protecting sensitive files
- Workflow recommendations:
  - Feature development
  - Bug fixing
  - Code review assistance
  - Documentation generation
- Integration with other tools (editors, git, etc.)

## Audience

These guides target:
- Developers who want to use YBS for coding assistance
- Users familiar with command-line tools
- Those who may not know Swift (implementation language)
- Both beginners and advanced users (separate sections as needed)

## Documentation Style

All user docs should:
- **Start with examples** - Show, then explain
- **Be task-oriented** - Focus on "how do I..." scenarios
- **Include screenshots** (when CLI output is relevant)
- **Provide copy-paste commands** - Make it easy to follow along
- **Link to troubleshooting** - Anticipate common problems
- **Avoid implementation details** - Users don't need to know Swift internals

## Writing Guidelines

- Use second person ("you can", "your config")
- Provide concrete examples over abstract descriptions
- Include both simple and advanced usage for each feature
- Cross-reference related sections
- Keep language clear and concise
- Test all commands and examples

## FAQ Topics

Common questions to address:
- "Why choose YBS over Aider/Cursor/etc?"
- "Can I use GPT-4/Claude with YBS?"
- "How much does it cost to run?"
- "Is my code sent to the cloud?"
- "How do I add my own tools?"
- "Can I use YBS without Ollama?"
- "What languages/frameworks does YBS support?"
- "How does YBS handle large files?"

## Reference Material

User documentation should reference:
- Configuration schema from `../ybs-spec/ybs-spec.md`
- Tool definitions from `../ybs-spec/ybs-spec.md`
- Design principles from `../ybs-spec/ybs-spec.md`

Avoid referencing:
- Implementation details from build-from-scratch/
- Architectural decisions (unless relevant to user choice)
- Internal code structure

---

**Status**: Planning phase
**Target audience**: End users of YBS (developers using it for coding assistance)
**Prerequisites**: Basic command-line familiarity, Git knowledge helpful
