// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CovidQL",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "CovidQL",
            targets: ["CovidQL"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nerdsupremacist/graphzahl-vapor-support.git", from: "0.1.0-alpha.4"),
    ],
    targets: [
        .target(
            name: "CovidQL",
            dependencies: ["GraphZahlVaporSupport"]
        ),
    ]
)
