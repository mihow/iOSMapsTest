// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iOSMapsTest",
    platforms: [.iOS(.v17)],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "MapLibre",
            path: "MapLibre.xcframework"
        ),
        .executableTarget(
            name: "iOSMapsTest",
            dependencies: [
                "MapLibre",
            ],
            path: "Sources",
            resources: [
                .process("Resources/Assets.xcassets"),
                .copy("Resources/leaflet.html"),
                .copy("Resources/test-polygon.geojson"),
                .copy("Resources/test-annotations.json"),
            ],
            linkerSettings: [
                .unsafeFlags(["-ObjC"])
            ]
        ),
        .testTarget(
            name: "iOSMapsTestTests",
            dependencies: ["iOSMapsTest"],
            path: "Tests/iOSMapsTestTests"
        ),
    ]
)
