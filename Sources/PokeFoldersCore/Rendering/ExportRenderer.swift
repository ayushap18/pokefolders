import AppKit
import CoreGraphics
import ImageIO

public enum ExportRenderer {
    public static func render(configuration: IconConfiguration, size: Int, quality: RenderQuality = .preview) -> NSImage {
        let clampedSize = max(16, min(size, 2048))
        guard let cgImage = renderCGImage(configuration: configuration, size: clampedSize, quality: quality) else {
            return NSImage(size: NSSize(width: clampedSize, height: clampedSize))
        }
        let imageSize = NSSize(width: clampedSize, height: clampedSize)
        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        bitmap.size = imageSize
        let image = NSImage(size: imageSize)
        image.addRepresentation(bitmap)
        return image
    }

    public static func renderCGImage(configuration: IconConfiguration, size: Int, quality: RenderQuality = .export) -> CGImage? {
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

        context.setShouldAntialias(quality.antialias && configuration.textureStyle != .pixel)
        context.interpolationQuality = configuration.textureStyle == .pixel ? .none : quality.interpolation

        let size = NSSize(width: clampedSize, height: clampedSize)
        context.clear(CGRect(origin: .zero, size: size))
        draw(configuration: configuration, in: CGRect(origin: .zero, size: size), context: context, quality: quality)

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

    public static func pngData(configuration: IconConfiguration, size: Int, quality: RenderQuality = .ultra) -> Data? {
        guard let cgImage = renderCGImage(configuration: configuration, size: size, quality: quality) else {
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

    private static func draw(configuration: IconConfiguration, in canvas: CGRect, context: CGContext, quality: RenderQuality) {
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

        drawAura(configuration: configuration, canvas: unitCanvas, context: context)
        drawShadow(configuration: configuration, bodyPath: bodyPath, tabPath: tabPath, context: context)
        GlowRenderer.drawGlow(in: context, paths: [bodyPath, tabPath], color: configuration.accentColor, intensity: configuration.glowIntensity)

        fill(path: tabPath, in: tabRect, context: context, primary: configuration.tabColor, accent: configuration.accentColor, palette: configuration.gradientColors, style: configuration.gradientStyle)
        fill(path: bodyPath, in: bodyRect, context: context, primary: configuration.baseColor, accent: configuration.accentColor, palette: configuration.gradientColors, style: configuration.gradientStyle)

        drawAccentBand(configuration: configuration, in: bodyRect, context: context)
        TextureRenderer.apply(style: configuration.textureStyle, in: context, rect: bodyRect, clippedTo: bodyPath, accentColor: configuration.accentColor)
        if quality != .draft {
            drawGlossOverlay(configuration: configuration, in: bodyRect, context: context)
        }
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

        let shadowMultiplier: CGFloat = {
            switch configuration.shadowStyle {
            case .soft: 0.75
            case .elevated: 1
            case .dramatic: 1.35
            case .long: 1.6
            case .pixel: 0.65
            }
        }()
        context.saveGState()
        context.setShadow(
            offset: CGSize(width: 0, height: -12 * configuration.shadowIntensity * Double(shadowMultiplier)),
            blur: 18 + CGFloat(configuration.shadowIntensity) * 26 * shadowMultiplier,
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
        palette suppliedPalette: [RGBAColor],
        style: GradientStyle
    ) {
        context.saveGState()
        context.addPath(path)
        context.clip()

        let palette = suppliedPalette.isEmpty ? currentPalette(primary: primary, accent: accent) : suppliedPalette
        let colors = palette.map(\.cgColor) as CFArray
        let locations = palette.indices.map { index in
            CGFloat(Double(index) / Double(max(palette.count - 1, 1)))
        }
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: locations)

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
            case .layered:
                context.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: rect.midX, y: rect.maxY),
                    end: CGPoint(x: rect.midX, y: rect.minY),
                    options: []
                )
                context.setFillColor(accent.withAlpha(0.22).cgColor)
                context.fill(CGRect(x: rect.minX + 12, y: rect.minY + 30, width: rect.width - 24, height: rect.height * 0.28))
            case .aurora:
                context.drawRadialGradient(
                    gradient,
                    startCenter: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.maxY),
                    startRadius: rect.width * 0.08,
                    endCenter: CGPoint(x: rect.maxX - rect.width * 0.2, y: rect.midY),
                    endRadius: rect.width * 0.82,
                    options: .drawsAfterEndLocation
                )
                context.setFillColor(RGBAColor.white.withAlpha(0.12).cgColor)
                context.fill(CGRect(x: rect.minX, y: rect.midY, width: rect.width, height: rect.height * 0.42))
            }
        } else {
            context.setFillColor(primary.cgColor)
            context.fill(rect)
        }

        context.restoreGState()
    }

    private static func currentPalette(primary: RGBAColor, accent: RGBAColor) -> [RGBAColor] {
        [primary.adjusted(brightness: 0.18), primary, primary.mixed(with: accent, amount: 0.36).adjusted(brightness: -0.08), accent.withAlpha(0.82)]
    }

    private static func drawAura(configuration: IconConfiguration, canvas: CGRect, context: CGContext) {
        guard configuration.glowStyle != .none, configuration.glowIntensity > 0.05 else { return }

        let alpha: Double = {
            switch configuration.glowStyle {
            case .none: 0
            case .soft: 0.12
            case .aura: 0.22
            case .neon: 0.3
            case .ember: 0.24
            case .cosmic: 0.28
            case .shadow: 0.2
            case .pixel: 0.1
            }
        }()

        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                configuration.accentColor.withAlpha(alpha * configuration.glowIntensity).cgColor,
                configuration.accentColor.withAlpha(0).cgColor
            ] as CFArray,
            locations: [0, 1]
        )

        if let gradient {
            context.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: canvas.midX, y: canvas.midY + 18),
                startRadius: 30,
                endCenter: CGPoint(x: canvas.midX, y: canvas.midY),
                endRadius: 230,
                options: .drawsAfterEndLocation
            )
        }
    }

    private static func drawGlossOverlay(configuration: IconConfiguration, in rect: CGRect, context: CGContext) {
        let overlay = CGMutablePath()
        overlay.move(to: CGPoint(x: rect.minX + 30, y: rect.maxY - 42))
        overlay.addCurve(
            to: CGPoint(x: rect.maxX - 26, y: rect.maxY - 72),
            control1: CGPoint(x: rect.minX + 140, y: rect.maxY - 5),
            control2: CGPoint(x: rect.maxX - 150, y: rect.maxY - 18)
        )
        overlay.addLine(to: CGPoint(x: rect.maxX - 62, y: rect.maxY - 116))
        overlay.addCurve(
            to: CGPoint(x: rect.minX + 46, y: rect.maxY - 84),
            control1: CGPoint(x: rect.maxX - 160, y: rect.maxY - 72),
            control2: CGPoint(x: rect.minX + 140, y: rect.maxY - 64)
        )
        overlay.closeSubpath()

        context.saveGState()
        context.addPath(overlay)
        context.setFillColor(RGBAColor.white.withAlpha(configuration.textureStyle == .matte ? 0.08 : 0.18).cgColor)
        context.fillPath()
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
