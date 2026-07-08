import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var config: AppConfig
    @ObservedObject var metro: LiveProcess
    @State private var items: [StatusItem] = []
    @State private var branch: String = "?"
    @State private var lastChecked: Date? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("▓▓▓ PECKIT DEV CENTER ▓▓▓")
                    .font(Term.monoTitle)
                    .foregroundColor(Term.green)

                TermPanel(title: "ESTADO") {
                    HStack {
                        StatusDot(state: metro.isRunning ? .ok : .unknown)
                        Text("Metro")
                            .font(Term.mono)
                            .foregroundColor(Term.gray)
                        Spacer()
                        Text(metro.isRunning ? "corriendo" : "detenido")
                            .font(Term.monoSmall)
                            .foregroundColor(metro.isRunning ? Term.green : Term.gray)
                    }
                    Divider().background(Term.border)
                    ForEach(items) { item in
                        HStack {
                            StatusDot(state: item.state)
                            Text(item.name)
                                .font(Term.mono)
                                .foregroundColor(Term.gray)
                                .frame(width: 110, alignment: .leading)
                            Spacer()
                            Text(item.detail)
                                .font(Term.monoSmall)
                                .foregroundColor(Term.dimGreen)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    HStack {
                        TermButton(label: "REFRESH") { refresh() }
                        if let lastChecked = lastChecked {
                            Text("ultimo check: \(lastChecked.formatted(date: .omitted, time: .standard))")
                                .font(Term.monoSmall)
                                .foregroundColor(Term.gray)
                        }
                    }
                }

                TermPanel(title: "PROYECTO") {
                    HStack {
                        Text("Branch:")
                            .font(Term.mono)
                            .foregroundColor(Term.gray)
                        Text(branch)
                            .font(Term.mono)
                            .foregroundColor(Term.green)
                    }
                    HStack {
                        Text("Ruta:")
                            .font(Term.mono)
                            .foregroundColor(Term.gray)
                        Text(config.projectPath)
                            .font(Term.monoSmall)
                            .foregroundColor(Term.dimGreen)
                    }
                }
            }
            .padding(20)
        }
        .background(Term.background)
        .onAppear { refresh() }
    }

    private func refresh() {
        items = StatusChecker.checkAll(projectPath: config.projectPath)
        branch = GitController.currentBranch(projectPath: config.projectPath)
        lastChecked = Date()
    }
}
