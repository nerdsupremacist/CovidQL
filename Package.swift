// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CovidQL",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "CovidQL",
            targets: ["CovidQL"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nerdsupremacist/GraphZahl.git", from: "0.1.0-alpha.17"),
        .package(url: "https://github.com/nerdsupremacist/graphzahl-vapor-support.git", from: "0.1.0-alpha.4"),
    ],
    targets: [
        .target(
            name: "CovidQL",
            dependencies: ["GraphZahlVaporSupport"]
        ),
    ]
)
