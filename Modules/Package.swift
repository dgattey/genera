// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// Contains all modules separate from the main app package that exist. Eventually almost all code will be in one of
/// these! Done as one big package for convenience, no real reason
let package = Package(
    name: "Modules",
    platforms: [.macOS(.v11)],
    products: [
        /// Collects all data structures
        .library(
            name: "DataStructures",
            targets: ["DataStructures", "DataStructuresSwift"]
        ),
        /// The core of the game (shaders + code to run the Genera specific game)
        .library(
            name: "GeneraGame",
            targets: ["GeneraGame", "GeneraShaderTypes"]
        ),
        /// Eventually this shouldn't need to be a library, but right now does for rest of it
        .library(
            name: "Engine",
            targets: ["Engine"]
        ),
        /// All the reusable UI that the app itself should use
        .library(
            name: "UI",
            targets: ["UI"]
        ),
    ],
    dependencies: [
        .package(path: "Utility"),
        .package(url: "https://github.com/davecom/SwiftPriorityQueue", .upToNextMinor(from: "1.3.1")),
    ],
    targets: [
        /// All data structures, pure ObjC
        .target(
            name: "DataStructures"
        ),
        /// Data structures extended in Swift
        .target(
            name: "DataStructuresSwift",
            dependencies: ["DataStructures"]
        ),
        /// Game engine itself, used from the game & externally
        .target(
            name: "Engine",
            dependencies: ["DataStructures", "DataStructuresSwift", "SwiftPriorityQueue", "Utility", "UI"]
        ),
        /// The shaders that power the game (includes Engine + other shaders for now with hardcoded paths to other packages... not ideal)
        .target(
            name: "GeneraShaderTypes",
            dependencies: ["DataStructures"]
        ),
        /// In charge of running the Genera game (terrain + grid) in Swift
        .target(
            name: "GeneraGame",
            dependencies: ["DataStructuresSwift", "GeneraShaderTypes", "Engine"]
        ),
        /// All the Swift-based reusable UI to expose to the app
        .target(
            name: "UI",
            dependencies: ["DataStructuresSwift"]
        ),
    ]
)
