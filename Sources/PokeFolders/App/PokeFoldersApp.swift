import AppKit
import PokeFoldersCore
import SwiftUI

@main
struct PokeFoldersApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = DesignViewModel()
    @StateObject private var presetStore = PresetStore()

    var body: some Scene {
        WindowGroup("PokeFolders", id: "main") {
            ContentView(model: model, presetStore: presetStore)
                .frame(minWidth: 1180, minHeight: 720)
        }
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
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}
