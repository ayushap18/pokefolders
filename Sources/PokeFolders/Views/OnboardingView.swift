import PokeFoldersCore
import SwiftUI

struct OnboardingView: View {
    var dismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(nsImage: ExportRenderer.render(configuration: .starter, size: 256))
                .resizable()
                .frame(width: 132, height: 132)
                .shadow(color: .black.opacity(0.18), radius: 16, y: 8)

            VStack(spacing: 6) {
                Text("PokeFolders")
                    .font(.largeTitle.bold())
                Text("Original elemental folder icons for macOS.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Label("40 production icons", systemImage: "square.grid.3x3")
                Label("Export full packs", systemImage: "archivebox")
                Label("Apply to folders", systemImage: "folder.badge.gearshape")
            }
            .font(.callout)
            .foregroundStyle(.secondary)

            Text("Original creature-inspired designs only. Not affiliated with Pokemon, Nintendo, Game Freak, or The Pokemon Company.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 430)

            Button {
                dismiss()
            } label: {
                Text("Start Designing")
                    .frame(width: 180)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(36)
        .frame(width: 560)
    }
}
