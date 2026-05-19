import Foundation

public struct FolderTheme: Codable, Hashable, Identifiable, Sendable {
    public var id: String
    public var name: String
    public var category: ThemeCategory
    public var packName: String
    public var baseColor: RGBAColor
    public var accentColor: RGBAColor
    public var tabColor: RGBAColor
    public var elementType: ElementType
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
        elementType: ElementType,
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
        self.elementType = elementType
        self.glowIntensity = glowIntensity
        self.shadowIntensity = shadowIntensity
        self.gradientStyle = gradientStyle
        self.textureStyle = textureStyle
        self.badgePosition = badgePosition
        self.cornerRadius = cornerRadius
    }

    public static let sampleThemes: [FolderTheme] = [
        FolderTheme(
            id: "capture-orb",
            name: "Capture Orb Folder",
            category: .starter,
            packName: "Starter Pack",
            baseColor: .warmRed,
            accentColor: .black,
            tabColor: .cream,
            elementType: .fire,
            glowIntensity: 0.36,
            shadowIntensity: 0.38,
            gradientStyle: .softTop,
            textureStyle: .glossy,
            badgePosition: .center
        ),
        FolderTheme(
            id: "electric-yellow",
            name: "Electric Yellow Folder",
            category: .elemental,
            packName: "Electric Pack",
            baseColor: .electricYellow,
            accentColor: RGBAColor(hex: 0x2c2a62),
            tabColor: RGBAColor(hex: 0xffec8f),
            elementType: .electric,
            glowIntensity: 0.68,
            shadowIntensity: 0.25,
            gradientStyle: .diagonal,
            textureStyle: .glossy
        ),
        FolderTheme(
            id: "ember-dragon",
            name: "Fire Dragon Folder",
            category: .elemental,
            packName: "Fire Pack",
            baseColor: .ember,
            accentColor: RGBAColor(hex: 0x7c1e28),
            tabColor: RGBAColor(hex: 0xff9d56),
            elementType: .dragon,
            glowIntensity: 0.62,
            shadowIntensity: 0.42,
            gradientStyle: .prism,
            textureStyle: .matte
        ),
        FolderTheme(
            id: "tide-shell",
            name: "Water Turtle Folder",
            category: .elemental,
            packName: "Water Pack",
            baseColor: .aqua,
            accentColor: RGBAColor(hex: 0x125f8f),
            tabColor: RGBAColor(hex: 0xa7e7ff),
            elementType: .water,
            glowIntensity: 0.42,
            shadowIntensity: 0.3,
            gradientStyle: .radial,
            textureStyle: .glass
        ),
        FolderTheme(
            id: "sprout-starter",
            name: "Grass Starter Folder",
            category: .starter,
            packName: "Starter Pack",
            baseColor: .grass,
            accentColor: RGBAColor(hex: 0x245b32),
            tabColor: RGBAColor(hex: 0xa8df75),
            elementType: .grass,
            glowIntensity: 0.38,
            shadowIntensity: 0.28,
            gradientStyle: .softTop,
            textureStyle: .matte
        ),
        FolderTheme(
            id: "psychic-purple",
            name: "Psychic Purple Folder",
            category: .mystic,
            packName: "Starter Pack",
            baseColor: .psychic,
            accentColor: RGBAColor(hex: 0xffc1f3),
            tabColor: RGBAColor(hex: 0xcba8ff),
            elementType: .psychic,
            glowIntensity: 0.74,
            shadowIntensity: 0.34,
            gradientStyle: .prism,
            textureStyle: .glass
        ),
        FolderTheme(
            id: "shadow-ghost",
            name: "Dark Ghost Folder",
            category: .mystic,
            packName: "Dark Pack",
            baseColor: .shadow,
            accentColor: .ghost,
            tabColor: RGBAColor(hex: 0x40385e),
            elementType: .ghost,
            glowIntensity: 0.58,
            shadowIntensity: 0.72,
            gradientStyle: .radial,
            textureStyle: .matte,
            badgePosition: .watermark
        ),
        FolderTheme(
            id: "fairy-pastel",
            name: "Fairy Pastel Folder",
            category: .mystic,
            packName: "Starter Pack",
            baseColor: .fairy,
            accentColor: RGBAColor(hex: 0x8dd6ff),
            tabColor: RGBAColor(hex: 0xffd4ec),
            elementType: .fairy,
            glowIntensity: 0.55,
            shadowIntensity: 0.22,
            gradientStyle: .prism,
            textureStyle: .glossy
        ),
        FolderTheme(
            id: "legendary-gold",
            name: "Legendary Gold Folder",
            category: .special,
            packName: "Legendary Pack",
            baseColor: .gold,
            accentColor: RGBAColor(hex: 0x704d13),
            tabColor: RGBAColor(hex: 0xffdd73),
            elementType: .dragon,
            glowIntensity: 0.7,
            shadowIntensity: 0.46,
            gradientStyle: .prism,
            textureStyle: .glass
        ),
        FolderTheme(
            id: "retro-pixel",
            name: "Retro Pixel Folder",
            category: .special,
            packName: "Pixel Pack",
            baseColor: .pixelBlue,
            accentColor: RGBAColor(hex: 0xffd35b),
            tabColor: RGBAColor(hex: 0x72d6ff),
            elementType: .electric,
            glowIntensity: 0.24,
            shadowIntensity: 0.55,
            gradientStyle: .diagonal,
            textureStyle: .pixel,
            cornerRadius: 26
        )
    ]
}
