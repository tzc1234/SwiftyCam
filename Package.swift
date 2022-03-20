// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "SwiftyCam",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SwiftyCam",
            targets: ["SwiftyCam"]
        )
    ],
    dependencies: [],
    targets: [
        .target(name: "SwiftyCam")
    ],
    swiftLanguageVersions: [.v5]
)
