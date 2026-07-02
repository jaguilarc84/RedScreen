import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let filterEngine = FilterEngine()
    private var statusBarController: StatusBarController?
    private var preferencesWindowController: PreferencesWindowController?
    private var hotKey: GlobalHotKey?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusBarController = StatusBarController(filterEngine: filterEngine) { [weak self] in
            self?.showPreferences()
        }

        let preferences = PreferencesStore.shared
        hotKey = GlobalHotKey(
            keyCode: preferences.hotKeyCode,
            modifiers: preferences.hotKeyModifiers
        ) { [weak self] in
            self?.filterEngine.toggle()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        filterEngine.restoreAllDisplays()
    }

    private func showPreferences() {
        if preferencesWindowController == nil {
            preferencesWindowController = PreferencesWindowController(preferences: .shared, engine: filterEngine)
        }
        preferencesWindowController?.show()
    }
}
