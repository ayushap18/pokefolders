import AppKit
import Combine
import Foundation
import PokeFoldersCore

@MainActor
final class DesignViewModel: ObservableObject {
    @Published var configuration: IconConfiguration
    @Published var selectedThemeID: String?
    @Published var statusMessage: StatusMessage?

    let themes = FolderTheme.sampleThemes
    let packs = PresetPack.samplePacks

    private let exportService: ExportService
    private let folderIconApplier: FolderIconApplier

    init(
        configuration: IconConfiguration = .starter,
        exportService: ExportService = ExportService(),
        folderIconApplier: FolderIconApplier = FolderIconApplier()
    ) {
        self.configuration = configuration
        self.selectedThemeID = configuration.themeID
        self.exportService = exportService
        self.folderIconApplier = folderIconApplier
    }

    var selectedTheme: FolderTheme {
        themes.first { $0.id == configuration.themeID } ?? themes[0]
    }

    func selectTheme(id: String?) {
        guard let id, let theme = themes.first(where: { $0.id == id }) else { return }
        configuration.apply(theme: theme)
        selectedThemeID = id
        statusMessage = StatusMessage(text: "\(theme.name) loaded.", style: .success)
    }

    func apply(pack: PresetPack) {
        guard let id = pack.themeIDs.first else { return }
        selectTheme(id: id)
        statusMessage = StatusMessage(text: "\(pack.name) applied.", style: .success)
    }

    func apply(preset: DesignPreset) {
        configuration = preset.configuration
        selectedThemeID = preset.configuration.themeID
        statusMessage = StatusMessage(text: "\(preset.name) loaded.", style: .success)
    }

    func randomize() {
        configuration = IconConfiguration.random()
        selectedThemeID = configuration.themeID
        statusMessage = StatusMessage(text: "Random design generated.", style: .success)
    }

    func previewImage(size: Int = 512) -> NSImage {
        ExportRenderer.render(configuration: configuration, size: size)
    }

    func setCustomBadge(data: Data) {
        configuration.customBadgeImageData = data
        configuration.badgePosition = .watermark
        configuration.customBadgeOpacity = 0.72
        statusMessage = StatusMessage(text: "Custom badge added.", style: .success)
    }

    func clearCustomBadge() {
        configuration.customBadgeImageData = nil
        statusMessage = StatusMessage(text: "Custom badge cleared.", style: .success)
    }

    func savePreset(in presetStore: PresetStore) {
        let defaultName = "\(selectedTheme.name) \(DateFormatter.shortPresetStamp.string(from: Date()))"
        guard let name = PanelBridge.promptForText(
            title: "Save Preset",
            message: "Name this design.",
            defaultValue: defaultName
        ) else {
            return
        }

        if presetStore.save(name: name, configuration: configuration, packName: selectedTheme.packName) != nil {
            statusMessage = StatusMessage(text: "\(name) saved.", style: .success)
        } else if let error = presetStore.lastError {
            statusMessage = StatusMessage(text: error, style: .failure)
        }
    }

    func renamePreset(_ preset: DesignPreset, in presetStore: PresetStore) {
        guard let name = PanelBridge.promptForText(
            title: "Rename Preset",
            message: "Update the preset name.",
            defaultValue: preset.name
        ) else {
            return
        }

        presetStore.rename(id: preset.id, to: name)
        if let error = presetStore.lastError {
            statusMessage = StatusMessage(text: error, style: .failure)
        } else {
            statusMessage = StatusMessage(text: "Preset renamed.", style: .success)
        }
    }

    func deletePreset(_ preset: DesignPreset, in presetStore: PresetStore) {
        presetStore.delete(id: preset.id)
        if let error = presetStore.lastError {
            statusMessage = StatusMessage(text: error, style: .failure)
        } else {
            statusMessage = StatusMessage(text: "Preset deleted.", style: .success)
        }
    }

    func exportPNG(size: Int) {
        guard let url = PanelBridge.savePNGURL(defaultName: "PokeFolders-\(size)") else { return }

        do {
            try exportService.exportPNG(configuration: configuration, size: size, to: url)
            statusMessage = StatusMessage(text: "PNG exported to \(url.lastPathComponent).", style: .success)
        } catch {
            statusMessage = StatusMessage(text: error.localizedDescription, style: .failure)
        }
    }

    func exportIconset() {
        guard let directory = PanelBridge.chooseDirectory(title: "Export Iconset") else { return }

        do {
            let url = try exportService.exportIconset(configuration: configuration, to: directory, name: "PokeFoldersIcon")
            statusMessage = StatusMessage(text: "\(url.lastPathComponent) exported.", style: .success)
        } catch {
            statusMessage = StatusMessage(text: error.localizedDescription, style: .failure)
        }
    }

    func exportICNS() {
        guard let url = PanelBridge.saveICNSURL(defaultName: "PokeFoldersIcon") else { return }

        do {
            try exportService.exportICNS(configuration: configuration, to: url, name: "PokeFoldersIcon")
            statusMessage = StatusMessage(text: "ICNS exported to \(url.lastPathComponent).", style: .success)
        } catch {
            statusMessage = StatusMessage(text: error.localizedDescription, style: .failure)
        }
    }

    func applyToFolder() {
        guard let folderURL = PanelBridge.chooseFolder() else { return }

        do {
            try folderIconApplier.apply(configuration: configuration, to: folderURL)
            statusMessage = StatusMessage(text: "Icon applied to \(folderURL.lastPathComponent).", style: .success)
        } catch {
            statusMessage = StatusMessage(text: error.localizedDescription, style: .failure)
        }
    }
}

struct StatusMessage: Identifiable, Equatable {
    enum Style {
        case success
        case failure
        case neutral
    }

    let id = UUID()
    var text: String
    var style: Style
}

private extension DateFormatter {
    static let shortPresetStamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
}
