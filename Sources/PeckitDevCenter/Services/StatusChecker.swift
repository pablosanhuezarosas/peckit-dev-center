import Foundation

struct StatusItem: Identifiable {
    let id = UUID()
    let name: String
    let state: StatusDot.State
    let detail: String
}

enum StatusChecker {
    static func checkAll(projectPath: String) -> [StatusItem] {
        var items: [StatusItem] = []

        let node = ShellRunner.run("command -v node >/dev/null && node -v")
        items.append(StatusItem(
            name: "Node",
            state: node.exitCode == 0 ? .ok : .err,
            detail: node.exitCode == 0 ? node.output : "no encontrado"
        ))

        let java = ShellRunner.run("java -version 2>&1 | head -1")
        items.append(StatusItem(
            name: "Java",
            state: java.exitCode == 0 && !java.output.isEmpty ? .ok : .err,
            detail: java.output.isEmpty ? "no encontrado" : java.output
        ))

        let androidHome = ProcessInfo.processInfo.environment["ANDROID_HOME"]
            ?? "\(NSHomeDirectory())/Library/Android/sdk"
        let androidExists = FileManager.default.fileExists(atPath: androidHome)
        items.append(StatusItem(
            name: "Android SDK",
            state: androidExists ? .ok : .err,
            detail: androidExists ? androidHome : "no encontrado en \(androidHome)"
        ))

        let xcode = ShellRunner.run("xcode-select -p")
        items.append(StatusItem(
            name: "Xcode",
            state: xcode.exitCode == 0 ? .ok : .err,
            detail: xcode.exitCode == 0 ? xcode.output : "no configurado"
        ))

        let pod = ShellRunner.run("command -v pod >/dev/null && pod --version")
        items.append(StatusItem(
            name: "CocoaPods",
            state: pod.exitCode == 0 ? .ok : .warn,
            detail: pod.exitCode == 0 ? "v\(pod.output)" : "no encontrado"
        ))

        let watchman = ShellRunner.run("command -v watchman >/dev/null && echo instalado")
        items.append(StatusItem(
            name: "Watchman",
            state: watchman.exitCode == 0 ? .ok : .warn,
            detail: watchman.exitCode == 0 ? "instalado" : "no encontrado"
        ))

        let gitCheck = ShellRunner.run("git rev-parse --is-inside-work-tree", cwd: projectPath)
        items.append(StatusItem(
            name: "Git",
            state: gitCheck.exitCode == 0 ? .ok : .err,
            detail: gitCheck.exitCode == 0 ? "repo detectado" : "no es un repo git en esta ruta"
        ))

        return items
    }
}
