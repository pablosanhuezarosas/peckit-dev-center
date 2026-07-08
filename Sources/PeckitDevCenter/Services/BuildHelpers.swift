import Foundation

struct BuildCommand {
    let executable: String
    let args: [String]
    let cwd: String
}

enum AndroidBuild {
    static func assembleDebug(projectPath: String) -> BuildCommand {
        BuildCommand(executable: "./gradlew", args: ["assembleDebug"], cwd: "\(projectPath)/android")
    }

    static func apkPath(projectPath: String) -> String {
        "\(projectPath)/android/app/build/outputs/apk/debug/app-debug.apk"
    }
}

enum IOSBuild {
    static func derivedDataPath(projectPath: String) -> String {
        "\(projectPath)/ios/build-devcenter"
    }

    static func debugBuild(projectPath: String) -> BuildCommand {
        let scheme = AppInfo.iosScheme(projectPath: projectPath)
        return BuildCommand(
            executable: "xcodebuild",
            args: [
                "-workspace", "\(scheme).xcworkspace",
                "-scheme", scheme,
                "-configuration", "Debug",
                "-sdk", "iphonesimulator",
                "-derivedDataPath", derivedDataPath(projectPath: projectPath)
            ],
            cwd: "\(projectPath)/ios"
        )
    }

    static func appBundlePath(projectPath: String) -> String? {
        let scheme = AppInfo.iosScheme(projectPath: projectPath)
        let path = "\(derivedDataPath(projectPath: projectPath))/Build/Products/Debug-iphonesimulator/\(scheme).app"
        return FileManager.default.fileExists(atPath: path) ? path : nil
    }
}
