import Foundation
import Combine

struct ShellResult {
    let output: String
    let exitCode: Int32
}

enum ShellRunner {
    /// Runs a canned shell snippet via bash -c. Use only with fixed, developer-authored
    /// command strings — not with unsanitized user input.
    @discardableResult
    static func run(_ command: String, cwd: String? = nil) -> ShellResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]
        if let cwd = cwd {
            process.currentDirectoryURL = URL(fileURLWithPath: cwd)
        }
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
        } catch {
            return ShellResult(output: "error: \(error.localizedDescription)", exitCode: -1)
        }
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        return ShellResult(output: output.trimmingCharacters(in: .whitespacesAndNewlines), exitCode: process.terminationStatus)
    }

    /// Runs an executable directly with an argument array (no shell interpolation) —
    /// the safe path for dynamic values like branch names picked from a list.
    @discardableResult
    static func exec(_ executable: String, args: [String], cwd: String? = nil) -> ShellResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [executable] + args
        if let cwd = cwd {
            process.currentDirectoryURL = URL(fileURLWithPath: cwd)
        }
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
        } catch {
            return ShellResult(output: "error: \(error.localizedDescription)", exitCode: -1)
        }
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        return ShellResult(output: output.trimmingCharacters(in: .whitespacesAndNewlines), exitCode: process.terminationStatus)
    }
}

/// A long-running process (e.g. Metro) whose stdout/stderr is streamed line-by-line.
final class LiveProcess: ObservableObject {
    @Published var lines: [String] = []
    @Published var isRunning: Bool = false

    private var process: Process?
    private var outputPipe: Pipe?
    private let maxLines = 800

    func start(command: String, args: [String], cwd: String) {
        stop()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [command] + args
        process.currentDirectoryURL = URL(fileURLWithPath: cwd)

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let str = String(data: data, encoding: .utf8) else { return }
            let newLines = str.split(separator: "\n", omittingEmptySubsequences: false).map(String.init).filter { !$0.isEmpty }
            guard !newLines.isEmpty else { return }
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.lines.append(contentsOf: newLines)
                if self.lines.count > self.maxLines {
                    self.lines.removeFirst(self.lines.count - self.maxLines)
                }
            }
        }

        process.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.isRunning = false
            }
        }

        do {
            try process.run()
            self.process = process
            self.outputPipe = pipe
            isRunning = true
        } catch {
            lines.append("error starting process: \(error.localizedDescription)")
        }
    }

    func stop() {
        outputPipe?.fileHandleForReading.readabilityHandler = nil
        if let process = process, process.isRunning {
            process.terminate()
        }
        process = nil
        outputPipe = nil
        isRunning = false
    }

    func clear() {
        lines.removeAll()
    }
}
