import PokeFoldersCore
import SwiftUI

enum ColorTokens {
    static let appBackground = Color(red: 0.030, green: 0.028, blue: 0.034)
    static let sidebarBackground = Color(red: 0.046, green: 0.041, blue: 0.050)
    static let studioBackground = Color(red: 0.036, green: 0.040, blue: 0.052)
    static let inspectorBackground = Color(red: 0.044, green: 0.040, blue: 0.052)
    static let panelBase = Color(red: 0.082, green: 0.080, blue: 0.098)
    static let panelRaised = Color(red: 0.118, green: 0.116, blue: 0.140)
    static let panelBright = Color(red: 0.165, green: 0.160, blue: 0.190)
    static let panelStroke = Color.white.opacity(0.105)
    static let textPrimary = Color.white.opacity(0.94)
    static let textSecondary = Color.white.opacity(0.62)
    static let textTertiary = Color.white.opacity(0.40)
    static let scannerRed = Color(red: 1.000, green: 0.235, blue: 0.255)
    static let scannerOrange = Color(red: 1.000, green: 0.445, blue: 0.255)
    static let scannerYellow = Color(red: 1.000, green: 0.820, blue: 0.235)
    static let scannerCyan = Color(red: 0.180, green: 0.800, blue: 1.000)
    static let scannerBlue = Color(red: 0.330, green: 0.500, blue: 1.000)
    static let scannerPurple = Color(red: 0.650, green: 0.470, blue: 1.000)
    static let safetyGreen = Color(red: 0.420, green: 0.920, blue: 0.620)

    static func typeColor(_ type: ElementType) -> Color {
        switch type {
        case .fire: scannerOrange
        case .water: scannerCyan
        case .grass: Color(red: 0.360, green: 0.820, blue: 0.440)
        case .electric: scannerYellow
        case .mystic, .psychic: scannerPurple
        case .legendary: Color(red: 0.980, green: 0.735, blue: 0.255)
        case .pixel: scannerBlue
        case .dark: Color(red: 0.520, green: 0.410, blue: 0.880)
        case .ghost: Color(red: 0.720, green: 0.630, blue: 1.000)
        case .dragon: Color(red: 0.980, green: 0.390, blue: 0.520)
        case .fairy: Color(red: 1.000, green: 0.560, blue: 0.820)
        }
    }

    static func categoryColor(_ category: ThemeCategory) -> Color {
        switch category {
        case .starter: scannerOrange
        case .legendary: Color(red: 0.980, green: 0.735, blue: 0.255)
        case .electric: scannerYellow
        case .fire: Color(red: 1.000, green: 0.300, blue: 0.205)
        case .water: scannerCyan
        case .grass: Color(red: 0.360, green: 0.820, blue: 0.440)
        case .dark: scannerPurple
        case .pixelRetro: scannerBlue
        }
    }

    static func panelGradient(accent: Color, isActive: Bool = false) -> LinearGradient {
        LinearGradient(
            colors: [
                panelRaised.opacity(isActive ? 0.98 : 0.82),
                panelBase.opacity(0.96),
                accent.opacity(isActive ? 0.16 : 0.055)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension ThemeCategory {
    var dexSubtitle: String {
        switch self {
        case .starter: "Balanced intro set"
        case .legendary: "Elite aura index"
        case .electric: "Neon charge deck"
        case .fire: "Volcanic power set"
        case .water: "Aquatic glass set"
        case .grass: "Bio growth archive"
        case .dark: "Shadow aura vault"
        case .pixelRetro: "Arcade cartridge set"
        }
    }

    var dexCode: String {
        switch self {
        case .starter: "ST"
        case .legendary: "LG"
        case .electric: "EL"
        case .fire: "FI"
        case .water: "WA"
        case .grass: "GR"
        case .dark: "DK"
        case .pixelRetro: "PX"
        }
    }

    var dexSymbolName: String {
        switch self {
        case .starter: "sparkles"
        case .legendary: "crown.fill"
        case .electric: "bolt.fill"
        case .fire: "flame.fill"
        case .water: "drop.fill"
        case .grass: "leaf.fill"
        case .dark: "moon.fill"
        case .pixelRetro: "square.grid.3x3.fill"
        }
    }
}
