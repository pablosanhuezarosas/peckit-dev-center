import AppKit

let size = 1024.0
let img = NSImage(size: NSSize(width: size, height: size))
img.lockFocus()

// Rounded black background (macOS will still apply its own mask, but this gives clean edges pre-mask)
let bgPath = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: size, height: size), xRadius: size * 0.22, yRadius: size * 0.22)
NSColor.black.setFill()
bgPath.fill()

let green = NSColor(calibratedRed: 0.22, green: 1.0, blue: 0.08, alpha: 1.0)

func filledRoundedRect(_ x: Double, _ y: Double, _ w: Double, _ h: Double, radius: Double, color: NSColor, alpha: Double = 1.0) {
    let path = NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h), xRadius: radius, yRadius: radius)
    color.withAlphaComponent(alpha).setFill()
    path.fill()
}

// Head outline
let headRect = NSRect(x: size * 0.16, y: size * 0.155, width: size * 0.68, height: size * 0.5)
let headPath = NSBezierPath(roundedRect: headRect, xRadius: size * 0.08, yRadius: size * 0.08)
headPath.lineWidth = size * 0.045
green.setStroke()
headPath.stroke()

// Eyes
filledRoundedRect(size * 0.335, size * 0.355, size * 0.12, size * 0.12, radius: size * 0.02, color: green)
filledRoundedRect(size * 0.545, size * 0.355, size * 0.12, size * 0.12, radius: size * 0.02, color: green)

// Mouth
filledRoundedRect(size * 0.33, size * 0.215, size * 0.34, size * 0.045, radius: size * 0.02, color: green)

// Antenna stem
filledRoundedRect(size * 0.485, size * 0.655, size * 0.03, size * 0.1, radius: 0, color: green)

// Antenna glow dot
let dotCenter = NSPoint(x: size * 0.5, y: size * 0.775)
let glow = NSBezierPath(ovalIn: NSRect(x: dotCenter.x - size * 0.065, y: dotCenter.y - size * 0.065, width: size * 0.13, height: size * 0.13))
green.withAlphaComponent(0.35).setFill()
glow.fill()
let dot = NSBezierPath(ovalIn: NSRect(x: dotCenter.x - size * 0.04, y: dotCenter.y - size * 0.04, width: size * 0.08, height: size * 0.08))
green.setFill()
dot.fill()

img.unlockFocus()

guard let tiff = img.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("failed to render icon")
}

let outputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon-1024.png"
try! png.write(to: URL(fileURLWithPath: outputPath))
print("wrote \(outputPath)")
