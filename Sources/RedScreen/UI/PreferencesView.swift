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

            Text("Atajo global: \u{2303}\u{2325}Z")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(width: 300, height: 220)
    }
}
