import SwiftUI

struct BuildRunView: View {
    @EnvironmentObject var config: AppConfig
    @StateObject private var buildProcess = LiveProcess()
    @State private var statusLine: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("▓▓▓ BUILD & RUN ▓▓▓")
                .font(Term.monoTitle)
                .foregroundColor(Term.green)

            TermPanel(title: "ANDROID DEBUG") {
                HStack {
                    Text("Dispositivo:")
                        .font(Term.mono)
                        .foregroundColor(Term.gray)
                    Text(config.selectedAndroidSerial.isEmpty ? "(ninguno seleccionado en Devices)" : config.selectedAndroidSerial)
                        .font(Term.mono)
                        .foregroundColor(config.selectedAndroidSerial.isEmpty ? Term.red : Term.green)
                }
                HStack(spacing: 10) {
                    TermButton(label: buildProcess.isRunning ? "BUILDING..." : "BUILD APK DEBUG") {
                        runAndroidBuild(installAfter: false)
                    }
                    TermButton(label: "BUILD + INSTALL + RUN") {
                        runAndroidBuild(installAfter: true)
                    }
                }
            }

            TermPanel(title: "IOS DEBUG") {
                HStack {
                    Text("Simulador:")
                        .font(Term.mono)
                        .foregroundColor(Term.gray)
                    Text(config.selectedIOSUdid.isEmpty ? "(ninguno seleccionado en Devices)" : config.selectedIOSUdid)
                        .font(Term.monoSmall)
                        .foregroundColor(config.selectedIOSUdid.isEmpty ? Term.red : Term.green)
                }
                HStack(spacing: 10) {
                    TermButton(label: buildProcess.isRunning ? "BUILDING..." : "BUILD DEBUG") {
                        runIOSBuild(installAfter: false)
                    }
                    TermButton(label: "BUILD + INSTALL + RUN") {
                        runIOSBuild(installAfter: true)
                    }
                }
            }

            if !statusLine.isEmpty {
                Text(statusLine)
                    .font(Term.monoSmall)
                    .foregroundColor(Term.amber)
            }

            TermPanel(title: "BUILD OUTPUT") {
                HStack {
                    Spacer()
                    TermButton(label: "CLEAR") { buildProcess.clear() }
                }
                ScrollView {
                    ScrollViewReader { proxy in
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(Array(buildProcess.lines.enumerated()), id: \.offset) { idx, line in
                                Text(line)
                                    .font(Term.monoSmall)
                                    .foregroundColor(line.uppercased().contains("ERROR") ? Term.red : Term.dimGreen)
                                    .textSelection(.enabled)
                                    .id(idx)
                            }
                        }
                        .onChange(of: buildProcess.lines.count) { _ in
                            if let last = buildProcess.lines.indices.last {
                                proxy.scrollTo(last, anchor: .bottom)
                            }
                        }
                    }
                }
                .frame(minHeight: 260)
            }
        }
        .padding(20)
        .background(Term.background)
    }

    private func runAndroidBuild(installAfter: Bool) {
        buildProcess.clear()
        let cmd = AndroidBuild.assembleDebug(projectPath: config.projectPath)
        statusLine = "compilando APK debug..."
        buildProcess.start(command: cmd.executable, args: cmd.args, cwd: cmd.cwd)

        guard installAfter else { return }
        pollUntilFinished {
            let apk = AndroidBuild.apkPath(projectPath: config.projectPath)
            guard FileManager.default.fileExists(atPath: apk) else {
                statusLine = "build fallo — no se genero el APK (ver output)"
                return
            }
            guard !config.selectedAndroidSerial.isEmpty else {
                statusLine = "APK generado, pero no hay dispositivo Android seleccionado (pestana Devices)"
                return
            }
            statusLine = "instalando en \(config.selectedAndroidSerial)..."
            AndroidController.install(serial: config.selectedAndroidSerial, apkPath: apk)
            if let pkg = AppInfo.androidPackage(projectPath: config.projectPath) {
                AndroidController.launch(serial: config.selectedAndroidSerial, packageName: pkg)
                statusLine = "app lanzada en \(config.selectedAndroidSerial)"
            } else {
                statusLine = "instalado, pero no se encontro el package en app.json para lanzarla"
            }
        }
    }

    private func runIOSBuild(installAfter: Bool) {
        buildProcess.clear()
        let cmd = IOSBuild.debugBuild(projectPath: config.projectPath)
        statusLine = "compilando build de iOS (puede tardar varios minutos)..."
        buildProcess.start(command: cmd.executable, args: cmd.args, cwd: cmd.cwd)

        guard installAfter else { return }
        pollUntilFinished {
            guard let appPath = IOSBuild.appBundlePath(projectPath: config.projectPath) else {
                statusLine = "build fallo — no se genero el .app (ver output)"
                return
            }
            guard !config.selectedIOSUdid.isEmpty else {
                statusLine = "build generado, pero no hay simulador seleccionado (pestana Devices)"
                return
            }
            statusLine = "instalando en simulador..."
            IOSController.install(udid: config.selectedIOSUdid, appPath: appPath)
            if let bundleId = AppInfo.iosBundleId(projectPath: config.projectPath) {
                IOSController.launch(udid: config.selectedIOSUdid, bundleId: bundleId)
                statusLine = "app lanzada en el simulador"
            } else {
                statusLine = "instalado, pero no se encontro el bundleIdentifier en app.json para lanzarla"
            }
        }
    }

    /// Polls LiveProcess.isRunning and fires the completion block once the build process exits.
    private func pollUntilFinished(_ completion: @escaping () -> Void) {
        func check() {
            if buildProcess.isRunning {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: check)
            } else {
                completion()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: check)
    }
}
