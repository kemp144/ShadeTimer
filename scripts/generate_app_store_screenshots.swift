import AppKit

struct Slide {
    let sourceFilename: String
    let outputFilename: String
    let eyebrow: String
    let title: String
    let body: String
    let titleFontSize: CGFloat
    let titleRect: NSRect
    let eyebrowRect: NSRect
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputDirectory = root.appendingPathComponent("app-store-screenshots", isDirectory: true)

let slides: [Slide] = [
    .init(
        sourceFilename: "Screenshot 2026-03-13 at 15.23.46.png",
        outputFilename: "ShadeTimer-App-Store-01.png",
        eyebrow: "DIGITAL WELLNESS",
        title: "Gentle screen\ndimming for\nmindful work",
        body: "Create a calm visual cue before a break. ShadeTimer softens the screen without interrupting your flow.",
        titleFontSize: 50,
        titleRect: NSRect(x: 88, y: 326, width: 480, height: 235),
        eyebrowRect: NSRect(x: 92, y: 548, width: 420, height: 32)
    ),
    .init(
        sourceFilename: "Screenshot 2026-03-13 at 15.23.55.png",
        outputFilename: "ShadeTimer-App-Store-02.png",
        eyebrow: "FOCUSED RHYTHM",
        title: "Choose the right\nmoment to pause",
        body: "Pick quick presets or custom minutes and let your Mac signal when it is time to rest your eyes.",
        titleFontSize: 54,
        titleRect: NSRect(x: 88, y: 380, width: 480, height: 180),
        eyebrowRect: NSRect(x: 92, y: 558, width: 420, height: 28)
    ),
    .init(
        sourceFilename: "Screenshot 2026-03-13 at 15.24.06.png",
        outputFilename: "ShadeTimer-App-Store-03.png",
        eyebrow: "FINE-TUNED COMFORT",
        title: "Adjust dim level\nand fade duration",
        body: "Shape the experience around your workspace with smooth transitions, gentle overlays, and distraction-free controls.",
        titleFontSize: 54,
        titleRect: NSRect(x: 88, y: 380, width: 480, height: 180),
        eyebrowRect: NSRect(x: 92, y: 558, width: 420, height: 28)
    ),
    .init(
        sourceFilename: "Screenshot 2026-03-13 at 15.24.20.png",
        outputFilename: "ShadeTimer-App-Store-04.png",
        eyebrow: "END THE DAY SOFTLY",
        title: "Wind down with a\nserene desktop\nritual",
        body: "Track the remaining time, dim every display gradually, and ease into a healthier computer routine.",
        titleFontSize: 50,
        titleRect: NSRect(x: 88, y: 326, width: 480, height: 235),
        eyebrowRect: NSRect(x: 92, y: 548, width: 420, height: 32)
    )
]

let canvasSize = NSSize(width: 1280, height: 800)

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> NSColor {
    NSColor(calibratedRed: r / 255, green: g / 255, blue: b / 255, alpha: a)
}

func paragraphStyle(lineSpacing: CGFloat = 0, alignment: NSTextAlignment = .left) -> NSParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.lineSpacing = lineSpacing
    style.alignment = alignment
    return style
}

func drawText(_ text: String, in rect: NSRect, font: NSFont, color: NSColor, lineSpacing: CGFloat = 0, alignment: NSTextAlignment = .left) {
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraphStyle(lineSpacing: lineSpacing, alignment: alignment)
    ]
    text.draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes)
}

func fillBackground(in rect: NSRect) {
    let gradient = NSGradient(colors: [
        color(13, 17, 30),
        color(33, 28, 43),
        color(63, 45, 37)
    ])!
    gradient.draw(in: rect, angle: -18)

    let glowColors: [NSColor] = [
        color(255, 167, 61, 0.34),
        color(255, 167, 61, 0.02)
    ]
    let orangeGlow = NSGradient(colors: glowColors)!
    orangeGlow.draw(in: NSBezierPath(ovalIn: NSRect(x: 720, y: 360, width: 460, height: 320)), relativeCenterPosition: .zero)

    let tealGlow = NSGradient(colors: [
        color(73, 198, 222, 0.22),
        color(73, 198, 222, 0.01)
    ])!
    tealGlow.draw(in: NSBezierPath(ovalIn: NSRect(x: 660, y: 140, width: 420, height: 260)), relativeCenterPosition: .zero)

    for index in 0..<10 {
        let alpha = CGFloat(0.025 + (Double(index) * 0.004))
        color(255, 255, 255, alpha).setStroke()
        let path = NSBezierPath()
        path.lineWidth = 1
        let y = CGFloat(index) * 68 - 30
        path.move(to: NSPoint(x: -20, y: y))
        path.curve(to: NSPoint(x: 1300, y: y + 20),
                   controlPoint1: NSPoint(x: 320, y: y + 50),
                   controlPoint2: NSPoint(x: 900, y: y - 40))
        path.stroke()
    }
}

func drawBadge(title: String, in rect: NSRect) {
    let badge = NSBezierPath(roundedRect: rect, xRadius: rect.height / 2, yRadius: rect.height / 2)
    color(255, 255, 255, 0.11).setFill()
    badge.fill()
    color(255, 255, 255, 0.18).setStroke()
    badge.lineWidth = 1
    badge.stroke()

    drawText(
        title,
        in: rect.insetBy(dx: 16, dy: 7),
        font: NSFont.systemFont(ofSize: 16, weight: .semibold),
        color: color(255, 244, 226, 0.96)
    )
}

func drawIcon(at rect: NSRect) {
    let bg = NSBezierPath(roundedRect: rect, xRadius: 22, yRadius: 22)
    color(255, 255, 255, 0.08).setFill()
    bg.fill()

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowBlurRadius = 28
    shadow.shadowOffset = .zero
    shadow.shadowColor = color(255, 178, 76, 0.30)
    shadow.set()

    let sunCenter = NSPoint(x: rect.midX - 2, y: rect.midY + 6)
    let sunRect = NSRect(x: sunCenter.x - 36, y: sunCenter.y - 36, width: 72, height: 72)
    NSGradient(colors: [color(255, 177, 32), color(255, 113, 0)])!.draw(in: NSBezierPath(ovalIn: sunRect), relativeCenterPosition: .zero)

    let dialRect = NSRect(x: rect.midX - 46, y: rect.midY - 44, width: 96, height: 96)
    let dialPath = NSBezierPath()
    dialPath.appendArc(withCenter: NSPoint(x: dialRect.midX, y: dialRect.midY), radius: 46, startAngle: 220, endAngle: 28, clockwise: false)
    dialPath.lineWidth = 20
    color(34, 159, 255, 0.98).setStroke()
    dialPath.stroke()

    let needle = NSBezierPath()
    needle.move(to: NSPoint(x: dialRect.midX, y: dialRect.midY))
    needle.line(to: NSPoint(x: dialRect.midX + 34, y: dialRect.midY + 26))
    needle.lineWidth = 8
    needle.lineCapStyle = .round
    color(74, 235, 155, 0.98).setStroke()
    needle.stroke()
    NSGraphicsContext.restoreGraphicsState()
}

func drawScreenshotCard(image: NSImage, in rect: NSRect) {
    let shadow = NSShadow()
    shadow.shadowBlurRadius = 40
    shadow.shadowOffset = NSSize(width: 0, height: -16)
    shadow.shadowColor = color(0, 0, 0, 0.36)

    NSGraphicsContext.saveGraphicsState()
    shadow.set()
    let framePath = NSBezierPath(roundedRect: rect, xRadius: 34, yRadius: 34)
    color(20, 24, 35, 0.90).setFill()
    framePath.fill()
    NSGraphicsContext.restoreGraphicsState()

    let frameStroke = NSBezierPath(roundedRect: rect, xRadius: 34, yRadius: 34)
    color(255, 255, 255, 0.10).setStroke()
    frameStroke.lineWidth = 1
    frameStroke.stroke()

    let inset = rect.insetBy(dx: 18, dy: 18)
    let titleBarRect = NSRect(x: inset.minX, y: inset.maxY - 34, width: inset.width, height: 22)
    for (offset, dotColor) in [color(255, 95, 87), color(255, 189, 46), color(39, 201, 63)].enumerated() {
        dotColor.setFill()
        NSBezierPath(ovalIn: NSRect(x: titleBarRect.minX + CGFloat(offset) * 18, y: titleBarRect.minY + 4, width: 10, height: 10)).fill()
    }

    let imageRect = NSRect(x: inset.minX, y: inset.minY, width: inset.width, height: inset.height - 28)
    let sourceSize = image.size
    let scale = min(imageRect.width / sourceSize.width, imageRect.height / sourceSize.height)
    let drawSize = NSSize(width: sourceSize.width * scale, height: sourceSize.height * scale)
    let drawRect = NSRect(
        x: imageRect.midX - drawSize.width / 2,
        y: imageRect.midY - drawSize.height / 2,
        width: drawSize.width,
        height: drawSize.height
    )

    let clipPath = NSBezierPath(roundedRect: imageRect, xRadius: 24, yRadius: 24)
    clipPath.addClip()
    image.draw(in: drawRect)

    NSGradient(colors: [
        color(255, 173, 97, 0.10),
        color(255, 173, 97, 0.03),
        color(255, 173, 97, 0.10)
    ])!.draw(in: imageRect, angle: -70)
}

func render(slide: Slide) throws {
    let sourceURL = root.appendingPathComponent(slide.sourceFilename)
    guard let image = NSImage(contentsOf: sourceURL) else {
        throw NSError(domain: "ScreenshotGenerator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing source image: \(slide.sourceFilename)"])
    }

    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(canvasSize.width),
        pixelsHigh: Int(canvasSize.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "ScreenshotGenerator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to allocate bitmap for \(slide.outputFilename)"])
    }

    NSGraphicsContext.saveGraphicsState()
    guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        throw NSError(domain: "ScreenshotGenerator", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unable to create drawing context for \(slide.outputFilename)"])
    }
    NSGraphicsContext.current = context

    let bounds = NSRect(origin: .zero, size: canvasSize)
    fillBackground(in: bounds)

    drawIcon(at: NSRect(x: 88, y: 628, width: 112, height: 112))
    drawBadge(title: "ShadeTimer", in: NSRect(x: 216, y: 675, width: 154, height: 38))
    drawText(
        slide.eyebrow,
        in: slide.eyebrowRect,
        font: NSFont.systemFont(ofSize: 16, weight: .bold),
        color: color(255, 199, 140, 0.94)
    )
    drawText(
        slide.title,
        in: slide.titleRect,
        font: NSFont.systemFont(ofSize: slide.titleFontSize, weight: .bold),
        color: color(251, 247, 239),
        lineSpacing: 3
    )
    drawText(
        slide.body,
        in: NSRect(x: 92, y: 250, width: 410, height: 110),
        font: NSFont.systemFont(ofSize: 25, weight: .regular),
        color: color(233, 224, 213, 0.92),
        lineSpacing: 6
    )

    let accentLine = NSBezierPath(roundedRect: NSRect(x: 92, y: 220, width: 220, height: 6), xRadius: 3, yRadius: 3)
    color(96, 180, 255, 0.9).setFill()
    accentLine.fill()

    drawBadge(title: "Mindful Mac routine", in: NSRect(x: 92, y: 152, width: 212, height: 42))

    drawScreenshotCard(image: image, in: NSRect(x: 566, y: 74, width: 644, height: 652))
    NSGraphicsContext.restoreGraphicsState()

    let outputURL = outputDirectory.appendingPathComponent(slide.outputFilename)
    guard let png = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "ScreenshotGenerator", code: 4, userInfo: [NSLocalizedDescriptionKey: "Unable to encode \(slide.outputFilename)"])
    }
    try png.write(to: outputURL)
}

try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

for slide in slides {
    try render(slide: slide)
    print("Generated \(slide.outputFilename)")
}
