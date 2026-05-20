import PokeFoldersCore
import SwiftUI

struct ScanlineOverlay: View {
    var opacity: Double = 0.04
    var spacing: CGFloat = 8

    var body: some View {
        GeometryReader { proxy in
            Path { path in
                var y: CGFloat = 0
                while y <= proxy.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                    y += spacing
                }
            }
            .stroke(Color.white.opacity(opacity), lineWidth: 0.5)
        }
        .allowsHitTesting(false)
    }
}

struct CornerBrackets: View {
    var color: Color = AppTheme.Colors.scannerCyan.opacity(0.32)
    var inset: CGFloat = 10
    var length: CGFloat = 18

    var body: some View {
        GeometryReader { proxy in
            Path { path in
                let minX = inset
                let minY = inset
                let maxX = proxy.size.width - inset
                let maxY = proxy.size.height - inset

                path.move(to: CGPoint(x: minX, y: minY + length))
                path.addLine(to: CGPoint(x: minX, y: minY))
                path.addLine(to: CGPoint(x: minX + length, y: minY))

                path.move(to: CGPoint(x: maxX - length, y: minY))
                path.addLine(to: CGPoint(x: maxX, y: minY))
                path.addLine(to: CGPoint(x: maxX, y: minY + length))

                path.move(to: CGPoint(x: minX, y: maxY - length))
                path.addLine(to: CGPoint(x: minX, y: maxY))
                path.addLine(to: CGPoint(x: minX + length, y: maxY))

                path.move(to: CGPoint(x: maxX - length, y: maxY))
                path.addLine(to: CGPoint(x: maxX, y: maxY))
                path.addLine(to: CGPoint(x: maxX, y: maxY - length))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
        }
        .allowsHitTesting(false)
    }
}

struct StatusLED: View {
    var color: Color
    var isActive = true

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .shadow(color: color.opacity(isActive ? 0.72 : 0.18), radius: isActive ? 8 : 2)
            .overlay {
                Circle()
                    .stroke(Color.white.opacity(0.38), lineWidth: 0.7)
            }
            .opacity(isActive ? 1 : 0.42)
    }
}

struct DataChip: View {
    var label: String
    var value: String
    var accent: Color

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Text(label.uppercased())
                .font(AppTheme.Typography.utilityLabel)
                .foregroundStyle(AppTheme.Colors.textTertiary)
                .lineLimit(1)
            Text(value)
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .lineLimit(1)
        }
        .fixedSize(horizontal: true, vertical: false)
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(accent.opacity(0.12), in: Capsule())
        .overlay {
            Capsule()
                .stroke(accent.opacity(0.28), lineWidth: 1)
        }
    }
}

struct ElementTypeChip: View {
    var type: ElementType

    var body: some View {
        let accent = AppTheme.Colors.typeColor(type)
        HStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: type.symbolName)
                .font(.system(size: 10, weight: .bold))
            Text(type.shortCode)
                .font(AppTheme.Typography.utilityLabel)
        }
        .foregroundStyle(accent)
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(accent.opacity(0.13), in: Capsule())
        .overlay {
            Capsule()
                .stroke(accent.opacity(0.34), lineWidth: 1)
        }
    }
}
