import AppKit
import Combine
import Foundation
import PokeFoldersCore

@MainActor
final class DesignViewModel: ObservableObject {
    @Published var configuration: IconConfiguration
    @Published var selectedPackID: String
    @Published var selectedDesignID: String
    @Published var selectedThemeID: String?
    @Published var searchText = ""
    @Published var selectedTypeFilter: ElementType?
    @Published var hoveredDesignID: String?
    @Published var statusMessage: StatusMessage?
    @Published var isExporting = false

    let iconPacks = ProductionIconCatalog.allPacks
    let themes = FolderTheme.sampleThemes
    let legacyPresetPacks = PresetPack.samplePacks

    private let exportService: ExportService
    private let folderIconApplier: FolderIconApplier

    init(
        configuration: IconConfiguration = .starter,
        exportService: ExportService = ExportService(),
        folderIconApplier: FolderIconApplier = FolderIconApplier()
    ) {
        let firstDesign = ProductionIconCatalog.allDesigns[0]
        self.configuration = configuration
        self.selectedPackID = firstDesign.packId
        self.selectedDesignID = configuration.designID ?? firstDesign.id
        self.selectedThemeID = configuration.designID ?? firstDesign.id
        self.exportService = exportService
        self.folderIconApplier = folderIconApplier
        if let design = ProductionIconCatalog.design(id: self.selectedDesignID) {
            self.configuration = IconConfiguration(design: design)
        }
    }

    var selectedPack: IconPack {
        iconPacks.first { $0.id == selectedPackID } ?? iconPacks[0]
    }

    var selectedDesign: FolderIconDesign {
        ProductionIconCatalog.design(id: selectedDesignID) ?? selectedPack.icons[0]
    }

    var selectedTheme: FolderTheme {
        let pack = ProductionIconCatalog.pack(id: selectedDesign.packId) ?? selectedPack
        return FolderTheme(design: selectedDesign, pack: pack)
    }

    var filteredDesigns: [FolderIconDesign] {
        selectedPack.icons.filter { design in
            let matchesSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || design.name.localizedCaseInsensitiveContains(searchText)
                || design.type.title.localizedCaseInsensitiveContains(searchText)
            let matchesType = selectedTypeFilter == nil || design.type == selectedTypeFilter
            return matchesSearch && matchesType
        }
    }

    var productionFilterTypes: [ElementType] {
        [.fire, .water, .grass, .electric, .dark, .mystic, .legendary, .pixel]
    }

    func selectPack(id: String) {
        guard let pack = iconPacks.first(where: { $0.id == id }) else { return }
        selectedPackID = id
        selectedTypeFilter = nil
        searchText = ""
        if let first = pack.icons.first {
            selectDesign(first)
        }
    }

    func selectDesign(_ design: FolderIconDesign) {
        selectedDesignID = design.id
        selectedThemeID = design.id
        if selectedPackID != design.packId {
            selectedPackID = design.packId
        }
        configuration.apply(design: design)
        statusMessage = StatusMessage(text: "\(design.name) loaded.", style: .success)
    }

    func selectTheme(id: String?) {
        guard let id, let design = ProductionIconCatalog.design(id: id) else { return }
        selectDesign(design)
    }

    func apply(pack: IconPack) {
        selectPack(id: pack.id)
        statusMessage = StatusMessage(text: "\(pack.name) opened.", style: .success)
    }

    func apply(preset: DesignPreset) {
        configuration = preset.configuration
        let designID = preset.configuration.designID ?? preset.configuration.themeID
        if let design = ProductionIconCatalog.design(id: designID) {
            selectedDesignID = design.id
            selectedPackID = design.packId
            selectedThemeID = design.id
        }
        statusMessage = StatusMessage(text: "\(preset.name) loaded.", style: .success)
    }

    func randomize() {
        let design = ProductionIconCatalog.allDesigns.randomElement() ?? ProductionIconCatalog.allDesigns[0]
        selectDesign(design)
        configuration = IconConfiguration.random()
        selectedDesignID = design.id
        selectedPackID = design.packId
        selectedThemeID = design.id
        statusMessage = StatusMessage(text: "Random production design generated.", style: .success)
    }

    func previewImage(size: Int = 512, quality: RenderQuality = .preview) -> NSImage {
        ExportRenderer.render(configuration: configuration, size: size, quality: quality)
    }

    func previewImage(for design: FolderIconDesign, size: Int = 256) -> NSImage {
        ExportRenderer.render(configuration: IconConfiguration(design: design), size: size, quality: .preview)
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
        let defaultName = "\(selectedDesign.name) \(DateFormatter.shortPresetStamp.string(from: Date()))"
        guard let name = PanelBridge.promptForText(
            title: "Save Preset",
            message: "Name this production design.",
            defaultValue: defaultName
        ) else {
            return
        }

        if presetStore.save(name: name, configuration: configuration, packName: selectedPack.name) != nil {
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
        guard let url = PanelBridge.savePNGURL(defaultName: "\(selectedDesign.exportBaseName)_\(size)") else { return }

        do {
            try exportService.exportPNG(configuration: configuration, size: size, to: url, quality: .ultra)
            statusMessage = StatusMessage(text: "PNG exported to \(url.lastPathComponent).", style: .success)
        } catch {
            statusMessage = StatusMessage(text: error.localizedDescription, style: .failure)
        }
    }

    func exportSelectedIconset() {
        guard let directory = PanelBridge.chooseDirectory(title: "Export ICNS-ready Iconset") else { return }

        do {
            let url = try exportService.exportIconset(
                configuration: configuration,
                to: directory,
                name: selectedDesign.exportBaseName,
                quality: .ultra
            )
            statusMessage = StatusMessage(text: "\(url.lastPathComponent) exported.", style: .success)
        } catch {
            statusMessage = StatusMessage(text: error.localizedDescription, style: .failure)
        }
    }

    func exportICNS() {
        guard let url = PanelBridge.saveICNSURL(defaultName: selectedDesign.exportBaseName) else { return }

        do {
            try exportService.exportICNS(configuration: configuration, to: url, name: selectedDesign.exportBaseName, quality: .ultra)
            statusMessage = StatusMessage(text: "ICNS exported to \(url.lastPathComponent).", style: .success)
        } catch {
            statusMessage = StatusMessage(text: error.localizedDescription, style: .failure)
        }
    }

    func exportFullPack() {
        guard let directory = PanelBridge.chooseDirectory(title: "Export \(selectedPack.name)") else { return }

        isExporting = true
        do {
            let url = try exportService.exportFullPack(selectedPack, to: directory, includeZip: true)
            statusMessage = StatusMessage(text: "\(url.lastPathComponent) exported with PNG, iconsets, and ZIP.", style: .success)
        } catch {
            statusMessage = StatusMessage(text: error.localizedDescription, style: .failure)
        }
        isExporting = false
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
