import Foundation

public struct DesignPreset: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var configuration: IconConfiguration
    public var packName: String
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        configuration: IconConfiguration,
        packName: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.configuration = configuration
        self.packName = packName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct PresetPack: Codable, Hashable, Identifiable, Sendable {
    public var id: String
    public var name: String
    public var themeIDs: [String]

    public init(id: String, name: String, themeIDs: [String]) {
        self.id = id
        self.name = name
        self.themeIDs = themeIDs
    }

    public static let samplePacks: [PresetPack] = ProductionIconCatalog.allPacks.map { pack in
        PresetPack(id: pack.id, name: pack.name, themeIDs: pack.icons.map(\.id))
    }
}
