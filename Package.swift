// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FriendlyCaptcha",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(
            name: "FriendlyCaptcha",
            targets: ["FriendlyCaptcha"]
        )
    ],
    targets: [
        .target(
            name: "FriendlyCaptcha",
            path: "FriendlyCaptcha/Classes"
        )
    ]
)
