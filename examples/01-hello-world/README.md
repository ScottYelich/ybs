# Hello World Example

**Example Level**: 1 (Trivial)
**Language**: Python
**Purpose**: Minimal YBS example demonstrating basic workflow

---

## Overview

This example builds the simplest possible program: a Python script that prints "Hello, World!" to stdout.

**Why this example?**
- ✅ See complete YBS cycle in 20 minutes
- ✅ Understand spec → steps → build workflow
- ✅ No distractions (no dependencies, no complexity)
- ✅ Perfect first example for learning YBS

---

## What You'll Learn

1. **YBS structure**: How specs/, steps/, and builds/ work together
2. **Step 0**: Build configuration (the CONFIG system)
3. **Verification**: How YBS validates each step
4. **Traceability**: Linking code back to specifications

---

## Structure

```
01-hello-world/
├── README.md                          # This file
├── specs/                             # What to build
│   └── hello-world-spec.md            # Requirements
├── steps/                             # How to build
│   ├── hello-step_000000000000.md     # Step 0: Build config
│   ├── hello-step_478a8c4b0cef.md     # Step 1: Project structure
│   ├── hello-step_c5404152680d.md     # Step 2: Main script
│   ├── hello-step_89b9e6233da5.md     # Step 3: Permissions
│   └── hello-step_a1b2c3d4e5f6.md     # Step 4: Verification
└── builds/
    └── demo/                          # Example build output
        └── hello.py
```

---

## Status

✅ **Complete** (v1.0.0 - 2026-01-18)

This example is fully specified with complete specs and steps. Ready for AI agent execution.

---

## Next Steps

After completing this example:
1. **Study**: [02-calculator](../02-calculator/) - Multiple modules
2. **Read**: [Framework Methodology](../../framework/methodology/overview.md)
3. **Create**: Your own simple system

---

## References

- **Examples Overview**: [../README.md](../README.md)
- **Getting Started**: [../../docs/getting-started.md](../../docs/getting-started.md)
- **Writing Specs**: [../../framework/methodology/writing-specs.md](../../framework/methodology/writing-specs.md)
