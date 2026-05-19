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
    try check(themes.count == 10, "Expected 10 bundled themes.")
    try check(themes.contains { $0.name == "Capture Orb Folder" }, "Capture Orb theme missing.")
    try check(themes.contains { $0.name == "Retro Pixel Folder" }, "Retro Pixel theme missing.")

    let packs = Set(PresetPack.samplePacks.map(\.name))
    try check(
        packs.isSuperset(of: ["Starter Pack", "Electric Pack", "Fire Pack", "Water Pack", "Dark Pack", "Legendary Pack", "Pixel Pack"]),
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
}

do {
    try runChecks()
    print("All PokeFolders core checks passed.")
} catch {
    fputs("PokeFolders core checks failed: \(error)\n", stderr)
    exit(1)
}
