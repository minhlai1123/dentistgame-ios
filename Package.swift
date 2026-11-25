// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DentistGame",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "DentistGame",
            targets: ["DentistGame"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DentistGame",
            dependencies: [],
            path: "Sources",
            resources: [
                .process("Assets")
            ]
        ),
        .testTarget(
            name: "DentistGameTests",
            dependencies: ["DentistGame"],
            path: "Tests"
        ),
    ]
)
