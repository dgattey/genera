// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// The core of the non-engine specific game (shaders + code to run the Genera specific game)
let generaGamePackage = Package(
    name: "GeneraGame",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "GeneraGame",
            targets: ["GeneraGame", "GeneraGameData"]
        ),
    ],
    dependencies: [
        .package(path: "Engine"),
    ],
    targets: [
        /// The shader types that power the game
        .target(
            name: "GeneraGameData",
            dependencies: ["Engine"]
        ),
        /// In charge of running the Genera game (terrain + grid) in Swift
        .target(
            name: "GeneraGame",
            dependencies: [
                "GeneraGameData",
                "Engine",
            ]
        ),
    ]
)
