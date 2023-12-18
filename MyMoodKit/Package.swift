// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyMoodKit",
    platforms: [.iOS(.v17), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "RootFeature", targets: ["RootFeature"]),
        .library(name: "EntryListFeature", targets: ["EntryListFeature"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "Theme", targets: ["Theme"]),
        .library(name: "UIComponents", targets: ["UIComponents"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.5.3"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RootFeature",
            dependencies: [
                "EntryListFeature",
                "Theme",
                "UIComponents",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "RootFeatureTests",
            dependencies: [
                "RootFeature",
            ]
        ),
        .target(
            name: "EntryListFeature",
            dependencies: [
                "Theme",
                "UIComponents",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "EntryListFeatureTests",
            dependencies: [
                "EntryListFeature",
            ]
        ),
        .target(
            name: "Models",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Theme",
            dependencies: ["Models"],
            resources: [.process("Assets.xcassets")]
        ),
        .target(
            name: "UIComponents",
            dependencies: ["Theme"]
        ),
    ]
)
