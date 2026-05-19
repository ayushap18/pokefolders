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
        .library(name: "PokeFoldersCore", targets: ["PokeFoldersCore"])
    ],
    targets: [
        .target(
            name: "PokeFoldersCore"
        ),
        .executableTarget(
            name: "PokeFolders",
            dependencies: ["PokeFoldersCore"]
        ),
        .executableTarget(
            name: "PokeFoldersCoreChecks",
            dependencies: ["PokeFoldersCore"]
        )
    ]
)
