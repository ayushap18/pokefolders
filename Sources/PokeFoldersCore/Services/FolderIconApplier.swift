import AppKit
import Foundation

public enum FolderIconApplyError: LocalizedError {
    case notAFolder
    case appKitRejectedIcon

    public var errorDescription: String? {
        switch self {
        case .notAFolder:
            return "Choose a real folder before applying the icon."
        case .appKitRejectedIcon:
            return "macOS rejected the generated icon for this folder."
        }
    }
}

public struct FolderIconApplier {
    public init() {}

    public func apply(configuration: IconConfiguration, to folderURL: URL) throws {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: folderURL.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw FolderIconApplyError.notAFolder
        }

        let image = ExportRenderer.render(configuration: configuration, size: 1024)
        let success = NSWorkspace.shared.setIcon(image, forFile: folderURL.path, options: [])
        guard success else {
            throw FolderIconApplyError.appKitRejectedIcon
        }
    }
}
