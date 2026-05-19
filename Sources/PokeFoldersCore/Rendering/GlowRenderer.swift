import CoreGraphics

public enum GlowRenderer {
    public static func drawGlow(
        in context: CGContext,
        paths: [CGPath],
        color: RGBAColor,
        intensity: Double
    ) {
        guard intensity > 0.01 else { return }

        context.saveGState()
        context.setShadow(
            offset: .zero,
            blur: CGFloat(20 + intensity * 44),
            color: color.withAlpha(0.25 + intensity * 0.35).cgColor
        )
        context.setFillColor(color.withAlpha(0.24 + intensity * 0.2).cgColor)
        for path in paths {
            context.addPath(path)
            context.fillPath()
        }
        context.restoreGState()
    }
}
