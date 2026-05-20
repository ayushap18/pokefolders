import PokeFoldersCore
import SwiftUI

struct SidebarView: View {
    @ObservedObject var model: DesignViewModel

    var body: some View {
        ZStack {
            AppTheme.Colors.sidebarBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                SidebarHeader(totalPacks: model.iconPacks.count, totalIcons: ProductionIconCatalog.allDesigns.count)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.md)
                    .padding(.bottom, AppTheme.Spacing.md)

                SidebarPackSearch(text: $model.packSearchText)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.bottom, AppTheme.Spacing.md)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        sectionHeader

                        if model.visiblePacks.isEmpty {
                            SidebarEmptyState()
                        } else {
                            VStack(spacing: AppTheme.Spacing.sm) {
                                ForEach(model.visiblePacks) { pack in
                                    ProductionPackSidebarRow(
                                        pack: pack,
                                        index: model.iconPacks.firstIndex(where: { $0.id == pack.id }) ?? 0,
                                        isSelected: pack.id == model.selectedPackID,
                                        isPinned: model.pinnedPackIDs.contains(pack.id)
                                    ) {
                                        withAnimation(AppTheme.Motion.spring) {
                                            model.apply(pack: pack)
                                        }
                                    }
                                    .contextMenu {
                                        Button(model.pinnedPackIDs.contains(pack.id) ? "Unpin Pack" : "Pin Pack") {
                                            model.togglePinned(pack: pack)
                                        }
                                        Button("Export Full Pack") {
                                            model.apply(pack: pack)
                                            model.exportFullPack()
                                        }
                                    }
                                }
                            }
                        }

                        SafetyInfoCard()
                            .padding(.top, AppTheme.Spacing.md)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.bottom, AppTheme.Spacing.xl)
                }
            }
        }
    }

    private var sectionHeader: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Text("PACK INDEX")
                .font(AppTheme.Typography.sectionLabel)
                .tracking(1.3)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            Rectangle()
                .fill(AppTheme.Colors.panelStroke)
                .frame(height: 1)

            Text("\(model.visiblePacks.count)")
                .font(AppTheme.Typography.utilityLabel)
                .monospacedDigit()
                .foregroundStyle(AppTheme.Colors.scannerCyan)
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xxs)
                .background(AppTheme.Colors.scannerCyan.opacity(0.12), in: Capsule())
        }
        .padding(.top, AppTheme.Spacing.xs)
    }
}

private struct SidebarHeader: View {
    var totalPacks: Int
    var totalIcons: Int

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        StatusLED(color: AppTheme.Colors.scannerRed)
                        StatusLED(color: AppTheme.Colors.scannerYellow)
                        StatusLED(color: AppTheme.Colors.scannerCyan)
                    }

                    Text("PokeFolders")
                        .font(AppTheme.Typography.appTitle)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .lineLimit(1)

                    Text("DEX ICON STUDIO")
                        .font(AppTheme.Typography.utilityLabel)
                        .tracking(1.8)
                        .foregroundStyle(AppTheme.Colors.scannerCyan)
                }

                Spacer()

                Image(systemName: "rectangle.grid.2x2.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .frame(width: 38, height: 38)
                    .background(AppTheme.Colors.panelBright.opacity(0.68), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppTheme.Colors.panelStroke, lineWidth: 1)
                    }
            }

            HStack(spacing: AppTheme.Spacing.sm) {
                DataChip(label: "Packs", value: "\(totalPacks)", accent: AppTheme.Colors.scannerOrange)
                DataChip(label: "Icons", value: "\(totalIcons)", accent: AppTheme.Colors.scannerCyan)
            }
        }
        .padding(AppTheme.Spacing.md)
        .dexPanel(cornerRadius: AppTheme.Radius.xl, accent: AppTheme.Colors.scannerRed, isActive: true, showScanlines: true)
    }
}

private struct SidebarPackSearch: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.Colors.scannerCyan)

            TextField("Search packs", text: $text)
                .textFieldStyle(.plain)
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .frame(height: 38)
        .background(AppTheme.Colors.panelBase.opacity(0.78), in: RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                .stroke(AppTheme.Colors.panelStroke, lineWidth: 1)
        }
    }
}

private struct SidebarEmptyState: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundStyle(AppTheme.Colors.textTertiary)
            Text("No pack matches this scan.")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .dexPanel(cornerRadius: AppTheme.Radius.lg, accent: AppTheme.Colors.scannerCyan, showScanlines: true)
    }
}

struct SafetyInfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.safetyGreen)

                Text("ORIGINAL DESIGN NOTICE")
                    .font(AppTheme.Typography.utilityLabel)
                    .tracking(1.1)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            Text("Creature-inspired folder designs only. Not affiliated with Pokemon, Nintendo, Game Freak, or The Pokemon Company.")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppTheme.Spacing.md)
        .dexPanel(cornerRadius: AppTheme.Radius.lg, accent: AppTheme.Colors.safetyGreen, showScanlines: true)
    }
}
