import SwiftUI

struct DexPanelModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.Radius.lg
    var accent: Color = AppTheme.Colors.scannerCyan
    var isActive = false
    var showScanlines = false

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.Colors.panelGradient(accent: accent, isActive: isActive))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        isActive ? accent.opacity(0.46) : AppTheme.Colors.panelStroke,
                        lineWidth: isActive ? 1.2 : 1
                    )
            }
            .overlay {
                if showScanlines && isActive {
                    ScanlineOverlay(opacity: isActive ? 0.045 : 0.025)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
            }
            .overlay {
                if isActive {
                    CornerBrackets(color: accent.opacity(0.54), inset: 8)
                }
            }
            .shadow(color: accent.opacity(isActive ? 0.14 : 0.035), radius: isActive ? 14 : 6, x: 0, y: isActive ? 7 : 4)
            .shadow(color: .black.opacity(0.24), radius: 12, x: 0, y: 8)
    }
}

struct DexButtonStyle: ButtonStyle {
    var accent: Color = AppTheme.Colors.scannerCyan
    var isProminent = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.callout.weight(.semibold))
            .lineLimit(1)
            .foregroundStyle(isProminent ? Color.black.opacity(0.86) : AppTheme.Colors.textPrimary)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, 9)
            .background {
                RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous)
                    .fill(
                        isProminent
                            ? LinearGradient(colors: [accent, accent.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [accent.opacity(0.18), AppTheme.Colors.panelRaised.opacity(0.84)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous)
                    .stroke(isProminent ? Color.white.opacity(0.32) : accent.opacity(0.30), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(AppTheme.Motion.quick, value: configuration.isPressed)
    }
}

extension View {
    func dexPanel(
        cornerRadius: CGFloat = AppTheme.Radius.lg,
        accent: Color = AppTheme.Colors.scannerCyan,
        isActive: Bool = false,
        showScanlines: Bool = false
    ) -> some View {
        modifier(DexPanelModifier(cornerRadius: cornerRadius, accent: accent, isActive: isActive, showScanlines: showScanlines))
    }

    func dexButton(accent: Color = AppTheme.Colors.scannerCyan, prominent: Bool = false) -> some View {
        buttonStyle(DexButtonStyle(accent: accent, isProminent: prominent))
    }
}
