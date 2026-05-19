import Combine
import Foundation

public enum PresetStorageError: LocalizedError {
    case presetNotFound

    public var errorDescription: String? {
        switch self {
        case .presetNotFound:
            return "The preset no longer exists."
        }
    }
}

public struct PresetStorageService {
    public let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? Self.defaultFileURL()
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder.dateDecodingStrategy = .iso8601
    }

    public func loadPresets() throws -> [DesignPreset] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([DesignPreset].self, from: data)
    }

    @discardableResult
    public func savePreset(name: String, configuration: IconConfiguration, packName: String) throws -> DesignPreset {
        var presets = try loadPresets()
        let preset = DesignPreset(name: name, configuration: configuration, packName: packName)
        presets.insert(preset, at: 0)
        try write(presets)
        return preset
    }

    @discardableResult
    public func renamePreset(id: UUID, to name: String) throws -> DesignPreset {
        var presets = try loadPresets()
        guard let index = presets.firstIndex(where: { $0.id == id }) else {
            throw PresetStorageError.presetNotFound
        }
        presets[index].name = name
        presets[index].updatedAt = Date()
        try write(presets)
        return presets[index]
    }

    public func deletePreset(id: UUID) throws {
        var presets = try loadPresets()
        presets.removeAll { $0.id == id }
        try write(presets)
    }

    private func write(_ presets: [DesignPreset]) throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try encoder.encode(presets)
        try data.write(to: fileURL, options: .atomic)
    }

    private static func defaultFileURL() -> URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support", isDirectory: true)
        return baseURL
            .appendingPathComponent("PokeFolders", isDirectory: true)
            .appendingPathComponent("presets.json")
    }
}

public final class PresetStore: ObservableObject {
    @Published public private(set) var presets: [DesignPreset] = []
    @Published public private(set) var lastError: String?

    private let service: PresetStorageService

    public init(service: PresetStorageService = PresetStorageService()) {
        self.service = service
        reload()
    }

    public func reload() {
        do {
            presets = try service.loadPresets()
            lastError = nil
        } catch {
            presets = []
            lastError = error.localizedDescription
        }
    }

    @discardableResult
    public func save(name: String, configuration: IconConfiguration, packName: String) -> DesignPreset? {
        do {
            let preset = try service.savePreset(name: name, configuration: configuration, packName: packName)
            reload()
            return preset
        } catch {
            lastError = error.localizedDescription
            return nil
        }
    }

    public func rename(id: UUID, to name: String) {
        do {
            _ = try service.renamePreset(id: id, to: name)
            reload()
        } catch {
            lastError = error.localizedDescription
        }
    }

    public func delete(id: UUID) {
        do {
            try service.deletePreset(id: id)
            reload()
        } catch {
            lastError = error.localizedDescription
        }
    }
}
