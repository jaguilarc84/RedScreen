# RedScreen

App nativa de macOS que vive en la barra de menús: reduce la luz azul de la
pantalla mediante la tabla de gamma del sistema (igual que Night Shift) y
ofrece atenuación de brillo por software, con modos rápidos Día/Tarde/Noche
y un atajo de teclado global.

Inspirada en las especificaciones de [pauninja.com/filtro-luz-azul-pantallas](https://pauninja.com/filtro-luz-azul-pantallas).

## Funciones

- **Calidez (0–100%)**: desliza de luz de día a rojo puro; al 100% elimina
  por completo el canal azul.
- **Brillo (15–100%)**: atenúa por software vía tabla de gamma, sin tocar el
  retroiluminado (nunca deja la pantalla completamente negra).
- **Modos Día / Tarde / Noche**: presets con transición suave de ~0.6s.
- **ZAP**: encendido/apagado instantáneo desde el popover o con `⌃⌥Z`
  (atajo global, configurable en `PreferencesStore`).
- **Multi-monitor**: aplica a todas las pantallas por defecto; cada una se
  puede excluir individualmente desde Preferencias.
- **Sin permisos especiales**: el atajo global usa el Carbon Event Manager
  (`RegisterEventHotKey`), no un monitor de `NSEvent`, así que no pide
  Accessibility. No hay red, cuentas ni analítica.
- **Capturas y videollamadas sin teñir**: al modificar la tabla de gamma en
  vez de dibujar una capa encima, las capturas de pantalla y el video de
  llamadas (que leen el framebuffer antes de la LUT) se ven sin filtro.
- **Inicio automático**: vía `SMAppService` (macOS 13+).

## Estructura

```
Package.swift
Resources/Info.plist          # LSUIElement, bundle id, versión
Scripts/build_app.sh          # empaqueta el binario de SPM en un .app
Sources/RedScreen/
  main.swift                  # punto de entrada NSApplication
  AppDelegate.swift           # arranque, hotkey global, ventana de prefs
  Display/
    GammaFilter.swift         # cálculo puro de la curva calidez+brillo
    DisplayManager.swift      # enumerar pantallas y aplicar/restaurar gamma
    ExternalDisplayBrightnessController.swift  # ver "Limitaciones" abajo
  HotKey/GlobalHotKey.swift   # wrapper de Carbon RegisterEventHotKey
  Presets/FilterMode.swift    # Día/Tarde/Noche/Personalizado
  Preferences/
    PreferencesStore.swift    # persistencia en UserDefaults
    LaunchAtLogin.swift       # SMAppService
  Engine/FilterEngine.swift   # estado central + transiciones animadas
  UI/
    StatusBarController.swift # NSStatusItem + NSPopover
    FilterPopoverView.swift   # sliders, ZAP, modos (SwiftUI)
    PreferencesWindowController.swift
    PreferencesView.swift     # inicio automático, exclusión por monitor
```

## Compilar y ejecutar

Este proyecto **requiere macOS y Xcode/Swift toolchain** (usa AppKit,
SwiftUI y Carbon; no compila en Linux).

**Opción A — línea de comandos:**

```bash
./Scripts/build_app.sh
open "$(swift build -c release --show-bin-path)/RedScreen.app"
```

**Opción B — Xcode:**

Abre `Package.swift` directamente con Xcode (`File > Open`) y ejecuta el
esquema `RedScreen`. Para distribuirla como `.app` firmada, crea un target
de tipo "App" en Xcode y arrastra los archivos de `Sources/RedScreen` dentro
(Xcode gestionará el Info.plist y el firmado por ti).

## Limitaciones conocidas / decisiones deliberadas

- **No se pudo compilar ni ejecutar en este entorno**: el desarrollo se hizo
  en un contenedor Linux sin Xcode ni toolchain de Swift, así que el código
  no ha sido verificado con un build real. Revísalo con `swift build` en un
  Mac antes de confiar en él para producción.
- **DDC/CI para monitores externos** (`ExternalDisplayBrightnessController`)
  se deja como punto de extensión sin implementar. Controlar el brillo real
  del retroiluminado de un monitor externo requiere hablar con un servicio
  IOKit no documentado (`IOAVService` en Apple Silicon, I2C crudo en Intel);
  no hay forma de verificar esa integración sin hardware físico y sin poder
  compilar aquí, así que se documenta en vez de improvisarse. El slider de
  brillo sí funciona en todas las pantallas vía gamma de software.
- **Mínimo macOS 11**, no 10.15 como en la página de referencia: los iconos
  de la barra de menús usan SF Symbols (`NSImage(systemSymbolName:)`), que
  requieren macOS 11+. Soportar 10.15 exigiría empaquetar iconos bitmap
  propios.
- **Inicio automático** solo está implementado para macOS 13+ (`SMAppService`).
  En 11–12 necesitarías un target auxiliar de tipo Login Item.
