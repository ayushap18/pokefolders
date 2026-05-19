import CoreGraphics
import Foundation

public enum ElementType: String, CaseIterable, Codable, Identifiable, Sendable {
    case fire
    case water
    case grass
    case electric
    case mystic
    case legendary
    case pixel
    case psychic
    case dark
    case ghost
    case dragon
    case fairy

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .fire: "Fire"
        case .water: "Water"
        case .grass: "Grass"
        case .electric: "Electric"
        case .mystic: "Mystic"
        case .legendary: "Legendary"
        case .pixel: "Pixel"
        case .psychic: "Psychic"
        case .dark: "Dark"
        case .ghost: "Ghost"
        case .dragon: "Dragon"
        case .fairy: "Fairy"
        }
    }

    public var shortCode: String {
        switch self {
        case .fire: "FI"
        case .water: "WA"
        case .grass: "GR"
        case .electric: "EL"
        case .mystic: "MY"
        case .legendary: "LG"
        case .pixel: "PX"
        case .psychic: "PS"
        case .dark: "DK"
        case .ghost: "GH"
        case .dragon: "DR"
        case .fairy: "FA"
        }
    }

    public var symbolName: String {
        switch self {
        case .fire: "flame.fill"
        case .water: "drop.fill"
        case .grass: "leaf.fill"
        case .electric: "bolt.fill"
        case .mystic: "sparkles"
        case .legendary: "crown.fill"
        case .pixel: "square.grid.3x3.fill"
        case .psychic: "sparkles"
        case .dark: "moon.fill"
        case .ghost: "eye.fill"
        case .dragon: "wind"
        case .fairy: "wand.and.stars"
        }
    }
}

public enum TextureStyle: String, CaseIterable, Codable, Identifiable, Sendable {
    case glossy
    case matte
    case glass
    case pixel
    case brushed
    case aura
    case crystalline

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .glossy: "Glossy"
        case .matte: "Matte"
        case .glass: "Glass"
        case .pixel: "Pixel"
        case .brushed: "Brushed"
        case .aura: "Aura"
        case .crystalline: "Crystalline"
        }
    }
}

public enum GradientStyle: String, CaseIterable, Codable, Identifiable, Sendable {
    case softTop
    case diagonal
    case radial
    case prism
    case layered
    case aurora

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .softTop: "Soft Top"
        case .diagonal: "Diagonal"
        case .radial: "Radial"
        case .prism: "Prism"
        case .layered: "Layered"
        case .aurora: "Aurora"
        }
    }
}

public enum BadgePosition: String, CaseIterable, Codable, Identifiable, Sendable {
    case center
    case topRight
    case bottomRight
    case watermark

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .center: "Center"
        case .topRight: "Top Right"
        case .bottomRight: "Bottom Right"
        case .watermark: "Watermark"
        }
    }
}

public enum ThemeCategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case starter
    case legendary
    case electric
    case fire
    case water
    case grass
    case dark
    case pixelRetro

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .starter: "Starter Pack"
        case .legendary: "Legendary Pack"
        case .electric: "Electric Pack"
        case .fire: "Fire Pack"
        case .water: "Water Pack"
        case .grass: "Grass Pack"
        case .dark: "Dark Pack"
        case .pixelRetro: "Pixel Retro Pack"
        }
    }
}

public enum BadgeStyle: String, CaseIterable, Codable, Identifiable, Sendable {
    case flame
    case droplet
    case leaf
    case thunder
    case mysticCore
    case goldAura
    case crystal
    case cosmic
    case dragonCrest
    case rune
    case cyberSpark
    case storm
    case plasma
    case ember
    case lava
    case volcano
    case inferno
    case ocean
    case bubble
    case ice
    case wave
    case deepSea
    case forest
    case vine
    case natureAura
    case leafCrest
    case jungle
    case shadow
    case ghostAura
    case moon
    case void
    case smoke
    case pixelBlock
    case pixelCreature
    case retroConsole
    case arcadeBadge
    case classicGame

    public var id: String { rawValue }

    public var title: String {
        rawValue
            .replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
            .capitalized
    }
}

public enum GlowStyle: String, CaseIterable, Codable, Identifiable, Sendable {
    case none
    case soft
    case aura
    case neon
    case ember
    case cosmic
    case shadow
    case pixel

    public var id: String { rawValue }
    public var title: String { rawValue.capitalized }
}

public enum ShadowStyle: String, CaseIterable, Codable, Identifiable, Sendable {
    case soft
    case elevated
    case dramatic
    case long
    case pixel

    public var id: String { rawValue }
    public var title: String { rawValue.capitalized }
}

public enum RenderQuality: String, CaseIterable, Codable, Identifiable, Sendable {
    case draft
    case preview
    case export
    case ultra

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .draft: "Draft"
        case .preview: "Preview"
        case .export: "Export"
        case .ultra: "Ultra"
        }
    }

    public var antialias: Bool {
        switch self {
        case .draft: false
        case .preview, .export, .ultra: true
        }
    }

    public var interpolation: CGInterpolationQuality {
        switch self {
        case .draft: .low
        case .preview: .medium
        case .export, .ultra: .high
        }
    }
}
