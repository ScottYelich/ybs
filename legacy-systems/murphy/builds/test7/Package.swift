// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "test7",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "test7",
            targets: ["YBS"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/swift-server/async-http-client", from: "1.20.0"),
        .package(url: "https://github.com/andybest/linenoise-swift", from: "0.0.3"),
    ],
    targets: [
        .executableTarget(
            name: "YBS",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "LineNoise", package: "linenoise-swift"),
            ]
        ),
        .testTarget(
            name: "YBSTests",
            dependencies: ["YBS"]
        ),
    ]
)
