import SwiftUI

struct FilterPopoverView: View {
    @ObservedObject var engine: FilterEngine
    let onOpenPreferences: () -> Void

    private let warmthColor = Color(red: 0.95, green: 0.38, blue: 0.27)

    var body: some View {
        VStack(spacing: 18) {
            header
            slidersSection
            pwmStatusRow
            modeButtons
            activateButton
            Text("\u{2303}\u{2325}Z activa/desactiva")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(width: 320)
        .background(Color(red: 0.08, green: 0.08, blue: 0.10))
    }

    private var header: some View {
        HStack {
            Spacer()
            Button(action: onOpenPreferences) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
    }

    private var slidersSection: some View {
        HStack(spacing: 40) {
            VStack(spacing: 14) {
                Text("CALIDEZ")
                    .font(.headline)
                    .foregroundColor(warmthColor)
                FaderSlider(value: engine.warmth, range: 0...1, tint: warmthColor) {
                    engine.setWarmth($0)
                }
                ValueBadge(text: kelvinText(for: engine.warmth), tint: warmthColor)
            }
            VStack(spacing: 14) {
                Text("BRILLO")
                    .font(.headline)
                    .foregroundColor(.white)
                FaderSlider(value: engine.brightness, range: 0.15...1, tint: .white) {
                    engine.setBrightness($0)
                }
                ValueBadge(text: percentText(for: engine.brightness), tint: .white)
            }
        }
    }

    private var pwmStatusRow: some View {
        let softwareDimmingActive = engine.isEnabled && engine.brightness < 1.0
        return HStack {
            Circle()
                .fill(softwareDimmingActive ? Color.green : Color.gray.opacity(0.5))
                .frame(width: 8, height: 8)
            Text("MODO SEGURO PWM")
                .font(.caption2.bold())
                .foregroundColor(.secondary)
            Spacer()
            Text(softwareDimmingActive ? "ENCENDIDO" : "APAGADO")
                .font(.caption2.bold())
                .foregroundColor(softwareDimmingActive ? .green : .secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.05)))
    }

    private var modeButtons: some View {
        HStack(spacing: 10) {
            ForEach([FilterMode.day, .evening, .night], id: \.self) { mode in
                Button(mode.title.uppercased()) {
                    engine.selectMode(mode)
                }
                .font(.caption.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(engine.activeMode == mode ? Color.white.opacity(0.16) : Color.white.opacity(0.05))
                )
                .foregroundColor(engine.activeMode == mode ? .white : .secondary)
                .buttonStyle(.plain)
            }
        }
    }

    private var activateButton: some View {
        Button(action: engine.toggle) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                Text(engine.isEnabled ? "DESACTIVAR" : "ACTIVAR")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    engine.isEnabled
                        ? AnyShapeStyle(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing))
                        : AnyShapeStyle(Color.white.opacity(0.08))
                )
        )
        .foregroundColor(engine.isEnabled ? .white : .secondary)
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
