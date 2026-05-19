import Foundation

public enum ElementType: String, CaseIterable, Codable, Identifiable, Sendable {
    case fire
    case water
    case grass
    case electric
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

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .glossy: "Glossy"
        case .matte: "Matte"
        case .glass: "Glass"
        case .pixel: "Pixel"
        }
    }
}

public enum GradientStyle: String, CaseIterable, Codable, Identifiable, Sendable {
    case softTop
    case diagonal
    case radial
    case prism

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .softTop: "Soft Top"
        case .diagonal: "Diagonal"
        case .radial: "Radial"
        case .prism: "Prism"
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
    case elemental
    case mystic
    case special

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .starter: "Starter Styles"
        case .elemental: "Elemental Folders"
        case .mystic: "Mystic Styles"
        case .special: "Special Editions"
        }
    }
}
