// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "test6",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/swift-server/async-http-client", from: "1.20.0"),
    ],
    targets: [
        .executableTarget(
            name: "test6",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ]
        ),
        .testTarget(
            name: "test6Tests",
            dependencies: ["test6"]
        ),
    ]
)
