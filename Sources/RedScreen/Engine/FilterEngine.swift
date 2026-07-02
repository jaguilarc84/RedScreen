import AppKit
import Combine

/// Owns the current filter state, persists it, and pushes it to every
/// connected display. Nothing runs on a timer outside of the ~0.6s preset
/// transitions, which is how the app stays under 1% CPU while idle.
final class FilterEngine: ObservableObject {
    @Published private(set) var isEnabled: Bool
    @Published private(set) var warmth: CGFloat
    @Published private(set) var brightness: CGFloat
    @Published private(set) var activeMode: FilterMode

    struct ConnectedDisplay: Identifiable {
        let id: CGDirectDisplayID
        let name: String
    }

    var connectedDisplays: [ConnectedDisplay] {
        DisplayManager.activeDisplayIDs().map { ConnectedDisplay(id: $0, name: DisplayManager.name(for: $0)) }
    }

    private let preferences: PreferencesStore
    private let externalBrightness = ExternalDisplayBrightnessController()
    private var transitionTimer: Timer?
    private var screenObserver: NSObjectProtocol?

    init(preferences: PreferencesStore = .shared) {
        self.preferences = preferences
        self.isEnabled = preferences.isEnabled
        self.warmth = preferences.warmth
        self.brightness = preferences.brightness
        self.activeMode = preferences.activeMode

        applyCurrentState()

        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyCurrentState()
        }
    }

    deinit {
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
        }
    }

    func toggle() {
        isEnabled.toggle()
        preferences.isEnabled = isEnabled
        applyCurrentState()
    }

    func setWarmth(_ value: CGFloat) {
        warmth = value
        activeMode = .custom
        preferences.warmth = value
        preferences.activeMode = .custom
        applyCurrentState()
    }

    func setBrightness(_ value: CGFloat) {
        brightness = value
        activeMode = .custom
        preferences.brightness = value
        preferences.activeMode = .custom
        applyCurrentState()
    }

    func selectMode(_ mode: FilterMode) {
        guard mode != .custom else { return }
        activeMode = mode
        preferences.activeMode = mode
        animateTransition(to: mode.preset)
    }

    func setExcludedDisplay(_ displayID: CGDirectDisplayID, excluded: Bool) {
        var ids = preferences.excludedDisplayIDs
        if excluded { ids.insert(displayID) } else { ids.remove(displayID) }
        preferences.excludedDisplayIDs = ids
        applyCurrentState()
    }

    func restoreAllDisplays() {
        transitionTimer?.invalidate()
        DisplayManager.restoreAll()
    }

    private func animateTransition(to preset: FilterPreset, duration: TimeInterval = 0.6, steps: Int = 24) {
        transitionTimer?.invalidate()
        let startWarmth = warmth
        let startBrightness = brightness
        var step = 0

        transitionTimer = Timer.scheduledTimer(withTimeInterval: duration / Double(steps), repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            step += 1
            let t = CGFloat(step) / CGFloat(steps)
            self.warmth = startWarmth + (preset.warmth - startWarmth) * t
            self.brightness = startBrightness + (preset.brightness - startBrightness) * t
            self.applyCurrentState()

            if step >= steps {
                timer.invalidate()
                self.preferences.warmth = self.warmth
                self.preferences.brightness = self.brightness
            }
        }
    }

    private func applyCurrentState() {
        let excluded = preferences.excludedDisplayIDs
        for displayID in DisplayManager.activeDisplayIDs() {
            if isEnabled && !excluded.contains(displayID) {
                DisplayManager.apply(warmth: warmth, brightness: brightness, to: displayID)
            } else {
                DisplayManager.reset(displayID: displayID)
            }
        }
        externalBrightness.setBrightness(isEnabled ? brightness : 1.0, excluding: excluded)
    }
}
