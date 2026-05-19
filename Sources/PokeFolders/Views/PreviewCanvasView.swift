import AppKit
import PokeFoldersCore
import SwiftUI
import UniformTypeIdentifiers

struct PreviewCanvasView: View {
    @ObservedObject var model: DesignViewModel
    @State private var isDropTargeted = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HeaderBlock(model: model)

                let image = model.previewImage(size: 512)
                VStack(spacing: 16) {
                    Image(nsImage: image)
                        .resizable()
                        .interpolation(model.configuration.textureStyle == .pixel ? .none : .high)
                        .frame(width: 512, height: 512)
                        .padding(18)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isDropTargeted ? Color.accentColor : Color.secondary.opacity(0.18), lineWidth: isDropTargeted ? 3 : 1)
                        }
                        .shadow(color: .black.opacity(0.18), radius: 20, y: 8)
                        .animation(.easeInOut(duration: 0.18), value: model.configuration)
                        .onDrop(of: [UTType.image.identifier, UTType.fileURL.identifier], isTargeted: $isDropTargeted) { providers in
                            handleDrop(providers)
                        }

                    FinderPreviewRow(image: image)
                }

                DesktopPreviewGrid(image: image)

                if let status = model.statusMessage {
                    StatusBanner(status: status)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(Color(nsColor: .textBackgroundColor).opacity(0.18))
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                    guard let data else { return }
                    Task { @MainActor in
                        model.setCustomBadge(data: data)
                    }
                }
                return true
            }

            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, _ in
                    guard
                        let data,
                        let urlString = String(data: data, encoding: .utf8),
                        let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)),
                        let imageData = try? Data(contentsOf: url)
                    else {
                        return
                    }
                    Task { @MainActor in
                        model.setCustomBadge(data: imageData)
                    }
                }
                return true
            }
        }
        return false
    }
}

private struct HeaderBlock: View {
    @ObservedObject var model: DesignViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(model.selectedTheme.name)
                .font(.largeTitle.bold())
                .lineLimit(1)
            Text("\(model.selectedTheme.packName) - \(model.configuration.elementType.title) - \(model.configuration.textureStyle.title)")
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

private struct FinderPreviewRow: View {
    var image: NSImage

    var body: some View {
        HStack(spacing: 18) {
            FinderTile(image: image, title: "Assets", size: 72)
            FinderTile(image: image, title: "Build", size: 48)
            FinderTile(image: image, title: "Archive", size: 32)
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct FinderTile: View {
    var image: NSImage
    var title: String
    var size: CGFloat

    var body: some View {
        VStack(spacing: 6) {
            Image(nsImage: image)
                .resizable()
                .frame(width: size, height: size)
            Text(title)
                .font(.caption)
                .lineLimit(1)
        }
        .frame(width: max(82, size + 20))
    }
}

private struct DesktopPreviewGrid: View {
    var image: NSImage

    var body: some View {
        HStack(spacing: 14) {
            DesktopPreview(image: image, title: "Light Desktop", background: .white, foreground: .black, isDark: false)
            DesktopPreview(image: image, title: "Dark Desktop", background: .black, foreground: .white, isDark: true)
        }
    }
}

private struct DesktopPreview: View {
    var image: NSImage
    var title: String
    var background: Color
    var foreground: Color
    var isDark: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            ZStack {
                background
                Image(nsImage: image)
                    .resizable()
                    .frame(width: 118, height: 118)
                    .shadow(color: .black.opacity(isDark ? 0.5 : 0.16), radius: 10, y: 5)
                Text("Designs")
                    .font(.caption)
                    .foregroundStyle(foreground)
                    .offset(y: 78)
            }
            .frame(height: 210)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct StatusBanner: View {
    var status: StatusMessage

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
            Text(status.text)
                .lineLimit(2)
            Spacer()
        }
        .font(.callout)
        .padding(12)
        .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))
        .foregroundStyle(tint)
    }

    private var iconName: String {
        switch status.style {
        case .success: "checkmark.circle.fill"
        case .failure: "exclamationmark.triangle.fill"
        case .neutral: "info.circle.fill"
        }
    }

    private var tint: Color {
        switch status.style {
        case .success: .green
        case .failure: .red
        case .neutral: .accentColor
        }
    }
}
