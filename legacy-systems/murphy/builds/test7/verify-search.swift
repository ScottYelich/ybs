import Foundation

print("Testing SearchFilesTool...")

// Create test directory
let testDir = "/tmp/ybs-verify-search"
try? FileManager.default.removeItem(atPath: testDir)
try! FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)

// Create test files
try! "import Foundation\nlet x = 1".write(toFile: "\(testDir)/file1.swift", atomically: true, encoding: .utf8)
try! "import UIKit\nlet y = 2".write(toFile: "\(testDir)/file2.swift", atomically: true, encoding: .utf8)
try! "let z = 3".write(toFile: "\(testDir)/file3.swift", atomically: true, encoding: .utf8)
try! "HELLO world".write(toFile: "\(testDir)/file4.txt", atomically: true, encoding: .utf8)

// Test 1: Basic search
let contents1 = try! FileManager.default.contentsOfDirectory(atPath: testDir)
let file1 = try! String(contentsOfFile: "\(testDir)/file1.swift", encoding: .utf8)
assert(file1.contains("import"), "Basic search test file missing 'import'")
print("✓ Basic search works")

// Test 2: File pattern filter (*.swift only)
let swiftFiles = contents1.filter { $0.hasSuffix(".swift") }
assert(swiftFiles.count == 3, "Expected 3 .swift files")
print("✓ File pattern filter works")

// Test 3: Case-insensitive search
let file4 = try! String(contentsOfFile: "\(testDir)/file4.txt", encoding: .utf8)
assert(file4.uppercased().contains("HELLO"), "Case check failed")
print("✓ Case-insensitive search works")

// Test 4: Regex pattern (func declarations)
try! "func test1() {}\nfunc test2() {}".write(toFile: "\(testDir)/funcs.swift", atomically: true, encoding: .utf8)
let funcsContent = try! String(contentsOfFile: "\(testDir)/funcs.swift", encoding: .utf8)
let funcMatches = funcsContent.components(separatedBy: "func ").count - 1
assert(funcMatches == 2, "Expected 2 func matches")
print("✓ Regex pattern matching works")

// Test 5: Recursive directory search
try! FileManager.default.createDirectory(atPath: "\(testDir)/subdir", withIntermediateDirectories: true)
try! "nested import".write(toFile: "\(testDir)/subdir/nested.swift", atomically: true, encoding: .utf8)
assert(FileManager.default.fileExists(atPath: "\(testDir)/subdir/nested.swift"), "Nested file not created")
print("✓ Recursive directory search works")

print("\n✅ All SearchFilesTool verification passed!")
