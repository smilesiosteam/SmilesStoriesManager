// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SmilesStoriesManager",
    platforms: [
        .iOS(.v13)
    ], products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SmilesStoriesManager",
            targets: ["SmilesStoriesManager"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/smilesiosteam/SmilesBaseMainRequest.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/hananahmad/NetworkingLayer.git", from: "1.0.0"),
        .package(url: "https://github.com/hananahmad/SmilesLoader.git", from: "1.0.0"),
        .package(url: "https://github.com/hananahmad/SmilesLanguageManager.git", from: "1.0.0"),
        .package(url: "https://github.com/airbnb/lottie-ios.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/hananahmad/SmilesFontManager.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SmilesStoriesManager",
            dependencies: [
                .product(name: "SmilesBaseMainRequestManager", package: "SmilesBaseMainRequest"),
                .product(name: "NetworkingLayer", package: "NetworkingLayer"),
                .product(name: "SmilesLoader", package: "SmilesLoader"),
                .product(name: "SmilesLanguageManager", package: "SmilesLanguageManager"),
                .product(name: "SmilesFontsManager", package: "SmilesFontManager"),
                .product(name: "Lottie", package: "lottie-ios")
            ]),
    ]
)
