// swift-tools-version:4.2

///
/// Annotator
/// Copyright (c) 2018 József Vesza
/// Licensed under the MIT license. See LICENSE file.
///

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
    ]
)
