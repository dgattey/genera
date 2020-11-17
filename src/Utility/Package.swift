// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Utility",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "Utility",
            targets: ["Utility"]
        ),
    ],
    targets: [
        .target(
            name: "Utility",
            dependencies: []
        ),
    ]
)
