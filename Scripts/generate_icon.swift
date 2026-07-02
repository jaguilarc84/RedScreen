#!/usr/bin/env swift
// Genera AppIcon.iconset/ con todos los tamaños que macOS necesita para un
// ícono de app. Corre esto en un Mac (usa AppKit, no compila en Linux):
//
//   swift Scripts/generate_icon.swift
//   iconutil -c icns AppIcon.iconset -o Resources/AppIcon.icns
//
// Luego reconstruye la app con Scripts/build_app.sh, que copia
// Resources/AppIcon.icns al bundle si existe.

import AppKit

let sizes: [(pixels: Int, name: String)] = [
    (16, "icon_16x16"),
    (32, "icon_16x16@2x"),
    (32, "icon_32x32"),
    (64, "icon_32x32@2x"),
    (128, "icon_128x128"),
    (256, "icon_128x128@2x"),
    (256, "icon_256x256"),
    (512, "icon_256x256@2x"),
    (512, "icon_512x512"),
    (1024, "icon_512x512@2x"),
]

func tintedImage(_ image: NSImage, color: NSColor) -> NSImage {
    let tinted = NSImage(size: image.size)
    tinted.lockFocus()
    let imageRect = NSRect(origin: .zero, size: image.size)
    image.draw(in: imageRect, from: .zero, operation: .sourceOver, fraction: 1.0)
    color.set()
    imageRect.fill(using: .sourceAtop)
    tinted.unlockFocus()
    return tinted
}

func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    let cornerRadius = size * 0.22
    NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius).addClip()

    let context = NSGraphicsContext.current!.cgContext
    let colors = [
        NSColor(calibratedRed: 0.95, green: 0.25, blue: 0.35, alpha: 1).cgColor,
        NSColor(calibratedRed: 0.55, green: 0.15, blue: 0.60, alpha: 1).cgColor,
    ]
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1])!
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: 0, y: size),
        end: CGPoint(x: size, y: 0),
        options: []
    )

    if let sun = NSImage(systemSymbolName: "sun.max.fill", accessibilityDescription: nil) {
        let config = NSImage.SymbolConfiguration(pointSize: size * 0.46, weight: .semibold)
        let configured = sun.withSymbolConfiguration(config) ?? sun
        let white = tintedImage(configured, color: .white)
        let sunSize = white.size
        let sunRect = CGRect(
            x: (size - sunSize.width) / 2,
            y: (size - sunSize.height) / 2,
            width: sunSize.width,
            height: sunSize.height
        )
        white.draw(in: sunRect, from: .zero, operation: .sourceOver, fraction: 1.0)
    }

    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, size: Int, to url: URL) {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(x: 0, y: 0, width: size, height: size))
    NSGraphicsContext.restoreGraphicsState()

    guard let png = rep.representation(using: .png, properties: [:]) else {
        fatalError("No se pudo generar PNG para \(url.lastPathComponent)")
    }
    try? png.write(to: url)
}

let outputDir = URL(fileURLWithPath: "AppIcon.iconset")
try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

for entry in sizes {
    let image = drawIcon(size: CGFloat(entry.pixels))
    let url = outputDir.appendingPathComponent("\(entry.name).png")
    savePNG(image, size: entry.pixels, to: url)
    print("Generado \(url.lastPathComponent)")
}

print("\nListo. Ahora corre:")
print("  iconutil -c icns AppIcon.iconset -o Resources/AppIcon.icns")
