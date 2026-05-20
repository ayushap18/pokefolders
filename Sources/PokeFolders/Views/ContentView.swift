import PokeFoldersCore
import SwiftUI

struct ContentView: View {
    @ObservedObject var model: DesignViewModel
    @ObservedObject var presetStore: PresetStore
    @AppStorage("hasSeenPokeFoldersOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        NavigationSplitView {
            SidebarView(model: model)
                .navigationSplitViewColumnWidth(min: 284, ideal: 312, max: 360)
        } detail: {
            HSplitView {
                PackBrowserView(model: model)
                    .frame(minWidth: 680, maxWidth: .infinity, maxHeight: .infinity)

                IconDetailView(model: model, presetStore: presetStore)
                    .frame(minWidth: 380, idealWidth: 420, maxWidth: 480, maxHeight: .infinity)
            }
            .background(AppTheme.Colors.appBackground)
            .overlay(alignment: .bottom) {
                if let status = model.statusMessage {
                    ToastBanner(status: status)
                        .padding(.bottom, 18)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .navigationTitle("PokeFolders")
        .preferredColorScheme(.dark)
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
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .padding(AppTheme.Spacing.lg)
                    .dexPanel(cornerRadius: AppTheme.Radius.lg, accent: AppTheme.Colors.scannerCyan, isActive: true, showScanlines: true)
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
                .font(.system(size: 15, weight: .bold))
            Text(status.text)
                .lineLimit(2)
            Spacer(minLength: 0)
        }
        .font(AppTheme.Typography.callout)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .frame(width: 460)
        .dexPanel(cornerRadius: AppTheme.Radius.lg, accent: tint, isActive: true, showScanlines: true)
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
