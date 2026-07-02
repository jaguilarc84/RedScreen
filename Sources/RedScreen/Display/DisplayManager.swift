import AppKit
import CoreGraphics

/// Applies/reverts the warmth+brightness filter through the per-display
/// gamma table (`CGSetDisplayTransferByFormula`), the same public API Night
/// Shift uses. Because it rewrites the color LUT rather than compositing an
/// overlay, it costs effectively no CPU once set, and screen captures /
/// video calls read the framebuffer before the LUT is applied, so they come
/// out untinted.
enum DisplayManager {
    static func activeDisplayIDs() -> [CGDirectDisplayID] {
        var displayCount: UInt32 = 0
        guard CGGetActiveDisplayList(0, nil, &displayCount) == .success, displayCount > 0 else { return [] }
        var displayIDs = [CGDirectDisplayID](repeating: 0, count: Int(displayCount))
        guard CGGetActiveDisplayList(displayCount, &displayIDs, &displayCount) == .success else { return [] }
        return displayIDs
    }

    static func apply(warmth: CGFloat, brightness: CGFloat, to displayID: CGDirectDisplayID) {
        let parameters = GammaFilter.parameters(warmth: warmth, brightness: brightness)
        CGSetDisplayTransferByFormula(
            displayID,
            0.0, parameters.redMax, 1.0,
            0.0, parameters.greenMax, 1.0,
            0.0, parameters.blueMax, 1.0
        )
    }

    static func reset(displayID: CGDirectDisplayID) {
        CGSetDisplayTransferByFormula(displayID, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0)
    }

    static func restoreAll() {
        CGDisplayRestoreColorSyncSettings()
    }

    static func name(for displayID: CGDirectDisplayID) -> String {
        for screen in NSScreen.screens {
            if let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber,
               CGDirectDisplayID(number.uint32Value) == displayID {
                return screen.localizedName
            }
        }
        return "Pantalla \(displayID)"
    }
}
