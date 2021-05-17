// swift-tools-version:5.3
// Minimum tool version 5.3 required for Swift Argument Parser. Sorry Mojave users.

import PackageDescription

let package = Package(
    name: "spmalot",
    platforms: [
      .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "spmalot",
            targets: ["spmalot"]),
    ],
    dependencies: [
        .package(url:"https://github.com/apple/swift-argument-parser", .exact("0.4.2")),
        .package(url: "https://github.com/erica/Swift-General-Utility", from: "0.0.6"),
        .package(url: "https://github.com/erica/Swift-Mac-Utility", from:"0.0.4"),
    ],
    targets: [
        .target(
            name: "spmalot",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "MacUtility", package: "Swift-Mac-Utility"),
                .product(name: "GeneralUtility", package: "Swift-General-Utility"),
            ],
            path: "Sources/"
        ),
    ],
    swiftLanguageVersions: [
      .v5
    ]
)
