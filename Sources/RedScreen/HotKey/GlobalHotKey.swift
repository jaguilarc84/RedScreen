import Carbon
import Foundation

/// A single global keyboard shortcut backed by the classic Carbon Event
/// Manager (`RegisterEventHotKey`). Unlike an `NSEvent` global monitor, this
/// does not require the Accessibility permission, matching the "no pide
/// Accessibility" requirement.
final class GlobalHotKey {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private let handler: () -> Void
    private let hotKeyID = EventHotKeyID(signature: 0x5253_4352, id: 1) // 'RSCR'

    init?(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) {
        self.handler = handler
        guard register(keyCode: keyCode, modifiers: modifiers) else { return nil }
    }

    deinit {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
        }
    }

    private func register(keyCode: UInt32, modifiers: UInt32) -> Bool {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let callback: EventHandlerUPP = { _, eventRef, userData in
            guard let userData, let eventRef else { return noErr }

            var pressedHotKeyID = EventHotKeyID()
            GetEventParameter(
                eventRef,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &pressedHotKeyID
            )

            let instance = Unmanaged<GlobalHotKey>.fromOpaque(userData).takeUnretainedValue()
            if pressedHotKeyID.id == instance.hotKeyID.id {
                instance.handler()
            }
            return noErr
        }

        let installStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )
        guard installStatus == noErr else { return false }

        let registerStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        return registerStatus == noErr
    }
}
