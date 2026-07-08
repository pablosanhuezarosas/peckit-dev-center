import Foundation

enum AppInfo {
    private static func readAppJSON(projectPath: String) -> [String: Any]? {
        let path = "\(projectPath)/app.json"
        guard let data = FileManager.default.contents(atPath: path),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }

    static func androidPackage(projectPath: String) -> String? {
        guard let json = readAppJSON(projectPath: projectPath),
              let expo = json["expo"] as? [String: Any],
              let android = expo["android"] as? [String: Any] else { return nil }
        return android["package"] as? String
    }

    static func iosBundleId(projectPath: String) -> String? {
        guard let json = readAppJSON(projectPath: projectPath),
              let expo = json["expo"] as? [String: Any],
              let ios = expo["ios"] as? [String: Any] else { return nil }
        return ios["bundleIdentifier"] as? String
    }

    /// Derives the Xcode scheme/workspace name from the .xcworkspace present under ios/.
    static func iosScheme(projectPath: String) -> String {
        let iosDir = "\(projectPath)/ios"
        if let contents = try? FileManager.default.contentsOfDirectory(atPath: iosDir),
           let workspace = contents.first(where: { $0.hasSuffix(".xcworkspace") }) {
            return String(workspace.dropLast(".xcworkspace".count))
        }
        return "App"
    }
}
