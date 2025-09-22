// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Letopis",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Letopis",
            targets: ["Letopis"]
        )
    ],
    targets: [
        .target(
            name: "Letopis",
            exclude: ["Examples/Example.md"]
        ),
        .testTarget(
            name: "LetopisTests",
            dependencies: ["Letopis"]
        )
    ]
)
