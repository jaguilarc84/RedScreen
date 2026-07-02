import SwiftUI

struct PreferencesView: View {
    @ObservedObject var engine: FilterEngine
    let preferences: PreferencesStore

    @State private var launchAtLogin: Bool

    init(preferences: PreferencesStore, engine: FilterEngine) {
        self.preferences = preferences
        self.engine = engine
        _launchAtLogin = State(initialValue: preferences.launchAtLogin)
    }

    var body: some View {
        Form {
            Toggle("Iniciar con macOS", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { newValue in
                    LaunchAtLogin.setEnabled(newValue)
                    preferences.launchAtLogin = newValue
                }

            Section("Monitores") {
                ForEach(engine.connectedDisplays) { display in
                    Toggle(display.name, isOn: Binding(
                        get: { !preferences.excludedDisplayIDs.contains(display.id) },
                        set: { isOn in engine.setExcludedDisplay(display.id, excluded: !isOn) }
                    ))
                }
            }

            Section("Modos") {
                ForEach([FilterMode.day, .evening, .night], id: \.self) { mode in
                    modeEditor(for: mode)
                }
            }

            Text("Atajo global: \u{2303}\u{2325}Z")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(width: 320, height: 460)
    }

    private func modeEditor(for mode: FilterMode) -> some View {
        let preset = engine.preset(for: mode)
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(mode.title)
                    .font(.subheadline.bold())
                Spacer()
                Button("Restablecer") {
                    engine.resetPreset(for: mode)
                }
                .font(.caption2)
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            LabeledSlider(title: "Calidez", value: preset.warmth, range: 0...1) { newValue in
                engine.updatePreset(warmth: newValue, brightness: preset.brightness, for: mode)
            }
            LabeledSlider(title: "Brillo", value: preset.brightness, range: 0.15...1) { newValue in
                engine.updatePreset(warmth: preset.warmth, brightness: newValue, for: mode)
            }
        }
        .padding(.vertical, 4)
    }
}
