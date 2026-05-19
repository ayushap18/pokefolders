import PokeFoldersCore
import SwiftUI

struct IconDetailView: View {
    @ObservedObject var model: DesignViewModel
    @ObservedObject var presetStore: PresetStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                preview
                safetyNote
                actionButtons
                editableControls
                savedPresets
            }
            .padding(16)
        }
        .background(.bar)
    }

    private var preview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(nsImage: model.previewImage(size: 512, quality: .preview))
                .resizable()
                .interpolation(model.configuration.textureStyle == .pixel ? .none : .high)
                .frame(width: 256, height: 256)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(model.selectedDesign.accentColor.swiftUIColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(model.selectedDesign.name)
                    .font(.title2.bold())
                    .lineLimit(1)
                Text("\(model.selectedPack.name) - \(model.selectedDesign.type.title)")
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .detailCard()
    }

    private var safetyNote: some View {
        Label("These are original creature-inspired folder designs. This app is not affiliated with Pokemon, Nintendo, Game Freak, or The Pokemon Company.", systemImage: "checkmark.shield")
            .font(.caption)
            .foregroundStyle(.secondary)
            .detailCard()
    }

    private var actionButtons: some View {
        VStack(spacing: 8) {
            Button {
                model.applyToFolder()
            } label: {
                Label("Apply this design", systemImage: "folder.badge.gearshape")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            HStack {
                Button("Export this icon") { model.exportPNG(size: 1024) }
                Button("Export full pack") { model.exportFullPack() }
            }
            .buttonStyle(.bordered)
        }
        .detailCard()
    }

    private var editableControls: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Detail Controls", systemImage: "slider.horizontal.3")
                .font(.headline)

            ColorPicker("Base color", selection: $model.configuration.color(\.baseColor), supportsOpacity: true)
            ColorPicker("Accent color", selection: $model.configuration.color(\.accentColor), supportsOpacity: true)
            ColorPicker("Tab color", selection: $model.configuration.color(\.tabColor), supportsOpacity: true)

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
        }
        .detailCard()
    }

    private var savedPresets: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Saved Presets", systemImage: "bookmark")
                    .font(.headline)
                Spacer()
                Button {
                    model.savePreset(in: presetStore)
                } label: {
                    Image(systemName: "plus")
                }
            }

            if presetStore.presets.isEmpty {
                Text("No saved presets yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(presetStore.presets) { preset in
                    HStack(spacing: 8) {
                        Image(nsImage: ExportRenderer.render(configuration: preset.configuration, size: 64, quality: .draft))
                            .resizable()
                            .frame(width: 36, height: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(preset.name)
                                .lineLimit(1)
                            Text(preset.packName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Button { model.apply(preset: preset) } label: { Image(systemName: "arrow.down.circle") }
                        Button { model.renamePreset(preset, in: presetStore) } label: { Image(systemName: "pencil") }
                        Button(role: .destructive) { model.deletePreset(preset, in: presetStore) } label: { Image(systemName: "trash") }
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .detailCard()
    }
}

private struct SliderRow: View {
    var title: String
    @Binding var value: Double
    var range: ClosedRange<Double>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(value.formatted(.number.precision(.fractionLength(2))))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Slider(value: $value, in: range)
        }
    }
}

private extension View {
    func detailCard() -> some View {
        self.padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}
