import AppKit
import PokeFoldersCore
import SwiftUI

@main
struct PokeFoldersApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = DesignViewModel()
    @StateObject private var presetStore = PresetStore()

    var body: some Scene {
        WindowGroup("PokeFolders") {
            ContentView(model: model, presetStore: presetStore)
                .frame(minWidth: 1180, minHeight: 720)
        }
        .defaultSize(width: 1440, height: 860)
        .windowStyle(.titleBar)
        .commands {
            CommandMenu("Design") {
                Button("Export Current Icon") {
                    model.exportPNG(size: 1024)
                }
                .keyboardShortcut("e", modifiers: [.command])

                Button("Randomize") {
                    model.randomize()
                }
                .keyboardShortcut("r", modifiers: [.command])

                Button("Apply to Folder") {
                    model.applyToFolder()
                }
                .keyboardShortcut("a", modifiers: [.command, .shift])

                Button("Save Preset") {
                    model.savePreset(in: presetStore)
                }
                .keyboardShortcut("s", modifiers: [.command])
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var fallbackWindow: NSWindow?
    private var fallbackModel: DesignViewModel?
    private var fallbackPresetStore: PresetStore?

    func applicationDidFinishLaunching(_ notification: Notification) {
        installAppIcon()
        NSApp.setActivationPolicy(.regular)
        Task { @MainActor in
            ensureMainWindow()
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        Task { @MainActor in
            ensureMainWindow()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            Task { @MainActor in
                ensureMainWindow()
            }
        }
        return true
    }

    private func installAppIcon() {
        if let logoURL = Bundle.module.url(forResource: "PokeFolders", withExtension: "icns", subdirectory: "AppIcon"),
           let logo = NSImage(contentsOf: logoURL) {
            NSApp.applicationIconImage = logo
        } else if let logoURL = Bundle.module.url(forResource: "PokeFoldersLogo", withExtension: "png", subdirectory: "AppIcon"),
                  let logo = NSImage(contentsOf: logoURL) {
            NSApp.applicationIconImage = logo
        }
    }

    @MainActor private func ensureMainWindow() {
        guard !NSApp.windows.contains(where: { $0.isVisible }) else { return }

        let model = DesignViewModel()
        let presetStore = PresetStore()
        fallbackModel = model
        fallbackPresetStore = presetStore

        let contentView = ContentView(model: model, presetStore: presetStore)
            .frame(minWidth: 1180, minHeight: 720)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1440, height: 860),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "PokeFolders"
        window.contentView = NSHostingView(rootView: contentView)
        window.center()
        window.makeKeyAndOrderFront(nil)
        fallbackWindow = window
    }
}
