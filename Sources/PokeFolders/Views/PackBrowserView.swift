import PokeFoldersCore
import SwiftUI

struct PackBrowserView: View {
    @ObservedObject var model: DesignViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 168, maximum: 220), spacing: AppTheme.Spacing.md)
    ]

    private var accent: Color {
        AppTheme.Colors.categoryColor(model.selectedPack.category)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                StudioToolbar(model: model)
                PackHeroView(model: model)
                PackCarouselView(model: model)

                if !model.recentlyExportedDesigns.isEmpty {
                    RecentExportStrip(model: model)
                }

                BrowserControlPanel(model: model)

                if model.filteredDesigns.isEmpty {
                    EmptyStateView()
                } else {
                    LazyVGrid(columns: columns, spacing: AppTheme.Spacing.md) {
                        ForEach(model.filteredDesigns) { design in
                            IconGridCard(
                                design: design,
                                image: model.previewImage(for: design, size: 256),
                                isSelected: design.id == model.selectedDesignID,
                                isFavorite: model.favoriteDesignIDs.contains(design.id),
                                selectAction: {
                                    withAnimation(AppTheme.Motion.spring) {
                                        model.selectDesign(design)
                                    }
                                },
                                favoriteAction: {
                                    model.toggleFavorite(design)
                                },
                                exportAction: {
                                    model.selectDesign(design)
                                    model.exportPNG(size: 1024)
                                }
                            )
                            .contextMenu {
                                Button("Apply this design") { model.selectDesign(design) }
                                Button(model.favoriteDesignIDs.contains(design.id) ? "Remove Favorite" : "Favorite") {
                                    model.toggleFavorite(design)
                                }
                                Button("Export this icon") {
                                    model.selectDesign(design)
                                    model.exportPNG(size: 1024)
                                }
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(AppTheme.Spacing.xl)
        }
        .background {
            ZStack {
                AppTheme.Colors.studioBackground
                RadialGradient(
                    colors: [accent.opacity(0.18), .clear],
                    center: .topLeading,
                    startRadius: 80,
                    endRadius: 680
                )
                ScanlineOverlay(opacity: 0.016, spacing: 10)
            }
            .ignoresSafeArea()
        }
    }
}

private struct StudioToolbar: View {
    @ObservedObject var model: DesignViewModel

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: AppTheme.Spacing.md) {
                searchField
                toolbarActions
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                searchField
                toolbarActions
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var searchField: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "scope")
                .foregroundStyle(AppTheme.Colors.scannerCyan)
            TextField("Scan icons, types, textures", text: $model.searchText)
                .textFieldStyle(.plain)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            if !model.searchText.isEmpty {
                Button {
                    model.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .frame(height: 42)
        .frame(minWidth: 260, maxWidth: .infinity)
        .dexPanel(cornerRadius: AppTheme.Radius.md, accent: AppTheme.Colors.scannerCyan, showScanlines: true)
    }

    private var toolbarActions: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Picker("Sort", selection: $model.sortMode) {
                ForEach(IconSortMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .frame(width: 126)

            Button {
                model.exportFullPack()
            } label: {
                Label("Export Pack", systemImage: "archivebox")
            }
            .dexButton(accent: AppTheme.Colors.categoryColor(model.selectedPack.category), prominent: true)

            Button {
                withAnimation(AppTheme.Motion.spring) {
                    model.randomize()
                }
            } label: {
                Label("Variants", systemImage: "sparkles")
            }
            .dexButton(accent: AppTheme.Colors.scannerPurple)
        }
    }
}

private struct PackHeroView: View {
    @ObservedObject var model: DesignViewModel

    private var pack: IconPack { model.selectedPack }
    private var design: FolderIconDesign { model.selectedDesign }
    private var accent: Color { AppTheme.Colors.categoryColor(pack.category) }

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.xl) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    DataChip(label: "Pack", value: pack.category.dexCode, accent: accent)
                    DataChip(label: "Count", value: "\(pack.icons.count) icons", accent: AppTheme.Colors.scannerCyan)
                    DataChip(label: "Mode", value: "Production", accent: AppTheme.Colors.scannerPurple)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text(pack.name)
                        .font(AppTheme.Typography.heroTitle)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(pack.description)
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: AppTheme.Spacing.sm) {
                    ElementTypeChip(type: design.type)
                    DataChip(label: "Texture", value: design.textureStyle.title, accent: accent)
                    DataChip(label: "Glow", value: design.glowStyle.title, accent: AppTheme.Colors.scannerYellow)
                }

                ViewThatFits(in: .horizontal) {
                    heroActions
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        heroActions
                    }
                }
            }
            .layoutPriority(1)

            Spacer(minLength: AppTheme.Spacing.md)

            ZStack {
                Circle()
                    .stroke(accent.opacity(0.26), lineWidth: 1)
                    .frame(width: 214, height: 214)
                Circle()
                    .stroke(AppTheme.Colors.scannerCyan.opacity(0.18), style: StrokeStyle(lineWidth: 1, dash: [6, 8]))
                    .frame(width: 176, height: 176)
                Image(nsImage: model.previewImage(size: 384, quality: .preview))
                    .resizable()
                    .interpolation(model.configuration.textureStyle == .pixel ? .none : .high)
                    .frame(width: 176, height: 176)
                    .shadow(color: accent.opacity(0.30), radius: 18, y: 10)
            }
            .frame(width: 232, height: 224)
            .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous))
            .overlay {
                CornerBrackets(color: accent.opacity(0.50), inset: 13, length: 24)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .dexPanel(cornerRadius: AppTheme.Radius.xl, accent: accent, isActive: true, showScanlines: true)
    }

    private var heroActions: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Button {
                model.exportFullPack()
            } label: {
                Label("Export Pack", systemImage: "square.and.arrow.up")
            }
            .dexButton(accent: accent, prominent: true)

            Button {
                model.applyToFolder()
            } label: {
                Label("Apply", systemImage: "folder.badge.gearshape")
            }
            .dexButton(accent: AppTheme.Colors.scannerCyan)

            Button {
                withAnimation(AppTheme.Motion.spring) {
                    model.randomize()
                }
            } label: {
                Label("Variants", systemImage: "wand.and.stars")
            }
            .dexButton(accent: AppTheme.Colors.scannerPurple)
        }
    }
}

private struct PackCarouselView: View {
    @ObservedObject var model: DesignViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("PRODUCTION PACKS")
                    .font(AppTheme.Typography.sectionLabel)
                    .tracking(1.3)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Spacer()
                Text("\(model.visiblePacks.count) indexed")
                    .font(AppTheme.Typography.utilityLabel)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    ForEach(model.visiblePacks) { pack in
                        DexPackCard(
                            pack: pack,
                            isSelected: pack.id == model.selectedPackID,
                            isPinned: model.pinnedPackIDs.contains(pack.id),
                            selectAction: {
                                withAnimation(AppTheme.Motion.spring) {
                                    model.apply(pack: pack)
                                }
                            },
                            pinAction: {
                                model.togglePinned(pack: pack)
                            }
                        )
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

private struct DexPackCard: View {
    var pack: IconPack
    var isSelected: Bool
    var isPinned: Bool
    var selectAction: () -> Void
    var pinAction: () -> Void

    @State private var isHovered = false

    private var accent: Color {
        AppTheme.Colors.categoryColor(pack.category)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(LinearGradient(colors: [accent, accent.opacity(0.38)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Image(systemName: pack.category.dexSymbolName)
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.white)
                }
                .frame(width: 44, height: 44)

                Spacer()

                Button(action: pinAction) {
                    Image(systemName: isPinned ? "pin.fill" : "pin")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(isPinned ? accent : AppTheme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(pack.name)
                    .font(AppTheme.Typography.rowTitle)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .lineLimit(1)

                Text(pack.category.dexSubtitle)
                    .font(AppTheme.Typography.rowMeta)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .lineLimit(1)
            }

            HStack {
                Text("\(pack.icons.count) icons")
                    .font(AppTheme.Typography.utilityLabel)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                Spacer()
                StatusLED(color: accent, isActive: isSelected || isHovered)
            }
        }
        .padding(AppTheme.Spacing.md)
        .frame(width: 212, height: 154)
        .dexPanel(cornerRadius: AppTheme.Radius.lg, accent: accent, isActive: isSelected || isHovered, showScanlines: isSelected)
        .scaleEffect(isHovered ? 1.018 : 1)
        .animation(AppTheme.Motion.quick, value: isHovered)
        .onTapGesture(perform: selectAction)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

private struct RecentExportStrip: View {
    @ObservedObject var model: DesignViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Label("Recently Exported", systemImage: "clock.arrow.circlepath")
                    .font(AppTheme.Typography.sectionLabel)
                    .tracking(1.1)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Spacer()
            }

            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(model.recentlyExportedDesigns) { design in
                    Button {
                        withAnimation(AppTheme.Motion.spring) {
                            model.selectDesign(design)
                        }
                    } label: {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(nsImage: model.previewImage(for: design, size: 128))
                                .resizable()
                                .interpolation(design.textureStyle == .pixel ? .none : .high)
                                .frame(width: 34, height: 34)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(design.name)
                                    .lineLimit(1)
                                Text(design.type.title)
                                    .font(AppTheme.Typography.utilityLabel)
                                    .foregroundStyle(AppTheme.Colors.textTertiary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(AppTheme.Colors.panelRaised.opacity(0.52), in: RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                            .stroke(AppTheme.Colors.typeColor(design.type).opacity(0.25), lineWidth: 1)
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .dexPanel(cornerRadius: AppTheme.Radius.lg, accent: AppTheme.Colors.scannerCyan, showScanlines: true)
    }
}

private struct BrowserControlPanel: View {
    @ObservedObject var model: DesignViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("ICON GRID")
                    .font(AppTheme.Typography.sectionLabel)
                    .tracking(1.3)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                Spacer()

                Text("\(model.filteredDesigns.count) visible")
                    .font(AppTheme.Typography.utilityLabel)
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    FilterPill(title: "All", color: AppTheme.Colors.scannerCyan, isSelected: model.selectedTypeFilter == nil) {
                        withAnimation(AppTheme.Motion.smooth) { model.selectedTypeFilter = nil }
                    }
                    ForEach(model.productionFilterTypes) { type in
                        FilterPill(title: type.title, color: AppTheme.Colors.typeColor(type), isSelected: model.selectedTypeFilter == type) {
                            withAnimation(AppTheme.Motion.smooth) { model.selectedTypeFilter = type }
                        }
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .dexPanel(cornerRadius: AppTheme.Radius.lg, accent: AppTheme.Colors.categoryColor(model.selectedPack.category), showScanlines: true)
    }
}

private struct IconGridCard: View {
    var design: FolderIconDesign
    var image: NSImage
    var isSelected: Bool
    var isFavorite: Bool
    var selectAction: () -> Void
    var favoriteAction: () -> Void
    var exportAction: () -> Void

    @State private var isHovered = false

    private var accent: Color {
        AppTheme.Colors.typeColor(design.type)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [accent.opacity(isHovered ? 0.28 : 0.16), AppTheme.Colors.panelBase.opacity(0.72)],
                                center: .center,
                                startRadius: 8,
                                endRadius: 142
                            )
                        )

                    Circle()
                        .stroke(accent.opacity(0.18), style: StrokeStyle(lineWidth: 1, dash: [5, 7]))
                        .frame(width: 122, height: 122)

                    Image(nsImage: image)
                        .resizable()
                        .interpolation(design.textureStyle == .pixel ? .none : .high)
                        .frame(width: isHovered ? 134 : 124, height: isHovered ? 134 : 124)
                        .shadow(color: accent.opacity(isHovered ? 0.48 : 0.20), radius: isHovered ? 22 : 10, y: 8)
                }
                .frame(height: 164)

                HStack(spacing: AppTheme.Spacing.xs) {
                    Button(action: favoriteAction) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .buttonStyle(.plain)

                    Button(action: exportAction) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .buttonStyle(.plain)
                }
                .foregroundStyle(isFavorite ? AppTheme.Colors.scannerYellow : AppTheme.Colors.textSecondary)
                .padding(AppTheme.Spacing.sm)
                .background(AppTheme.Colors.panelBase.opacity(0.78), in: Capsule())
                .padding(AppTheme.Spacing.sm)
                .opacity(isHovered || isSelected || isFavorite ? 1 : 0)
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack {
                    Text(design.name)
                        .font(AppTheme.Typography.rowTitle)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .lineLimit(1)
                    Spacer(minLength: AppTheme.Spacing.sm)
                    ElementTypeChip(type: design.type)
                }

                HStack(spacing: AppTheme.Spacing.sm) {
                    Text(design.textureStyle.title)
                    Text("/")
                    Text(design.glowStyle.title)
                }
                .font(AppTheme.Typography.rowMeta)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .lineLimit(1)
            }
        }
        .padding(AppTheme.Spacing.md)
        .dexPanel(cornerRadius: AppTheme.Radius.lg, accent: accent, isActive: isSelected || isHovered, showScanlines: isSelected)
        .scaleEffect(isHovered ? 1.008 : 1)
        .animation(AppTheme.Motion.quick, value: isHovered)
        .animation(AppTheme.Motion.smooth, value: isSelected)
        .onTapGesture(perform: selectAction)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

private struct FilterPill: View {
    var title: String
    var color: Color
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.callout.weight(.semibold))
                .foregroundStyle(isSelected ? Color.black.opacity(0.82) : AppTheme.Colors.textSecondary)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(isSelected ? color : color.opacity(0.12), in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(color.opacity(isSelected ? 0.46 : 0.26), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "square.dashed")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textTertiary)
            Text("No icons match this scan")
                .font(AppTheme.Typography.title)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text("Clear search, switch type filters, or choose another production pack.")
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .dexPanel(cornerRadius: AppTheme.Radius.xl, accent: AppTheme.Colors.scannerCyan, showScanlines: true)
    }
}
