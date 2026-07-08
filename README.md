# Peckit Dev Center

App nativa de macOS (Swift + SwiftUI) que centraliza el flujo de desarrollo de un proyecto React Native / Expo: Metro, Git, dispositivos Android/iOS, y build+install+run — sin depender de Terminal, Android Studio, Xcode o GitHub Desktop por separado.

Por Pablo Sanhueza Rosas.

## Pantallas

- **Dashboard** — estado de Metro, Node, Java, Android SDK, Xcode, CocoaPods, Watchman y Git; rama actual y ruta del proyecto.
- **Metro** — start/stop/restart, clear cache, puerto configurable, logs en vivo con filtro (Todo/Errors/Warnings) y buscador.
- **Git** — rama actual, cambiar de rama, pull/push/fetch/diff, con output visible.
- **Devices** — lista AVDs de Android (con launch), dispositivos conectados vía `adb` (seleccionar/detener), simuladores de iOS (boot/shutdown/seleccionar).
- **Build & Run** — build APK debug de Android o build debug de iOS, con la opción "build + install + run" que compila, instala y lanza automáticamente en el dispositivo/simulador seleccionado, con logs de build en vivo.
- **Quick Actions** — abrir VSCode, Android Studio, Xcode, Finder o Terminal en la ruta del proyecto.

Al iniciar, la app muestra una pantalla de inicio con los 6 accesos como botones cuadrados; desde ahí navegás a cada sección.

## Cómo funciona

Todo corre invocando las herramientas de línea de comandos que ya tenés instaladas — no hay nada mágico:

- `git` para las operaciones de Git
- `npx expo start` para Metro
- `./gradlew assembleDebug` para el build de Android, e `adb` para instalar/lanzar
- `xcodebuild` para el build de iOS, y `xcrun simctl` para manejar simuladores

El package/bundle identifier y el nombre del scheme/workspace de Xcode se leen dinámicamente del `app.json` del proyecto Expo configurado — no están hardcodeados, así que funciona con cualquier proyecto Expo/React Native, no solo con el mío.

## Instalación

Requiere Xcode (para el toolchain de Swift) en macOS 13+.

```bash
git clone https://github.com/pablosanhuezarosas/peckit-dev-center.git
cd peckit-dev-center
./package-app.sh --install
```

Esto compila en release, arma el `.app` con ícono incluido, y lo instala en `/Applications/PeckitDevCenter.app`.

Para correrla en modo desarrollo sin instalarla: `swift run PeckitDevCenter` (nota: al correr así, activá el foco de la ventana manualmente la primera vez si no aparece — es una limitación de ejecutables sueltos sin bundle).

Configurá la ruta de tu proyecto en la pestaña **Quick Actions** la primera vez que la abras.

## Limitaciones conocidas

- Pensada para proyectos Expo (lee `app.json` para el package/bundle ID). Un proyecto React Native puro sin Expo necesitaría adaptar `AppInfo.swift`.
- El build de iOS asume que existe un `.xcworkspace` en `ios/` (estándar en proyectos con CocoaPods/Expo prebuild).
- No firma ni sube nada — solo debug builds locales.

## Licencia

MIT — ver `LICENSE`.
