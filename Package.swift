// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PokeFolders",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "PokeFolders", targets: ["PokeFolders"]),
        .executable(name: "PokeFoldersCoreChecks", targets: ["PokeFoldersCoreChecks"]),
        .executable(name: "PokeFoldersAssetGenerator", targets: ["PokeFoldersAssetGenerator"]),
        .library(name: "PokeFoldersCore", targets: ["PokeFoldersCore"])
    ],
    targets: [
        .target(
            name: "PokeFoldersCore"
        ),
        .executableTarget(
            name: "PokeFolders",
            dependencies: ["PokeFoldersCore"],
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "PokeFoldersCoreChecks",
            dependencies: ["PokeFoldersCore"]
        ),
        .executableTarget(
            name: "PokeFoldersAssetGenerator",
            dependencies: ["PokeFoldersCore"]
        )
    ]
)
