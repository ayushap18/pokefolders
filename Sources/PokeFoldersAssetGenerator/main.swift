import Foundation
import PokeFoldersCore

let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assetRoot = rootURL.appendingPathComponent("Assets", isDirectory: true)
let iconRoot = assetRoot.appendingPathComponent("IconPacks", isDirectory: true)
let promptRoot = assetRoot.appendingPathComponent("GenerationPrompts", isDirectory: true)
let sizes = [1024, 512, 256, 128]

let packDirectoryNames: [String: String] = [
    "starter": "Starter",
    "legendary": "Legendary",
    "electric": "Electric",
    "fire": "Fire",
    "water": "Water",
    "grass": "Grass",
    "dark": "Dark",
    "pixel-retro": "PixelRetro"
]

let promptFileNames: [String: String] = [
    "starter": "starter-pack-prompts.md",
    "legendary": "legendary-pack-prompts.md",
    "electric": "electric-pack-prompts.md",
    "fire": "fire-pack-prompts.md",
    "water": "water-pack-prompts.md",
    "grass": "grass-pack-prompts.md",
    "dark": "dark-pack-prompts.md",
    "pixel-retro": "pixel-retro-pack-prompts.md"
]

func resetDirectory(_ url: URL) throws {
    if FileManager.default.fileExists(atPath: url.path) {
        try FileManager.default.removeItem(at: url)
    }
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
}

func writePrompts(for pack: IconPack) throws {
    let fileName = promptFileNames[pack.id] ?? "\(pack.id)-prompts.md"
    let url = promptRoot.appendingPathComponent(fileName)
    var markdown = "# \(pack.name) Image 2.0 Prompts\n\n"
    markdown += "Use these prompts to replace the CoreGraphics placeholder PNGs with AI-generated production assets. All prompts are copyright-safe and avoid official characters, logos, and trademarked artwork.\n\n"

    for design in pack.icons {
        markdown += """
        ## \(design.name)

        Icon Name:
        \(design.name)

        Prompt:
        \(design.generationPrompt)

        Negative Prompt:
        \(design.negativePrompt)

        Recommended Size:
        1024x1024 PNG

        Transparent Background:
        Yes

        Style Notes:
        Centered macOS folder silhouette, smooth 3D/vector hybrid finish, \(design.textureStyle.title.lowercased()) texture, \(design.glowStyle.title.lowercased()) glow, no text, no logo.

        """
    }

    try markdown.write(to: url, atomically: true, encoding: .utf8)
}

func generatePNGs(for pack: IconPack) throws {
    let directoryName = packDirectoryNames[pack.id] ?? pack.id
    let packURL = iconRoot.appendingPathComponent(directoryName, isDirectory: true)
    try FileManager.default.createDirectory(at: packURL, withIntermediateDirectories: true)

    for design in pack.icons {
        let configuration = IconConfiguration(design: design)
        for size in sizes {
            let fileName = design.exportFileNames["\(size)"] ?? "\(design.exportBaseName)_\(size).png"
            guard let data = ExportRenderer.pngData(configuration: configuration, size: size, quality: .ultra) else {
                throw AssetGenerationError.pngFailed(design.id, size)
            }
            try data.write(to: packURL.appendingPathComponent(fileName), options: .atomic)
        }
    }
}

enum AssetGenerationError: Error, CustomStringConvertible {
    case pngFailed(String, Int)

    var description: String {
        switch self {
        case .pngFailed(let id, let size):
            return "Failed to render \(id) at \(size)."
        }
    }
}

do {
    try resetDirectory(iconRoot)
    try resetDirectory(promptRoot)

    for pack in ProductionIconCatalog.allPacks {
        try generatePNGs(for: pack)
        try writePrompts(for: pack)
    }

    print("Generated \(ProductionIconCatalog.allDesigns.count) designs across \(ProductionIconCatalog.allPacks.count) packs.")
} catch {
    fputs("Asset generation failed: \(error)\n", stderr)
    exit(1)
}
