// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StayAwake",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "StayAwake", targets: ["StayAwake"])
    ],
    targets: [
        .executableTarget(
            name: "StayAwake",
            linkerSettings: [
                .linkedFramework("IOKit")
            ]
        ),
        .testTarget(
            name: "StayAwakeTests",
            dependencies: ["StayAwake"]
        )
    ]
)
