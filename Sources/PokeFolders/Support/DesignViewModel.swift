import AppKit
import Combine
import Foundation
import PokeFoldersCore

enum IconSortMode: String, CaseIterable, Identifiable {
    case packOrder
    case name
    case type
    case rarity

    var id: String { rawValue }

    var title: String {
        switch self {
        case .packOrder: "Pack Order"
        case .name: "Name"
        case .type: "Type"
        case .rarity: "Aura"
        }
    }
}

@MainActor
final class DesignViewModel: ObservableObject {
    @Published var configuration: IconConfiguration
    @Published var selectedPackID: String
    @Published var selectedDesignID: String
    @Published var selectedThemeID: String?
    @Published var packSearchText = ""
    @Published var searchText = ""
    @Published var selectedTypeFilter: ElementType?
    @Published var sortMode: IconSortMode = .packOrder
    @Published var hoveredDesignID: String?
    @Published var favoriteDesignIDs: Set<String> = []
    @Published var pinnedPackIDs: Set<String> = []
    @Published var recentlyExportedDesignIDs: [String] = []
    @Published var statusMessage: StatusMessage?
    @Published var isExporting = false

    let iconPacks = ProductionIconCatalog.allPacks
    let themes = FolderTheme.sampleThemes
    let legacyPresetPacks = PresetPack.samplePacks

    private let exportService: ExportService
    private let folderIconApplier: FolderIconApplier
    private var designPreviewCache: [String: NSImage] = [:]
    private var livePreviewCache: [String: NSImage] = [:]

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

    var visiblePacks: [IconPack] {
        let query = packSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = iconPacks.filter { pack in
            query.isEmpty
                || pack.name.localizedCaseInsensitiveContains(query)
                || pack.description.localizedCaseInsensitiveContains(query)
                || pack.category.dexSubtitle.localizedCaseInsensitiveContains(query)
                || pack.icons.contains { $0.name.localizedCaseInsensitiveContains(query) || $0.type.title.localizedCaseInsensitiveContains(query) }
        }

        return filtered.sorted { lhs, rhs in
            let lhsPinned = pinnedPackIDs.contains(lhs.id)
            let rhsPinned = pinnedPackIDs.contains(rhs.id)
            if lhsPinned != rhsPinned {
                return lhsPinned
            }

            let lhsIndex = iconPacks.firstIndex(where: { $0.id == lhs.id }) ?? Int.max
            let rhsIndex = iconPacks.firstIndex(where: { $0.id == rhs.id }) ?? Int.max
            return lhsIndex < rhsIndex
        }
    }

    var filteredDesigns: [FolderIconDesign] {
        let filtered = selectedPack.icons.filter { design in
            let matchesSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || design.name.localizedCaseInsensitiveContains(searchText)
                || design.type.title.localizedCaseInsensitiveContains(searchText)
            let matchesType = selectedTypeFilter == nil || design.type == selectedTypeFilter
            return matchesSearch && matchesType
        }

        switch sortMode {
        case .packOrder:
            return filtered
        case .name:
            return filtered.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .type:
            return filtered.sorted {
                if $0.type.title == $1.type.title {
                    return $0.name.localizedStandardCompare($1.name) == .orderedAscending
                }
                return $0.type.title.localizedStandardCompare($1.type.title) == .orderedAscending
            }
        case .rarity:
            return filtered.sorted { rarityScore($0) > rarityScore($1) }
        }
    }

    var productionFilterTypes: [ElementType] {
        [.fire, .water, .grass, .electric, .dark, .mystic, .legendary, .pixel]
    }

    var recentlyExportedDesigns: [FolderIconDesign] {
        recentlyExportedDesignIDs.compactMap { ProductionIconCatalog.design(id: $0) }
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
        livePreviewCache.removeAll(keepingCapacity: true)
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

    func togglePinned(pack: IconPack) {
        if pinnedPackIDs.contains(pack.id) {
            pinnedPackIDs.remove(pack.id)
            statusMessage = StatusMessage(text: "\(pack.name) unpinned.", style: .neutral)
        } else {
            pinnedPackIDs.insert(pack.id)
            statusMessage = StatusMessage(text: "\(pack.name) pinned.", style: .success)
        }
    }

    func toggleFavorite(_ design: FolderIconDesign) {
        if favoriteDesignIDs.contains(design.id) {
            favoriteDesignIDs.remove(design.id)
            statusMessage = StatusMessage(text: "\(design.name) removed from favorites.", style: .neutral)
        } else {
            favoriteDesignIDs.insert(design.id)
            statusMessage = StatusMessage(text: "\(design.name) favorited.", style: .success)
        }
    }

    func apply(preset: DesignPreset) {
        configuration = preset.configuration
        livePreviewCache.removeAll(keepingCapacity: true)
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
        livePreviewCache.removeAll(keepingCapacity: true)
        statusMessage = StatusMessage(text: "Random production design generated.", style: .success)
    }

    func previewImage(size: Int = 512, quality: RenderQuality = .preview) -> NSImage {
        let key = "\(configuration.hashValue)-\(size)-\(quality.rawValue)"
        if let cached = livePreviewCache[key] {
            return cached
        }

        if livePreviewCache.count > 12 {
            livePreviewCache.removeAll(keepingCapacity: true)
        }

        let image = ExportRenderer.render(configuration: configuration, size: size, quality: quality)
        livePreviewCache[key] = image
        return image
    }

    func previewImage(for design: FolderIconDesign, size: Int = 256) -> NSImage {
        let key = "\(design.id)-\(size)"
        if let cached = designPreviewCache[key] {
            return cached
        }

        let image = ExportRenderer.render(configuration: IconConfiguration(design: design), size: size, quality: .preview)
        designPreviewCache[key] = image
        return image
    }

    func setCustomBadge(data: Data) {
        configuration.customBadgeImageData = data
        configuration.badgePosition = .watermark
        configuration.customBadgeOpacity = 0.72
        livePreviewCache.removeAll(keepingCapacity: true)
        statusMessage = StatusMessage(text: "Custom badge added.", style: .success)
    }

    func clearCustomBadge() {
        configuration.customBadgeImageData = nil
        livePreviewCache.removeAll(keepingCapacity: true)
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
            markRecentlyExported(selectedDesign)
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
            markRecentlyExported(selectedDesign)
            statusMessage = StatusMessage(text: "\(url.lastPathComponent) exported.", style: .success)
        } catch {
            statusMessage = StatusMessage(text: error.localizedDescription, style: .failure)
        }
    }

    func exportICNS() {
        guard let url = PanelBridge.saveICNSURL(defaultName: selectedDesign.exportBaseName) else { return }

        do {
            try exportService.exportICNS(configuration: configuration, to: url, name: selectedDesign.exportBaseName, quality: .ultra)
            markRecentlyExported(selectedDesign)
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
            selectedPack.icons.forEach { markRecentlyExported($0) }
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

    private func markRecentlyExported(_ design: FolderIconDesign) {
        recentlyExportedDesignIDs.removeAll { $0 == design.id }
        recentlyExportedDesignIDs.insert(design.id, at: 0)
        recentlyExportedDesignIDs = Array(recentlyExportedDesignIDs.prefix(6))
    }

    private func rarityScore(_ design: FolderIconDesign) -> Double {
        design.glowIntensity + design.shadowIntensity + (design.glowStyle == .cosmic ? 0.40 : 0) + (design.type == .legendary ? 0.35 : 0)
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
