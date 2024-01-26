// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyMoodKit",
    platforms: [.iOS(.v17), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "ColorGeneratorClient", targets: ["ColorGeneratorClient"]),
        .library(name: "EntryListFeature", targets: ["EntryListFeature"]),
        .library(name: "FormattersClient", targets: ["FormattersClient"]),
        .library(name: "LocationClient", targets: ["LocationClient"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "MoodEntryFeature", targets: ["MoodEntryFeature"]),
        .library(name: "NoteEntryFeature", targets: ["NoteEntryFeature"]),
        .library(name: "RootFeature", targets: ["RootFeature"]),
        .library(name: "Theme", targets: ["Theme"]),
        .library(name: "UIComponents", targets: ["UIComponents"]),
        .library(name: "WeatherClient", targets: ["WeatherClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.5.3"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ColorGeneratorClient",
            dependencies: [
                "Models",
                "Theme",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "ColorGeneratorClientTests",
            dependencies: [
                "ColorGeneratorClient",
            ]
        ),
        .target(
            name: "EntryListFeature",
            dependencies: [
                "ColorGeneratorClient",
                "FormattersClient",
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
            name: "FormattersClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "FormattersClientTests",
            dependencies: [
                "FormattersClient",
            ]
        ),
        .target(
            name: "LocationClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "LocationClientTests",
            dependencies: [
                "LocationClient",
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
            name: "MoodEntryFeature",
            dependencies: [
                "ColorGeneratorClient",
                "FormattersClient",
                "Theme",
                "LocationClient",
                "Models",
                "NoteEntryFeature",
                "UIComponents",
                "WeatherClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "MoodEntryFeatureTests",
            dependencies: [
                "MoodEntryFeature",
            ]
        ),
        .target(
          name: "NoteEntryFeature",
          dependencies: [
            "UIComponents",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
          ]
        ),
        .testTarget(
          name: "NoteEntryFeatureTests",
          dependencies: [
            "NoteEntryFeature",
          ]
        ),
        .target(
            name: "RootFeature",
            dependencies: [
                "EntryListFeature",
                "MoodEntryFeature",
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
            name: "Theme",
            dependencies: ["Models"],
            resources: [.process("Assets.xcassets")]
        ),
        .target(
            name: "UIComponents",
            dependencies: ["Theme"]
        ),
        .target(
            name: "WeatherClient",
            dependencies: [
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "WeatherClientTests",
            dependencies: [
                "WeatherClient",
            ]
        ),
    ]
)
