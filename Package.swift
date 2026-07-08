// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PeckitDevCenter",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "PeckitDevCenter",
            path: "Sources/PeckitDevCenter"
        )
    ]
)
