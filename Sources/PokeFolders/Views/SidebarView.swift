import PokeFoldersCore
import SwiftUI

struct SidebarView: View {
    @ObservedObject var model: DesignViewModel

    var body: some View {
        List(selection: $model.selectedThemeID) {
            ForEach(ThemeCategory.allCases) { category in
                let themes = model.themes.filter { $0.category == category }
                if !themes.isEmpty {
                    Section(category.title) {
                        ForEach(themes) { theme in
                            SidebarThemeRow(theme: theme)
                                .tag(Optional(theme.id))
                        }
                    }
                }
            }

            Section("Preset Packs") {
                ForEach(model.packs) { pack in
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            model.apply(pack: pack)
                        }
                    } label: {
                        Label(pack.name, systemImage: "shippingbox")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.sidebar)
        .onChange(of: model.selectedThemeID) { newValue in
            model.selectTheme(id: newValue)
        }
    }
}

private struct SidebarThemeRow: View {
    var theme: FolderTheme

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(theme.baseColor.swiftUIColor.gradient)
                Circle()
                    .fill(theme.accentColor.swiftUIColor)
                    .frame(width: 12, height: 12)
                    .offset(x: 7, y: -5)
            }
            .frame(width: 24, height: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(theme.name)
                    .lineLimit(1)
                Text(theme.elementType.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}
