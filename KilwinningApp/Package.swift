// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "KilwinningApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "KilwinningApp",
            targets: ["KilwinningApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "KilwinningApp",
            path: "Sources",
        
        ),
        .testTarget(
            name: "KilwinningAppTests",
            dependencies: ["KilwinningApp"],
            path: "Tests"
        )
    ]
)