// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ICUNumberSkeletonFormat",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "ICUNumberSkeletonFormat",
            targets: ["ICUNumberSkeletonFormat"]
        ),
    ],
    targets: [
        .target(
            name: "ICUNumberSkeletonFormat",
            dependencies: []
        ),
        .testTarget(
            name: "ICUNumberSkeletonFormatTests",
            dependencies: ["ICUNumberSkeletonFormat"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
