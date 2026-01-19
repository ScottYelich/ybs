# Legacy Systems Directory

**Version**: 0.3.0
**Last Updated**: 2026-01-18

📍 **You are here**: YBS Repository > Legacy Systems
**↑ Parent**: [Repository Root](../README.md)
📚 **See also**: [Framework](../framework/README.md) | [CLAUDE.md](CLAUDE.md)

**Status**: ⚠️ **Temporary holding area** - Contents to be extracted to separate repositories

---

## What is This Directory?

**This directory temporarily contains systems that were part of the YBS repository restructure and will be extracted to standalone repositories.**

Originally called `systems/`, this directory was renamed to `legacy-systems/` as part of YBS v2.0.0 restructure to clarify the new architecture:

- **YBS Framework** (this repo): Methodology, templates, tools, examples
- **Murphy** (future separate repo): AI chat tool with YBS support
- **User systems** (external repos): User-created systems using YBS

---

## Repository Architecture: Option B

**YBS follows Option B architecture** (separate but tightly integrated):

### YBS Framework Repository
```
ybs/                                   # github.com/USER/ybs
├── framework/                         # Methodology, tools
├── examples/                          # Learning examples (placeholders)
├── docs/                              # User guides
└── legacy-systems/                    # ⚠️ Temporary (to be extracted)
    └── murphy/                        # AI chat tool (moving out)
```

### Murphy Repository (Future)
```
murphy/                                # github.com/USER/murphy (to be created)
├── README.md                          # Murphy: AI chat tool
├── specs/                             # System specifications
├── steps/                             # Build steps
├── Sources/                           # Swift implementation
└── docs/                              # Murphy documentation
```

### User Systems (External)
```
my-payment-system/                     # github.com/USER/my-payment-system
├── .ybs/config.json                   # References YBS framework
├── specs/                             # System specifications
├── steps/                             # Build steps
└── builds/                            # Build workspaces
```

---

## Current Contents

### murphy

**Location**: [legacy-systems/murphy/](murphy/)

**Status**: ⚠️ **To be extracted to separate repository** (`github.com/USER/murphy`)

**What**: Swift-based AI chat tool (LLM coding assistant) for macOS with first-class YBS build system support

**Named after**: Murphy's Law ("Anything that can go wrong, will go wrong") - your AI pair programmer for handling what goes wrong

**History**: Originally called "bootstrap" (renamed 2026-01-18 to avoid YBS framework name confusion)

**Purpose Dual**:
1. **Reference implementation**: Demonstrates how AI agents can work with YBS
2. **General-purpose tool**: Works for any development task (not YBS-only)

**Key Features** (when complete):
- Command-line AI coding assistant
- Local or remote LLMs (Ollama, OpenAI, Anthropic)
- 6 built-in tools + unlimited external tools
- Security by default (sandboxed execution)
- macOS native (Swift)
- **YBS integration**: `murphy build`, `murphy step <N>`, `murphy verify`

**See**: [legacy-systems/murphy/README.md](murphy/README.md) for complete details

---

## Why "Legacy Systems"?

This directory name reflects the transition:

**Before (v1.x)**: `systems/` contained all system definitions
- Implied: Systems live inside YBS repo
- Problem: Confusing - is YBS a framework or a monorepo?

**After (v2.0)**: `legacy-systems/` temporary holding area
- Clarifies: This content is transitioning out
- Murphy will move to: `github.com/USER/murphy`
- User systems will be: External repositories

**Future (v2.1+)**: This directory may be removed entirely after Murphy extraction

---

## Murphy + YBS: The Perfect Pair

**Separate but integrated** (Option B architecture):

### YBS Framework Provides:
- Specifications (what to build)
- Build steps (how to build)
- Configuration system (BUILD_CONFIG.json)
- Verification requirements
- Language-agnostic methodology

### Murphy Provides:
- AI execution engine (reads and executes YBS steps)
- Tool use (git, swift, npm, docker, etc.)
- Streaming responses (real-time feedback)
- Context management (handles large builds)
- Local execution (works with Ollama, no API costs)

### Together:
```bash
# Install both
brew install ybs murphy

# Create system with YBS
cd my-system
ybs init

# Execute with Murphy
murphy build
```

### But Also Separate:
- Use YBS with Claude CLI, OpenAI assistants, or any AI agent
- Use Murphy for non-YBS development tasks
- Independent versioning: ybs v2.0.0, murphy v1.0.0

---

## References

- **Framework**: [../framework/README.md](../framework/README.md)
- **Repository**: [../README.md](../README.md)
- **AI Agent Guide**: [CLAUDE.md](CLAUDE.md)
- **Murphy**: [murphy/README.md](murphy/README.md)
- **Murphy Future Repo**: github.com/USER/murphy (to be created)
- **Architecture Decision**: [../scratch/ybs-repository-architecture-recommendation.md](../scratch/ybs-repository-architecture-recommendation.md)

---

## Version History

- **0.3.0** (2026-01-18): Renamed to legacy-systems, documented Option B architecture, bootstrap → murphy
- **0.2.0** (2026-01-18): Initial systems directory README
- **0.1.0** (2026-01-17): Directory created during restructure

---

*This directory is temporary. Murphy will move to standalone repository.*
