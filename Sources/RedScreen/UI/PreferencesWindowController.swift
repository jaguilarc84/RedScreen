import AppKit
import SwiftUI

final class PreferencesWindowController: NSWindowController {
    convenience init(preferences: PreferencesStore, engine: FilterEngine) {
        let hosting = NSHostingController(rootView: PreferencesView(preferences: preferences, engine: engine))
        let window = NSWindow(contentViewController: hosting)
        window.title = "Preferencias de RedScreen"
        window.styleMask = [.titled, .closable]
        self.init(window: window)
    }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        window?.center()
        window?.makeKeyAndOrderFront(nil)
    }
}
