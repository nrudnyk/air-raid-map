// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Extensions",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v15),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "Extensions",
            targets: ["Extensions"]
        )
    ],
    targets: [
        .target(
            name: "Extensions",
            path: "Sources"
        ),
        .testTarget(
            name: "ExtensionsTests",
            dependencies: ["Extensions"]
        ),
    ]
)
