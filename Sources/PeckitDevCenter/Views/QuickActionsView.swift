import SwiftUI
import AppKit

struct QuickActionsView: View {
    @EnvironmentObject var config: AppConfig

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("▓▓▓ QUICK ACTIONS ▓▓▓")
                .font(Term.monoTitle)
                .foregroundColor(Term.green)

            TermPanel(title: "RUTA DEL PROYECTO") {
                TextField("ruta del proyecto", text: $config.projectPath)
                    .font(Term.mono)
                    .foregroundColor(Term.green)
                    .textFieldStyle(.plain)
                    .padding(6)
                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(Term.border))
            }

            TermPanel(title: "ABRIR") {
                VStack(alignment: .leading, spacing: 8) {
                    TermButton(label: "VSCode") { open(app: "Visual Studio Code") }
                    TermButton(label: "Android Studio") { open(app: "Android Studio") }
                    TermButton(label: "Xcode") { openXcodeWorkspace() }
                    TermButton(label: "Finder") { openFinder() }
                    TermButton(label: "Terminal") { openTerminal() }
                }
            }
        }
        .padding(20)
        .background(Term.background)
    }

    private func open(app: String) {
        ShellRunner.exec("open", args: ["-a", app, config.projectPath])
    }

    private func openXcodeWorkspace() {
        let ios = "\(config.projectPath)/ios"
        ShellRunner.exec("open", args: ["-a", "Xcode", ios])
    }

    private func openFinder() {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: config.projectPath)
    }

    private func openTerminal() {
        ShellRunner.exec("open", args: ["-a", "Terminal", config.projectPath])
    }
}
