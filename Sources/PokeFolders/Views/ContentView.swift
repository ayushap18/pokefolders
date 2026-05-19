import PokeFoldersCore
import SwiftUI

struct ContentView: View {
    @ObservedObject var model: DesignViewModel
    @ObservedObject var presetStore: PresetStore
    @AppStorage("hasSeenPokeFoldersOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        NavigationSplitView {
            SidebarView(model: model)
                .navigationSplitViewColumnWidth(min: 230, ideal: 260, max: 320)
        } detail: {
            HSplitView {
                PackBrowserView(model: model)
                    .frame(minWidth: 610, maxWidth: .infinity, maxHeight: .infinity)

                IconDetailView(model: model, presetStore: presetStore)
                    .frame(minWidth: 350, idealWidth: 390, maxWidth: 460, maxHeight: .infinity)
            }
            .overlay(alignment: .bottom) {
                if let status = model.statusMessage {
                    ToastBanner(status: status)
                        .padding(.bottom, 18)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .navigationTitle("PokeFolders")
        .toolbar {
            ToolbarItemGroup {
                Menu {
                    Button("Export Current PNG 1024") { model.exportPNG(size: 1024) }
                        .keyboardShortcut("e", modifiers: [.command])
                    Button("Export Current PNG 512") { model.exportPNG(size: 512) }
                    Button("Export Current Iconset") { model.exportSelectedIconset() }
                    Button("Export Current ICNS") { model.exportICNS() }
                    Divider()
                    Button("Export Full Pack") { model.exportFullPack() }
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }

                Button {
                    model.applyToFolder()
                } label: {
                    Label("Apply to Folder", systemImage: "folder.badge.gearshape")
                }

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                        model.randomize()
                    }
                } label: {
                    Label("Randomize", systemImage: "shuffle")
                }
                .keyboardShortcut("r", modifiers: [.command])

                Button {
                    model.savePreset(in: presetStore)
                } label: {
                    Label("Save Preset", systemImage: "bookmark")
                }
                .keyboardShortcut("s", modifiers: [.command])
            }
        }
        .overlay {
            if model.isExporting {
                ProgressView("Exporting pack...")
                    .padding(18)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .sheet(isPresented: Binding(get: { !hasSeenOnboarding }, set: { hasSeenOnboarding = !$0 })) {
            OnboardingView {
                hasSeenOnboarding = true
            }
        }
    }
}

private struct ToastBanner: View {
    var status: StatusMessage

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
            Text(status.text)
                .lineLimit(2)
            Spacer(minLength: 0)
        }
        .font(.callout)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: 420)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(tint.opacity(0.35), lineWidth: 1)
        }
        .foregroundStyle(tint)
        .shadow(color: .black.opacity(0.16), radius: 16, y: 8)
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
