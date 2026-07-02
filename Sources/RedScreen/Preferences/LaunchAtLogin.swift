import Foundation
import ServiceManagement

enum LaunchAtLogin {
    static func setEnabled(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                NSLog("RedScreen: no se pudo actualizar el inicio automático: \(error)")
            }
        } else {
            // macOS 11-12 requires a separate helper bundled under
            // Contents/Library/LoginItems plus SMLoginItemSetEnabled(_:_:).
            // Not included here; add a helper target if you need
            // launch-at-login support below macOS 13.
            NSLog("RedScreen: el inicio automático requiere macOS 13 o superior en esta build.")
        }
    }
}
