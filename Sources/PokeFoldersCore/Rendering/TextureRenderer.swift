import CoreGraphics

public enum TextureRenderer {
    public static func apply(
        style: TextureStyle,
        in context: CGContext,
        rect: CGRect,
        clippedTo path: CGPath,
        accentColor: RGBAColor
    ) {
        context.saveGState()
        context.addPath(path)
        context.clip()

        switch style {
        case .glossy:
            drawGloss(in: context, rect: rect)
        case .matte:
            drawMatteLines(in: context, rect: rect, accentColor: accentColor)
        case .glass:
            drawGlass(in: context, rect: rect)
        case .pixel:
            drawPixelGrid(in: context, rect: rect, accentColor: accentColor)
        }

        context.restoreGState()
    }

    private static func drawGloss(in context: CGContext, rect: CGRect) {
        let highlightRect = CGRect(
            x: rect.minX + rect.width * 0.08,
            y: rect.minY + rect.height * 0.53,
            width: rect.width * 0.84,
            height: rect.height * 0.37
        )

        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                RGBAColor.white.withAlpha(0.46).cgColor,
                RGBAColor.white.withAlpha(0.05).cgColor
            ] as CFArray,
            locations: [0, 1]
        )

        context.saveGState()
        context.addEllipse(in: highlightRect)
        context.clip()
        if let gradient {
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: highlightRect.midX, y: highlightRect.maxY),
                end: CGPoint(x: highlightRect.midX, y: highlightRect.minY),
                options: []
            )
        }
        context.restoreGState()
    }

    private static func drawMatteLines(in context: CGContext, rect: CGRect, accentColor: RGBAColor) {
        context.setLineWidth(1)
        context.setStrokeColor(accentColor.withAlpha(0.12).cgColor)
        var y = rect.minY + 18
        while y < rect.maxY {
            context.move(to: CGPoint(x: rect.minX + 24, y: y))
            context.addLine(to: CGPoint(x: rect.maxX - 24, y: y + 10))
            y += 18
        }
        context.strokePath()
    }

    private static func drawGlass(in context: CGContext, rect: CGRect) {
        context.setStrokeColor(RGBAColor.white.withAlpha(0.38).cgColor)
        context.setLineWidth(3)
        context.stroke(CGRect(x: rect.minX + 18, y: rect.minY + 18, width: rect.width - 36, height: rect.height - 36))

        let stripe = CGMutablePath()
        stripe.move(to: CGPoint(x: rect.minX + 44, y: rect.maxY - 26))
        stripe.addLine(to: CGPoint(x: rect.maxX - 58, y: rect.maxY - 78))
        stripe.addLine(to: CGPoint(x: rect.maxX - 78, y: rect.maxY - 110))
        stripe.addLine(to: CGPoint(x: rect.minX + 60, y: rect.maxY - 58))
        stripe.closeSubpath()
        context.addPath(stripe)
        context.setFillColor(RGBAColor.white.withAlpha(0.18).cgColor)
        context.fillPath()
    }

    private static func drawPixelGrid(in context: CGContext, rect: CGRect, accentColor: RGBAColor) {
        let cell: CGFloat = max(8, floor(rect.width / 28))
        var y = rect.minY
        var row = 0
        while y < rect.maxY {
            var x = rect.minX
            var column = 0
            while x < rect.maxX {
                if (row + column) % 5 == 0 {
                    context.setFillColor(accentColor.withAlpha(0.18).cgColor)
                    context.fill(CGRect(x: x, y: y, width: cell, height: cell))
                }
                x += cell
                column += 1
            }
            y += cell
            row += 1
        }
    }
}
