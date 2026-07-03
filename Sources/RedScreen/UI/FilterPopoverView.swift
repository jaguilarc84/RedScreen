import SwiftUI

struct FilterPopoverView: View {
    @ObservedObject var engine: FilterEngine
    let onOpenPreferences: () -> Void

    private let accentColor = Color(red: 1.0, green: 0.23, blue: 0.19)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            VStack(spacing: 14) {
                warmthRow
                brightnessRow
            }
            separator
            modePicker
            activateButton
        }
        .padding(18)
        .frame(width: 280)
        .background(Color(red: 0.09, green: 0.09, blue: 0.11))
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(engine.isEnabled ? accentColor : Color.gray.opacity(0.4))
                .frame(width: 8, height: 8)
                .padding(.top, 4)
            VStack(alignment: .leading, spacing: 1) {
                Text("RedScreen")
                    .font(.system(size: 13, weight: .semibold))
                Text("by Make It Happen LAB")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: onOpenPreferences) {
                Image(systemName: "gearshape")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
    }

    private var warmthRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("Calidez", systemImage: "flame.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(kelvinText(for: engine.warmth))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            Slider(
                value: Binding(get: { Double(engine.warmth) }, set: { engine.setWarmth(CGFloat($0)) }),
                in: 0...1
            )
            .tint(accentColor)
        }
    }

    private var brightnessRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("Brillo", systemImage: "sun.max.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(percentText(for: engine.brightness))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            Slider(
                value: Binding(get: { Double(engine.brightness) }, set: { engine.setBrightness(CGFloat($0)) }),
                in: 0.15...1
            )
            .tint(Color(white: 0.85))

            if engine.isEnabled && engine.brightness < 1.0 {
                Text("Atenuando por software, sin bajar el brillo real")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
    }

    private var separator: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 1)
    }

    private var modePicker: some View {
        Picker(
            "",
            selection: Binding(
                get: { engine.activeMode },
                set: { engine.selectMode($0) }
            )
        ) {
            Text("Día").tag(FilterMode.day)
            Text("Tarde").tag(FilterMode.evening)
            Text("Noche").tag(FilterMode.night)
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }

    private var activateButton: some View {
        Button(action: engine.toggle) {
            HStack(spacing: 8) {
                Image(systemName: engine.isEnabled ? "sun.min.fill" : "sun.max.fill")
                Text(engine.isEnabled ? "Desactivar filtro" : "Activar filtro")
                    .fontWeight(.semibold)
                Spacer()
                Text("\u{2303}\u{2325}Z")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .opacity(0.6)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .background(
            Capsule().fill(
                engine.isEnabled ? AnyShapeStyle(accentColor) : AnyShapeStyle(Color.white.opacity(0.08))
            )
        )
        .foregroundColor(engine.isEnabled ? .white : .primary)
    }

    private func kelvinText(for warmth: CGFloat) -> String {
        let kelvin = Int((6500 - warmth * 5500).rounded())
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        let formatted = formatter.string(from: NSNumber(value: kelvin)) ?? "\(kelvin)"
        return "\(formatted)K"
    }

    private func percentText(for brightness: CGFloat) -> String {
        "\(Int((brightness * 100).rounded()))%"
    }
}
