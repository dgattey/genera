// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// Provides everything to debug data cross app (needs UI to be able to show views)
let package = Package(
    name: "Debug",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "Debug",
            targets: ["Debug"]
        ),
    ],
    dependencies: [.package(path: "UI")],
    targets: [
        .target(
            name: "Debug",
            dependencies: ["UI"]
        ),
    ]
)
