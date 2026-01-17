# CONFIG Marker Syntax

**Version**: 0.1.0
**Last Updated**: 2026-01-17

📍 **You are here**: YBS Framework > Documentation > CONFIG Markers
**↑ Parent**: [Documentation Hub](README.md)
📚 **Quick Links**: [README](../README.md) | [Glossary](glossary.md)

---

## Overview

CONFIG markers are special syntax used in step files to declare configurable values that should be collected by Step 0 and stored in BUILD_CONFIG.json. This enables autonomous execution by collecting all configuration upfront.

---

## Syntax

```
{{CONFIG:key|type|description|default}}
```

### Components

1. **key** (required): Configuration key name (lowercase_with_underscores)
2. **type** (required): Data type (see Available Types below)
3. **description** (required): Human-readable description for users
4. **default** (required): Default value if user doesn't provide one

---

## Available Types

### Basic Types

- **string**: Free-form text input
  - Example: `{{CONFIG:system_name|string|Name of the system|myapp}}`

- **integer**: Whole numbers
  - Example: `{{CONFIG:port|integer|Server port number|8080}}`

- **float**: Decimal numbers
  - Example: `{{CONFIG:version|float|Version number|1.0}}`

- **boolean**: True/false values
  - Example: `{{CONFIG:enable_logging|boolean|Enable debug logging|true}}`

### Choice Types

- **choice[option1,option2,...]**: Single selection from options
  - Example: `{{CONFIG:language|choice[Swift,Python,Go,Rust,TypeScript]|Programming language|Swift}}`

- **multichoice[option1,option2,...]**: Multiple selections allowed
  - Example: `{{CONFIG:features|multichoice[auth,api,cli,web]|Features to include|auth,cli}}`

### Specialized Types

- **color**: Color values (hex format)
  - Example: `{{CONFIG:theme_color|color|Primary theme color|#007AFF}}`

- **url**: URL/endpoint
  - Example: `{{CONFIG:api_endpoint|url|API endpoint|https://api.example.com}}`

- **email**: Email address
  - Example: `{{CONFIG:admin_email|email|Administrator email|admin@example.com}}`

- **path**: File system path
  - Example: `{{CONFIG:install_dir|path|Installation directory|/usr/local/bin}}`

---

## Usage in Step Files

### Declaration

In the **Configurable Values** section of a step file:

```markdown
## Configurable Values

**This step uses the following configuration values:**

- `{{CONFIG:system_name|string|Name of the system being built|myapp}}` - Used for directory name and all documentation
- `{{CONFIG:language|choice[Swift,Python,Go,Rust,TypeScript]|Programming language for the project|Swift}}` - Determines project structure
```

### Reference

In step instructions, reference config values using the key:

```markdown
Create the directory `builds/{{CONFIG:system_name}}/` for your project.
```

### Runtime

At execution time (Steps 1-N):
1. Step 0 has already collected all values
2. Values are stored in `BUILD_CONFIG.json`
3. Agent reads values from JSON: `jq -r '.values.system_name' BUILD_CONFIG.json`
4. Agent substitutes values in instructions

---

## Step 0 Processing

Step 0 scans all step files and:

1. **Extracts** all CONFIG markers
2. **Deduplicates** by key (same key in multiple steps = one question)
3. **Groups** into batches (max 4 questions per AskUserQuestion call)
4. **Asks** user for all values upfront
5. **Validates** responses match type constraints
6. **Generates** BUILD_CONFIG.json with all values

---

## BUILD_CONFIG.json Format

Generated configuration file structure:

```json
{
  "version": "1.0",
  "generated": "2026-01-17T10:30:00Z",
  "values": {
    "system_name": "myapp",
    "language": "Swift",
    "platform": "macOS only",
    "enable_logging": true,
    "port": 8080
  }
}
```

---

## Best Practices

### For Step Authors

1. **Use descriptive keys**: `system_name` not `name`
2. **Provide clear descriptions**: Users see these when choosing
3. **Set sensible defaults**: Make common case the default
4. **Use appropriate types**: Constrain choices with `choice[...]`
5. **Document usage**: Explain where/how the value is used

### For Configurable Steps

1. **Declare all CONFIG markers** in Configurable Values section
2. **Reference by key** in instructions
3. **Read from BUILD_CONFIG.json** at runtime
4. **Never prompt user** in Steps 1-N (Step 0 collected everything)

### For Non-Configurable Steps

If a step has no configurable values, explicitly state:

```markdown
## Configurable Values

This step has no configurable values.
```

---

## Examples

### Simple String Configuration

```markdown
{{CONFIG:app_name|string|Application name|MyApp}}
```

Usage:
```bash
echo "Building {{CONFIG:app_name}}..."
```

### Choice with Platform Selection

```markdown
{{CONFIG:platform|choice[macOS only,Linux only,macOS + Linux,All platforms]|Target platform(s)|macOS only}}
```

Usage in instructions:
```markdown
The chosen platform is {{CONFIG:platform}}, which affects sandboxing approach.
```

### Multiple Configurations in One Step

```markdown
## Configurable Values

- `{{CONFIG:system_name|string|System name|myapp}}` - Directory and file names
- `{{CONFIG:language|choice[Swift,Python,Go]|Language|Swift}}` - Project structure
- `{{CONFIG:platform|choice[macOS only,Linux only,Both]|Platform|macOS only}}` - Build target
```

---

## Advanced: Type Validation

Step 0 validates user input against type constraints:

- **string**: Any text (non-empty)
- **integer**: Must be whole number
- **float**: Must be decimal number
- **boolean**: Must be true/false (case-insensitive)
- **choice[...]**: Must be one of the options
- **multichoice[...]**: Must be subset of options (comma-separated)
- **color**: Must be valid hex color (#RRGGBB or #RGB)
- **url**: Must be valid URL format
- **email**: Must be valid email format
- **path**: Must be valid file path (not validated for existence)

---

## Migration Notes

**Before CONFIG markers**:
- Each step asked user directly
- Interruptions during build
- No upfront visibility of all questions

**After CONFIG markers**:
- Step 0 asks everything upfront
- Steps 1-N run autonomously
- User sees all questions before build starts

---

## See Also

- [Step Template](../templates/step-template.md) - Template showing CONFIG usage
- [Step Format](step-format.md) - Complete step file format specification
- [Glossary](glossary.md) - BUILD_CONFIG.json definition

---

**Version**: 0.1.0
**Created**: 2026-01-17
