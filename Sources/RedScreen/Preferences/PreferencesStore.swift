import CoreGraphics
import Foundation

final class PreferencesStore {
    static let shared = PreferencesStore()

    // Mirrors Carbon's kVK_ANSI_Z (0x06) and controlKey|optionKey
    // (0x1000 | 0x0800) — i.e. the default ⌃⌥Z shortcut — without pulling in
    // Carbon just for two constants.
    static let defaultHotKeyCode: UInt32 = 0x06
    static let defaultHotKeyModifiers: UInt32 = 0x1000 | 0x0800

    private let defaults = UserDefaults.standard

    private enum Key {
        static let isEnabled = "redscreen.isEnabled"
        static let warmth = "redscreen.warmth"
        static let brightness = "redscreen.brightness"
        static let activeMode = "redscreen.activeMode"
        static let excludedDisplayIDs = "redscreen.excludedDisplayIDs"
        static let launchAtLogin = "redscreen.launchAtLogin"
        static let hotKeyCode = "redscreen.hotKeyCode"
        static let hotKeyModifiers = "redscreen.hotKeyModifiers"
    }

    var isEnabled: Bool {
        get { defaults.object(forKey: Key.isEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.isEnabled) }
    }

    var warmth: CGFloat {
        get { CGFloat(defaults.object(forKey: Key.warmth) as? Double ?? 0.35) }
        set { defaults.set(Double(newValue), forKey: Key.warmth) }
    }

    var brightness: CGFloat {
        get { CGFloat(defaults.object(forKey: Key.brightness) as? Double ?? 0.9) }
        set { defaults.set(Double(newValue), forKey: Key.brightness) }
    }

    var activeMode: FilterMode {
        get { FilterMode(rawValue: defaults.string(forKey: Key.activeMode) ?? "") ?? .evening }
        set { defaults.set(newValue.rawValue, forKey: Key.activeMode) }
    }

    var excludedDisplayIDs: Set<CGDirectDisplayID> {
        get { Set((defaults.array(forKey: Key.excludedDisplayIDs) as? [Int] ?? []).map { CGDirectDisplayID($0) }) }
        set { defaults.set(Array(newValue).map { Int($0) }, forKey: Key.excludedDisplayIDs) }
    }

    var launchAtLogin: Bool {
        get { defaults.object(forKey: Key.launchAtLogin) as? Bool ?? false }
        set { defaults.set(newValue, forKey: Key.launchAtLogin) }
    }

    var hotKeyCode: UInt32 {
        get { UInt32(defaults.object(forKey: Key.hotKeyCode) as? Int ?? Int(Self.defaultHotKeyCode)) }
        set { defaults.set(Int(newValue), forKey: Key.hotKeyCode) }
    }

    var hotKeyModifiers: UInt32 {
        get { UInt32(defaults.object(forKey: Key.hotKeyModifiers) as? Int ?? Int(Self.defaultHotKeyModifiers)) }
        set { defaults.set(Int(newValue), forKey: Key.hotKeyModifiers) }
    }
}
