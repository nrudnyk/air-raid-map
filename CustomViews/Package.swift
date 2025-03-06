// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CustomViews",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7)
    ],
    products: [
        .library(name: "CustomViews", targets: ["CustomViews"]),
    ],
    dependencies: [
        .package(path: "../Extensions"),
    ],
    targets: [
        .target(name: "CustomViews", dependencies: [
            .product(name: "Extensions", package: "Extensions")
        ], path: "./Sources"),
        .testTarget(name: "CustomViewsTests", dependencies: ["CustomViews"]),
    ]
)
