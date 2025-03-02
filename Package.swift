// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "DeVolume",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "DeVolume", targets: ["DeVolume"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "DeVolume",
            dependencies: [],
            path: "DeVolume",
            sources: ["Sources"],
            resources: [
                .copy("Resources")
            ]
        )
    ]
) 