import AppKit
import CoreGraphics
import ImageIO

public enum ExportRenderer {
    public static func render(configuration: IconConfiguration, size: Int) -> NSImage {
        let clampedSize = max(16, min(size, 2048))
        guard let cgImage = renderCGImage(configuration: configuration, size: clampedSize) else {
            return NSImage(size: NSSize(width: clampedSize, height: clampedSize))
        }
        let imageSize = NSSize(width: clampedSize, height: clampedSize)
        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        bitmap.size = imageSize
        let image = NSImage(size: imageSize)
        image.addRepresentation(bitmap)
        return image
    }

    public static func renderCGImage(configuration: IconConfiguration, size: Int) -> CGImage? {
        let clampedSize = max(16, min(size, 2048))
        guard let context = CGContext(
            data: nil,
            width: clampedSize,
            height: clampedSize,
            bitsPerComponent: 8,
            bytesPerRow: clampedSize * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        context.setShouldAntialias(configuration.textureStyle != .pixel)
        context.interpolationQuality = configuration.textureStyle == .pixel ? .none : .high

        let size = NSSize(width: clampedSize, height: clampedSize)
        context.clear(CGRect(origin: .zero, size: size))
        draw(configuration: configuration, in: CGRect(origin: .zero, size: size), context: context)

        return context.makeImage()
    }

    public static func pngData(for image: NSImage) -> Data? {
        if let bitmap = image.representations.compactMap({ $0 as? NSBitmapImageRep }).first,
           let cgImage = bitmap.cgImage {
            return pngData(from: cgImage)
        }

        var proposedRect = CGRect(origin: .zero, size: image.size)
        guard let cgImage = image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil) else {
            return nil
        }
        return pngData(from: cgImage)
    }

    public static func pngData(configuration: IconConfiguration, size: Int) -> Data? {
        guard let cgImage = renderCGImage(configuration: configuration, size: size) else {
            return nil
        }
        return pngData(from: cgImage)
    }

    private static func pngData(from cgImage: CGImage) -> Data? {
        let data = NSMutableData()
        guard
            let destination = CGImageDestinationCreateWithData(data, "public.png" as CFString, 1, nil)
        else {
            return nil
        }
        CGImageDestinationAddImage(destination, cgImage, nil)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        return data as Data
    }

    private static func draw(configuration: IconConfiguration, in canvas: CGRect, context: CGContext) {
        let scale = canvas.width / 512
        context.saveGState()
        context.scaleBy(x: scale, y: scale)

        let unitCanvas = CGRect(x: 0, y: 0, width: 512, height: 512)
        if !configuration.transparentBackground {
            drawOpaqueBackground(in: context, canvas: unitCanvas)
        }

        let bodyRect = CGRect(x: 56, y: 80, width: 400, height: 278)
        let tabRect = CGRect(x: 82, y: 330, width: 178, height: 76)
        let bodyPath = BaseFolderShape.path(in: bodyRect, cornerRadius: CGFloat(configuration.cornerRadius))
        let tabPath = FolderTabShape.path(in: tabRect, cornerRadius: min(CGFloat(configuration.cornerRadius), 38))

        drawShadow(configuration: configuration, bodyPath: bodyPath, tabPath: tabPath, context: context)
        GlowRenderer.drawGlow(in: context, paths: [bodyPath, tabPath], color: configuration.accentColor, intensity: configuration.glowIntensity)

        fill(path: tabPath, in: tabRect, context: context, primary: configuration.tabColor, accent: configuration.accentColor, style: configuration.gradientStyle)
        fill(path: bodyPath, in: bodyRect, context: context, primary: configuration.baseColor, accent: configuration.accentColor, style: configuration.gradientStyle)

        drawAccentBand(configuration: configuration, in: bodyRect, context: context)
        TextureRenderer.apply(style: configuration.textureStyle, in: context, rect: bodyRect, clippedTo: bodyPath, accentColor: configuration.accentColor)
        drawFolderEdges(configuration: configuration, bodyPath: bodyPath, tabPath: tabPath, context: context)
        TypeBadgeRenderer.drawBadge(configuration: configuration, in: context, canvas: unitCanvas)
        TextOverlayRenderer.drawText(configuration.customText, configuration: configuration, in: unitCanvas, context: context)

        context.restoreGState()
    }

    private static func drawOpaqueBackground(in context: CGContext, canvas: CGRect) {
        let background = CGPath(roundedRect: canvas.insetBy(dx: 28, dy: 28), cornerWidth: 72, cornerHeight: 72, transform: nil)
        context.addPath(background)
        context.setFillColor(RGBAColor(hex: 0xf8f8fa).cgColor)
        context.fillPath()
    }

    private static func drawShadow(configuration: IconConfiguration, bodyPath: CGPath, tabPath: CGPath, context: CGContext) {
        guard configuration.shadowIntensity > 0.01 else { return }

        context.saveGState()
        context.setShadow(
            offset: CGSize(width: 0, height: -12 * configuration.shadowIntensity),
            blur: 18 + CGFloat(configuration.shadowIntensity) * 26,
            color: RGBAColor.black.withAlpha(0.16 + configuration.shadowIntensity * 0.24).cgColor
        )
        context.setFillColor(RGBAColor.black.withAlpha(0.2).cgColor)
        context.addPath(tabPath)
        context.fillPath()
        context.addPath(bodyPath)
        context.fillPath()
        context.restoreGState()
    }

    private static func fill(
        path: CGPath,
        in rect: CGRect,
        context: CGContext,
        primary: RGBAColor,
        accent: RGBAColor,
        style: GradientStyle
    ) {
        context.saveGState()
        context.addPath(path)
        context.clip()

        let light = primary.adjusted(brightness: 0.16)
        let dark = primary.mixed(with: accent, amount: 0.32).adjusted(brightness: -0.08)
        let colors = [light.cgColor, primary.cgColor, dark.cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.45, 1])

        if let gradient {
            switch style {
            case .softTop:
                context.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: rect.midX, y: rect.maxY),
                    end: CGPoint(x: rect.midX, y: rect.minY),
                    options: []
                )
            case .diagonal:
                context.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: rect.minX, y: rect.maxY),
                    end: CGPoint(x: rect.maxX, y: rect.minY),
                    options: []
                )
            case .radial:
                context.drawRadialGradient(
                    gradient,
                    startCenter: CGPoint(x: rect.midX, y: rect.maxY),
                    startRadius: rect.width * 0.05,
                    endCenter: CGPoint(x: rect.midX, y: rect.midY),
                    endRadius: rect.width * 0.65,
                    options: .drawsAfterEndLocation
                )
            case .prism:
                context.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: rect.minX, y: rect.minY),
                    end: CGPoint(x: rect.maxX, y: rect.maxY),
                    options: []
                )
                context.setFillColor(accent.withAlpha(0.18).cgColor)
                context.fill(CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height * 0.44))
            }
        } else {
            context.setFillColor(primary.cgColor)
            context.fill(rect)
        }

        context.restoreGState()
    }

    private static func drawAccentBand(configuration: IconConfiguration, in rect: CGRect, context: CGContext) {
        let band = CGRect(x: rect.minX + 18, y: rect.maxY - 74, width: rect.width - 36, height: 18)
        let bandPath = CGPath(roundedRect: band, cornerWidth: 9, cornerHeight: 9, transform: nil)
        context.addPath(bandPath)
        context.setFillColor(configuration.accentColor.withAlpha(0.5).cgColor)
        context.fillPath()

        if configuration.themeID == "capture-orb" {
            let split = CGRect(x: rect.minX + 20, y: rect.midY + 8, width: rect.width - 40, height: 10)
            context.setFillColor(configuration.accentColor.withAlpha(0.75).cgColor)
            context.addPath(CGPath(roundedRect: split, cornerWidth: 5, cornerHeight: 5, transform: nil))
            context.fillPath()

            let lens = CGRect(x: rect.midX - 35, y: rect.midY - 24, width: 70, height: 70)
            context.setFillColor(RGBAColor.white.withAlpha(0.9).cgColor)
            context.fillEllipse(in: lens)
            context.setStrokeColor(configuration.accentColor.withAlpha(0.88).cgColor)
            context.setLineWidth(9)
            context.strokeEllipse(in: lens.insetBy(dx: 4, dy: 4))
        }
    }

    private static func drawFolderEdges(configuration: IconConfiguration, bodyPath: CGPath, tabPath: CGPath, context: CGContext) {
        context.saveGState()
        context.setStrokeColor(configuration.accentColor.withAlpha(0.24).cgColor)
        context.setLineWidth(2)
        context.addPath(tabPath)
        context.strokePath()
        context.addPath(bodyPath)
        context.strokePath()

        context.setStrokeColor(RGBAColor.white.withAlpha(0.42).cgColor)
        context.setLineWidth(2)
        context.move(to: CGPoint(x: 78, y: 342))
        context.addCurve(to: CGPoint(x: 432, y: 338), control1: CGPoint(x: 160, y: 368), control2: CGPoint(x: 300, y: 370))
        context.strokePath()
        context.restoreGState()
    }
}
