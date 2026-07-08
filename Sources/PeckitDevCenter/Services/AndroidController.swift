import Foundation

struct AndroidDevice: Identifiable {
    let id: String       // serial (e.g. emulator-5554, or physical device serial)
    let description: String
    let isEmulator: Bool
}

enum AndroidController {
    static var androidHome: String {
        ProcessInfo.processInfo.environment["ANDROID_HOME"]
            ?? "\(NSHomeDirectory())/Library/Android/sdk"
    }

    static var adbPath: String { "\(androidHome)/platform-tools/adb" }
    static var emulatorPath: String { "\(androidHome)/emulator/emulator" }

    static func listAVDs() -> [String] {
        let result = ShellRunner.exec(emulatorPath, args: ["-list-avds"])
        return result.output.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
    }

    static func listDevices() -> [AndroidDevice] {
        let result = ShellRunner.exec(adbPath, args: ["devices", "-l"])
        var devices: [AndroidDevice] = []
        for line in result.output.split(separator: "\n").dropFirst() {
            let parts = line.split(separator: " ", omittingEmptySubsequences: true)
            guard let serial = parts.first, parts.count > 1 else { continue }
            let desc = parts.dropFirst().joined(separator: " ")
            devices.append(AndroidDevice(
                id: String(serial),
                description: desc,
                isEmulator: serial.hasPrefix("emulator-")
            ))
        }
        return devices
    }

    static func startEmulator(avdName: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [emulatorPath, "-avd", avdName]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try? process.run()
    }

    @discardableResult
    static func killEmulator(serial: String) -> ShellResult {
        ShellRunner.exec(adbPath, args: ["-s", serial, "emu", "kill"])
    }

    @discardableResult
    static func install(serial: String, apkPath: String) -> ShellResult {
        ShellRunner.exec(adbPath, args: ["-s", serial, "install", "-r", apkPath])
    }

    @discardableResult
    static func launch(serial: String, packageName: String) -> ShellResult {
        ShellRunner.exec(adbPath, args: ["-s", serial, "shell", "monkey", "-p", packageName, "-c", "android.intent.category.LAUNCHER", "1"])
    }

    @discardableResult
    static func restartAdb() -> ShellResult {
        ShellRunner.exec(adbPath, args: ["kill-server"])
        return ShellRunner.exec(adbPath, args: ["start-server"])
    }
}
