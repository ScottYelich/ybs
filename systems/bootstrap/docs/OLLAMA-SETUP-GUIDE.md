# Ollama Setup Guide for test7

**Quick guide for running Ollama + qwen2.5:2b locally in your VM**

---

## System Requirements (Your VM)

✅ **Your specs**: 10GB RAM, M1 Virtual, macOS 15.1
✅ **Can run**: qwen2.5:2b (~1.5GB) or qwen2.5:7b (~4GB)
❌ **Cannot run**: qwen2.5:14b (~8GB) - too tight on 10GB VM

---

## Quick Setup (5 minutes)

### 1. Install Ollama

```bash
# Download and install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Or download manually:
# https://ollama.com/download
```

### 2. Pull Small Model

```bash
# For testing (smallest, fastest)
ollama pull qwen2.5:0.5b    # 0.5B params, ~400MB

# Recommended (good quality, small)
ollama pull qwen2.5:1.5b    # 1.5B params, ~1GB

# Best for 10GB VM (if you have room)
ollama pull qwen2.5:3b      # 3B params, ~2GB
```

**Recommendation**: Start with `qwen2.5:1.5b` - good balance.

### 3. Test It

```bash
# Start Ollama (runs automatically usually)
ollama serve &

# Test model
ollama run qwen2.5:1.5b "Hello, test message"
```

### 4. Configure test7

Update your config (`~/.config/ybs/config.json` or project `.ybs.json`):

```json
{
  "llm": {
    "provider": "ollama",
    "model": "qwen2.5:1.5b",
    "endpoint": "http://localhost:11434/v1/chat/completions",
    "temperature": 0.7,
    "max_tokens": 2048
  }
}
```

### 5. Run test7

```bash
cd builds/test7
swift build
swift run test7

# In the app:
/provider ollama
/config
# Should show qwen2.5:1.5b as model
```

---

## Model Comparison (For Your 10GB VM)

| Model | Size | RAM | Speed | Quality | Tool Support |
|-------|------|-----|-------|---------|--------------|
| **qwen2.5:0.5b** | 400MB | ~1GB | ⚡️⚡️⚡️ | ⭐️⭐️ | Fair |
| **qwen2.5:1.5b** | 1GB | ~2GB | ⚡️⚡️ | ⭐️⭐️⭐️ | Good |
| **qwen2.5:3b** | 2GB | ~3GB | ⚡️ | ⭐️⭐️⭐️⭐️ | Excellent |
| **qwen2.5:7b** | 4GB | ~5GB | 🐢 | ⭐️⭐️⭐️⭐️⭐️ | Excellent |

**Recommendation for testing**: `qwen2.5:1.5b` or `qwen2.5:3b`

---

## Using Network Ollama Server (36GB)

### On Your 36GB Server

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull best model for 36GB
ollama pull qwen2.5:32b    # ~20GB

# Run server (exposed on network)
OLLAMA_HOST=0.0.0.0:11434 ollama serve
```

### In Your VM (test7 config)

```json
{
  "llm": {
    "provider": "ollama",
    "model": "qwen2.5:32b",
    "endpoint": "http://localhost:11434/v1/chat/completions"
  }
}
```

**Benefits**:
- VM stays light (no model loaded)
- Access powerful 32B model
- Single server serves multiple clients

---

## Troubleshooting

### Ollama Won't Start

```bash
# Check if running
pgrep ollama

# Kill and restart
pkill ollama
ollama serve
```

### Model Download Fails

```bash
# Check disk space
df -h

# Try smaller model
ollama pull qwen2.5:0.5b
```

### test7 Can't Connect

```bash
# Check Ollama is running
curl http://localhost:11434/api/tags

# Should return JSON with models
```

### Out of Memory

Your VM has 10GB. If you get OOM:
1. Stop other apps
2. Use smaller model (0.5b or 1.5b)
3. Or point to network server

---

## Quick Commands Reference

```bash
# List models
ollama list

# Remove model
ollama rm qwen2.5:7b

# Pull model
ollama pull qwen2.5:1.5b

# Test model
ollama run qwen2.5:1.5b "test"

# Check server
curl http://localhost:11434/api/tags

# Check memory
vm_stat | head -5
```

---

## Recommended Setup for Your Situation

**Option A: Local (VM only)**
```json
{
  "llm": {
    "provider": "ollama",
    "model": "qwen2.5:1.5b",
    "endpoint": "http://localhost:11434/v1/chat/completions"
  }
}
```
- ✅ Fully local
- ✅ Fast for testing
- ⚠️ Limited capability (1.5B model)

**Option B: Network Server**
```json
{
  "llm": {
    "provider": "ollama",
    "model": "qwen2.5:32b",
    "endpoint": "http://localhost:11434/v1/chat/completions"
  }
}
```
- ✅ Powerful model (32B)
- ✅ VM stays light
- ⚠️ Requires network

**Option C: Hybrid**
- Local: qwen2.5:1.5b for quick tests
- Network: qwen2.5:32b for real work
- Switch with `/provider` and `/model` commands

---

## Performance Expectations

**qwen2.5:1.5b on 10GB VM**:
- Load time: ~2 seconds
- First token: ~200ms
- Tokens/sec: ~50-100
- Suitable for: Testing, simple tasks

**qwen2.5:32b on 36GB Server**:
- Load time: ~5 seconds
- First token: ~300ms
- Tokens/sec: ~30-50
- Suitable for: Production use, complex tasks

---

## Next Steps

1. ✅ Install Ollama
2. ✅ Pull qwen2.5:1.5b (or 0.5b/3b)
3. ✅ Test with `ollama run`
4. ✅ Update test7 config
5. ✅ Run test7 and verify
6. ⚠️ Optionally: Set up 36GB network server for qwen2.5:32b

---

**TL;DR**:
```bash
# Install
curl -fsSL https://ollama.com/install.sh | sh

# Get model
ollama pull qwen2.5:1.5b

# Test
ollama run qwen2.5:1.5b "hello"

# Configure test7 to use it (see config above)
```

Done! 🎉
