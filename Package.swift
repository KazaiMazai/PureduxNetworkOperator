// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PureduxNetworkOperator",
    platforms: [
       .iOS(.v9)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PureduxNetworkOperator",
            targets: ["PureduxNetworkOperator"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "PureduxSideEffects",
                 url: "https://github.com/KazaiMazai/PureduxSideEffects.git",
                 .exact("1.0.0-beta.2"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PureduxNetworkOperator",
            dependencies: [
                .product(name: "PureduxSideEffects", package: "PureduxSideEffects"),

            ]),
        .testTarget(
            name: "PureduxNetworkOperatorTests",
            dependencies: ["PureduxNetworkOperator"]),
    ]
)
