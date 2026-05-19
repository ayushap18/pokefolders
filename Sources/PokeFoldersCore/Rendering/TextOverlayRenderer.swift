import CoreGraphics
import CoreText
import Foundation

public enum TextOverlayRenderer {
    public static func drawText(_ text: String, configuration: IconConfiguration, in canvas: CGRect, context: CGContext) {
        let trimmed = String(text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(8))
        guard !trimmed.isEmpty else { return }

        let foreground = configuration.baseColor.luminance < 0.45 ? RGBAColor.white : RGBAColor.black
        let fontSize = canvas.width * 0.084
        let font = CTFontCreateWithName("Helvetica-Bold" as CFString, fontSize, nil)
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(kCTFontAttributeName as String): font,
            NSAttributedString.Key(kCTForegroundColorAttributeName as String): foreground.withAlpha(0.92).cgColor
        ]
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: trimmed.uppercased(), attributes: attributes))
        let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)

        let rect = CGRect(
            x: canvas.minX + canvas.width * 0.18,
            y: canvas.minY + canvas.height * 0.18,
            width: canvas.width * 0.64,
            height: fontSize * 1.45
        )

        context.saveGState()
        context.setShadow(
            offset: CGSize(width: 0, height: -2),
            blur: 8 * configuration.shadowIntensity,
            color: RGBAColor.black.withAlpha(0.22 + configuration.shadowIntensity * 0.3).cgColor
        )
        context.textMatrix = .identity
        context.textPosition = CGPoint(
            x: rect.midX - bounds.width / 2 - bounds.minX,
            y: rect.midY - bounds.height / 2 - bounds.minY
        )
        CTLineDraw(line, context)
        context.restoreGState()
    }
}
