// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// All the reusable UI that the app itself should use
let uiPackage = Package(
    name: "UI",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "UI",
            targets: ["UI"]
        ),
    ],
    targets: [
        .target(
            name: "UI"
        ),
    ]
)
