import AppKit
import Foundation
import UniformTypeIdentifiers

public enum ExportServiceError: LocalizedError {
    case pngEncodingFailed
    case iconutilFailed(String)
    case zipFailed(String)

    public var errorDescription: String? {
        switch self {
        case .pngEncodingFailed:
            return "The generated icon could not be encoded as PNG."
        case .iconutilFailed(let details):
            return "The .icns export failed. \(details)"
        case .zipFailed(let details):
            return "The ZIP archive export failed. \(details)"
        }
    }
}

public struct ExportService {
    public let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    @discardableResult
    public func exportPNG(configuration: IconConfiguration, size: Int, to fileURL: URL, quality: RenderQuality = .ultra) throws -> URL {
        guard let data = ExportRenderer.pngData(configuration: configuration, size: size, quality: quality) else {
            throw ExportServiceError.pngEncodingFailed
        }
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }

    @discardableResult
    public func exportIconset(configuration: IconConfiguration, to directoryURL: URL, name: String, quality: RenderQuality = .ultra) throws -> URL {
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
            guard let data = ExportRenderer.pngData(configuration: configuration, size: representation.size, quality: quality) else {
                throw ExportServiceError.pngEncodingFailed
            }
            try data.write(to: iconsetURL.appendingPathComponent(representation.fileName), options: .atomic)
        }

        return iconsetURL
    }

    @discardableResult
    public func exportICNS(configuration: IconConfiguration, to fileURL: URL, name: String = "PokeFoldersIcon", quality: RenderQuality = .ultra) throws -> URL {
        let temporaryDirectory = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: temporaryDirectory) }

        let iconsetURL = try exportIconset(configuration: configuration, to: temporaryDirectory, name: name, quality: quality)
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

    @discardableResult
    public func exportFullPack(_ pack: IconPack, to directoryURL: URL, includeZip: Bool = true) throws -> URL {
        let packFolderName = "PokeFolders-\(sanitizedFileName(pack.name.replacingOccurrences(of: " ", with: "-")))"
        let packURL = directoryURL.appendingPathComponent(packFolderName, isDirectory: true)

        if fileManager.fileExists(atPath: packURL.path) {
            try fileManager.removeItem(at: packURL)
        }

        let pngRoot = packURL.appendingPathComponent("PNG", isDirectory: true)
        let iconsetRoot = packURL.appendingPathComponent("ICNS-Ready", isDirectory: true)
        for size in [1024, 512, 256, 128] {
            try fileManager.createDirectory(
                at: pngRoot.appendingPathComponent("\(size)", isDirectory: true),
                withIntermediateDirectories: true
            )
        }
        try fileManager.createDirectory(at: iconsetRoot, withIntermediateDirectories: true)

        for design in pack.icons {
            let configuration = IconConfiguration(design: design)
            for size in [1024, 512, 256, 128] {
                let fileName = design.exportFileNames["\(size)"] ?? "\(design.exportBaseName)_\(size).png"
                try exportPNG(
                    configuration: configuration,
                    size: size,
                    to: pngRoot.appendingPathComponent("\(size)", isDirectory: true).appendingPathComponent(fileName),
                    quality: .ultra
                )
            }

            _ = try exportIconset(
                configuration: configuration,
                to: iconsetRoot,
                name: design.exportBaseName,
                quality: .ultra
            )
        }

        try packReadme(for: pack).write(
            to: packURL.appendingPathComponent("README.txt"),
            atomically: true,
            encoding: .utf8
        )

        if includeZip {
            try zipPack(at: packURL)
        }

        return packURL
    }

    private func sanitizedFileName(_ name: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_ "))
        return name.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" }.reduce("") { $0 + String($1) }
    }

    private func packReadme(for pack: IconPack) -> String {
        """
        \(pack.name)

        \(pack.description)

        Included sizes:
        - PNG/1024
        - PNG/512
        - PNG/256
        - PNG/128
        - ICNS-Ready iconset folders

        How to apply on macOS:
        1. Open a PNG in Preview.
        2. Press Command-A, then Command-C.
        3. Select a folder in Finder and press Command-I.
        4. Click the small folder icon in the Get Info window.
        5. Press Command-V.

        License and safety note:
        These are original generated folder icon designs for PokeFolders. They are not affiliated with Pokemon, Nintendo, Game Freak, Creatures Inc., or The Pokemon Company. No official characters, logos, or trademarked artwork are included.
        """
    }

    private func zipPack(at packURL: URL) throws {
        let parent = packURL.deletingLastPathComponent()
        let zipURL = parent.appendingPathComponent("\(packURL.lastPathComponent).zip")
        if fileManager.fileExists(atPath: zipURL.path) {
            try fileManager.removeItem(at: zipURL)
        }

        let process = Process()
        process.currentDirectoryURL = parent
        process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        process.arguments = ["-qry", zipURL.lastPathComponent, packURL.lastPathComponent]

        let errorPipe = Pipe()
        process.standardError = errorPipe
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let data = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let details = String(data: data, encoding: .utf8) ?? "zip exited with status \(process.terminationStatus)."
            throw ExportServiceError.zipFailed(details)
        }
    }
}
