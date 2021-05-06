// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "EasyTable",
    platforms: [
        .iOS(.v12), .tvOS(.v12)
    ],
    products: [
        .library(
            name: "EasyTable",
            targets: ["EasyTable"]
        ),
    ],
    targets: [
        .target(
            name: "EasyTable",
            dependencies: []
        ),
    ]
)
