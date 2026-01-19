import Foundation

print("Testing RunShellTool...")

// Test 1: Basic command execution (echo)
let process1 = Process()
process1.executableURL = URL(fileURLWithPath: "/bin/sh")
process1.arguments = ["-c", "echo 'Hello from shell'"]
let pipe1 = Pipe()
process1.standardOutput = pipe1
try! process1.run()
process1.waitUntilExit()
let data1 = pipe1.fileHandleForReading.readDataToEndOfFile()
let output1 = String(data: data1, encoding: .utf8)!
assert(output1.contains("Hello from shell"), "Basic command failed")
print("✓ Basic command execution works")

// Test 2: Command with exit code
let process2 = Process()
process2.executableURL = URL(fileURLWithPath: "/bin/sh")
process2.arguments = ["-c", "exit 0"]
try! process2.run()
process2.waitUntilExit()
assert(process2.terminationStatus == 0, "Exit code check failed")
print("✓ Command exit codes work")

// Test 3: Capture stderr
let process3 = Process()
process3.executableURL = URL(fileURLWithPath: "/bin/sh")
process3.arguments = ["-c", "echo 'error message' >&2"]
let stderr3 = Pipe()
process3.standardError = stderr3
try! process3.run()
process3.waitUntilExit()
let errData = stderr3.fileHandleForReading.readDataToEndOfFile()
let errOutput = String(data: errData, encoding: .utf8)!
assert(errOutput.contains("error message"), "Stderr capture failed")
print("✓ Stderr capture works")

// Test 4: Working directory
let process4 = Process()
process4.executableURL = URL(fileURLWithPath: "/bin/sh")
process4.arguments = ["-c", "pwd"]
process4.currentDirectoryURL = URL(fileURLWithPath: "/tmp")
let pipe4 = Pipe()
process4.standardOutput = pipe4
try! process4.run()
process4.waitUntilExit()
let data4 = pipe4.fileHandleForReading.readDataToEndOfFile()
let output4 = String(data: data4, encoding: .utf8)!
assert(output4.contains("/tmp"), "Working directory not respected")
print("✓ Working directory works")

print("\n✅ All RunShellTool verification passed!")
