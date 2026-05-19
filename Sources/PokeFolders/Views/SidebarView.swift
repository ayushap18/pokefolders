import PokeFoldersCore
import SwiftUI

struct SidebarView: View {
    @ObservedObject var model: DesignViewModel

    var body: some View {
        List(selection: $model.selectedPackID) {
            Section("Production Packs") {
                ForEach(model.iconPacks) { pack in
                    SidebarPackRow(pack: pack)
                        .tag(pack.id)
                }
            }

            Section("Safety") {
                Label("Original creature-inspired designs", systemImage: "checkmark.shield")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Not affiliated with Pokemon, Nintendo, Game Freak, or The Pokemon Company.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.sidebar)
        .onChange(of: model.selectedPackID) { newValue in
            model.selectPack(id: newValue)
        }
    }
}

private struct SidebarPackRow: View {
    var pack: IconPack

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(pack.accentColor.swiftUIColor.gradient)
                Text("\(pack.icons.count)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: 24, height: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(pack.name)
                    .lineLimit(1)
                Text(pack.category.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}
