# Step 1: Initialize Project Structure

**Step ID**: 478a8c4b0cef
**System**: rest-api-client
**Version**: 1.0.0
**Estimated Time**: 2 minutes
**Depends On**: Step 0 (Build Configuration)

---

## Context

**What**: Create the project directory structure and initialize the build workspace

**Why**: Establishes organized structure for source code, tests, and build artifacts

**Implements**: rest-api-client-spec.md § 6.1 (File Organization)

---

## Prerequisites

- ✅ BUILD_CONFIG.json exists (created in Step 0)
- ✅ Build configuration validated

---

## Instructions

### 1. Read Build Configuration

Load configuration values from BUILD_CONFIG.json:

```bash
BUILD_NAME=$(jq -r '.build_name' BUILD_CONFIG.json)
LANGUAGE=$(jq -r '.language' BUILD_CONFIG.json)
```

**Alternative if jq not available**:
```python
import json
with open('BUILD_CONFIG.json') as f:
    config = json.load(f)
    build_name = config['build_name']
    language = config['language']
```

---

### 2. Determine File Extensions

Based on {{CONFIG:language}}, set appropriate file extension:

| Language | Source Extension | Test Extension |
|----------|-----------------|----------------|
| python | .py | test_*.py |
| javascript | .js | *.test.js |
| ruby | .rb | *_spec.rb |

---

### 3. Create Build Directory

Create the build workspace directory:

```bash
# Ensure we're in examples/03-rest-api directory
cd examples/03-rest-api

# Create builds directory if it doesn't exist
mkdir -p builds

# Create this specific build directory
mkdir -p builds/{{CONFIG:build_name}}

# Navigate into build directory
cd builds/{{CONFIG:build_name}}
```

---

### 4. Create BUILD_STATUS.md

Create build status tracking file:

```markdown
# Build Status: {{CONFIG:build_name}}

**System**: rest-api-client
**Started**: $(date '+%Y-%m-%d %H:%M:%S')
**Language**: {{CONFIG:language}}
**Status**: In Progress

---

## Steps

- [x] Step 0: Build Configuration
- [ ] Step 1: Initialize Project Structure (IN PROGRESS)
- [ ] Step 2: Create Main Client Script
- [ ] Step 3: Create Test Suite
- [ ] Step 4: Run Tests and Verify Coverage
- [ ] Step 5: Integration Test
- [ ] Step 6: Final Verification

---

## Configuration

```json
{
  "build_name": "{{CONFIG:build_name}}",
  "language": "{{CONFIG:language}}",
  "api_base_url": "{{CONFIG:api_base_url}}",
  "default_endpoint": "{{CONFIG:default_endpoint}}",
  "json_indent": {{CONFIG:json_indent}},
  "timeout": {{CONFIG:timeout}}
}
```

---

## Notes

Build initialized: $(date)
```

**Save to**: `BUILD_STATUS.md` in build directory

---

### 5. Copy BUILD_CONFIG.json

Copy the configuration file into the build directory:

```bash
cp ../../BUILD_CONFIG.json .
```

**Verify**:
```bash
ls -la BUILD_CONFIG.json
cat BUILD_CONFIG.json
```

---

### 6. Create Dependencies File (if needed)

**For Python**:
Create `requirements.txt`:
```
requests>=2.28.0
pytest>=7.0.0
pytest-cov>=4.0.0
pytest-mock>=3.10.0
```

**For JavaScript**:
Create `package.json`:
```json
{
  "name": "rest-api-client",
  "version": "1.0.0",
  "description": "Simple REST API client for JSONPlaceholder",
  "main": "api_client.js",
  "scripts": {
    "test": "jest --coverage"
  },
  "devDependencies": {
    "jest": "^29.0.0"
  }
}
```

**For Ruby**:
Create `Gemfile`:
```ruby
source 'https://rubygems.org'

gem 'rspec', '~> 3.12'
gem 'webmock', '~> 3.18'
```

---

### 7. Display Structure

Show the created directory structure:

```bash
tree . -L 2
# Or if tree not available:
find . -maxdepth 2 -type f -o -type d | sort
```

**Expected output**:
```
.
├── BUILD_CONFIG.json
├── BUILD_STATUS.md
└── requirements.txt (or package.json or Gemfile)
```

---

## Verification

**This step is complete when:**
- ✅ Build directory exists at `examples/03-rest-api/builds/{{CONFIG:build_name}}`
- ✅ BUILD_CONFIG.json copied to build directory
- ✅ BUILD_STATUS.md created with current status
- ✅ Dependencies file created for chosen language
- ✅ All files have correct content
- ✅ No errors during directory creation

**Verification Commands**:
```bash
# Check directory exists
[ -d "examples/03-rest-api/builds/{{CONFIG:build_name}}" ] && echo "✅ Build directory exists" || echo "❌ Missing"

# Check files exist
cd examples/03-rest-api/builds/{{CONFIG:build_name}}
[ -f BUILD_CONFIG.json ] && echo "✅ BUILD_CONFIG.json" || echo "❌ Missing"
[ -f BUILD_STATUS.md ] && echo "✅ BUILD_STATUS.md" || echo "❌ Missing"

# Language-specific dependency file
# Python:
[ -f requirements.txt ] && echo "✅ requirements.txt" || echo "❌ Missing"
# JavaScript:
[ -f package.json ] && echo "✅ package.json" || echo "❌ Missing"
# Ruby:
[ -f Gemfile ] && echo "✅ Gemfile" || echo "❌ Missing"
```

**Retry Limit**: 3 attempts

---

## Troubleshooting

**Problem**: Cannot create builds directory (permission denied)
**Solution**: Check write permissions on examples/03-rest-api directory

**Problem**: BUILD_CONFIG.json not found in expected location
**Solution**: Verify Step 0 completed successfully, check current directory

**Problem**: jq not available for reading JSON
**Solution**: Use Python or manual extraction to read config values

---

## Output Files

| File | Purpose | Format |
|------|---------|--------|
| BUILD_CONFIG.json | Build configuration | JSON |
| BUILD_STATUS.md | Step completion tracking | Markdown |
| requirements.txt | Python dependencies | Plain text |
| package.json | Node.js dependencies | JSON |
| Gemfile | Ruby dependencies | Ruby DSL |

---

## Next Step

**Step 2**: Create Main Client Script

---

## References

- **Specification**: [../specs/rest-api-client-spec.md](../specs/rest-api-client-spec.md) § 4.1, § 6.1
- **YBS Framework**: [../../framework/methodology/executing-builds.md](../../framework/methodology/executing-builds.md)

---

**End of Step 1**
