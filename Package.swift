// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "itsypad",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "Packages/Bonsplit"),
    ],
    targets: [
        .target(
            name: "ItsypadCore",
            dependencies: [
                .product(name: "Bonsplit", package: "Bonsplit"),
            ],
            path: "Sources",
            exclude: ["Info.plist", "itsypad.entitlements", "itsypad-direct.entitlements", "itsypad-local.entitlements"],
            resources: [.process("Resources")]
        ),
        .executableTarget(
            name: "Itsypad",
            dependencies: ["ItsypadCore"],
            path: "Executable",
            exclude: ["PackageInfo.plist"],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "Executable/PackageInfo.plist"])
            ]
        ),
        .testTarget(
            name: "ItsypadTests",
            dependencies: ["ItsypadCore"],
            path: "Tests"
        ),
    ]
)
