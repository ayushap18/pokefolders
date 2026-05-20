import PokeFoldersCore
import SwiftUI

struct ProductionPackSidebarRow: View {
    var pack: IconPack
    var index: Int
    var isSelected: Bool
    var isPinned: Bool
    var action: () -> Void

    @State private var isHovered = false

    private var accent: Color {
        AppTheme.Colors.categoryColor(pack.category)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.sm) {
                token

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text(pack.name)
                            .font(AppTheme.Typography.rowTitle)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)

                        if isPinned {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(accent)
                        }
                    }

                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text(pack.category.dexSubtitle)
                            .font(AppTheme.Typography.rowMeta)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                            .lineLimit(1)

                        Text("IDX \(String(format: "%02d", index + 1))")
                            .font(AppTheme.Typography.utilityLabel)
                            .foregroundStyle(accent.opacity(0.9))
                    }
                }

                Spacer(minLength: AppTheme.Spacing.xs)

                VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                    Text("\(pack.icons.count)")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(isSelected ? Color.black.opacity(0.80) : accent)
                        .frame(width: 28, height: 22)
                        .background(isSelected ? accent : accent.opacity(0.14), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .stroke(accent.opacity(isSelected ? 0.35 : 0.28), lineWidth: 1)
                        }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(isSelected ? accent : AppTheme.Colors.textTertiary)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.sm)
            .frame(height: 62)
            .background {
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                    .fill(AppTheme.Colors.panelGradient(accent: accent, isActive: isSelected || isHovered))
            }
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(accent)
                    .frame(width: isSelected ? 4 : 2, height: isSelected ? 40 : 24)
                    .shadow(color: accent.opacity(isSelected ? 0.78 : 0.28), radius: isSelected ? 10 : 4)
                    .padding(.leading, 6)
                    .opacity(isSelected || isHovered ? 1 : 0.45)
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                    .stroke(isSelected ? accent.opacity(0.55) : AppTheme.Colors.panelStroke, lineWidth: isSelected ? 1.2 : 1)
            }
            .overlay {
                if isSelected {
                    ScanlineOverlay(opacity: 0.035)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.006 : 1)
        .animation(AppTheme.Motion.quick, value: isHovered)
        .animation(AppTheme.Motion.smooth, value: isSelected)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var token: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accent.opacity(0.98), accent.opacity(0.48), Color.black.opacity(0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: pack.category.dexSymbolName)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.28), radius: 3, y: 2)

            Text(pack.category.dexCode)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.82))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(5)
        }
        .frame(width: 38, height: 38)
        .overlay {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(Color.white.opacity(0.30), lineWidth: 1)
        }
        .shadow(color: accent.opacity(isSelected ? 0.50 : 0.20), radius: isSelected ? 12 : 6, y: 4)
    }
}
