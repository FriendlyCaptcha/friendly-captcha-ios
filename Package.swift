// swift-tools-version: 6.1
import PackageDescription

internal let package = Package(
    name: "FriendlyCaptcha",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "FriendlyCaptcha",
            targets: ["FriendlyCaptcha"]
        ),
    ],
    targets: [
        .target(
            name: "FriendlyCaptcha",
            path: "FriendlyCaptcha/Classes"
        ),
    ],
    swiftLanguageModes: [.v5]
)

