import SwiftUI

struct GitView: View {
    @EnvironmentObject var config: AppConfig

    @State private var branch: String = "?"
    @State private var branches: [String] = []
    @State private var selectedBranch: String = ""
    @State private var changedFiles: [String] = []
    @State private var output: String = ""
    @State private var isBusy = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("▓▓▓ GIT ▓▓▓")
                .font(Term.monoTitle)
                .foregroundColor(Term.green)

            TermPanel(title: "RAMA ACTUAL") {
                HStack {
                    Text(branch)
                        .font(Term.mono)
                        .foregroundColor(Term.green)
                    Spacer()
                    TermButton(label: "REFRESH") { refresh() }
                }
                if !changedFiles.isEmpty {
                    Text("\(changedFiles.count) archivo(s) modificado(s)")
                        .font(Term.monoSmall)
                        .foregroundColor(Term.amber)
                }
            }

            TermPanel(title: "CAMBIAR RAMA") {
                HStack {
                    Picker("", selection: $selectedBranch) {
                        ForEach(branches, id: \.self) { b in
                            Text(b).tag(b)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 240)
                    TermButton(label: "CHECKOUT") { checkout() }
                }
            }

            TermPanel(title: "ACCIONES") {
                HStack(spacing: 10) {
                    TermButton(label: "PULL") { runAction { GitController.pull(projectPath: config.projectPath) } }
                    TermButton(label: "PUSH") { runAction { GitController.push(projectPath: config.projectPath) } }
                    TermButton(label: "FETCH") { runAction { GitController.fetch(projectPath: config.projectPath) } }
                    TermButton(label: "DIFF") { runAction { GitController.diff(projectPath: config.projectPath) } }
                }
            }

            TermPanel(title: "OUTPUT") {
                ScrollView {
                    Text(output.isEmpty ? "(sin salida aun)" : output)
                        .font(Term.monoSmall)
                        .foregroundColor(Term.dimGreen)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minHeight: 200)
            }
        }
        .padding(20)
        .background(Term.background)
        .onAppear { refresh() }
    }

    private func refresh() {
        let status = GitController.status(projectPath: config.projectPath)
        branch = status.branch
        changedFiles = status.changedFiles
        branches = GitController.branches(projectPath: config.projectPath)
        if selectedBranch.isEmpty { selectedBranch = branch }
    }

    private func checkout() {
        guard !selectedBranch.isEmpty else { return }
        let result = GitController.checkout(branch: selectedBranch, projectPath: config.projectPath)
        output = result.output
        refresh()
    }

    private func runAction(_ action: @escaping () -> ShellResult) {
        isBusy = true
        DispatchQueue.global(qos: .userInitiated).async {
            let result = action()
            DispatchQueue.main.async {
                output = result.output.isEmpty ? "(sin salida)" : result.output
                isBusy = false
                refresh()
            }
        }
    }
}
