# Calculator Example

**Example Level**: 2 (Simple)
**Language**: Python or JavaScript
**Purpose**: Basic YBS workflow with multiple modules and testing

---

## Overview

This example builds a CLI calculator with basic arithmetic operations (add, subtract, multiply, divide).

**Why this example?**
- ✅ Multiple modules (separation of concerns)
- ✅ Test-driven development pattern
- ✅ Traceability demonstration (code → spec)
- ✅ Still simple enough to understand fully

---

## What You'll Learn

1. **Module organization**: How to structure multi-module systems
2. **Testing strategy**: Unit tests, integration tests
3. **Traceability**: `// Implements:` comments linking to specs
4. **Verification**: Running tests before proceeding to next step
5. **Documentation**: Creating user-facing docs

---

## Features

- **Core calculator module**: Basic arithmetic operations
- **Input parser**: Parse user input (CLI arguments or interactive)
- **Output formatter**: Format results for display
- **CLI interface**: User-friendly command-line interface
- **Comprehensive tests**: Unit and integration test coverage
- **Documentation**: README, usage guide

---

## Structure

```
02-calculator/
├── README.md                          # This file
├── specs/                             # What to build
│   └── calculator-spec.md             # Requirements
├── steps/                             # How to build (10 steps)
│   ├── calc-step_000000000000.md      # Step 0: Build config
│   ├── calc-step_478a8c4b0cef.md      # Step 1: Project structure
│   ├── calc-step_c5404152680d.md      # Step 2: Calculator module
│   ├── calc-step_89b9e6233da5.md      # Step 3: Parser module
│   ├── calc-step_a1b2c3d4e5f6.md      # Step 4: Formatter module
│   ├── calc-step_b2c3d4e5f6a1.md      # Step 5: CLI interface
│   ├── calc-step_c3d4e5f6a1b2.md      # Step 6: Unit tests (calculator)
│   ├── calc-step_d4e5f6a1b2c3.md      # Step 7: Unit tests (parser)
│   ├── calc-step_e5f6a1b2c3d4.md      # Step 8: Integration tests
│   ├── calc-step_f6a1b2c3d4e5.md      # Step 9: Documentation
│   └── calc-step_a2b3c4d5e6f7.md      # Step 10: Verification
└── builds/
    └── demo/                          # Example build output
        ├── src/
        │   ├── calculator.py
        │   ├── parser.py
        │   ├── formatter.py
        │   └── cli.py
        ├── tests/
        └── README.md
```

---

## Example Usage

```bash
# After building
./calculator.py add 5 3
# Output: 8

./calculator.py divide 10 2
# Output: 5

# Interactive mode
./calculator.py
> add 5 3
8
> multiply 4 7
28
> quit
```

---

## Status

🚧 **Coming Soon**

This example is a placeholder in the YBS v2.0.0 restructure. Content will be added in a future update.

---

## Next Steps

After completing this example:
1. **Study**: [03-rest-api](../03-rest-api/) - Multi-tier system
2. **Study**: [04-claude-chat](../04-claude-chat/) - Production complexity
3. **Create**: Your own multi-module system

---

## References

- **Examples Overview**: [../README.md](../README.md)
- **Previous**: [01-hello-world](../01-hello-world/) - Learn basics first
- **Writing Steps**: [../../framework/methodology/writing-steps.md](../../framework/methodology/writing-steps.md)
- **Testing Requirements**: See [../../framework/docs/](../../framework/docs/)
