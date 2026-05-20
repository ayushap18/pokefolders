import PokeFoldersCore
import SwiftUI

struct IconDetailView: View {
    @ObservedObject var model: DesignViewModel
    @ObservedObject var presetStore: PresetStore

    private var accent: Color {
        AppTheme.Colors.typeColor(model.selectedDesign.type)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                InspectorPreviewPanel(model: model)
                InspectorActionPanel(model: model)
                InspectorControlsPanel(model: model)
                SavedPresetPanel(model: model, presetStore: presetStore)
                SafetyInfoCard()
            }
            .padding(AppTheme.Spacing.lg)
        }
        .background {
            ZStack {
                AppTheme.Colors.inspectorBackground
                RadialGradient(
                    colors: [accent.opacity(0.16), .clear],
                    center: .top,
                    startRadius: 60,
                    endRadius: 420
                )
                ScanlineOverlay(opacity: 0.014, spacing: 10)
            }
            .ignoresSafeArea()
        }
    }
}

private struct InspectorPreviewPanel: View {
    @ObservedObject var model: DesignViewModel

    private var design: FolderIconDesign { model.selectedDesign }
    private var accent: Color { AppTheme.Colors.typeColor(design.type) }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("ACTIVE DESIGN")
                        .font(AppTheme.Typography.utilityLabel)
                        .tracking(1.3)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    Text(design.name)
                        .font(AppTheme.Typography.title)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
                Spacer()
                ElementTypeChip(type: design.type)
            }

            ZStack {
                Circle()
                    .stroke(accent.opacity(0.24), lineWidth: 1)
                    .frame(width: 258, height: 258)
                Circle()
                    .stroke(AppTheme.Colors.scannerCyan.opacity(0.16), style: StrokeStyle(lineWidth: 1, dash: [4, 8]))
                    .frame(width: 216, height: 216)
                Image(nsImage: model.previewImage(size: 512, quality: .preview))
                    .resizable()
                    .interpolation(model.configuration.textureStyle == .pixel ? .none : .high)
                    .frame(width: 224, height: 224)
                    .shadow(color: accent.opacity(0.42), radius: 28, y: 12)
            }
            .frame(maxWidth: .infinity, minHeight: 274)
            .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous))
            .overlay {
                CornerBrackets(color: accent.opacity(0.55), inset: 14, length: 24)
            }

            HStack(spacing: AppTheme.Spacing.sm) {
                DataChip(label: "Pack", value: model.selectedPack.name.replacingOccurrences(of: " Pack", with: ""), accent: AppTheme.Colors.categoryColor(model.selectedPack.category))
                DataChip(label: "Badge", value: design.badgeStyle.title, accent: accent)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .dexPanel(cornerRadius: AppTheme.Radius.xl, accent: accent, isActive: true, showScanlines: true)
    }
}

private struct InspectorActionPanel: View {
    @ObservedObject var model: DesignViewModel

    private var accent: Color {
        AppTheme.Colors.typeColor(model.selectedDesign.type)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("OUTPUT")
                .font(AppTheme.Typography.sectionLabel)
                .tracking(1.3)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            Button {
                model.applyToFolder()
            } label: {
                Label("Apply to Folder", systemImage: "folder.badge.gearshape")
                    .frame(maxWidth: .infinity)
            }
            .dexButton(accent: accent, prominent: true)

            HStack(spacing: AppTheme.Spacing.sm) {
                Button {
                    model.exportPNG(size: 1024)
                } label: {
                    Label("PNG", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                }
                .dexButton(accent: AppTheme.Colors.scannerCyan)

                Button {
                    model.exportICNS()
                } label: {
                    Label("ICNS", systemImage: "app.dashed")
                        .frame(maxWidth: .infinity)
                }
                .dexButton(accent: AppTheme.Colors.scannerPurple)
            }

            Button {
                model.exportFullPack()
            } label: {
                Label("Export Full Pack", systemImage: "archivebox")
                    .frame(maxWidth: .infinity)
            }
            .dexButton(accent: AppTheme.Colors.categoryColor(model.selectedPack.category))
        }
        .padding(AppTheme.Spacing.md)
        .dexPanel(cornerRadius: AppTheme.Radius.lg, accent: accent, showScanlines: true)
    }
}

private struct InspectorControlsPanel: View {
    @ObservedObject var model: DesignViewModel

    private var accent: Color {
        AppTheme.Colors.typeColor(model.selectedDesign.type)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Label("Design Controls", systemImage: "slider.horizontal.3")
                .font(AppTheme.Typography.sectionLabel)
                .tracking(1.1)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            VStack(spacing: AppTheme.Spacing.md) {
                ColorPicker("Base color", selection: $model.configuration.color(\.baseColor), supportsOpacity: true)
                ColorPicker("Accent color", selection: $model.configuration.color(\.accentColor), supportsOpacity: true)
                ColorPicker("Tab color", selection: $model.configuration.color(\.tabColor), supportsOpacity: true)
            }
            .font(AppTheme.Typography.callout)

            Divider()
                .overlay(AppTheme.Colors.panelStroke)

            Picker("Badge", selection: $model.configuration.badgeStyle) {
                ForEach(BadgeStyle.allCases) { badge in
                    Text(badge.title).tag(badge)
                }
            }

            Picker("Texture", selection: $model.configuration.textureStyle) {
                ForEach(TextureStyle.allCases) { style in
                    Text(style.title).tag(style)
                }
            }

            Picker("Glow", selection: $model.configuration.glowStyle) {
                ForEach(GlowStyle.allCases) { style in
                    Text(style.title).tag(style)
                }
            }

            SliderRow(title: "Glow intensity", value: $model.configuration.glowIntensity, range: 0...1)
            SliderRow(title: "Shadow intensity", value: $model.configuration.shadowIntensity, range: 0...1)
            SliderRow(title: "Corner radius", value: $model.configuration.cornerRadius, range: 24...78)

            Toggle("Transparent background", isOn: $model.configuration.transparentBackground)
                .toggleStyle(.switch)
        }
        .font(AppTheme.Typography.callout)
        .foregroundStyle(AppTheme.Colors.textPrimary)
        .padding(AppTheme.Spacing.md)
        .dexPanel(cornerRadius: AppTheme.Radius.lg, accent: accent, showScanlines: true)
    }
}

private struct SavedPresetPanel: View {
    @ObservedObject var model: DesignViewModel
    @ObservedObject var presetStore: PresetStore

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Label("Saved Presets", systemImage: "bookmark")
                    .font(AppTheme.Typography.sectionLabel)
                    .tracking(1.1)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Spacer()
                Button {
                    model.savePreset(in: presetStore)
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppTheme.Colors.scannerCyan)
            }

            if presetStore.presets.isEmpty {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "bookmark.slash")
                        .font(.title3)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    Text("No saved presets yet.")
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity, minHeight: 92)
                .background(AppTheme.Colors.panelBase.opacity(0.42), in: RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            } else {
                ForEach(presetStore.presets) { preset in
                    PresetRow(
                        preset: preset,
                        loadAction: { model.apply(preset: preset) },
                        renameAction: { model.renamePreset(preset, in: presetStore) },
                        deleteAction: { model.deletePreset(preset, in: presetStore) }
                    )
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .dexPanel(cornerRadius: AppTheme.Radius.lg, accent: AppTheme.Colors.scannerCyan, showScanlines: true)
    }
}

private struct PresetRow: View {
    var preset: DesignPreset
    var loadAction: () -> Void
    var renameAction: () -> Void
    var deleteAction: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(nsImage: ExportRenderer.render(configuration: preset.configuration, size: 64, quality: .draft))
                .resizable()
                .interpolation(preset.configuration.textureStyle == .pixel ? .none : .high)
                .frame(width: 40, height: 40)
                .background(AppTheme.Colors.panelBase.opacity(0.54), in: RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(preset.name)
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .lineLimit(1)
                Text(preset.packName)
                    .font(AppTheme.Typography.utilityLabel)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: loadAction) { Image(systemName: "arrow.down.circle") }
            Button(action: renameAction) { Image(systemName: "pencil") }
            Button(role: .destructive, action: deleteAction) { Image(systemName: "trash") }
        }
        .buttonStyle(.plain)
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.panelBase.opacity(0.46), in: RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                .stroke(AppTheme.Colors.panelStroke, lineWidth: 1)
        }
    }
}

private struct SliderRow: View {
    var title: String
    @Binding var value: Double
    var range: ClosedRange<Double>

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack {
                Text(title)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Spacer()
                Text(value.formatted(.number.precision(.fractionLength(2))))
                    .foregroundStyle(AppTheme.Colors.scannerCyan)
                    .monospacedDigit()
            }
            Slider(value: $value, in: range)
        }
    }
}
