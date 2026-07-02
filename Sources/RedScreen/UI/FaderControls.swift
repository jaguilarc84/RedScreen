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

/// A vertical fader (SwiftUI's Slider is horizontal-only on macOS, so this
/// rotates one -90° and re-constrains its layout box to read as vertical,
/// with the minimum at the bottom and the maximum at the top).
struct FaderSlider: View {
    let value: CGFloat
    let range: ClosedRange<CGFloat>
    let tint: Color
    let onChange: (CGFloat) -> Void

    private let trackLength: CGFloat = 170

    var body: some View {
        HStack(spacing: 10) {
            TickMarks()
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { onChange(CGFloat($0)) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound)
            )
            .tint(tint)
            .frame(width: trackLength)
            .rotationEffect(.degrees(-90))
            .frame(width: 28, height: trackLength)
            TickMarks()
        }
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
