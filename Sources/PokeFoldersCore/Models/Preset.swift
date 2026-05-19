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

    public static let samplePacks: [PresetPack] = [
        PresetPack(id: "starter", name: "Starter Pack", themeIDs: ["capture-orb", "sprout-starter", "fairy-pastel"]),
        PresetPack(id: "electric", name: "Electric Pack", themeIDs: ["electric-yellow", "retro-pixel"]),
        PresetPack(id: "fire", name: "Fire Pack", themeIDs: ["ember-dragon", "capture-orb"]),
        PresetPack(id: "water", name: "Water Pack", themeIDs: ["tide-shell"]),
        PresetPack(id: "dark", name: "Dark Pack", themeIDs: ["shadow-ghost"]),
        PresetPack(id: "legendary", name: "Legendary Pack", themeIDs: ["legendary-gold"]),
        PresetPack(id: "pixel", name: "Pixel Pack", themeIDs: ["retro-pixel"])
    ]
}
