// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// Game engine itself, used from the game & externally
let package = Package(
    name: "Engine",
    platforms: [.macOS(.v11)],
    products: [
        /// Combine the data from the game engine and the engine itself
        .library(
            name: "Engine",
            targets: ["Engine", "EngineData"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/davecom/SwiftPriorityQueue", .upToNextMinor(from: "1.3.1")),
        .package(path: "Debug"),
    ],
    targets: [
        /// All data structures, pure ObjC
        .target(
            name: "EngineData"
        ),
        /// Data extensions + rest of the engine
        .target(
            name: "Engine",
            dependencies: [
                "SwiftPriorityQueue",
                "EngineData",
                "Debug",
            ]
        ),
    ]
)
