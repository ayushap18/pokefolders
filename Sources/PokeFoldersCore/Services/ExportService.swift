import AppKit
import Foundation
import UniformTypeIdentifiers

public enum ExportServiceError: LocalizedError {
    case pngEncodingFailed
    case iconutilFailed(String)

    public var errorDescription: String? {
        switch self {
        case .pngEncodingFailed:
            return "The generated icon could not be encoded as PNG."
        case .iconutilFailed(let details):
            return "The .icns export failed. \(details)"
        }
    }
}

public struct ExportService {
    public let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    @discardableResult
    public func exportPNG(configuration: IconConfiguration, size: Int, to fileURL: URL) throws -> URL {
        guard let data = ExportRenderer.pngData(configuration: configuration, size: size) else {
            throw ExportServiceError.pngEncodingFailed
        }
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }

    @discardableResult
    public func exportIconset(configuration: IconConfiguration, to directoryURL: URL, name: String) throws -> URL {
        let safeName = sanitizedFileName(name.isEmpty ? "PokeFoldersIcon" : name)
        let iconsetURL = directoryURL.appendingPathComponent("\(safeName).iconset", isDirectory: true)

        if fileManager.fileExists(atPath: iconsetURL.path) {
            try fileManager.removeItem(at: iconsetURL)
        }
        try fileManager.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

        let representations: [(fileName: String, size: Int)] = [
            ("icon_16x16.png", 16),
            ("icon_16x16@2x.png", 32),
            ("icon_32x32.png", 32),
            ("icon_32x32@2x.png", 64),
            ("icon_64x64.png", 64),
            ("icon_128x128.png", 128),
            ("icon_128x128@2x.png", 256),
            ("icon_256x256.png", 256),
            ("icon_256x256@2x.png", 512),
            ("icon_512x512.png", 512),
            ("icon_512x512@2x.png", 1024),
            ("icon_1024x1024.png", 1024)
        ]

        for representation in representations {
            guard let data = ExportRenderer.pngData(configuration: configuration, size: representation.size) else {
                throw ExportServiceError.pngEncodingFailed
            }
            try data.write(to: iconsetURL.appendingPathComponent(representation.fileName), options: .atomic)
        }

        return iconsetURL
    }

    @discardableResult
    public func exportICNS(configuration: IconConfiguration, to fileURL: URL, name: String = "PokeFoldersIcon") throws -> URL {
        let temporaryDirectory = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: temporaryDirectory) }

        let iconsetURL = try exportIconset(configuration: configuration, to: temporaryDirectory, name: name)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
        process.arguments = ["-c", "icns", iconsetURL.path, "-o", fileURL.path]

        let errorPipe = Pipe()
        process.standardError = errorPipe
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let data = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let details = String(data: data, encoding: .utf8) ?? "iconutil exited with status \(process.terminationStatus)."
            throw ExportServiceError.iconutilFailed(details)
        }

        return fileURL
    }

    private func sanitizedFileName(_ name: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_ "))
        return name.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" }.reduce("") { $0 + String($1) }
    }
}
