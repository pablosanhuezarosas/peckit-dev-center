import SwiftUI

struct MetroView: View {
    @EnvironmentObject var config: AppConfig
    @ObservedObject var metro: LiveProcess

    @State private var filter: LogFilter = .all
    @State private var search: String = ""

    enum LogFilter: String, CaseIterable {
        case all = "TODO"
        case errors = "ERRORS"
        case warnings = "WARNINGS"
    }

    var filteredLines: [String] {
        var lines = metro.lines
        switch filter {
        case .all: break
        case .errors: lines = lines.filter { $0.uppercased().contains("ERROR") }
        case .warnings: lines = lines.filter { $0.uppercased().contains("WARN") }
        }
        if !search.isEmpty {
            lines = lines.filter { $0.localizedCaseInsensitiveContains(search) }
        }
        return lines
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("▓▓▓ METRO ▓▓▓")
                .font(Term.monoTitle)
                .foregroundColor(Term.green)

            TermPanel(title: "CONTROL") {
                HStack(spacing: 10) {
                    TermButton(label: metro.isRunning ? "RUNNING" : "START") { startMetro(clearCache: false) }
                    TermButton(label: "STOP", danger: true, action: metro.stop)
                    TermButton(label: "RESTART") { restartMetro(clearCache: false) }
                    TermButton(label: "CLEAR CACHE + START") { startMetro(clearCache: true) }
                }
                HStack {
                    Text("Puerto:")
                        .font(Term.mono)
                        .foregroundColor(Term.gray)
                    TextField("8081", text: $config.metroPort)
                        .font(Term.mono)
                        .foregroundColor(Term.green)
                        .textFieldStyle(.plain)
                        .frame(width: 80)
                        .padding(4)
                        .overlay(RoundedRectangle(cornerRadius: 3).stroke(Term.border))
                }
            }

            TermPanel(title: "LOGS") {
                HStack {
                    ForEach(LogFilter.allCases, id: \.self) { f in
                        Button(action: { filter = f }) {
                            Text(f.rawValue)
                                .font(Term.monoSmall)
                                .foregroundColor(filter == f ? Term.green : Term.gray)
                                .underline(filter == f)
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                    TermButton(label: "CLEAR") { metro.clear() }
                }
                TextField("buscar...", text: $search)
                    .font(Term.monoSmall)
                    .foregroundColor(Term.green)
                    .textFieldStyle(.plain)
                    .padding(4)
                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(Term.border))

                ScrollView {
                    ScrollViewReader { proxy in
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(Array(filteredLines.enumerated()), id: \.offset) { idx, line in
                                Text(line)
                                    .font(Term.monoSmall)
                                    .foregroundColor(colorFor(line))
                                    .textSelection(.enabled)
                                    .id(idx)
                            }
                        }
                        .onChange(of: filteredLines.count) { _ in
                            if let last = filteredLines.indices.last {
                                proxy.scrollTo(last, anchor: .bottom)
                            }
                        }
                    }
                }
                .frame(minHeight: 280)
            }
        }
        .padding(20)
        .background(Term.background)
    }

    private func colorFor(_ line: String) -> Color {
        let upper = line.uppercased()
        if upper.contains("ERROR") { return Term.red }
        if upper.contains("WARN") { return Term.amber }
        return Term.dimGreen
    }

    private func startMetro(clearCache: Bool) {
        var args = ["expo", "start", "--port", config.metroPort]
        if clearCache { args.append("-c") }
        metro.start(command: "npx", args: args, cwd: config.projectPath)
    }

    private func restartMetro(clearCache: Bool) {
        metro.stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            startMetro(clearCache: clearCache)
        }
    }
}
