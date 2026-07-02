// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "RedScreen",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "RedScreen",
            path: "Sources/RedScreen"
        )
    ]
)
