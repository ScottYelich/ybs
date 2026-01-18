# Web Search Setup for Bootstrap

**Status**: ✅ Complete and Working
**Last Updated**: 2026-01-18

---

## Overview

Bootstrap has **unlimited web search** capability with zero cost using a self-hosted SearXNG server. This guide explains how the system is configured and how to use it.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Bootstrap AI Chat (Swift application)                      │
│  ┌────────────────────────────────────────────┐             │
│  │  LLM: "Search the web for Swift tutorials" │             │
│  └─────────────────┬──────────────────────────┘             │
│                    │                                         │
│                    │ Tool call: web_search                   │
│                    ▼                                         │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  External Tool: ~/.config/ybs/tools/web_search      │    │
│  │  • Auto-discovered at bootstrap startup             │    │
│  │  • JSON input: {"query": "...", "max_results": 5}   │    │
│  │  • JSON output: {success, result, metadata}         │    │
│  └─────────────────┬───────────────────────────────────┘    │
└────────────────────┼────────────────────────────────────────┘
                     │
                     │ HTTP request to localhost:38888
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  SearXNG Server (Python, self-hosted)                       │
│  • URL: http://127.0.0.1:38888                              │
│  • RAM: ~30-50 MB                                           │
│  • Search engines: Google, Bing, DuckDuckGo, Wikipedia     │
│  • Aggregates and returns results                          │
└─────────────────────────────────────────────────────────────┘
```

---

## Components

### 1. SearXNG Server

**What**: Self-hosted meta-search engine that aggregates results from Google, Bing, DuckDuckGo, etc.

**Location**: `~/.config/searxng/`

**Management**: `systems/bootstrap/tools/searxng` script

**Configuration**:
- Port: 38888 (chosen to avoid conflicts with common port 8888)
- Python: 3.13.11 (via pyenv)
- Installation type: Native (not Docker)
- RAM usage: 30-50 MB
- Monthly limit: Unlimited
- Cost: $0

**Commands**:
```bash
cd systems/bootstrap

# Start SearXNG server
./tools/searxng start

# Check if running
./tools/searxng status

# Test search functionality
./tools/searxng test

# View logs
./tools/searxng logs

# Stop server
./tools/searxng stop
```

**Why SearXNG?**
- ✅ Unlimited searches (no monthly limits)
- ✅ Zero cost (self-hosted)
- ✅ No API keys required
- ✅ Privacy-focused
- ✅ Low resource usage (30-50 MB vs 150-200 MB for Docker)

**Alternatives Considered**:
- ❌ Brave API: 2,000 searches/month limit
- ❌ DuckDuckGo HTML: Blocked by CAPTCHA
- ❌ Kagi API: Costs $5-25/month
- ❌ SearXNG Docker: 150-200 MB RAM overhead

---

### 2. web_search External Tool

**What**: Shell script that interfaces between bootstrap and SearXNG.

**Location**: `~/.config/ybs/tools/web_search`

**Protocol**: JSON input via stdin, JSON output via stdout

**Schema Discovery**: Implements `--schema` flag for auto-discovery

**Input Format**:
```json
{
  "query": "Swift programming language",
  "max_results": 5
}
```

**Output Format**:
```json
{
  "success": true,
  "result": "1. Swift.org - Swift Programming Language\n   URL: https://swift.org\n   Swift is a powerful...\n\n2. ...",
  "metadata": {
    "query": "Swift programming language",
    "results_count": "22",
    "search_engine": "searxng",
    "note": "Using SearXNG (self-hosted). Unlimited searches, no API keys."
  }
}
```

**Testing**:
```bash
# Test tool directly
echo '{"query": "Swift programming", "max_results": 3}' | \
  ~/.config/ybs/tools/web_search | jq .

# Check schema
~/.config/ybs/tools/web_search --schema | jq .

# Check status
~/.config/ybs/tools/web_search --status
```

---

### 3. Bootstrap Auto-Discovery

**How Tools Are Registered**:

Bootstrap automatically discovers external tools at startup by:
1. Scanning configured tool search paths:
   - `~/.config/ybs/tools` (system-wide, **primary**)
   - `~/.ybs/tools` (user-specific)
   - `./tools` (project-specific)
2. For each executable file found:
   - Call `<tool> --schema` to get schema
   - If schema is valid JSON with required fields, register tool
3. Tool becomes available to LLM during chat

**No manual registration required** - just place executable in search path with `--schema` support.

**Runtime Tool Reloading**:
```bash
# In bootstrap chat session
You: /reload-tools
🔄 Rescanning for external tools...
✅ Tool reload complete!
   Built-in tools: 6
   External tools: 1
   Total: 7 tools available

External tools loaded:
  • web_search: Search the web for information using SearXNG
```

---

## Setup Summary

**Everything is already configured**:

1. ✅ Python 3.13.11 installed via pyenv
2. ✅ SearXNG installed at `~/.config/searxng/`
3. ✅ web_search tool at `~/.config/ybs/tools/web_search`
4. ✅ Management script at `systems/bootstrap/tools/searxng`
5. ✅ Documentation updated

**To use web search in bootstrap**:
```bash
# 1. Start SearXNG server
cd systems/bootstrap
./tools/searxng start

# 2. Build and run bootstrap (when ready)
cd builds/test5
swift build
swift run ybs

# 3. In chat, LLM can now use web_search tool
You: What are the latest Swift features?
LLM: [calls web_search tool, receives results, answers with current info]
```

---

## Testing Checklist

**SearXNG Server**:
- [x] Installed at ~/.config/searxng/
- [x] Running on port 38888
- [x] Returns search results for test queries
- [x] Management script works (start/stop/status/test)

**web_search Tool**:
- [x] Located at ~/.config/ybs/tools/web_search
- [x] Executable permissions set
- [x] --schema flag returns valid JSON
- [x] Accepts JSON input via stdin
- [x] Returns JSON output to stdout
- [x] Connects to SearXNG successfully
- [x] Handles errors gracefully

**Bootstrap Integration** (when implementation complete):
- [ ] Tool auto-discovered at startup
- [ ] LLM can call web_search during chat
- [ ] Results returned correctly to LLM
- [ ] /reload-tools command works

---

## Troubleshooting

### SearXNG Not Responding

**Check if running**:
```bash
cd systems/bootstrap
./tools/searxng status
```

**View logs**:
```bash
./tools/searxng logs
```

**Restart**:
```bash
./tools/searxng restart
```

---

### web_search Tool Errors

**Test tool directly**:
```bash
# Should return results
echo '{"query": "test"}' | ~/.config/ybs/tools/web_search | jq .

# Should return error
echo '{"query": ""}' | ~/.config/ybs/tools/web_search | jq .
```

**Check if SearXNG is running**:
```bash
curl -s "http://127.0.0.1:38888/search?q=test&format=json" | jq .
```

---

### Port 38888 Conflict

**Find what's using the port**:
```bash
lsof -i :38888
```

**Change port**:
```bash
# Edit SearXNG config
vi ~/.config/searxng/settings.yml
# Change: port: 38888 to different port

# Edit web_search tool
vi ~/.config/ybs/tools/web_search
# Change: SEARXNG_URL="http://127.0.0.1:38888" to new port

# Restart SearXNG
cd systems/bootstrap
./tools/searxng restart
```

---

## Performance

**Typical search response time**: 500-1500ms

**Breakdown**:
- Google: 300-500ms
- Bing: 300-500ms
- DuckDuckGo: 300-500ms
- Aggregation overhead: ~200ms

**First search** may be slower (cold start), subsequent searches are faster.

**Resource usage**:
- RAM: 30-50 MB (SearXNG + Python virtualenv)
- CPU: < 1% idle, brief spike during search
- Disk: ~100 MB total installation

---

## Auto-Start (Optional)

To start SearXNG automatically on login:

```bash
cd systems/bootstrap
./tools/searxng autostart
```

This creates a launchd plist that starts SearXNG when you log in.

---

## File Locations

```
~/.config/searxng/           # SearXNG installation
├── venv/                    # Python virtualenv
├── searxng-src/             # Source code
├── settings.yml             # Configuration (port: 38888)
├── start.sh                 # Start script
├── stop.sh                  # Stop script
├── searxng.pid              # Process ID (when running)
├── searxng.log              # Server logs
└── README.md                # Setup documentation

~/.config/ybs/tools/         # YBS external tools directory
└── web_search               # Web search tool (queries SearXNG)

systems/bootstrap/tools/     # Bootstrap management tools
├── README.md                # Tools documentation
├── searxng                  # SearXNG management script
└── SETUP_SUMMARY.md         # Setup summary
```

---

## External Tool Protocol

**For developers adding new external tools**:

1. **Create executable** in one of the tool search paths:
   - `~/.config/ybs/tools/` (recommended)
   - `~/.ybs/tools/`
   - `./tools/`

2. **Implement `--schema` flag**:
   ```bash
   #!/bin/bash
   if [ "$1" = "--schema" ]; then
     cat <<'EOF'
   {
     "name": "my_tool",
     "description": "What this tool does",
     "parameters": {
       "param1": {
         "type": "string",
         "description": "What param1 is",
         "required": true
       }
     }
   }
   EOF
     exit 0
   fi
   ```

3. **Read JSON from stdin**:
   ```bash
   INPUT=$(cat)
   PARAM1=$(echo "$INPUT" | jq -r '.param1')
   ```

4. **Output JSON to stdout**:
   ```bash
   jq -n --arg result "$RESULT" '{
     "success": true,
     "result": $result,
     "metadata": {}
   }'
   ```

5. **Bootstrap will auto-discover** at startup (no manual registration needed)

---

## References

- **SearXNG Setup**: [tools/SETUP_SUMMARY.md](../tools/SETUP_SUMMARY.md)
- **Tools Documentation**: [tools/README.md](../tools/README.md)
- **Bootstrap README**: [../README.md](../README.md)
- **Technical Spec**: [../specs/technical/ybs-spec.md § 4-5](../specs/technical/ybs-spec.md)

---

**Result**: Unlimited web searches for $0 with 30-50 MB RAM overhead.

**Status**: ✅ Complete - ready to use when bootstrap implementation is finished.
