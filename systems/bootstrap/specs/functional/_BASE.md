# Functional BASE Specification: Bootstrap

**System**: Bootstrap (Swift AI Chat Tool)
**Version**: 1.0.0
**Last Updated**: 2026-01-17

## Overview

System-wide functional standards for Bootstrap including macOS accessibility, UX patterns, and interaction models.

## Accessibility Standards (macOS)

### VoiceOver Support

**Requirements**:
- All UI elements accessible via VoiceOver
- Descriptive labels for all controls
- Semantic SwiftUI views (Button, TextField, etc.)
- Keyboard shortcuts announced

```swift
// Example accessible button
Button("Send Message") {
    sendMessage()
}
.accessibilityLabel("Send message to AI")
.accessibilityHint("Sends your message and receives a response")
.accessibilityAddTraits(.isButton)
```

### Keyboard Navigation

**Standard macOS Shortcuts**:
- `Cmd+N` - New conversation
- `Cmd+S` - Save conversation
- `Cmd+W` - Close window
- `Cmd+Q` - Quit application
- `Cmd+,` - Open preferences
- `Cmd+Return` - Send message

**Text Editing**:
- Full macOS text editing support
- Emacs-style shortcuts (Ctrl+A, Ctrl+E, etc.)
- Option+Arrow for word movement
- Cmd+Arrow for line movement

**Focus Management**:
- Logical tab order (top to bottom, left to right)
- Focus visible on all interactive elements
- Return to previous focus after dialogs

### Dynamic Type Support

```swift
// Use native SwiftUI text styles
Text("Message")
    .font(.body)  // Automatically respects user's font size preference

// For custom sizes, scale with Dynamic Type
Text("Heading")
    .font(.system(size: 24))
    .dynamicTypeSize(.medium...xlarge)  // Cap at xLarge if needed
```

### Dark Mode Support

- Automatic support via native Color APIs
- Test all UI in both light and dark modes
- Respect user's appearance preference
- No hardcoded colors (use system colors)

### Reduced Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Conditional animation
if reduceMotion {
    // Instant update
} else {
    withAnimation {
        // Animated update
    }
}
```

### Screen Magnification

- Support up to 400% zoom
- Use relative layouts (not fixed sizes)
- Text remains readable when zoomed
- No horizontal scrolling at 200% zoom

## UX Patterns (macOS)

### Window Management

**Main Window**:
- Resizable with minimum size: 400x600 pt
- Remember window position/size
- Support full screen mode
- Title shows current conversation name

**Preferences Window**:
- Modal sheet (standard macOS pattern)
- Non-resizable
- Dismiss with Cmd+W or close button

### Navigation Patterns

**Sidebar** (if multi-conversation):
- Left sidebar with conversation list
- Collapsible (Cmd+Ctrl+S to toggle)
- Minimum width: 200pt
- Draggable splitter

**Main Content Area**:
- Scrollable message list
- Input field at bottom (fixed position)
- Auto-scroll to latest message

### Loading States

**Initial App Launch**:
- Show splash screen if > 1s load time
- Progress indicator for config loading

**Message Sending**:
- Disable input field
- Show "Sending..." indicator
- Spinning activity indicator

**Waiting for AI Response**:
- Show "AI is typing..." indicator
- Pulsing animation (unless reduce motion)
- Allow cancel operation

### Empty States

**No Conversations**:
```
[Icon: Chat bubble]

Welcome to Bootstrap

Start a conversation with AI to get started.

[Button: New Conversation]
```

**No Messages in Conversation**:
```
Send a message to begin

Type your message below and press Cmd+Return to send.
```

### Error States

**Connection Error**:
```
⚠️ Unable to connect to AI service

Check your internet connection and try again.

[Button: Retry]  [Button: Check Settings]
```

**API Key Missing**:
```
🔑 API Key Required

Add your Anthropic API key in preferences to start using Bootstrap.

[Button: Open Preferences]
```

### Confirmation Dialogs

**Delete Conversation**:
```
Alert Title: "Delete "[Conversation Name]"?"

Message: "This conversation will be permanently deleted. This action cannot be undone."

Buttons: [Cancel (default)] [Delete (destructive)]
```

**Quit with Unsaved Changes**:
```
Alert Title: "Do you want to save changes?"

Message: "Your conversation has unsaved changes."

Buttons: [Don't Save] [Cancel (default)] [Save]
```

### Form Patterns (Preferences)

**Layout**:
- Tabs for different preference categories
- Label on left, control on right
- Group related settings visually

**Validation**:
- Validate on field blur
- Show inline error messages
- Disable "Save" button until valid

**Help Text**:
- Use subtle secondary text below fields
- Link to documentation for complex settings

### Feedback Patterns

**Success Messages**:
```
✓ API key saved successfully
```

- Toast notification (auto-dismiss after 3s)
- Subtle animation
- Green checkmark

**Copy to Clipboard**:
```
✓ Copied to clipboard
```

- Brief toast notification
- Audio feedback (system sound)

### macOS-Specific Patterns

**Menu Bar**:
- Standard macOS menu structure
- File, Edit, View, Window, Help
- Keyboard shortcuts shown in menus

**Touch Bar** (if available):
- Quick actions: Send, New Conversation, Settings
- Text suggestions while typing

**Services Integration**:
- Support "Send to Bootstrap" service
- Accept text from other apps

**Drag & Drop**:
- Drop text files to load content
- Drop images to analyze (future feature)

## Content Guidelines

### Tone

- **Friendly**: Conversational and approachable
- **Clear**: Technical but not jargon-heavy
- **Helpful**: Guide users to success

### Button Labels

- Use action verbs: "Send Message", not "OK"
- Be specific: "Save API Key", not "Save"
- Destructive actions: "Delete Conversation" (red)

### Error Messages

- State what happened: "Connection failed"
- Explain why: "Unable to reach AI service"
- Suggest action: "Check your internet connection"

### Microcopy

**Placeholders**:
- "Type your message here..." (input field)
- "Search conversations..." (search field)

**Tooltips**:
- Keep to 1 sentence
- Provide helpful context
- Don't state the obvious

## Workflow Standards

### Core User Workflows

#### 1. Send Message to AI

**Goal**: Get response from AI

**Steps**:
1. User types message in input field
2. User presses Cmd+Return or clicks Send button
3. App sends message to AI service
4. App displays "AI is typing..." indicator
5. App receives and displays AI response
6. Input field re-enabled for next message

**Success Criteria**: Response received and displayed within 10s

#### 2. Start New Conversation

**Goal**: Begin fresh conversation

**Steps**:
1. User presses Cmd+N or clicks "New Conversation"
2. App creates new conversation
3. App shows empty conversation view
4. User begins typing

**Success Criteria**: New conversation ready within 500ms

#### 3. Configure API Key

**Goal**: Set up API credentials

**Steps**:
1. User opens Preferences (Cmd+,)
2. User navigates to "API" tab
3. User pastes API key
4. User clicks "Save"
5. App validates key
6. App saves to Keychain
7. Success message shown

**Success Criteria**: Key saved and validated

---

## Usage in Feature Specs

```markdown
## Accessibility Requirements

**Extends**: $ref:functional/_BASE.md#accessibility-standards

### Feature-Specific Requirements
[Any additional accessibility needs for this feature]

## User Workflow

**Extends**: $ref:functional/_BASE.md#workflow-standards

### Workflow: [Feature-Specific Workflow]
[Detailed steps]
```

---

**Related BASE Specs**:
- `technical/_BASE.md` - UI design tokens
- `testing/_BASE.md` - Accessibility testing
- `business/_BASE.md` - Success metrics
