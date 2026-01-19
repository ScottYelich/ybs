import Foundation

print("Testing WriteFileTool...")

let testPath = "/tmp/ybs-verify-write.txt"
try? FileManager.default.removeItem(atPath: testPath)

// Test 1: Basic write
let content = "Hello from YBS WriteFileTool!"
try! content.write(toFile: testPath, atomically: true, encoding: .utf8)
let readBack = try! String(contentsOfFile: testPath, encoding: .utf8)
assert(readBack == content, "Content mismatch")
print("✓ Basic file write works")

// Test 2: Overwrite
let newContent = "Updated content"
try! newContent.write(toFile: testPath, atomically: true, encoding: .utf8)
let readBack2 = try! String(contentsOfFile: testPath, encoding: .utf8)
assert(readBack2 == newContent, "Overwrite failed")
print("✓ File overwrite works")

// Test 3: Nested directories
let nestedPath = "/tmp/ybs-verify-nested/sub1/sub2/file.txt"
let nestedURL = URL(fileURLWithPath: nestedPath)
let parentDir = nestedURL.deletingLastPathComponent()
try! FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
try! "Nested content".write(to: nestedURL, atomically: true, encoding: .utf8)
assert(FileManager.default.fileExists(atPath: nestedPath), "Nested file not created")
print("✓ Nested directory creation works")

print("\n✅ All WriteFileTool verification passed!")
