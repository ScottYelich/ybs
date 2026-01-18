# Testing BASE Specification: Bootstrap

**System**: Bootstrap (Swift AI Chat Tool)
**Version**: 1.0.0
**Last Updated**: 2026-01-17

## Test Infrastructure

### Test Frameworks

| Type | Framework | Purpose |
|------|-----------|---------|
| Unit Tests | XCTest | Testing individual Swift components |
| UI Tests | XCTest UI | Testing user workflows |
| Accessibility Tests | Accessibility Inspector | VoiceOver, keyboard testing |

### Coverage Targets

- **Unit Tests**: 80% line coverage
- **UI Tests**: Critical workflows (send message, new conversation)
- **Accessibility Tests**: 100% of UI elements

## Test Naming Convention

```swift
func test_sendMessage_validInput_sendsToAPI() {}
func test_loadConfig_fileNotFound_throwsError() {}
func test_newConversation_keyboardShortcut_createsConversation() {}
```

## Test Structure (Arrange-Act-Assert)

```swift
func test_example() {
    // Arrange: Set up test data
    let sut = MessageService()
    let message = "Hello"

    // Act: Execute functionality
    let result = sut.send(message)

    // Assert: Verify result
    XCTAssertNotNil(result)
}
```

## Accessibility Testing Checklist

- [ ] All buttons keyboard accessible
- [ ] VoiceOver announces all elements correctly
- [ ] Focus indicators visible
- [ ] Keyboard shortcuts work
- [ ] Supports Dynamic Type
- [ ] Works in Dark Mode

## macOS-Specific Testing

- Test on macOS 13 (Ventura), 14 (Sonoma), 15 (Sequoia)
- Test with App Sandbox enabled
- Test with restricted network access
- Test Keychain integration
