// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ForgeMMDB",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(name: "ForgeMMDB", targets: ["ForgeMMDB"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CoderQuinn/ForgeBase.git", from: "0.2.1"),
    ],
    targets: [
        .target(
            name: "libmaxminddb",
            path: "Sources/libmaxminddb",
            sources: [
                "src/data-pool.c",
                "src/maxminddb.c"
            ],
            publicHeadersPath: "include",
            cSettings: [
                .define("MMDB_UINT128_IS_BYTE_ARRAY"),
                .headerSearchPath("src"),
                .define("PACKAGE_VERSION", to: "\"0.0.0\"")
            ]
        ),
        .target(
            name: "ForgeMMDBBridge",
            dependencies: ["libmaxminddb"],
            path: "Sources/ForgeMMDBBridge",
            publicHeadersPath: "include"
        ),
        .target(
            name: "ForgeMMDB",
            dependencies: ["ForgeMMDBBridge", "ForgeBase"],
            path: "Sources/ForgeMMDB",
            resources: [
                .copy("Resources/Country.mmdb")
            ]
        ),
        .testTarget(
            name: "ForgeMMDBTests",
            dependencies: ["ForgeMMDB"],
            path: "Tests/ForgeMMDBTests"
        ),
    ]
)

