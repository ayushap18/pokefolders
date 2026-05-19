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
                PreviewCanvasView(model: model)
                    .frame(minWidth: 560, maxWidth: .infinity, maxHeight: .infinity)

                InspectorView(model: model, presetStore: presetStore)
                    .frame(minWidth: 330, idealWidth: 370, maxWidth: 430, maxHeight: .infinity)
            }
        }
        .navigationTitle("PokeFolders")
        .toolbar {
            ToolbarItemGroup {
                Menu {
                    Button("PNG 512x512") { model.exportPNG(size: 512) }
                    Button("PNG 1024x1024") { model.exportPNG(size: 1024) }
                    Divider()
                    Button("ICNS-ready Iconset") { model.exportIconset() }
                    Button("macOS ICNS") { model.exportICNS() }
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

                Button {
                    model.savePreset(in: presetStore)
                } label: {
                    Label("Save Preset", systemImage: "bookmark")
                }
            }
        }
        .sheet(isPresented: Binding(get: { !hasSeenOnboarding }, set: { hasSeenOnboarding = !$0 })) {
            OnboardingView {
                hasSeenOnboarding = true
            }
        }
    }
}
