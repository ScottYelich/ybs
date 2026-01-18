# Bootstrap Tools

**Helper scripts for the bootstrap system.**

## Available Tools

### `searxng` - SearXNG Management

Manages the SearXNG web search server used by bootstrap.

**Usage:**
```bash
# Start SearXNG server
./searxng start

# Stop SearXNG server
./searxng stop

# Restart SearXNG server
./searxng restart

# Check server status
./searxng status

# View server logs (live)
./searxng logs

# Test search functionality
./searxng test

# Setup auto-start on login
./searxng autostart

# Show help
./searxng --help
```

**Details:**
- **URL**: http://127.0.0.1:38888
- **RAM**: ~30-50 MB
- **Monthly Limit**: Unlimited
- **Cost**: $0 (self-hosted)

**Installation Location**: `~/.config/searxng/`

**See Also**: [SearXNG Setup Guide](~/.config/searxng/README.md)

---

## Adding New Tools

When adding new helper tools to this directory:

1. **Make it executable**: `chmod +x toolname`
2. **Add --help**: Support `--help` flag with usage info
3. **Document it**: Add section to this README
4. **Keep it focused**: One tool = one purpose
5. **Test it**: Verify it works from any directory

**Tool naming**: Use lowercase, no file extensions (e.g., `searxng`, not `searxng.sh`)

---

## Tool Guidelines

### Script Header Template

```bash
#!/bin/bash
set -e

# ==============================================================================
# toolname - Brief Description
# ==============================================================================
#
# Longer description of what this tool does.
#
# USAGE:
#   toolname command     Description
#   toolname --help      Show help
#
# ==============================================================================
```

### Help Flag

All tools should support `--help`:

```bash
case "${1:-}" in
  --help|-h|help)
    show_help
    ;;
  *)
    # ... handle commands
    ;;
esac
```

### Error Handling

```bash
set -e  # Exit on error

# Use colored output for clarity
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'  # No Color

print_error() { echo -e "${RED}❌ $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
```

---

## Future Tools (Ideas)

Potential tools that could be added:

- **`bootstrap`** - Build/run bootstrap binary
- **`test-runner`** - Run specific test suites
- **`lint`** - Code quality checks
- **`benchmark`** - Performance benchmarks
- **`tools-doctor`** - Verify all dependencies installed

---

## Version History

- **0.1.0** (2026-01-18): Initial tools directory with `searxng` management script

---

**Location**: `systems/bootstrap/tools/`
