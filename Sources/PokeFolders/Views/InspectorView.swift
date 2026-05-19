import PokeFoldersCore
import SwiftUI

struct InspectorView: View {
    @ObservedObject var model: DesignViewModel
    @ObservedObject var presetStore: PresetStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                InspectorSection(title: "Colors", systemImage: "paintpalette") {
                    ColorPicker("Base", selection: $model.configuration.color(\.baseColor), supportsOpacity: true)
                    ColorPicker("Accent", selection: $model.configuration.color(\.accentColor), supportsOpacity: true)
                    ColorPicker("Tab", selection: $model.configuration.color(\.tabColor), supportsOpacity: true)
                }

                InspectorSection(title: "Element", systemImage: "sparkles") {
                    Picker("Badge", selection: $model.configuration.elementType) {
                        ForEach(ElementType.allCases) { type in
                            Label(type.title, systemImage: type.symbolName)
                                .tag(type)
                        }
                    }
                    Picker("Position", selection: $model.configuration.badgePosition) {
                        ForEach(BadgePosition.allCases) { position in
                            Text(position.title).tag(position)
                        }
                    }
                    .pickerStyle(.segmented)
                    TextField("Initials or text", text: $model.configuration.customText)
                    if model.configuration.customBadgeImageData != nil {
                        HStack {
                            Label("Custom image", systemImage: "photo")
                            Spacer()
                            Button("Clear") { model.clearCustomBadge() }
                        }
                        SliderRow(title: "Badge Scale", value: $model.configuration.customBadgeScale, range: 0.35...1.8)
                        SliderRow(title: "Badge Opacity", value: $model.configuration.customBadgeOpacity, range: 0.1...1)
                    }
                }

                InspectorSection(title: "Finish", systemImage: "slider.horizontal.3") {
                    Picker("Gradient", selection: $model.configuration.gradientStyle) {
                        ForEach(GradientStyle.allCases) { style in
                            Text(style.title).tag(style)
                        }
                    }
                    Picker("Texture", selection: $model.configuration.textureStyle) {
                        ForEach(TextureStyle.allCases) { style in
                            Text(style.title).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                    SliderRow(title: "Glow", value: $model.configuration.glowIntensity, range: 0...1)
                    SliderRow(title: "Shadow", value: $model.configuration.shadowIntensity, range: 0...1)
                    SliderRow(title: "Corner Radius", value: $model.configuration.cornerRadius, range: 24...78)
                    Stepper("Icon Size: \(model.configuration.iconSize)", value: $model.configuration.iconSize, in: 128...1024, step: 128)
                    Toggle("Transparent Background", isOn: $model.configuration.transparentBackground)
                }

                InspectorSection(title: "Preset Packs", systemImage: "shippingbox") {
                    PackGrid(model: model)
                }

                InspectorSection(title: "Saved Presets", systemImage: "bookmark") {
                    SavedPresetList(model: model, presetStore: presetStore)
                }
            }
            .padding(16)
        }
        .background(.bar)
    }
}

private struct InspectorSection<Content: View>: View {
    var title: String
    var systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                content
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
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

private struct PackGrid: View {
    @ObservedObject var model: DesignViewModel

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 8)], spacing: 8) {
            ForEach(model.packs) { pack in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        model.apply(pack: pack)
                    }
                } label: {
                    HStack {
                        Image(systemName: "shippingbox.fill")
                        Text(pack.name)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

private struct SavedPresetList: View {
    @ObservedObject var model: DesignViewModel
    @ObservedObject var presetStore: PresetStore

    var body: some View {
        if presetStore.presets.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Label("No saved presets", systemImage: "bookmark.slash")
                    .foregroundStyle(.secondary)
                Button {
                    model.savePreset(in: presetStore)
                } label: {
                    Label("Save Current Design", systemImage: "plus")
                }
            }
        } else {
            VStack(spacing: 8) {
                ForEach(presetStore.presets) { preset in
                    HStack(spacing: 8) {
                        PresetThumbnail(configuration: preset.configuration)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(preset.name)
                                .lineLimit(1)
                            Text(preset.packName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Button {
                            model.apply(preset: preset)
                        } label: {
                            Image(systemName: "arrow.down.circle")
                        }
                        .help("Load")
                        Button {
                            model.renamePreset(preset, in: presetStore)
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .help("Rename")
                        Button(role: .destructive) {
                            model.deletePreset(preset, in: presetStore)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .help("Delete")
                    }
                    .buttonStyle(.borderless)
                    .padding(8)
                    .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

private struct PresetThumbnail: View {
    var configuration: IconConfiguration

    var body: some View {
        Image(nsImage: ExportRenderer.render(configuration: configuration, size: 64))
            .resizable()
            .frame(width: 42, height: 42)
    }
}
