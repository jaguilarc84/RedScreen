import CoreGraphics
import Foundation

/// Turns a warmth/brightness pair into per-channel gamma-table maxima.
///
/// Warmth drives blue and green towards zero at different rates so the
/// transition reads as daylight -> warm white -> orange -> pure red, fully
/// removing blue at warmth == 1 (the "0K / 100% blue blocked" claim).
/// Brightness scales all three channels together, which dims the screen
/// through the color LUT instead of the backlight.
enum GammaFilter {
    struct Parameters {
        let redMax: CGGammaValue
        let greenMax: CGGammaValue
        let blueMax: CGGammaValue
    }

    static func parameters(warmth: CGFloat, brightness: CGFloat) -> Parameters {
        let w = min(max(warmth, 0), 1)
        let b = min(max(brightness, 0.1), 1)

        let blueMax = (1 - pow(w, 0.8)) * b
        let greenMax = (1 - pow(w, 1.6)) * b
        let redMax = b

        return Parameters(
            redMax: CGGammaValue(redMax),
            greenMax: CGGammaValue(greenMax),
            blueMax: CGGammaValue(blueMax)
        )
    }
}
