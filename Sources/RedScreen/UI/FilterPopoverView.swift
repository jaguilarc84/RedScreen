import SwiftUI

struct FilterPopoverView: View {
    @ObservedObject var engine: FilterEngine
    let onOpenPreferences: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            header
            zapButton
            slidersSection
            modeButtons
            footer
        }
        .padding(16)
        .frame(width: 280)
    }

    private var header: some View {
        HStack {
            Text("RedScreen")
                .font(.headline)
            Spacer()
            Text(engine.isEnabled ? "Activo" : "Desactivado")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var zapButton: some View {
        Button(action: engine.toggle) {
            Text("ZAP")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .frame(width: 84, height: 84)
                .background(
                    Circle().fill(
                        LinearGradient(
                            colors: engine.isEnabled
                                ? [.pink, .purple]
                                : [Color.gray.opacity(0.35), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                )
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }

    private var slidersSection: some View {
        VStack(spacing: 12) {
            sliderRow(title: "CALIDEZ", value: engine.warmth, range: 0...1) { engine.setWarmth($0) }
            sliderRow(title: "BRILLO", value: engine.brightness, range: 0.15...1) { engine.setBrightness($0) }
        }
    }

    private func sliderRow(
        title: String,
        value: CGFloat,
        range: ClosedRange<CGFloat>,
        onChange: @escaping (CGFloat) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { onChange(CGFloat($0)) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound)
            )
        }
    }

    private var modeButtons: some View {
        HStack(spacing: 8) {
            ForEach([FilterMode.day, .evening, .night], id: \.self) { mode in
                Button(mode.title.uppercased()) {
                    engine.selectMode(mode)
                }
                .buttonStyle(.bordered)
                .tint(engine.activeMode == mode ? .accentColor : .gray)
            }
        }
    }

    private var footer: some View {
        HStack {
            Text("\u{2303}\u{2325}Z activa/desactiva")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: onOpenPreferences) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
        }
    }
}
