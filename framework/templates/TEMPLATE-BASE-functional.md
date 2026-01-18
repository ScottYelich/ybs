# Functional BASE Specification

**System**: [System Name]
**Version**: 1.0.0
**Last Updated**: [YYYY-MM-DD]

## Overview

This BASE spec defines **system-wide functional standards** including accessibility requirements, UX patterns, and interaction models that apply to all user-facing features.

## Accessibility Standards

### WCAG Compliance

**Target Level**: WCAG 2.1 Level AA (mandatory by April 2026)

**Core Principles**:
1. **Perceivable**: Information must be presentable to users in ways they can perceive
2. **Operable**: UI components must be operable by all users
3. **Understandable**: Information and operation must be understandable
4. **Robust**: Content must be robust enough for assistive technologies

### Keyboard Navigation

**Requirements**:
- All interactive elements must be keyboard accessible
- Visible focus indicators on all focusable elements
- Logical tab order (left-to-right, top-to-bottom)
- Keyboard shortcuts must not conflict with assistive technology

**Standard Shortcuts**:
- `Tab` / `Shift+Tab` - Navigate between elements
- `Enter` / `Space` - Activate buttons/links
- `Esc` - Close dialogs, cancel operations
- `Cmd+S` / `Ctrl+S` - Save (where applicable)
- `Cmd+Z` / `Ctrl+Z` - Undo

**Custom Shortcuts**:
- Must be documented
- Must be configurable (avoid conflicts)
- Must work with modifier keys (Cmd/Ctrl/Alt)

### Screen Reader Support

**Requirements**:
- Semantic HTML (use `<button>`, `<nav>`, `<main>`, etc.)
- ARIA labels for icons and visual-only elements
- ARIA live regions for dynamic content
- Alt text for all images (decorative images: `alt=""`)
- Form labels properly associated with inputs

**ARIA Patterns**:
```html
<!-- Button -->
<button aria-label="Close dialog">×</button>

<!-- Loading state -->
<div role="status" aria-live="polite">Loading...</div>

<!-- Form field -->
<label for="email">Email Address</label>
<input id="email" type="email" aria-required="true" aria-describedby="email-hint">
<span id="email-hint">We'll never share your email</span>

<!-- Navigation -->
<nav aria-label="Main navigation">
  <ul role="list">
    <li><a href="/">Home</a></li>
  </ul>
</nav>
```

### Color & Contrast

**Minimum Contrast Ratios** (WCAG AA):
- Normal text: 4.5:1
- Large text (18pt+): 3:1
- UI components: 3:1
- Focus indicators: 3:1

**Color Independence**:
- Never use color alone to convey information
- Supplement color with icons, text, or patterns
- Example: Success (green checkmark), Error (red X icon)

**Dark Mode Support**:
- Provide dark mode variant for all UI
- Maintain contrast ratios in both modes
- Respect system preference

### Assistive Technology

**Voice Control** (Siri, Voice Access):
- All buttons have unique, descriptive labels
- Use platform-native controls when possible

**Switch Control**:
- Large touch targets (minimum 44x44 pt on iOS, 48x48 dp on Android)
- Adequate spacing between interactive elements (8pt minimum)

**Screen Magnification**:
- Layouts must adapt to magnification (don't break at 200% zoom)
- Avoid fixed positioning that breaks when zoomed

### Accessibility Testing Checklist

Before releasing any feature:
- [ ] All interactive elements keyboard accessible
- [ ] Focus indicators visible on all focusable elements
- [ ] Screen reader announces all content correctly
- [ ] Color contrast ratios meet WCAG AA
- [ ] Color not used as only means of conveying information
- [ ] All images have alt text
- [ ] All form fields have labels
- [ ] Supports system accessibility features (large text, dark mode)

## UX Patterns

### Interaction Models

#### Loading States

**Short Operations** (< 2 seconds):
- Show inline spinner
- Disable interactive elements
- Optional: "Loading..." text for screen readers

**Long Operations** (> 2 seconds):
- Show progress indicator with percentage/steps
- Provide cancel option
- Display estimated time remaining
- Show what's happening ("Uploading file...")

#### Empty States

**Purpose**: Guide users when no data exists

**Components**:
- Icon or illustration
- Heading: "No [items] yet"
- Description: Why is it empty?
- Call to action: "Create your first [item]"

Example:
```
[Icon: Empty inbox]

No messages yet

You don't have any messages. Start a conversation to see it here.

[Button: Send a message]
```

#### Error States

**User Errors** (validation, input):
- Show inline error message near the field
- Use clear, actionable language
- Provide recovery suggestion
- Don't blame the user

Example:
```
❌ Email format is invalid
Please enter a valid email address (e.g., user@example.com)
```

**System Errors** (failures, outages):
- Explain what happened (in user-friendly terms)
- What the user can do (retry, contact support)
- Avoid technical jargon

Example:
```
⚠️ We couldn't save your changes

Our servers are experiencing issues. Your work is saved locally.
Try again in a moment, or contact support if this continues.

[Button: Try Again]  [Button: Contact Support]
```

### Confirmation Patterns

**Destructive Actions** (delete, remove):
- Always confirm before execution
- Clearly state what will be deleted
- Use danger color (red) for confirm button
- Provide undo option when possible

Example:
```
Delete "Project Alpha"?

This will permanently delete the project and all its files.
This action cannot be undone.

[Button: Cancel]  [Button: Delete (red)]
```

**Non-Destructive Actions**:
- No confirmation needed for easily reversible actions
- Provide undo/redo instead

### Form Patterns

**Field Layout**:
- Vertical layout (label above field)
- Left-align labels and fields
- Group related fields visually

**Validation**:
- Validate on blur (when user leaves field)
- Show inline error messages
- Don't validate while user is typing (except password strength)
- Disable submit button until form is valid

**Field Types**:
- Use appropriate input types (`email`, `tel`, `date`, etc.)
- Provide input masks for formatted data (phone, credit card)
- Show character counters for limited fields

**Help Text**:
- Use hint text below field for clarification
- Use placeholder sparingly (doesn't replace label)
- Link to help docs for complex fields

### Navigation Patterns

**Breadcrumbs**:
- Show hierarchy: Home > Category > Item
- Make ancestors clickable
- Current page not clickable

**Tabs**:
- Use for related content/views of same object
- Highlight active tab
- Maximum 5-7 tabs (use dropdown for more)

**Back Navigation**:
- Provide clear back button in hierarchical navigation
- Preserve user's place when returning

### Feedback Patterns

**Success Messages**:
- Show confirmation for important actions
- Use success color (green)
- Auto-dismiss after 3-5 seconds
- Position: Top-center or near action

Example:
```
✓ Changes saved successfully
```

**Progress Indicators**:
- Show progress for multi-step processes
- Indicate current step
- Show total steps

Example:
```
Step 2 of 4: Billing Information
[Progress bar: 50% complete]
```

### Responsive Behavior

**Breakpoints**:
- Mobile: < 768px
- Tablet: 768px - 1024px
- Desktop: > 1024px

**Mobile Considerations**:
- Touch targets minimum 44x44pt
- Use bottom navigation for primary actions
- Avoid hover-only interactions
- Support gestures (swipe, pinch-to-zoom)

**Desktop Considerations**:
- Optimize for keyboard + mouse
- Support drag-and-drop where appropriate
- Use hover states for feedback

## Content Guidelines

### Tone & Voice

- **Friendly**: Conversational but professional
- **Clear**: Simple language, avoid jargon
- **Concise**: Get to the point quickly
- **Helpful**: Guide users, don't confuse them

### Writing Guidelines

**Buttons**: Use action verbs
- Good: "Save Changes", "Delete Project"
- Bad: "OK", "Submit"

**Error Messages**: Be specific and helpful
- Good: "Email format is invalid. Please use format: user@example.com"
- Bad: "Invalid input"

**Labels**: Use sentence case
- Good: "Email address"
- Bad: "Email Address", "EMAIL ADDRESS"

**Headings**: Use clear, descriptive headings
- Good: "Reset your password"
- Bad: "Password"

### Microcopy

**Placeholders**:
- Example of expected input
- Don't use as labels

**Tooltips**:
- Short explanations (1-2 sentences)
- Avoid stating the obvious

**Empty States**:
- Explain why it's empty
- Suggest next action

## Workflow Standards

### User Goals

Every feature should have clear user goals:
1. What does the user want to accomplish?
2. Why do they want to do it?
3. What indicates success?

### Task Flow Structure

```
1. Entry Point: How does user start this task?
2. Required Steps: What must the user do?
3. Decision Points: What choices do they make?
4. Completion: How do they know they're done?
5. Exit: Where do they go next?
```

### Success Criteria

Define success for each workflow:
- **Completion rate**: % of users who complete the task
- **Time to completion**: How long it takes
- **Error rate**: % of users who encounter errors
- **Satisfaction**: User rating (e.g., NPS score)

---

## Usage in Feature Specs

Feature specs reference this BASE spec:

```markdown
## Accessibility Requirements

**Extends**: $ref:functional/_BASE.md#accessibility-standards

### Feature-Specific Requirements
- Custom keyboard shortcut: Cmd+K (quick search)
- ARIA live region for real-time updates

## User Workflow

**Extends**: $ref:functional/_BASE.md#workflow-standards

[Feature-specific workflow details]
```

---

**Related BASE Specs**:
- `technical/_BASE.md` - UI design tokens
- `testing/_BASE.md` - Accessibility testing
- `business/_BASE.md` - Success metrics
