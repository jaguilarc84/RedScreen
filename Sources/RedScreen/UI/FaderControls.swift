import SwiftUI

/// Small decorative tick marks flanking a fader, alternating long/short
/// like a mixing-console scale. Purely cosmetic.
struct TickMarks: View {
    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<9, id: \.self) { index in
                Capsule()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: index.isMultiple(of: 2) ? 18 : 10, height: 2)
            }
        }
    }
}

/// A vertical fader with a hand-drawn thumb (a pill-shaped handle with a
/// colored grip line), since SwiftUI's native `Slider` has no public API to
/// restyle its knob and its default knob reads as barely-there on a dark
/// background. Tracks drags anywhere along the rail, not just on the thumb.
struct FaderSlider: View {
    let value: CGFloat
    let range: ClosedRange<CGFloat>
    let tint: Color
    let onChange: (CGFloat) -> Void

    private let trackLength: CGFloat = 170
    private let thumbWidth: CGFloat = 52
    private let thumbHeight: CGFloat = 30

    var body: some View {
        HStack(spacing: 10) {
            TickMarks()
            GeometryReader { geo in
                let height = geo.size.height
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 3)
                        .frame(maxWidth: .infinity)

                    thumb
                        .position(x: geo.size.width / 2, y: thumbCenterY(in: height))
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            updateValue(fromY: drag.location.y, height: height)
                        }
                )
            }
            .frame(width: thumbWidth, height: trackLength)
            TickMarks()
        }
    }

    private var thumb: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(white: 0.24))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .overlay(
                Capsule()
                    .fill(tint)
                    .frame(width: thumbWidth * 0.45, height: 3)
            )
            .frame(width: thumbWidth, height: thumbHeight)
            .shadow(color: .black.opacity(0.4), radius: 3, y: 2)
    }

    private func thumbCenterY(in height: CGFloat) -> CGFloat {
        let span = range.upperBound - range.lowerBound
        let fraction = span > 0 ? (value - range.lowerBound) / span : 0
        return (1 - fraction) * height
    }

    private func updateValue(fromY y: CGFloat, height: CGFloat) {
        guard height > 0 else { return }
        let span = range.upperBound - range.lowerBound
        let clampedY = min(max(y, 0), height)
        let fraction = 1 - (clampedY / height)
        onChange(range.lowerBound + fraction * span)
    }
}

/// The small LED-style readout under each fader (e.g. "6,406K", "100%").
struct ValueBadge: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.system(.callout, design: .monospaced).bold())
            .foregroundColor(tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.6))
            )
    }
}
