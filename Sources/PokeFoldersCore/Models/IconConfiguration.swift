import Foundation

public struct IconConfiguration: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var themeID: String
    public var designID: String?
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
    public var customText: String
    public var badgePosition: BadgePosition
    public var cornerRadius: Double
    public var iconSize: Int
    public var transparentBackground: Bool
    public var customBadgeImageData: Data?
    public var customBadgeScale: Double
    public var customBadgeOpacity: Double

    public init(
        id: UUID = UUID(),
        themeID: String,
        designID: String? = nil,
        baseColor: RGBAColor,
        accentColor: RGBAColor,
        tabColor: RGBAColor,
        gradientColors: [RGBAColor] = [],
        elementType: ElementType,
        badgeStyle: BadgeStyle = .mysticCore,
        glowStyle: GlowStyle = .soft,
        shadowStyle: ShadowStyle = .soft,
        glowIntensity: Double,
        shadowIntensity: Double,
        gradientStyle: GradientStyle,
        textureStyle: TextureStyle,
        customText: String = "",
        badgePosition: BadgePosition,
        cornerRadius: Double,
        iconSize: Int = 512,
        transparentBackground: Bool = true,
        customBadgeImageData: Data? = nil,
        customBadgeScale: Double = 1,
        customBadgeOpacity: Double = 1
    ) {
        self.id = id
        self.themeID = themeID
        self.designID = designID
        self.baseColor = baseColor
        self.accentColor = accentColor
        self.tabColor = tabColor
        self.gradientColors = gradientColors.isEmpty ? [tabColor.adjusted(brightness: 0.08), baseColor, baseColor.mixed(with: accentColor, amount: 0.35)] : gradientColors
        self.elementType = elementType
        self.badgeStyle = badgeStyle
        self.glowStyle = glowStyle
        self.shadowStyle = shadowStyle
        self.glowIntensity = glowIntensity.clamped(to: 0...1)
        self.shadowIntensity = shadowIntensity.clamped(to: 0...1)
        self.gradientStyle = gradientStyle
        self.textureStyle = textureStyle
        self.customText = customText
        self.badgePosition = badgePosition
        self.cornerRadius = cornerRadius.clamped(to: 24...78)
        self.iconSize = min(max(iconSize, 128), 1024)
        self.transparentBackground = transparentBackground
        self.customBadgeImageData = customBadgeImageData
        self.customBadgeScale = customBadgeScale.clamped(to: 0.35...1.8)
        self.customBadgeOpacity = customBadgeOpacity.clamped(to: 0.1...1)
    }

    public init(theme: FolderTheme) {
        self.init(
            themeID: theme.id,
            designID: theme.id,
            baseColor: theme.baseColor,
            accentColor: theme.accentColor,
            tabColor: theme.tabColor,
            elementType: theme.elementType,
            badgeStyle: theme.badgeStyle,
            glowStyle: theme.glowStyle,
            shadowStyle: theme.shadowStyle,
            glowIntensity: theme.glowIntensity,
            shadowIntensity: theme.shadowIntensity,
            gradientStyle: theme.gradientStyle,
            textureStyle: theme.textureStyle,
            badgePosition: theme.badgePosition,
            cornerRadius: theme.cornerRadius
        )
    }

    public init(design: FolderIconDesign) {
        self.init(
            themeID: design.id,
            designID: design.id,
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
            customText: "",
            badgePosition: design.badgePosition,
            cornerRadius: design.cornerRadius,
            iconSize: 512,
            transparentBackground: true
        )
    }

    public mutating func apply(theme: FolderTheme) {
        themeID = theme.id
        designID = theme.id
        baseColor = theme.baseColor
        accentColor = theme.accentColor
        tabColor = theme.tabColor
        gradientColors = theme.gradientColors
        elementType = theme.elementType
        badgeStyle = theme.badgeStyle
        glowStyle = theme.glowStyle
        shadowStyle = theme.shadowStyle
        glowIntensity = theme.glowIntensity
        shadowIntensity = theme.shadowIntensity
        gradientStyle = theme.gradientStyle
        textureStyle = theme.textureStyle
        badgePosition = theme.badgePosition
        cornerRadius = theme.cornerRadius
    }

    public mutating func apply(design: FolderIconDesign) {
        self = IconConfiguration(design: design)
    }

    public static let starter = IconConfiguration(design: ProductionIconCatalog.allDesigns[0])

    public static func random() -> IconConfiguration {
        let design = ProductionIconCatalog.allDesigns.randomElement() ?? ProductionIconCatalog.allDesigns[0]
        var config = IconConfiguration(design: design)
        config.id = UUID()
        config.elementType = ElementType.allCases.randomElement() ?? design.type
        config.glowIntensity = Double.random(in: 0.05...0.95)
        config.shadowIntensity = Double.random(in: 0.15...0.82)
        config.gradientStyle = GradientStyle.allCases.randomElement() ?? design.gradientStyle
        config.textureStyle = TextureStyle.allCases.randomElement() ?? design.textureStyle
        config.badgePosition = BadgePosition.allCases.randomElement() ?? design.badgePosition
        config.cornerRadius = Double.random(in: 28...72)
        config.iconSize = [128, 256, 512, 1024].randomElement() ?? 512
        config.customText = ["", "", "01", "LV"].randomElement() ?? ""
        config.baseColor = design.baseColor.adjusted(brightness: Double.random(in: -0.05...0.07))
        config.accentColor = design.accentColor.adjusted(brightness: Double.random(in: -0.07...0.07))
        config.tabColor = design.tabColor.adjusted(brightness: Double.random(in: -0.04...0.08))
        config.gradientColors = [config.tabColor.adjusted(brightness: 0.06), config.baseColor, config.accentColor.withAlpha(0.7)]
        return config
    }
}
