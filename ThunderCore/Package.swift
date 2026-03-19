// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ThunderCore",
    platforms: [
        .iOS(.v18),    // Minimum for SwiftData + CloudKit; Xcode project enforces iOS 26+
        .macOS(.v14),  // Required for swift test to run SwiftData-dependent test targets on macOS
    ],
    products: [
        .library(
            name: "ThunderCore",
            targets: ["ThunderCore"]
        ),
    ],
    targets: [
        .target(
            name: "ThunderCore",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "ThunderCoreTests",
            dependencies: ["ThunderCore"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
    ]
)
