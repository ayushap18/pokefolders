import PokeFoldersCore
import SwiftUI

struct PackBrowserView: View {
    @ObservedObject var model: DesignViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 164, maximum: 220), spacing: 14)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                packCards
                controls

                if model.filteredDesigns.isEmpty {
                    EmptyStateView()
                } else {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(model.filteredDesigns) { design in
                            IconGridCard(
                                design: design,
                                image: model.previewImage(for: design, size: 256),
                                isSelected: design.id == model.selectedDesignID,
                                isHovered: design.id == model.hoveredDesignID
                            )
                            .onHover { hovering in
                                withAnimation(.easeInOut(duration: 0.16)) {
                                    model.hoveredDesignID = hovering ? design.id : nil
                                }
                            }
                            .onTapGesture {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                    model.selectDesign(design)
                                }
                            }
                            .contextMenu {
                                Button("Apply this design") { model.selectDesign(design) }
                                Button("Export this icon") {
                                    model.selectDesign(design)
                                    model.exportPNG(size: 1024)
                                }
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(Color(nsColor: .textBackgroundColor).opacity(0.16))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Production Icon Packs")
                .font(.largeTitle.bold())
                .lineLimit(1)
            Text("Premium original folder designs for collectible-creature inspired desktops.")
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
    }

    private var packCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(model.iconPacks) { pack in
                    PackCard(pack: pack, isSelected: pack.id == model.selectedPackID)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                model.apply(pack: pack)
                            }
                        }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search icons", text: $model.searchText)
                    .textFieldStyle(.plain)
            }
            .padding(10)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterPill(title: "All", isSelected: model.selectedTypeFilter == nil) {
                        withAnimation { model.selectedTypeFilter = nil }
                    }
                    ForEach(model.productionFilterTypes) { type in
                        FilterPill(title: type.title, isSelected: model.selectedTypeFilter == type) {
                            withAnimation { model.selectedTypeFilter = type }
                        }
                    }
                }
            }
        }
    }
}

private struct PackCard: View {
    var pack: IconPack
    var isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(pack.name)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                if pack.isPremium {
                    Image(systemName: "sparkles")
                        .foregroundStyle(pack.accentColor.swiftUIColor)
                }
            }

            Text(pack.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            HStack {
                Label("\(pack.icons.count) icons", systemImage: "square.grid.2x2")
                Spacer()
                Circle()
                    .fill(pack.accentColor.swiftUIColor)
                    .frame(width: 10, height: 10)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(width: 230, height: 132)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? pack.accentColor.swiftUIColor.opacity(0.8) : Color.secondary.opacity(0.16), lineWidth: isSelected ? 2 : 1)
        }
    }
}

private struct IconGridCard: View {
    var design: FolderIconDesign
    var image: NSImage
    var isSelected: Bool
    var isHovered: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(design.accentColor.swiftUIColor.opacity(isHovered ? 0.18 : 0.08))
                Image(nsImage: image)
                    .resizable()
                    .interpolation(design.textureStyle == .pixel ? .none : .high)
                    .frame(width: isHovered ? 128 : 118, height: isHovered ? 128 : 118)
                    .shadow(color: design.accentColor.swiftUIColor.opacity(isHovered ? 0.38 : 0.16), radius: isHovered ? 18 : 8, y: 6)
            }
            .frame(height: 150)

            VStack(alignment: .leading, spacing: 3) {
                Text(design.name)
                    .font(.headline)
                    .lineLimit(1)
                Text("\(design.type.title) - \(design.textureStyle.title)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? design.accentColor.swiftUIColor : Color.secondary.opacity(0.14), lineWidth: isSelected ? 2 : 1)
        }
        .scaleEffect(isHovered ? 1.015 : 1)
    }
}

private struct FilterPill: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.1), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "square.dashed")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No icons match this filter")
                .font(.headline)
            Text("Clear search or choose another type.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 260)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}
