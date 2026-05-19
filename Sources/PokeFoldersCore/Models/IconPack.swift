import Foundation

public struct IconPack: Codable, Hashable, Identifiable, Sendable {
    public var id: String
    public var name: String
    public var description: String
    public var category: ThemeCategory
    public var icons: [FolderIconDesign]
    public var previewImage: String
    public var accentColor: RGBAColor
    public var isPremium: Bool

    public init(
        id: String,
        name: String,
        description: String,
        category: ThemeCategory,
        icons: [FolderIconDesign],
        previewImage: String,
        accentColor: RGBAColor,
        isPremium: Bool
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.icons = icons
        self.previewImage = previewImage
        self.accentColor = accentColor
        self.isPremium = isPremium
    }
}

public struct FolderIconDesign: Codable, Hashable, Identifiable, Sendable {
    public var id: String
    public var name: String
    public var packId: String
    public var type: ElementType
    public var baseColor: RGBAColor
    public var accentColor: RGBAColor
    public var tabColor: RGBAColor
    public var gradientColors: [RGBAColor]
    public var badgeStyle: BadgeStyle
    public var glowStyle: GlowStyle
    public var textureStyle: TextureStyle
    public var shadowStyle: ShadowStyle
    public var badgePosition: BadgePosition
    public var cornerRadius: Double
    public var glowIntensity: Double
    public var shadowIntensity: Double
    public var exportFileNames: [String: String]
    public var generationPrompt: String
    public var negativePrompt: String

    public init(
        id: String,
        name: String,
        packId: String,
        type: ElementType,
        baseColor: RGBAColor,
        accentColor: RGBAColor,
        tabColor: RGBAColor,
        gradientColors: [RGBAColor],
        badgeStyle: BadgeStyle,
        glowStyle: GlowStyle,
        textureStyle: TextureStyle,
        shadowStyle: ShadowStyle,
        badgePosition: BadgePosition = .topRight,
        cornerRadius: Double = 52,
        glowIntensity: Double = 0.45,
        shadowIntensity: Double = 0.4,
        exportFileNames: [String: String],
        generationPrompt: String,
        negativePrompt: String
    ) {
        self.id = id
        self.name = name
        self.packId = packId
        self.type = type
        self.baseColor = baseColor
        self.accentColor = accentColor
        self.tabColor = tabColor
        self.gradientColors = gradientColors
        self.badgeStyle = badgeStyle
        self.glowStyle = glowStyle
        self.textureStyle = textureStyle
        self.shadowStyle = shadowStyle
        self.badgePosition = badgePosition
        self.cornerRadius = cornerRadius
        self.glowIntensity = glowIntensity.clamped(to: 0...1)
        self.shadowIntensity = shadowIntensity.clamped(to: 0...1)
        self.exportFileNames = exportFileNames
        self.generationPrompt = generationPrompt
        self.negativePrompt = negativePrompt
    }

    public var exportBaseName: String {
        exportFileNames["base"] ?? id.replacingOccurrences(of: "-", with: "_")
    }

    public var gradientStyle: GradientStyle {
        switch glowStyle {
        case .cosmic, .aura: return .aurora
        case .neon, .pixel: return .diagonal
        case .ember: return .layered
        case .shadow: return .radial
        case .none, .soft: return .softTop
        }
    }
}
