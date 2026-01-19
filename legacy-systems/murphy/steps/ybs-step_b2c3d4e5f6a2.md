# Step 000028: Colored Output & UX

**GUID**: b2c3d4e5f6a2
**Type**: Implementation
**Status**: Planned
**Last Updated**: 2026-01-17

---

## Overview

**Purpose**: Improve terminal output with colors, formatting, and visual feedback.

**What This Step Does**:
- ANSI color codes for different message types
- Progress spinner while waiting for LLM
- Formatted output (boxes, borders)
- Streaming output (print tokens as received)
- Improved visual hierarchy

**Why This Step Exists**:
After Steps 4-27, functionality is complete but UX is basic. This step adds polish:
- Hard to distinguish user vs AI messages
- No feedback during long LLM calls
- Plain text output is boring
- Professional appearance matters

**Dependencies**:
- ✅ Step 13: Agent loop (where output happens)
- ✅ Step 12: LLM client (for streaming)

---

## Specifications

**Implements**:
- Spec: `systems/bootstrap/specs/technical/ybs-spec.md` § User Experience
- ADR: `systems/bootstrap/specs/architecture/ybs-decisions.md` § ANSI colors for terminal UI

**References**:
- `systems/bootstrap/specs/technical/ybs-spec.md` lines 720-750 (UX section)

---

## What to Build

### File Structure

```
Sources/YBS/UI/
├── ColorOutput.swift          # ANSI color formatting
├── ProgressIndicator.swift    # Spinner/progress display
└── OutputFormatter.swift      # Formatted output helpers
```

### 1. ColorOutput.swift

**Purpose**: ANSI color formatting for terminal output.

**Key Components**:

```swift
public enum ANSIColor: String {
    case black = "\u{001B}[30m"
    case red = "\u{001B}[31m"
    case green = "\u{001B}[32m"
    case yellow = "\u{001B}[33m"
    case blue = "\u{001B}[34m"
    case magenta = "\u{001B}[35m"
    case cyan = "\u{001B}[36m"
    case white = "\u{001B}[37m"
    case gray = "\u{001B}[90m"

    case reset = "\u{001B}[0m"
    case bold = "\u{001B}[1m"
    case dim = "\u{001B}[2m"
}

public class ColorOutput {
    private let config: UIConfig

    public init(config: UIConfig) {
        self.config = config
    }

    /// Check if colors are enabled
    public var colorsEnabled: Bool {
        config.useColors && isTerminalSupported()
    }

    /// Check if terminal supports ANSI colors
    private func isTerminalSupported() -> Bool {
        guard let term = ProcessInfo.processInfo.environment["TERM"] else {
            return false
        }
        return !term.contains("dumb")
    }

    /// Colorize text
    public func colorize(
        _ text: String,
        color: ANSIColor,
        bold: Bool = false
    ) -> String {
        guard colorsEnabled else { return text }

        var output = ""
        if bold { output += ANSIColor.bold.rawValue }
        output += color.rawValue
        output += text
        output += ANSIColor.reset.rawValue

        return output
    }

    /// Print user message
    public func printUser(_ message: String) {
        let colored = colorize(message, color: .blue, bold: true)
        print("You: \(colored)")
    }

    /// Print assistant message
    public func printAssistant(_ message: String) {
        let colored = colorize(message, color: .green)
        print("AI: \(colored)")
    }

    /// Print tool call
    public func printToolCall(_ toolName: String, _ parameters: String = "") {
        let colored = colorize("→ \(toolName)", color: .yellow)
        print(colored)
        if !parameters.isEmpty {
            print(colorize("  \(parameters)", color: .gray))
        }
    }

    /// Print tool result
    public func printToolResult(_ result: String, success: Bool) {
        let icon = success ? "✓" : "✗"
        let color: ANSIColor = success ? .green : .red
        let colored = colorize("\(icon) \(result)", color: color)
        print(colored)
    }

    /// Print error
    public func printError(_ message: String) {
        let colored = colorize("Error: \(message)", color: .red, bold: true)
        print(colored)
    }

    /// Print info
    public func printInfo(_ message: String) {
        let colored = colorize("ℹ \(message)", color: .cyan)
        print(colored)
    }

    /// Print warning
    public func printWarning(_ message: String) {
        let colored = colorize("⚠ \(message)", color: .yellow)
        print(colored)
    }
}
```

**Size**: ~120 lines

---

### 2. ProgressIndicator.swift

**Purpose**: Show progress/spinner while waiting for LLM.

**Key Components**:

```swift
public class ProgressIndicator {
    private var isRunning = false
    private var task: Task<Void, Never>?
    private let frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    private var frameIndex = 0

    /// Start spinner
    public func start(message: String = "Thinking...") {
        guard !isRunning else { return }
        isRunning = true

        task = Task {
            print("\n\(message) ", terminator: "")
            fflush(stdout)

            while isRunning {
                print("\r\(message) \(frames[frameIndex]) ", terminator: "")
                fflush(stdout)

                frameIndex = (frameIndex + 1) % frames.count

                try? await Task.sleep(nanoseconds: 80_000_000) // 80ms
            }

            // Clear line
            print("\r\u{001B}[K", terminator: "")
            fflush(stdout)
        }
    }

    /// Stop spinner
    public func stop() {
        isRunning = false
        task?.cancel()
        task = nil
    }

    /// Update message
    public func update(message: String) {
        if isRunning {
            print("\r\u{001B}[K\(message) \(frames[frameIndex]) ", terminator: "")
            fflush(stdout)
        }
    }
}
```

**Size**: ~60 lines

---

### 3. OutputFormatter.swift

**Purpose**: Formatted output helpers (boxes, separators).

**Key Components**:

```swift
public class OutputFormatter {
    /// Print box around text
    public static func printBox(_ content: String, width: Int = 60) {
        let topBorder = "┌" + String(repeating: "─", count: width - 2) + "┐"
        let bottomBorder = "└" + String(repeating: "─", count: width - 2) + "┘"

        print(topBorder)

        let lines = content.components(separatedBy: "\n")
        for line in lines {
            let padded = line.padding(
                toLength: width - 4,
                withPad: " ",
                startingAt: 0
            )
            print("│ \(padded) │")
        }

        print(bottomBorder)
    }

    /// Print separator line
    public static func printSeparator(width: Int = 60, char: Character = "─") {
        print(String(repeating: char, count: width))
    }

    /// Print header
    public static func printHeader(_ text: String, width: Int = 60) {
        let padding = (width - text.count - 2) / 2
        let left = String(repeating: "═", count: padding)
        let right = String(repeating: "═", count: width - text.count - padding - 2)

        print("\n\(left) \(text) \(right)")
    }

    /// Word wrap text
    public static func wordWrap(_ text: String, width: Int = 80) -> String {
        var result = ""
        var currentLine = ""

        for word in text.split(separator: " ") {
            if currentLine.count + word.count + 1 > width {
                result += currentLine + "\n"
                currentLine = String(word)
            } else {
                if !currentLine.isEmpty {
                    currentLine += " "
                }
                currentLine += word
            }
        }

        if !currentLine.isEmpty {
            result += currentLine
        }

        return result
    }
}
```

**Size**: ~80 lines

---

### 4. Integration with Agent Loop

**Update**: `Sources/YBS/Agent/AgentLoop.swift`

```swift
public class Agent {
    private let colorOutput: ColorOutput
    private let progress: ProgressIndicator

    public init(config: Config, ...) {
        self.colorOutput = ColorOutput(config: config.ui)
        self.progress = ProgressIndicator()
        // ...
    }

    func run() async throws {
        // Print welcome header
        OutputFormatter.printHeader("YBS - AI Coding Assistant")
        colorOutput.printInfo("Type 'quit' to exit, 'help' for commands")
        print()

        while true {
            // Print prompt
            if config.ui.showTokenUsage {
                let usage = context.getTokenUsage().formattedUsage()
                print(colorOutput.colorize("[\(usage)]", color: .gray))
            }

            print(colorOutput.colorize("You: ", color: .blue, bold: true), terminator: "")
            fflush(stdout)

            // Read input
            guard let input = readLine() else { break }

            // Show progress
            progress.start(message: "Thinking...")

            // Send to LLM
            let response = try await llmClient.sendMessage(...)

            // Stop progress
            progress.stop()

            // Print response
            colorOutput.printAssistant(response.content)

            // Handle tool calls
            if let toolCalls = response.toolCalls {
                for call in toolCalls {
                    colorOutput.printToolCall(call.name, call.parameters)

                    let result = try await executor.execute(call)

                    colorOutput.printToolResult(result.content, success: result.isSuccess)
                }
            }

            print()
        }
    }
}
```

---

### 5. Streaming Output

**Update**: LLMClient to support streaming callbacks

```swift
public class LLMClient {
    /// Send message with streaming
    public func sendMessageStreaming(
        messages: [Message],
        tools: [Tool],
        onToken: @escaping (String) -> Void
    ) async throws -> Message {
        // Setup streaming request
        let request = buildRequest(messages: messages, tools: tools, stream: true)

        // Stream response
        for try await chunk in streamResponse(request) {
            if let token = parseToken(from: chunk) {
                onToken(token)
            }
        }

        // Return complete message
        return ...
    }
}

// In Agent:
func printStreamingResponse() async throws {
    print(colorOutput.colorize("AI: ", color: .green), terminator: "")
    fflush(stdout)

    var fullResponse = ""

    try await llmClient.sendMessageStreaming(
        messages: context.getMessages(),
        tools: tools
    ) { token in
        fullResponse += token
        print(token, terminator: "")
        fflush(stdout)
    }

    print() // Newline at end
}
```

---

## Configuration

**Add to BUILD_CONFIG.json**:

```json
{
  "ui": {
    "useColors": true,
    "showTokenUsage": true,
    "showProgress": true,
    "streamOutput": true,
    "lineWidth": 80
  }
}
```

**Configuration Options**:
- `useColors`: Enable ANSI colors
- `showTokenUsage`: Display token count
- `showProgress`: Show spinner during LLM calls
- `streamOutput`: Stream AI responses
- `lineWidth`: Terminal width for formatting

---

## Tests

**Location**: `Tests/YBSTests/UI/ColorOutputTests.swift`

### Test Cases

**1. Color Formatting**:
```swift
func testColorize() {
    let config = UIConfig(useColors: true)
    let output = ColorOutput(config: config)

    let colored = output.colorize("Hello", color: .red, bold: true)

    XCTAssertTrue(colored.contains("\u{001B}[1m")) // Bold
    XCTAssertTrue(colored.contains("\u{001B}[31m")) // Red
    XCTAssertTrue(colored.contains("\u{001B}[0m"))  // Reset
}
```

**2. Colors Disabled**:
```swift
func testColorsDisabled() {
    let config = UIConfig(useColors: false)
    let output = ColorOutput(config: config)

    let plain = output.colorize("Hello", color: .red)

    XCTAssertEqual(plain, "Hello") // No ANSI codes
}
```

**3. Word Wrap**:
```swift
func testWordWrap() {
    let text = "This is a very long line that needs to be wrapped at a certain width"
    let wrapped = OutputFormatter.wordWrap(text, width: 20)

    let lines = wrapped.components(separatedBy: "\n")
    for line in lines {
        XCTAssertLessThanOrEqual(line.count, 20)
    }
}
```

**Total Tests**: ~6-8 tests

---

## Verification Steps

### 1. Manual Testing

**Test colors**:
```bash
cd systems/bootstrap/builds/test6
swift run ybs

# Should see:
# ═══════════ YBS - AI Coding Assistant ═══════════
# ℹ Type 'quit' to exit, 'help' for commands
#
# [0 / 100,000 tokens (0.0%)]
# You: Hello (in blue)
# [spinner while waiting]
# AI: Hi there! How can I help? (in green)
```

**Test tool calls**:
```bash
You: Read Package.swift
→ read_file (in yellow)
  path: Package.swift (in gray)
✓ File read successfully (in green)
AI: The Package.swift file contains...
```

**Test errors**:
```bash
You: Delete everything
Error: Command blocked for safety (in red)
```

### 2. Disable Colors

```bash
swift run ybs --no-colors
# Plain text output, no ANSI codes
```

### 3. Success Criteria

- ✅ User messages in blue
- ✅ AI messages in green
- ✅ Tool calls in yellow
- ✅ Errors in red
- ✅ Spinner shows during LLM calls
- ✅ Streaming output works
- ✅ Colors disable gracefully (--no-colors)
- ✅ Boxes and formatting work

---

## Dependencies

**Requires**:
- Step 12: LLM client (for streaming)
- Step 13: Agent loop (where output happens)

**Enables**:
- Professional appearance
- Better usability
- Clear visual hierarchy

---

## Implementation Notes

### ANSI Color Support

**Terminal detection**:
- Check `TERM` environment variable
- Skip if `TERM=dumb` (non-color terminals)
- Fallback to plain text gracefully

**Common terminals**:
- ✅ iTerm2
- ✅ Terminal.app
- ✅ Alacritty
- ✅ Kitty
- ✅ VS Code terminal
- ❌ Xcode console (no ANSI support)

### Color Choices

**Accessibility considerations**:
- Blue for user (high contrast)
- Green for AI (easy on eyes)
- Yellow for tools (attention but not alarming)
- Red for errors (clear danger signal)
- Gray for metadata (de-emphasized)

**Color blindness**:
- Use bold/icons in addition to color
- Don't rely solely on color for meaning

### Performance

**Streaming output**:
- Print tokens immediately (no buffering)
- Flush stdout after each token
- Smooth user experience

**Spinner overhead**:
- ~80ms refresh rate (smooth)
- Minimal CPU usage (<1%)
- Cancellable task (stops cleanly)

---

## Future Enhancements

**Possible improvements**:
- Markdown rendering (bold, italic, code blocks)
- Syntax highlighting for code
- Interactive elements (menus, selections)
- Progress bars (for long operations)
- Notification sounds

---

## Lessons Learned Integration

**From** `systems/bootstrap/specs/general/ybs-lessons-learned.md`:

**§ User Experience**:
- ✅ Visual feedback (spinner, colors)
- ✅ Clear message attribution (who said what)
- ✅ Professional appearance

**§ Accessibility**:
- ✅ Color disable option
- ✅ Works in basic terminals
- ✅ Screen reader compatible (plain text fallback)

---

## Completion Criteria

**This step is complete when**:

1. **Code Written**:
   - [ ] ColorOutput.swift with ANSI formatting
   - [ ] ProgressIndicator.swift with spinner
   - [ ] OutputFormatter.swift with helpers
   - [ ] Agent loop integration

2. **Tests Pass**:
   - [ ] All ColorOutputTests pass
   - [ ] Color codes correct
   - [ ] Disable option works

3. **Verification Complete**:
   - [ ] Colors display correctly
   - [ ] Spinner shows during LLM calls
   - [ ] Streaming output smooth
   - [ ] Plain text fallback works

4. **Documentation Updated**:
   - [ ] Code comments explain ANSI codes
   - [ ] Config options documented

**Estimated Time**: 2-3 hours
**Estimated Size**: ~260 lines

---

## Next Steps

**After This Step**:
→ **Step 29**: Error Recovery & Retry (robustness improvements)

**What It Enables**:
- Professional appearance
- Better user experience
- Clear visual feedback

---

**Last Updated**: 2026-01-17
**Status**: Ready for implementation
