import SwiftUI

enum TypographyTokens {
    static let appTitle = Font.system(size: 22, weight: .black, design: .rounded)
    static let heroTitle = Font.system(size: 34, weight: .black, design: .rounded)
    static let title = Font.system(size: 22, weight: .bold, design: .rounded)
    static let sectionLabel = Font.system(size: 11, weight: .bold, design: .rounded)
    static let rowTitle = Font.system(size: 15, weight: .semibold, design: .rounded)
    static let rowMeta = Font.system(size: 11, weight: .medium, design: .rounded)
    static let utilityLabel = Font.system(size: 10, weight: .bold, design: .rounded)
    static let body = Font.system(size: 13, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 12, weight: .medium, design: .rounded)
    static let metric = Font.system(size: 18, weight: .bold, design: .rounded).monospacedDigit()
}
