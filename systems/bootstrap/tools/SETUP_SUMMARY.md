# SearXNG Setup Summary

**Date**: 2026-01-18
**Status**: ✅ Complete and Working

---

## What Was Accomplished

### 1. Installed SearXNG Natively

- **Python**: 3.13.11 (via pyenv)
- **Location**: `~/.config/searxng/`
- **Method**: Native install (not Docker)
- **RAM Usage**: 30-50 MB
- **Port**: 38888 (changed from 8888 to avoid conflicts)

### 2. Created Management Script

**Location**: `systems/bootstrap/tools/searxng`

**Commands**:
```bash
./tools/searxng start      # Start server
./tools/searxng stop       # Stop server
./tools/searxng restart    # Restart server
./tools/searxng status     # Check status
./tools/searxng logs       # View logs
./tools/searxng test       # Test search
./tools/searxng autostart  # Setup auto-start
./tools/searxng --help     # Show help
```

### 3. Updated web_search Tool

**Location**: `~/.config/ybs/tools/web_search`

- Now queries SearXNG at http://127.0.0.1:38888
- Returns real search results (Google, Bing, DuckDuckGo aggregated)
- Unlimited searches, no API keys
- Includes status checking with `--status` flag

### 4. Updated Bootstrap Documentation

**Updated files**:
- `systems/bootstrap/README.md` - Added Management Tools section
- `systems/bootstrap/specs/technical/ybs-spec.md` - Documented SearXNG implementation
- `systems/bootstrap/tools/README.md` - Tools documentation

### 5. Created Bootstrap Tools Directory

**Location**: `systems/bootstrap/tools/`

Structure for helper scripts with:
- README with guidelines
- searxng management script
- Template for future tools

---

## Testing

All tests passing:

```bash
# Status check
✅ ./tools/searxng status
   Running on http://127.0.0.1:38888
   Server responding

# Search test
✅ ./tools/searxng test
   25 results found for "test"
   Search successful

# web_search tool test
✅ echo '{"query": "test"}' | ~/.config/ybs/tools/web_search
   Real results returned from SearXNG
```

---

## Why These Choices?

### Port 38888 (not 8888)
- 8888 commonly used by other services
- 38888 less likely to conflict
- Easy to remember (3 + 8888)

### Native Install (not Docker)
- Much lighter: 30-50 MB vs 300 MB
- No Docker overhead
- Faster startup
- Direct Python control

### SearXNG (not Brave API or DuckDuckGo)
- **Unlimited searches** (no 2,000/month limit)
- **Zero cost** (no API fees)
- **No API keys** (no signup friction)
- **Privacy-focused** (self-hosted)
- **DuckDuckGo blocked** (CAPTCHA challenges)

---

## File Locations

```
~/.config/searxng/           # SearXNG installation
├── venv/                    # Python virtualenv
├── searxng-src/             # Source code
├── settings.yml             # Configuration
├── start.sh                 # Start script
├── stop.sh                  # Stop script
├── searxng.pid              # Process ID (when running)
├── searxng.log              # Server logs
└── README.md                # Setup documentation

systems/bootstrap/tools/     # Bootstrap management tools
├── README.md                # Tools documentation
├── searxng                  # SearXNG management script
└── SETUP_SUMMARY.md         # This file

~/.config/ybs/tools/         # YBS external tools
└── web_search               # Web search tool (queries SearXNG)
```

---

## Quick Reference

### Start SearXNG
```bash
cd systems/bootstrap
./tools/searxng start
```

### Check if Running
```bash
./tools/searxng status
```

### Test Search
```bash
./tools/searxng test
```

### Use from Web Search Tool
```bash
echo '{"query": "Swift programming", "max_results": 3}' | \
  ~/.config/ybs/tools/web_search | jq .
```

---

## Auto-Start (Optional)

To start SearXNG automatically on login:

```bash
cd systems/bootstrap
./tools/searxng autostart
```

This creates a launchd plist that starts SearXNG when you log in.

---

## Troubleshooting

**SearXNG not responding**:
```bash
# Check if running
./tools/searxng status

# View logs
./tools/searxng logs

# Restart
./tools/searxng restart
```

**Port conflict**:
```bash
# Find what's using port 38888
lsof -i :38888

# Change port in ~/.config/searxng/settings.yml
# Then restart
```

**Search results slow**:
- First search may be slower (cold start)
- SearXNG aggregates from multiple engines
- Typical response: 500-1500ms

---

## Performance

**Typical search**:
- Query: "Swift programming"
- Results: 22 found
- Time: ~800ms
- Engines: Google, Bing, DuckDuckGo, Wikipedia

**Resource usage**:
- RAM: 30-50 MB (confirmed via Activity Monitor)
- CPU: < 1% when idle, brief spike during search
- Disk: ~100 MB total installation
- Network: Only during searches

---

## Comparison to Alternatives

| Solution | Limit | Cost | RAM | Setup | Chosen? |
|----------|-------|------|-----|-------|---------|
| **SearXNG Native** | ∞ | $0 | 30-50 MB | 15 min | ✅ **YES** |
| SearXNG Docker | ∞ | $0 | 150-200 MB | 5 min | ❌ Too heavy |
| Brave API | 2,000/mo | $0-5 | 0 MB | 30 sec | ❌ Monthly limits |
| DuckDuckGo HTML | N/A | $0 | 0 MB | N/A | ❌ CAPTCHA blocks |
| Kagi API | 300/mo | $5-25 | 0 MB | 30 sec | ❌ Costs money |

---

## Result

**✅ Unlimited web searches for $0 with 30-50 MB RAM overhead**

No API keys, no monthly limits, completely self-hosted, privacy-focused.

---

**Last Updated**: 2026-01-18
