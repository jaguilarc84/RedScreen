import CoreGraphics

/// Extension point for real hardware-backlight brightness control on
/// external monitors via DDC/CI.
///
/// The warmth/brightness sliders already dim every display — built-in and
/// external — through `DisplayManager`'s gamma table, which is what keeps
/// CPU usage near zero and needs no special permissions. Actually lowering
/// an external monitor's backlight goes through DDC/CI, which on macOS means
/// talking to an undocumented, hardware-specific IOKit service
/// (`IOAVService` on Apple Silicon, raw I2C on Intel via IOFramebuffer).
/// That surface can't be verified without physical external displays to
/// test against, so it is intentionally left as a no-op extension point
/// rather than guessed at here. See README.md for pointers on wiring in a
/// DDC/CI backend (e.g. adapting the approach from the open-source
/// MonitorControl project).
final class ExternalDisplayBrightnessController {
    func setBrightness(_ value: CGFloat, excluding excluded: Set<CGDirectDisplayID>) {
        // No-op by design; see type documentation above.
    }
}
