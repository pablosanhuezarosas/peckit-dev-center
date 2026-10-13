# Peckit Dev Center

App nativa de macOS (Swift + SwiftUI) que reúne en una sola ventana todo el flujo de desarrollo de una app React Native / Expo: Metro, Git, emuladores y simuladores, y compilar-instalar-abrir en Android e iOS. Ya no hace falta saltar entre Terminal, Android Studio, Xcode y GitHub Desktop.

La construí para desarrollar las apps de iOS y Android de [Peckit](https://peckit.cl), pero funciona con cualquier proyecto Expo.

Por Pablo Sanhueza Rosas.

## Qué hace

| Sección | Para qué sirve |
|---|---|
| **Dashboard** | Estado de Metro, Node, Java, Android SDK, Xcode, CocoaPods, Watchman y Git, más la rama actual y la ruta del proyecto. |
| **Metro** | Iniciar, detener, reiniciar y limpiar caché, con puerto configurable. Logs en vivo con filtro (todo, errores, advertencias) y buscador. |
| **Git** | Ver la rama actual y cambiar de rama; `pull`, `push`, `fetch` y `diff` con la salida a la vista. |
| **Devices** | Emuladores Android (AVD) con opción de abrirlos, dispositivos conectados por `adb` y simuladores de iOS (encender, apagar, seleccionar). |
| **Build & Run** | Compila el APK de debug de Android o el build de debug de iOS. Con **build + install + run** compila, instala y abre la app en el dispositivo o simulador elegido, con los logs en vivo. |
| **Quick Actions** | Abre el proyecto en VS Code, Android Studio, Xcode, Finder o Terminal, y define la ruta del proyecto. |

Al abrirla aparece una pantalla de inicio con las seis secciones como botones; desde ahí entras a cada una. Todo con estética de terminal retro.

## Cómo funciona

No hay magia: la app llama a las mismas herramientas de línea de comandos que ya tienes instaladas.

- `git` para todo lo de Git.
- `npx expo start` para Metro.
- `./gradlew assembleDebug` para compilar en Android, y `adb` para instalar y abrir la app.
- `xcodebuild` para compilar en iOS, y `xcrun simctl` para manejar los simuladores.

El package de Android, el bundle identifier de iOS y el scheme/workspace de Xcode se leen del `app.json` del proyecto. No hay nada fijo en el código, así que sirve para cualquier proyecto Expo / React Native, no solo para Peckit.

## Instalación

Requiere macOS 13 o superior y Xcode (por el toolchain de Swift).

```bash
git clone https://github.com/pablosanhuezarosas/peckit-dev-center.git
cd peckit-dev-center
./package-app.sh --install
```

Esto compila en modo release, arma el `.app` con su ícono y lo instala en `/Applications/PeckitDevCenter.app`.

Para probarla sin instalarla: `swift run PeckitDevCenter`. La primera vez puede que tengas que hacer clic en la ventana para darle el foco; es una limitación de los ejecutables que corren sin bundle.

La primera vez que la abras, define la ruta de tu proyecto en **Quick Actions** (por defecto busca `~/peckit-mobile`).

## Limitaciones conocidas

- Está pensada para proyectos Expo: lee el `app.json` para obtener el package y el bundle ID. Para un proyecto React Native sin Expo habría que adaptar `AppInfo.swift`.
- El build de iOS asume que existe un `.xcworkspace` dentro de `ios/`, que es lo estándar con CocoaPods o `expo prebuild`.
- Solo hace builds locales de debug: no firma ni sube nada a las tiendas.

## Licencia

MIT. Ver `LICENSE`.
