import CoreGraphics
import Foundation
import ImageIO

public enum TypeBadgeRenderer {
    public static func drawBadge(
        configuration: IconConfiguration,
        in context: CGContext,
        canvas: CGRect
    ) {
        let badgeRect = rect(for: configuration.badgePosition, in: canvas)
        let scaledBadgeRect = badgeRect.scaledAboutCenter(by: CGFloat(configuration.customBadgeScale))
        let opacity = configuration.badgePosition == .watermark ? min(configuration.customBadgeOpacity, 0.26) : configuration.customBadgeOpacity

        if let data = configuration.customBadgeImageData,
           let source = CGImageSourceCreateWithData(data as CFData, nil),
           let image = CGImageSourceCreateImageAtIndex(source, 0, nil) {
            drawCustomBadge(image, in: scaledBadgeRect, context: context, opacity: opacity)
            return
        }

        drawElementBadge(configuration: configuration, rect: badgeRect, context: context)
    }

    private static func drawElementBadge(configuration: IconConfiguration, rect: CGRect, context: CGContext) {
        let isWatermark = configuration.badgePosition == .watermark
        let circle = CGPath(ellipseIn: rect, transform: nil)

        context.saveGState()
        context.addPath(circle)
        context.clip()

        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                configuration.accentColor.adjusted(brightness: 0.18).withAlpha(isWatermark ? 0.2 : 1).cgColor,
                configuration.accentColor.adjusted(brightness: -0.12).withAlpha(isWatermark ? 0.1 : 1).cgColor
            ] as CFArray,
            locations: [0, 1]
        )
        if let gradient {
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: rect.minX, y: rect.maxY),
                end: CGPoint(x: rect.maxX, y: rect.minY),
                options: []
            )
        }
        context.restoreGState()

        context.saveGState()
        context.addPath(circle)
        context.setLineWidth(isWatermark ? 5 : 3)
        context.setStrokeColor(RGBAColor.white.withAlpha(isWatermark ? 0.12 : 0.72).cgColor)
        context.strokePath()
        context.restoreGState()

        let foreground = configuration.accentColor.luminance < 0.45 ? RGBAColor.white : RGBAColor.black
        drawSymbol(
            configuration.elementType,
            in: rect.insetBy(dx: rect.width * 0.23, dy: rect.height * 0.23),
            color: foreground.withAlpha(isWatermark ? 0.2 : 0.94),
            context: context
        )
    }

    private static func drawCustomBadge(_ image: CGImage, in rect: CGRect, context: CGContext, opacity: Double) {
        context.saveGState()
        context.setAlpha(CGFloat(opacity))
        context.draw(image, in: rect)
        context.restoreGState()
    }

    private static func drawSymbol(_ element: ElementType, in rect: CGRect, color: RGBAColor, context: CGContext) {
        context.saveGState()
        context.setFillColor(color.cgColor)
        context.setStrokeColor(color.cgColor)
        context.setLineCap(.round)
        context.setLineJoin(.round)

        switch element {
        case .fire:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addCurve(to: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.minY + rect.height * 0.34), control1: CGPoint(x: rect.minX + rect.width * 0.05, y: rect.maxY - rect.height * 0.22), control2: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.58))
            path.addCurve(to: CGPoint(x: rect.midX, y: rect.minY), control1: CGPoint(x: rect.minX + rect.width * 0.22, y: rect.minY + rect.height * 0.12), control2: CGPoint(x: rect.minX + rect.width * 0.42, y: rect.minY))
            path.addCurve(to: CGPoint(x: rect.maxX - rect.width * 0.18, y: rect.minY + rect.height * 0.34), control1: CGPoint(x: rect.maxX - rect.width * 0.42, y: rect.minY), control2: CGPoint(x: rect.maxX - rect.width * 0.22, y: rect.minY + rect.height * 0.12))
            path.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control1: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.62), control2: CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.maxY - rect.height * 0.18))
            path.closeSubpath()
            context.addPath(path)
            context.fillPath()
        case .water:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addCurve(to: CGPoint(x: rect.minX + rect.width * 0.16, y: rect.minY + rect.height * 0.35), control1: CGPoint(x: rect.minX + rect.width * 0.24, y: rect.maxY - rect.height * 0.28), control2: CGPoint(x: rect.minX + rect.width * 0.16, y: rect.minY + rect.height * 0.56))
            path.addCurve(to: CGPoint(x: rect.midX, y: rect.minY), control1: CGPoint(x: rect.minX + rect.width * 0.16, y: rect.minY + rect.height * 0.12), control2: CGPoint(x: rect.minX + rect.width * 0.34, y: rect.minY))
            path.addCurve(to: CGPoint(x: rect.maxX - rect.width * 0.16, y: rect.minY + rect.height * 0.35), control1: CGPoint(x: rect.maxX - rect.width * 0.34, y: rect.minY), control2: CGPoint(x: rect.maxX - rect.width * 0.16, y: rect.minY + rect.height * 0.12))
            path.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control1: CGPoint(x: rect.maxX - rect.width * 0.16, y: rect.minY + rect.height * 0.56), control2: CGPoint(x: rect.maxX - rect.width * 0.24, y: rect.maxY - rect.height * 0.28))
            path.closeSubpath()
            context.addPath(path)
            context.fillPath()
        case .grass:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.minY + rect.height * 0.18))
            path.addCurve(to: CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.maxY - rect.height * 0.08), control1: CGPoint(x: rect.maxX - rect.width * 0.06, y: rect.minY + rect.height * 0.1), control2: CGPoint(x: rect.maxX, y: rect.maxY - rect.height * 0.32))
            path.addCurve(to: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.minY + rect.height * 0.18), control1: CGPoint(x: rect.maxX - rect.width * 0.38, y: rect.maxY), control2: CGPoint(x: rect.minX, y: rect.maxY - rect.height * 0.28))
            path.closeSubpath()
            context.addPath(path)
            context.fillPath()
            context.setLineWidth(rect.width * 0.08)
            context.move(to: CGPoint(x: rect.minX + rect.width * 0.22, y: rect.minY + rect.height * 0.2))
            context.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.18, y: rect.maxY - rect.height * 0.16))
            context.strokePath()
        case .electric:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: rect.maxX - rect.width * 0.26, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.22, y: rect.midY + rect.height * 0.05))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY + rect.height * 0.02))
            path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.34, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.14, y: rect.midY - rect.height * 0.02))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY))
            path.closeSubpath()
            context.addPath(path)
            context.fillPath()
        case .psychic:
            drawStar(in: rect, points: 8, innerScale: 0.42, context: context)
        case .dark:
            context.fillEllipse(in: rect)
            context.setBlendMode(.clear)
            context.fillEllipse(in: rect.offsetBy(dx: rect.width * 0.28, dy: rect.height * 0.12))
            context.setBlendMode(.normal)
        case .ghost:
            context.setLineWidth(rect.width * 0.1)
            context.strokeEllipse(in: rect.insetBy(dx: rect.width * 0.12, dy: rect.height * 0.28))
            context.fillEllipse(in: CGRect(x: rect.minX + rect.width * 0.34, y: rect.midY, width: rect.width * 0.12, height: rect.height * 0.12))
            context.fillEllipse(in: CGRect(x: rect.maxX - rect.width * 0.46, y: rect.midY, width: rect.width * 0.12, height: rect.height * 0.12))
        case .dragon:
            context.setLineWidth(rect.width * 0.12)
            context.move(to: CGPoint(x: rect.minX + rect.width * 0.16, y: rect.minY + rect.height * 0.28))
            context.addCurve(to: CGPoint(x: rect.maxX - rect.width * 0.18, y: rect.maxY - rect.height * 0.2), control1: CGPoint(x: rect.minX + rect.width * 0.52, y: rect.minY), control2: CGPoint(x: rect.maxX, y: rect.midY))
            context.strokePath()
            let wing = CGMutablePath()
            wing.move(to: CGPoint(x: rect.midX, y: rect.midY))
            wing.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.12, y: rect.midY + rect.height * 0.08))
            wing.addLine(to: CGPoint(x: rect.midX + rect.width * 0.16, y: rect.maxY - rect.height * 0.08))
            wing.closeSubpath()
            context.addPath(wing)
            context.fillPath()
        case .fairy:
            drawStar(in: rect, points: 5, innerScale: 0.45, context: context)
        }

        context.restoreGState()
    }

    private static func drawStar(in rect: CGRect, points: Int, innerScale: CGFloat, context: CGContext) {
        let path = CGMutablePath()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * innerScale
        let total = max(points * 2, 6)

        for index in 0..<total {
            let radius = index.isMultiple(of: 2) ? outer : inner
            let angle = (CGFloat(index) / CGFloat(total)) * CGFloat.pi * 2 + CGFloat.pi / 2
            let point = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        context.addPath(path)
        context.fillPath()
    }

    private static func rect(for position: BadgePosition, in canvas: CGRect) -> CGRect {
        switch position {
        case .center:
            return CGRect(x: canvas.midX - 78, y: canvas.midY - 62, width: 156, height: 156)
        case .topRight:
            return CGRect(x: canvas.maxX - 178, y: canvas.maxY - 182, width: 114, height: 114)
        case .bottomRight:
            return CGRect(x: canvas.maxX - 180, y: canvas.minY + 104, width: 116, height: 116)
        case .watermark:
            return CGRect(x: canvas.midX - 144, y: canvas.midY - 132, width: 288, height: 288)
        }
    }
}

private extension CGRect {
    func scaledAboutCenter(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return CGRect(
            x: midX - newWidth / 2,
            y: midY - newHeight / 2,
            width: newWidth,
            height: newHeight
        )
    }
}
