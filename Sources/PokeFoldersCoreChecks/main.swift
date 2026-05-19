import Foundation
import PokeFoldersCore

struct CheckFailure: Error, CustomStringConvertible {
    var message: String
    var description: String { message }
}

func check(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    guard condition() else {
        throw CheckFailure(message: message)
    }
}

func require<T>(_ value: T?, _ message: String) throws -> T {
    guard let value else {
        throw CheckFailure(message: message)
    }
    return value
}

func runChecks() throws {
    let themes = FolderTheme.sampleThemes
    let packsCatalog = ProductionIconCatalog.allPacks
    let designs = ProductionIconCatalog.allDesigns
    try check(packsCatalog.count == 8, "Expected 8 production icon packs.")
    try check(designs.count == 40, "Expected 40 production icon designs.")
    try check(themes.count == 40, "Expected 40 compatibility themes.")
    try check(designs.contains { $0.name == "Flame Starter" }, "Flame Starter design missing.")
    try check(designs.contains { $0.name == "Cosmic Beast" }, "Cosmic Beast design missing.")
    try check(designs.contains { $0.name == "Classic Game" }, "Classic Game design missing.")

    let packs = Set(PresetPack.samplePacks.map(\.name))
    try check(
        packs.isSuperset(of: ["Starter Pack", "Legendary Pack", "Electric Pack", "Fire Pack", "Water Pack", "Grass Pack", "Dark Pack", "Pixel Retro Pack"]),
        "Preset packs do not cover the required pack list."
    )

    let randomConfig = IconConfiguration.random()
    try check(themes.contains { $0.id == randomConfig.themeID }, "Random theme id is not in the theme catalog.")
    try check((0...1).contains(randomConfig.glowIntensity), "Random glow is outside 0...1.")
    try check((0...1).contains(randomConfig.shadowIntensity), "Random shadow is outside 0...1.")
    try check((24...78).contains(randomConfig.cornerRadius), "Random corner radius is outside 24...78.")
    try check((128...1024).contains(randomConfig.iconSize), "Random icon size is outside 128...1024.")

    let image = ExportRenderer.render(configuration: .starter, size: 512)
    try check(Int(image.size.width) == 512, "Rendered width is not 512.")
    try check(Int(image.size.height) == 512, "Rendered height is not 512.")
    try check(ExportRenderer.renderCGImage(configuration: .starter, size: 512) != nil, "CGImage rendering failed.")
    let pngData = try require(ExportRenderer.pngData(configuration: .starter, size: 512), "PNG encoding failed.")
    try check(pngData.count > 1_000, "PNG output is unexpectedly small.")

    let tempDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: tempDirectory) }

    let exportService = ExportService(fileManager: .default)
    let iconsetURL = try exportService.exportIconset(configuration: .starter, to: tempDirectory, name: "PokeFoldersTest")
    let expectedFiles = [
        "icon_16x16.png",
        "icon_16x16@2x.png",
        "icon_32x32.png",
        "icon_32x32@2x.png",
        "icon_128x128.png",
        "icon_128x128@2x.png",
        "icon_256x256.png",
        "icon_256x256@2x.png",
        "icon_512x512.png",
        "icon_512x512@2x.png"
    ]
    for fileName in expectedFiles {
        try check(
            FileManager.default.fileExists(atPath: iconsetURL.appendingPathComponent(fileName).path),
            "\(fileName) was not written."
        )
    }

    let icnsURL = tempDirectory.appendingPathComponent("PokeFoldersTest.icns")
    try exportService.exportICNS(configuration: .starter, to: icnsURL, name: "PokeFoldersTest")
    try check(FileManager.default.fileExists(atPath: icnsURL.path), "ICNS file was not written.")
    let icnsSize = try FileManager.default.attributesOfItem(atPath: icnsURL.path)[.size] as? NSNumber
    try check((icnsSize?.intValue ?? 0) > 1_000, "ICNS file is unexpectedly small.")

    let starterPack = try require(ProductionIconCatalog.pack(id: "starter"), "Starter pack missing.")
    let fullPackURL = try exportService.exportFullPack(starterPack, to: tempDirectory, includeZip: true)
    try check(FileManager.default.fileExists(atPath: fullPackURL.appendingPathComponent("PNG/1024/starter_flame_1024.png").path), "Full pack 1024 PNG missing.")
    try check(FileManager.default.fileExists(atPath: fullPackURL.appendingPathComponent("ICNS-Ready/starter_flame.iconset").path), "Full pack iconset missing.")
    try check(FileManager.default.fileExists(atPath: tempDirectory.appendingPathComponent("\(fullPackURL.lastPathComponent).zip").path), "Full pack ZIP missing.")

    let presetsURL = tempDirectory.appendingPathComponent("presets.json")
    let presetService = PresetStorageService(fileURL: presetsURL)
    let preset = try presetService.savePreset(name: "First", configuration: .starter, packName: "Starter Pack")
    let savedPresetNames = try presetService.loadPresets().map(\.name)
    try check(savedPresetNames == ["First"], "Preset save did not persist the expected name.")

    let renamed = try presetService.renamePreset(id: preset.id, to: "Renamed")
    try check(renamed.name == "Renamed", "Preset rename returned the wrong name.")

    let reloaded = try PresetStorageService(fileURL: presetsURL).loadPresets()
    try check(reloaded.count == 1, "Reloaded preset count is wrong.")
    try check(reloaded.first?.name == "Renamed", "Reloaded preset name is wrong.")

    try presetService.deletePreset(id: preset.id)
    let remainingPresets = try presetService.loadPresets()
    try check(remainingPresets.isEmpty, "Preset delete did not remove the preset.")

    let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let assetRoot = currentDirectory.appendingPathComponent("Assets/IconPacks", isDirectory: true)
    if FileManager.default.fileExists(atPath: assetRoot.path),
       let enumerator = FileManager.default.enumerator(at: assetRoot, includingPropertiesForKeys: nil) {
        let pngCount = enumerator.compactMap { $0 as? URL }.filter { $0.pathExtension == "png" }.count
        try check(pngCount == 160, "Expected 160 generated PNG assets, found \(pngCount).")
    }

    let promptRoot = currentDirectory.appendingPathComponent("Assets/GenerationPrompts", isDirectory: true)
    if FileManager.default.fileExists(atPath: promptRoot.path),
       let enumerator = FileManager.default.enumerator(at: promptRoot, includingPropertiesForKeys: nil) {
        let promptCount = enumerator.compactMap { $0 as? URL }.filter { $0.pathExtension == "md" }.count
        try check(promptCount == 8, "Expected 8 generation prompt files, found \(promptCount).")
    }
}

do {
    try runChecks()
    print("All PokeFolders core checks passed.")
} catch {
    fputs("PokeFolders core checks failed: \(error)\n", stderr)
    exit(1)
}
