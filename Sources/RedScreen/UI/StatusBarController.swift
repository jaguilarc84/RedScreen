import AppKit
import Combine
import SwiftUI

final class StatusBarController: NSObject {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private var cancellables = Set<AnyCancellable>()

    init(filterEngine: FilterEngine, onOpenPreferences: @escaping () -> Void) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        popover = NSPopover()
        super.init()

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "sun.max.fill", accessibilityDescription: "RedScreen")
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: FilterPopoverView(engine: filterEngine, onOpenPreferences: onOpenPreferences)
        )

        filterEngine.$isEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.statusItem.button?.image = NSImage(
                    systemSymbolName: enabled ? "sun.max.fill" : "sun.min",
                    accessibilityDescription: "RedScreen"
                )
            }
            .store(in: &cancellables)
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
