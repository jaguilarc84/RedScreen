import SwiftUI

struct LabeledSlider: View {
    let title: String
    let value: CGFloat
    let range: ClosedRange<CGFloat>
    let onChange: (CGFloat) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { onChange(CGFloat($0)) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound)
            )
        }
    }
}
