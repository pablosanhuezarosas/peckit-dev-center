import Foundation

struct IOSSimulator: Identifiable {
    let id: String  // udid
    let name: String
    let state: String  // "Booted", "Shutdown", etc.
}

enum IOSController {
    static func listSimulators() -> [IOSSimulator] {
        let result = ShellRunner.exec("xcrun", args: ["simctl", "list", "devices", "available", "-j"])
        guard let data = result.output.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let devicesByRuntime = json["devices"] as? [String: [[String: Any]]] else {
            return []
        }
        var sims: [IOSSimulator] = []
        for (_, devices) in devicesByRuntime {
            for device in devices {
                guard let udid = device["udid"] as? String,
                      let name = device["name"] as? String,
                      let state = device["state"] as? String else { continue }
                sims.append(IOSSimulator(id: udid, name: name, state: state))
            }
        }
        return sims.sorted { $0.name < $1.name }
    }

    @discardableResult
    static func boot(udid: String) -> ShellResult {
        let result = ShellRunner.exec("xcrun", args: ["simctl", "boot", udid])
        ShellRunner.exec("open", args: ["-a", "Simulator"])
        return result
    }

    @discardableResult
    static func shutdown(udid: String) -> ShellResult {
        ShellRunner.exec("xcrun", args: ["simctl", "shutdown", udid])
    }

    @discardableResult
    static func install(udid: String, appPath: String) -> ShellResult {
        ShellRunner.exec("xcrun", args: ["simctl", "install", udid, appPath])
    }

    @discardableResult
    static func launch(udid: String, bundleId: String) -> ShellResult {
        ShellRunner.exec("xcrun", args: ["simctl", "launch", udid, bundleId])
    }
}
