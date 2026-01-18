# Step 000042: Web Search Tool Implementation

**GUID**: a3b4c5d6e7f8
**Title**: Web Search Tool Implementation
**Implements**: ybs-spec.md § 4.5 (Web Search Tool)
**Created**: 2026-01-18

---

## Objectives

- Implement `web_search` external tool as Bash script
- Enable web search via DuckDuckGo (no API key required)
- Support schema discovery via `--schema` flag
- Handle JSON input/output protocol
- Auto-discover via ToolDiscovery system
- Pass all test requirements (80% coverage target)

---

## Prerequisites

- Step 23-24 complete (External Tool Discovery implemented)
- `curl` available (standard on macOS)
- `jq` installed (`brew install jq`)

---

## Implementation

### 1. Create Tool Directory

```bash
mkdir -p ~/.config/ybs/tools
```

### 2. Create web_search Script

Create `~/.config/ybs/tools/web_search`:

```bash
#!/bin/bash
set -euo pipefail

# web_search - DuckDuckGo search tool for YBS
# Uses DuckDuckGo HTML scraping (no API key needed)

# Schema discovery
if [ "${1:-}" = "--schema" ]; then
  cat <<'EOF'
{
  "name": "web_search",
  "description": "Search the web for information. Returns titles, URLs, and snippets from search results.",
  "parameters": {
    "query": {
      "type": "string",
      "description": "Search query string",
      "required": true
    },
    "max_results": {
      "type": "integer",
      "description": "Maximum number of results to return (default: 5, max: 10)",
      "required": false
    }
  }
}
EOF
  exit 0
fi

# Read JSON from stdin
INPUT=$(cat)

# Parse parameters using jq
QUERY=$(echo "$INPUT" | jq -r '.query // empty')
MAX_RESULTS=$(echo "$INPUT" | jq -r '.max_results // 5')

# Validate query
if [ -z "$QUERY" ]; then
  jq -n '{
    "success": false,
    "error": "Query parameter is required and cannot be empty"
  }'
  exit 0
fi

# Validate max_results bounds (1-10)
if [ "$MAX_RESULTS" -lt 1 ]; then
  MAX_RESULTS=1
fi
if [ "$MAX_RESULTS" -gt 10 ]; then
  MAX_RESULTS=10
fi

# URL encode query
ENCODED_QUERY=$(echo "$QUERY" | jq -sRr @uri)

# DuckDuckGo HTML endpoint
DDG_URL="https://html.duckduckgo.com/html/?q=${ENCODED_QUERY}"

# Fetch results with timeout
RESPONSE=$(curl -s -m 30 \
  -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
  "$DDG_URL" || echo "CURL_ERROR")

if [ "$RESPONSE" = "CURL_ERROR" ]; then
  jq -n '{
    "success": false,
    "error": "Network error: Unable to reach search service"
  }'
  exit 0
fi

# Parse HTML results
# DuckDuckGo HTML structure: <a class="result__a" href="...">Title</a>
# Snippet: <a class="result__snippet">...</a>

# Extract titles and URLs using grep/sed
TITLES=$(echo "$RESPONSE" | grep -o 'class="result__a"[^>]*>[^<]*' | sed 's/.*>\(.*\)/\1/' | head -n "$MAX_RESULTS")
URLS=$(echo "$RESPONSE" | grep -o 'class="result__url"[^>]*>[^<]*' | sed 's/.*>\(.*\)/\1/' | sed 's/&amp;/\&/g' | head -n "$MAX_RESULTS")
SNIPPETS=$(echo "$RESPONSE" | grep -o 'class="result__snippet">[^<]*' | sed 's/.*>\(.*\)/\1/' | head -n "$MAX_RESULTS")

# Check if we got any results
TITLE_COUNT=$(echo "$TITLES" | grep -c . || echo "0")

if [ "$TITLE_COUNT" -eq 0 ]; then
  jq -n --arg query "$QUERY" '{
    "success": true,
    "result": "No results found for query: \($query)",
    "metadata": {
      "query": $query,
      "results_count": 0,
      "search_engine": "duckduckgo"
    }
  }'
  exit 0
fi

# Format results as numbered list
RESULT_TEXT="Found $TITLE_COUNT results:\n"
INDEX=1

# Combine results line by line
while IFS= read -r TITLE && IFS= read -r URL <&3 && IFS= read -r SNIPPET <&4; do
  if [ -n "$TITLE" ]; then
    RESULT_TEXT="${RESULT_TEXT}\n${INDEX}. ${TITLE}"
    RESULT_TEXT="${RESULT_TEXT}\n   URL: ${URL}"
    RESULT_TEXT="${RESULT_TEXT}\n   ${SNIPPET}\n"
    INDEX=$((INDEX + 1))
  fi
done <<< "$TITLES" 3<<< "$URLS" 4<<< "$SNIPPETS"

# Return JSON response
jq -n \
  --arg result "$RESULT_TEXT" \
  --arg query "$QUERY" \
  --argjson count "$TITLE_COUNT" \
  '{
    "success": true,
    "result": $result,
    "metadata": {
      "query": $query,
      "results_count": $count,
      "search_engine": "duckduckgo"
    }
  }'
```

### 3. Make Executable

```bash
chmod +x ~/.config/ybs/tools/web_search
```

### 4. Install jq (if not present)

```bash
# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "Installing jq..."
  brew install jq
fi
```

### 5. Test Schema Discovery

```bash
~/.config/ybs/tools/web_search --schema
```

Expected output:
```json
{
  "name": "web_search",
  "description": "Search the web for information...",
  "parameters": {...}
}
```

### 6. Test Search Execution

```bash
echo '{"query": "Swift programming"}' | ~/.config/ybs/tools/web_search
```

Expected output:
```json
{
  "success": true,
  "result": "Found 5 results:\n\n1. Swift - Apple Developer\n   URL: https://developer.apple.com/swift/\n   ...",
  "metadata": {...}
}
```

---

## Verification

### Manual Tests

- [ ] Schema discovery works: `~/.config/ybs/tools/web_search --schema`
- [ ] Search returns results: `echo '{"query": "test"}' | ~/.config/ybs/tools/web_search`
- [ ] max_results parameter works: `echo '{"query": "test", "max_results": 3}' | ~/.config/ybs/tools/web_search`
- [ ] Empty query returns error: `echo '{"query": ""}' | ~/.config/ybs/tools/web_search`
- [ ] Tool is executable: `ls -l ~/.config/ybs/tools/web_search` shows `-rwxr-xr-x`

### Automated Tests

Run Swift tests:

```bash
cd systems/bootstrap/builds/test7
swift test --filter WebSearchToolTests
```

All tests must pass:
- ✓ `webSearchToolSchema()` - Schema discovery
- ✓ `webSearchValidQuery()` - Valid query returns results
- ✓ `webSearchMaxResults()` - Respects max_results parameter
- ✓ `webSearchEmptyQuery()` - Empty query returns error
- ✓ `webSearchMaxResultsBounds()` - Validates bounds (1-10)
- ✓ `webSearchAutoDiscovery()` - ToolDiscovery finds the tool

### Integration Test

Test in test7 interactive session:

```bash
cd systems/bootstrap/builds/test7
swift run test7
```

In the chat:
```
You: /reload-tools
You: /tools
# Should list web_search in external tools

You: Search the web for Swift async/await tutorials
# LLM should call web_search tool and provide results
```

### Test Coverage

Run with coverage (if available):

```bash
swift test --enable-code-coverage
# Target: 80% coverage
```

---

## Success Criteria

1. ✅ `web_search` script exists at `~/.config/ybs/tools/web_search`
2. ✅ Script is executable (`chmod +x`)
3. ✅ `jq` dependency installed
4. ✅ Schema discovery returns valid JSON
5. ✅ Search returns properly formatted results
6. ✅ All manual tests pass
7. ✅ All automated Swift tests pass
8. ✅ Tool auto-discovers in test7 startup
9. ✅ Tool callable by LLM during chat
10. ✅ Test coverage ≥ 80%

---

## Troubleshooting

### Issue: "jq: command not found"
**Solution**: Install jq with `brew install jq`

### Issue: "Permission denied" when executing tool
**Solution**: Run `chmod +x ~/.config/ybs/tools/web_search`

### Issue: No results returned
**Possible causes**:
- Network connectivity issue
- DuckDuckGo rate limiting (wait 10 seconds, retry)
- Query too specific (try broader query)

### Issue: Tool not auto-discovered
**Check**:
- Tool is in `~/.config/ybs/tools/` directory
- Tool is executable (`ls -l` shows `x` permission)
- Tool returns valid JSON for `--schema` flag
- Restart test7 or run `/reload-tools`

---

## Notes

- **No API key required**: DuckDuckGo HTML scraping works without authentication
- **Rate limiting**: DuckDuckGo may rate limit aggressive usage. Add delays if needed.
- **Privacy**: DuckDuckGo doesn't track searches
- **Alternatives**: Can be replaced with other search backends (SearXNG, Brave, etc.)
- **HTML parsing**: Uses grep/sed for simplicity. Could use dedicated HTML parser for robustness.

---

## References

- **Spec**: ybs-spec.md § 4.5 (Web Search Tool - Complete Specification)
- **External Tool Protocol**: ybs-spec.md § 5.2 (Runtime Tool Loading)
- **Test Requirements**: ybs-spec.md § 4.5 (Test Requirements section)
- **Tool Discovery**: Step 23-24 (External Tool Discovery)

---

## Next Steps

After verification passes:
- Document completion in `build-history/ybs-step_a3b4c5d6e7f8-DONE.txt`
- Update `BUILD_STATUS.md`
- Proceed to next step (or mark build complete if this is final step)
