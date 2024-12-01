// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EthCore",
    platforms: [
            .iOS(.v13),       // Minimum iOS version 13
            .macOS(.v11),     // Minimum macOS version 11
            .watchOS(.v7),    // Minimum watchOS version 7
            .tvOS(.v14)       // Minimum tvOS version 14
        ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EthCore",
            targets: ["EthCore"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EthCore"),
        .testTarget(
            name: "EthCoreTests",
            dependencies: ["EthCore"]
        ),
    ]
)
