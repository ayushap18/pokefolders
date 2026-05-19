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
        case .brushed:
            drawBrushedLines(in: context, rect: rect, accentColor: accentColor)
        case .aura:
            drawAuraSpeckles(in: context, rect: rect, accentColor: accentColor)
        case .crystalline:
            drawCrystalFacets(in: context, rect: rect, accentColor: accentColor)
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

    private static func drawBrushedLines(in context: CGContext, rect: CGRect, accentColor: RGBAColor) {
        context.setLineWidth(1.4)
        var y = rect.minY + 14
        var index = 0
        while y < rect.maxY - 10 {
            context.setStrokeColor(accentColor.withAlpha(index.isMultiple(of: 2) ? 0.16 : 0.08).cgColor)
            context.move(to: CGPoint(x: rect.minX + 24, y: y))
            context.addLine(to: CGPoint(x: rect.maxX - 32, y: y + 5))
            context.strokePath()
            y += 11
            index += 1
        }
    }

    private static func drawAuraSpeckles(in context: CGContext, rect: CGRect, accentColor: RGBAColor) {
        let points: [(CGFloat, CGFloat, CGFloat)] = [
            (0.18, 0.24, 5), (0.32, 0.7, 3), (0.62, 0.22, 4), (0.78, 0.58, 6),
            (0.46, 0.46, 3), (0.88, 0.3, 3), (0.24, 0.52, 4), (0.58, 0.78, 5)
        ]
        for point in points {
            let dot = CGRect(
                x: rect.minX + rect.width * point.0,
                y: rect.minY + rect.height * point.1,
                width: point.2,
                height: point.2
            )
            context.setFillColor(accentColor.withAlpha(0.22).cgColor)
            context.fillEllipse(in: dot)
        }
    }

    private static func drawCrystalFacets(in context: CGContext, rect: CGRect, accentColor: RGBAColor) {
        let facets = [
            [CGPoint(x: 0.1, y: 0.16), CGPoint(x: 0.42, y: 0.3), CGPoint(x: 0.2, y: 0.62)],
            [CGPoint(x: 0.43, y: 0.28), CGPoint(x: 0.82, y: 0.2), CGPoint(x: 0.68, y: 0.56)],
            [CGPoint(x: 0.28, y: 0.7), CGPoint(x: 0.65, y: 0.58), CGPoint(x: 0.86, y: 0.86)]
        ]
        for (index, facet) in facets.enumerated() {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: rect.minX + rect.width * facet[0].x, y: rect.minY + rect.height * facet[0].y))
            for point in facet.dropFirst() {
                path.addLine(to: CGPoint(x: rect.minX + rect.width * point.x, y: rect.minY + rect.height * point.y))
            }
            path.closeSubpath()
            context.addPath(path)
            context.setFillColor((index.isMultiple(of: 2) ? RGBAColor.white : accentColor).withAlpha(0.16).cgColor)
            context.fillPath()
        }
    }
}
