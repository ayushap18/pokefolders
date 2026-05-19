import Foundation

public struct IconConfiguration: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var themeID: String
    public var baseColor: RGBAColor
    public var accentColor: RGBAColor
    public var tabColor: RGBAColor
    public var elementType: ElementType
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
        baseColor: RGBAColor,
        accentColor: RGBAColor,
        tabColor: RGBAColor,
        elementType: ElementType,
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
        self.baseColor = baseColor
        self.accentColor = accentColor
        self.tabColor = tabColor
        self.elementType = elementType
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
            baseColor: theme.baseColor,
            accentColor: theme.accentColor,
            tabColor: theme.tabColor,
            elementType: theme.elementType,
            glowIntensity: theme.glowIntensity,
            shadowIntensity: theme.shadowIntensity,
            gradientStyle: theme.gradientStyle,
            textureStyle: theme.textureStyle,
            badgePosition: theme.badgePosition,
            cornerRadius: theme.cornerRadius
        )
    }

    public mutating func apply(theme: FolderTheme) {
        themeID = theme.id
        baseColor = theme.baseColor
        accentColor = theme.accentColor
        tabColor = theme.tabColor
        elementType = theme.elementType
        glowIntensity = theme.glowIntensity
        shadowIntensity = theme.shadowIntensity
        gradientStyle = theme.gradientStyle
        textureStyle = theme.textureStyle
        badgePosition = theme.badgePosition
        cornerRadius = theme.cornerRadius
    }

    public static let starter = IconConfiguration(theme: FolderTheme.sampleThemes[0])

    public static func random() -> IconConfiguration {
        let theme = FolderTheme.sampleThemes.randomElement() ?? FolderTheme.sampleThemes[0]
        var config = IconConfiguration(theme: theme)
        config.id = UUID()
        config.elementType = ElementType.allCases.randomElement() ?? theme.elementType
        config.glowIntensity = Double.random(in: 0.05...0.95)
        config.shadowIntensity = Double.random(in: 0.15...0.82)
        config.gradientStyle = GradientStyle.allCases.randomElement() ?? theme.gradientStyle
        config.textureStyle = TextureStyle.allCases.randomElement() ?? theme.textureStyle
        config.badgePosition = BadgePosition.allCases.randomElement() ?? theme.badgePosition
        config.cornerRadius = Double.random(in: 24...78)
        config.iconSize = [128, 256, 512, 1024].randomElement() ?? 512
        config.customText = ["", "", "PX", "01", "EV", "GO", "LV"].randomElement() ?? ""
        config.baseColor = theme.baseColor.adjusted(brightness: Double.random(in: -0.06...0.08))
        config.accentColor = theme.accentColor.adjusted(brightness: Double.random(in: -0.08...0.08))
        config.tabColor = theme.tabColor.adjusted(brightness: Double.random(in: -0.05...0.08))
        return config
    }
}
