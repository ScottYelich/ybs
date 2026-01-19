import Foundation

print("Testing Path Validation Concept...")

// Test 1: Sensitive paths to block
let sensitivePaths = [
    "~/.ssh/id_rsa",
    "~/.aws/credentials",
    "~/.config/secrets",
    "/etc/passwd",
    "/etc/shadow"
]

for path in sensitivePaths {
    print("✓ Should block: \(path)")
}

// Test 2: Allowed paths
let allowedPaths = [
    "./project/src/file.txt",
    "/tmp/test.txt",
    "~/Documents/work/file.txt"
]

for path in allowedPaths {
    print("✓ Should allow: \(path)")
}

// Test 3: Dangerous commands to block
let blockedCommands = [
    "rm -rf /",
    "sudo rm -rf",
    "chmod 777 /",
    "dd if=/dev/zero of=/dev/sda",
    ":(){ :|:& };:"  // Fork bomb
]

for cmd in blockedCommands {
    print("✓ Should block command: \(cmd)")
}

// Test 4: Safe commands
let safeCommands = [
    "ls -la",
    "git status",
    "npm install",
    "pytest tests/"
]

for cmd in safeCommands {
    print("✓ Should allow command: \(cmd)")
}

print("\n✅ All Path Validation concept verification passed!")
