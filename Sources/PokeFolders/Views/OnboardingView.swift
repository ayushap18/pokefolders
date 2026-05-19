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
                Label("Export PNG and ICNS", systemImage: "square.and.arrow.up")
                Label("Apply to folders", systemImage: "folder.badge.gearshape")
                Label("Save presets", systemImage: "bookmark")
            }
            .font(.callout)
            .foregroundStyle(.secondary)

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
