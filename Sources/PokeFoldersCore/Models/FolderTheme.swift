import Foundation

public struct FolderTheme: Codable, Hashable, Identifiable, Sendable {
    public var id: String
    public var name: String
    public var category: ThemeCategory
    public var packName: String
    public var baseColor: RGBAColor
    public var accentColor: RGBAColor
    public var tabColor: RGBAColor
    public var gradientColors: [RGBAColor]
    public var elementType: ElementType
    public var badgeStyle: BadgeStyle
    public var glowStyle: GlowStyle
    public var shadowStyle: ShadowStyle
    public var glowIntensity: Double
    public var shadowIntensity: Double
    public var gradientStyle: GradientStyle
    public var textureStyle: TextureStyle
    public var badgePosition: BadgePosition
    public var cornerRadius: Double

    public init(
        id: String,
        name: String,
        category: ThemeCategory,
        packName: String,
        baseColor: RGBAColor,
        accentColor: RGBAColor,
        tabColor: RGBAColor,
        gradientColors: [RGBAColor],
        elementType: ElementType,
        badgeStyle: BadgeStyle,
        glowStyle: GlowStyle,
        shadowStyle: ShadowStyle,
        glowIntensity: Double,
        shadowIntensity: Double,
        gradientStyle: GradientStyle,
        textureStyle: TextureStyle,
        badgePosition: BadgePosition = .topRight,
        cornerRadius: Double = 52
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.packName = packName
        self.baseColor = baseColor
        self.accentColor = accentColor
        self.tabColor = tabColor
        self.gradientColors = gradientColors
        self.elementType = elementType
        self.badgeStyle = badgeStyle
        self.glowStyle = glowStyle
        self.shadowStyle = shadowStyle
        self.glowIntensity = glowIntensity
        self.shadowIntensity = shadowIntensity
        self.gradientStyle = gradientStyle
        self.textureStyle = textureStyle
        self.badgePosition = badgePosition
        self.cornerRadius = cornerRadius
    }

    public init(design: FolderIconDesign, pack: IconPack) {
        self.init(
            id: design.id,
            name: design.name,
            category: pack.category,
            packName: pack.name,
            baseColor: design.baseColor,
            accentColor: design.accentColor,
            tabColor: design.tabColor,
            gradientColors: design.gradientColors,
            elementType: design.type,
            badgeStyle: design.badgeStyle,
            glowStyle: design.glowStyle,
            shadowStyle: design.shadowStyle,
            glowIntensity: design.glowIntensity,
            shadowIntensity: design.shadowIntensity,
            gradientStyle: design.gradientStyle,
            textureStyle: design.textureStyle,
            badgePosition: design.badgePosition,
            cornerRadius: design.cornerRadius
        )
    }

    public static let sampleThemes: [FolderTheme] = ProductionIconCatalog.allPacks.flatMap { pack in
        pack.icons.map { FolderTheme(design: $0, pack: pack) }
    }
}
