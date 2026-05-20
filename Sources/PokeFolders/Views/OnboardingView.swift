import PokeFoldersCore
import SwiftUI

struct OnboardingView: View {
    var dismiss: () -> Void

    var body: some View {
        ZStack {
            AppTheme.Colors.appBackground
            RadialGradient(
                colors: [AppTheme.Colors.scannerRed.opacity(0.22), .clear],
                center: .topLeading,
                startRadius: 40,
                endRadius: 520
            )
            ScanlineOverlay(opacity: 0.018, spacing: 10)

            HStack(spacing: AppTheme.Spacing.xxl) {
                ZStack {
                    Circle()
                        .stroke(AppTheme.Colors.scannerCyan.opacity(0.24), lineWidth: 1)
                        .frame(width: 250, height: 250)
                    Circle()
                        .stroke(AppTheme.Colors.scannerYellow.opacity(0.18), style: StrokeStyle(lineWidth: 1, dash: [6, 8]))
                        .frame(width: 208, height: 208)
                    Image(nsImage: ExportRenderer.render(configuration: .starter, size: 512, quality: .preview))
                        .resizable()
                        .frame(width: 190, height: 190)
                        .shadow(color: AppTheme.Colors.scannerOrange.opacity(0.48), radius: 28, y: 12)
                }
                .frame(width: 300, height: 300)
                .dexPanel(cornerRadius: AppTheme.Radius.xl, accent: AppTheme.Colors.scannerOrange, isActive: true, showScanlines: true)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        StatusLED(color: AppTheme.Colors.scannerRed)
                        StatusLED(color: AppTheme.Colors.scannerYellow)
                        StatusLED(color: AppTheme.Colors.scannerCyan)
                    }

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("PokeFolders")
                            .font(AppTheme.Typography.heroTitle)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        Text("A native macOS dex-inspired icon studio for original elemental folder packs.")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(spacing: AppTheme.Spacing.sm) {
                        DataChip(label: "Icons", value: "40", accent: AppTheme.Colors.scannerCyan)
                        DataChip(label: "Packs", value: "8", accent: AppTheme.Colors.scannerOrange)
                        DataChip(label: "Export", value: "PNG/ICNS", accent: AppTheme.Colors.scannerPurple)
                    }

                    Text("Original creature-inspired designs only. Not affiliated with Pokemon, Nintendo, Game Freak, or The Pokemon Company.")
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                        dismiss()
                    } label: {
                        Label("Start Designing", systemImage: "sparkles")
                            .frame(width: 188)
                    }
                    .dexButton(accent: AppTheme.Colors.scannerCyan, prominent: true)
                    .controlSize(.large)
                }
                .frame(width: 390, alignment: .leading)
            }
            .padding(AppTheme.Spacing.xxl)
        }
        .frame(width: 790, height: 430)
    }
}
