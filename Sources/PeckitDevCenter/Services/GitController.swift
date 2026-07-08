import Foundation

struct GitStatus {
    let branch: String
    let changedFiles: [String]
}

enum GitController {
    static func currentBranch(projectPath: String) -> String {
        let result = ShellRunner.exec("git", args: ["rev-parse", "--abbrev-ref", "HEAD"], cwd: projectPath)
        return result.exitCode == 0 ? result.output : "?"
    }

    static func status(projectPath: String) -> GitStatus {
        let branch = currentBranch(projectPath: projectPath)
        let statusResult = ShellRunner.exec("git", args: ["status", "--porcelain"], cwd: projectPath)
        let files = statusResult.output.split(separator: "\n").map(String.init)
        return GitStatus(branch: branch, changedFiles: files)
    }

    static func branches(projectPath: String) -> [String] {
        let result = ShellRunner.exec("git", args: ["branch", "--format=%(refname:short)"], cwd: projectPath)
        return result.output.split(separator: "\n").map(String.init)
    }

    static func checkout(branch: String, projectPath: String) -> ShellResult {
        ShellRunner.exec("git", args: ["checkout", branch], cwd: projectPath)
    }

    static func pull(projectPath: String) -> ShellResult {
        ShellRunner.exec("git", args: ["pull"], cwd: projectPath)
    }

    static func push(projectPath: String) -> ShellResult {
        ShellRunner.exec("git", args: ["push"], cwd: projectPath)
    }

    static func fetch(projectPath: String) -> ShellResult {
        ShellRunner.exec("git", args: ["fetch"], cwd: projectPath)
    }

    static func diff(projectPath: String) -> ShellResult {
        ShellRunner.exec("git", args: ["diff"], cwd: projectPath)
    }
}
