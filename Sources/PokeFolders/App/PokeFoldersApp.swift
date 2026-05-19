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
                .frame(minWidth: 1120, minHeight: 720)
        }
        .windowStyle(.titleBar)
        .commands {
            CommandMenu("Design") {
                Button("Randomize") {
                    model.randomize()
                }
                .keyboardShortcut("r", modifiers: [.command])

                Button("Apply to Folder") {
                    model.applyToFolder()
                }
                .keyboardShortcut("a", modifiers: [.command, .shift])
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
