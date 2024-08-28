// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppMobile",
    defaultLocalization: "en",
    platforms: [.macOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppMobile",
            targets: ["AppMobile"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Lakr233/AppleMobileDeviceLibrary", from: "1.0.0"),
        .package(url: "https://github.com/Lakr233/ColorfulX", from: "5.1.0"),
        .package(url: "https://github.com/Lakr233/AuxiliaryExecute", from: "2.0.0"),
        .package(url: "https://github.com/marksands/BetterCodable", from: "0.4.0"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.70.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppMobile",
            dependencies: [
                "AppleMobileDeviceLibrary",
                "ColorfulX",
                "AuxiliaryExecute",
                "BetterCodable",
                .product(name: "NIO", package: "swift-nio"),
            ]
        ),
        .testTarget(
            name: "AppMobileTests",
            dependencies: ["AppMobile"]
        ),
    ]
)
