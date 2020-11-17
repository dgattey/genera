// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// All resuable engine-powered UI
let package = Package(
    name: "EngineUI",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "EngineUI",
            targets: ["EngineUI"]
        ),
    ],
    dependencies: [
        .package(path: "Engine"),
        .package(path: "UI"),
    ],
    targets: [
        .target(
            name: "EngineUI",
            dependencies: ["Engine", "UI"]
        ),
    ]
)
