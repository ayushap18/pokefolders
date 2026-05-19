import AppKit
import SwiftUI

public struct RGBAColor: Codable, Hashable, Sendable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red.clamped(to: 0...1)
        self.green = green.clamped(to: 0...1)
        self.blue = blue.clamped(to: 0...1)
        self.alpha = alpha.clamped(to: 0...1)
    }

    public init(hex: UInt32, alpha: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            alpha: alpha
        )
    }

    public init(color: Color) {
        let resolved = NSColor(color).usingColorSpace(.deviceRGB) ?? .white
        self.init(
            red: Double(resolved.redComponent),
            green: Double(resolved.greenComponent),
            blue: Double(resolved.blueComponent),
            alpha: Double(resolved.alphaComponent)
        )
    }

    public var nsColor: NSColor {
        NSColor(
            calibratedRed: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(alpha)
        )
    }

    public var cgColor: CGColor {
        nsColor.cgColor
    }

    public var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }

    public func withAlpha(_ alpha: Double) -> RGBAColor {
        RGBAColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    public func mixed(with other: RGBAColor, amount: Double) -> RGBAColor {
        let amount = amount.clamped(to: 0...1)
        return RGBAColor(
            red: red + (other.red - red) * amount,
            green: green + (other.green - green) * amount,
            blue: blue + (other.blue - blue) * amount,
            alpha: alpha + (other.alpha - alpha) * amount
        )
    }

    public func adjusted(brightness delta: Double) -> RGBAColor {
        RGBAColor(
            red: red + delta,
            green: green + delta,
            blue: blue + delta,
            alpha: alpha
        )
    }

    public var luminance: Double {
        (0.2126 * red) + (0.7152 * green) + (0.0722 * blue)
    }

    public static let white = RGBAColor(hex: 0xffffff)
    public static let black = RGBAColor(hex: 0x111111)
    public static let warmRed = RGBAColor(hex: 0xe84b4b)
    public static let cream = RGBAColor(hex: 0xfff3df)
    public static let electricYellow = RGBAColor(hex: 0xffd84a)
    public static let ember = RGBAColor(hex: 0xff6b35)
    public static let aqua = RGBAColor(hex: 0x42b6e8)
    public static let grass = RGBAColor(hex: 0x4fb66d)
    public static let psychic = RGBAColor(hex: 0x9562e8)
    public static let shadow = RGBAColor(hex: 0x2b2542)
    public static let ghost = RGBAColor(hex: 0x6250a9)
    public static let fairy = RGBAColor(hex: 0xf5a6d6)
    public static let gold = RGBAColor(hex: 0xd7a72f)
    public static let pixelBlue = RGBAColor(hex: 0x496ddb)
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
