// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Annotator",
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", .branch("swift-DEVELOPMENT-SNAPSHOT-2018-08-25-a")),
    ],
    targets: [
        .target(
            name: "Annotator",
            dependencies: ["AnnotatorCore"]),
        .target(
            name: "AnnotatorCore",
            dependencies: ["SwiftSyntax"]),
        .testTarget(
            name: "AnnotatorTests",
            dependencies: ["Annotator"]),
    ]
)
