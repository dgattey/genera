// swift-tools-version:5.6
import PackageDescription

/// This package incldues SwiftFormat so we can run linting and formatting
let buildToolsPackage = Package(
    name: "BuildTools",
    platforms: [.macOS(.v11)],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.49.18"),
    ],
    targets: [
        .target(name: "BuildTools", path: "", exclude: ["format-swift.zsh"]),
    ]
)
