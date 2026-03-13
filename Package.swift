// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iOSMapsTest",
    platforms: [.iOS(.v17)],
    dependencies: [
        .package(url: "https://github.com/maplibre/maplibre-gl-native-distribution.git", from: "6.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "iOSMapsTest",
            dependencies: [
                .product(name: "MapLibre", package: "maplibre-gl-native-distribution"),
            ],
            path: "Sources",
            resources: [
                .process("Resources/Assets.xcassets"),
                .copy("Resources/leaflet.html"),
                .copy("Resources/test-polygon.geojson"),
                .copy("Resources/test-annotations.json"),
            ]
        ),
        .testTarget(
            name: "iOSMapsTestTests",
            dependencies: ["iOSMapsTest"],
            path: "Tests/iOSMapsTestTests"
        ),
    ]
)
