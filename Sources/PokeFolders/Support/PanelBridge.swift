import AppKit
import Foundation
import UniformTypeIdentifiers

enum PanelBridge {
    static func savePNGURL(defaultName: String) -> URL? {
        let panel = NSSavePanel()
        panel.title = "Export PNG"
        panel.nameFieldStringValue = "\(defaultName).png"
        panel.allowedContentTypes = [.png]
        panel.canCreateDirectories = true
        return panel.runModal() == .OK ? panel.url : nil
    }

    static func saveICNSURL(defaultName: String) -> URL? {
        let panel = NSSavePanel()
        panel.title = "Export ICNS"
        panel.nameFieldStringValue = "\(defaultName).icns"
        if let icnsType = UTType(filenameExtension: "icns") {
            panel.allowedContentTypes = [icnsType]
        }
        panel.canCreateDirectories = true
        return panel.runModal() == .OK ? panel.url : nil
    }

    static func chooseDirectory(title: String) -> URL? {
        let panel = NSOpenPanel()
        panel.title = title
        panel.prompt = "Export"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        return panel.runModal() == .OK ? panel.url : nil
    }

    static func chooseFolder() -> URL? {
        let panel = NSOpenPanel()
        panel.title = "Apply Icon to Folder"
        panel.prompt = "Apply"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        return panel.runModal() == .OK ? panel.url : nil
    }

    static func promptForText(title: String, message: String, defaultValue: String) -> String? {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")

        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 320, height: 24))
        textField.stringValue = defaultValue
        alert.accessoryView = textField

        guard alert.runModal() == .alertFirstButtonReturn else {
            return nil
        }

        let value = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
