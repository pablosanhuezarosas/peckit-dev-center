import SwiftUI

enum Tab: String, CaseIterable, Identifiable {
    case dashboard = "DASHBOARD"
    case metro = "METRO"
    case git = "GIT"
    case devices = "DEVICES"
    case buildRun = "BUILD & RUN"
    case quickActions = "QUICK ACTIONS"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "gauge"
        case .metro: return "antenna.radiowaves.left.and.right"
        case .git: return "arrow.triangle.branch"
        case .devices: return "iphone"
        case .buildRun: return "hammer.fill"
        case .quickActions: return "bolt.fill"
        }
    }
}

private let sidebarColumns = [GridItem(.fixed(80), spacing: 10), GridItem(.fixed(80), spacing: 10)]
private let homeColumns = [GridItem(.fixed(140), spacing: 24), GridItem(.fixed(140), spacing: 24), GridItem(.fixed(140), spacing: 24)]

struct ContentView: View {
    @StateObject private var metro = LiveProcess()
    @State private var selectedTab: Tab? = nil

    var body: some View {
        Group {
            if let tab = selectedTab {
                HStack(spacing: 0) {
                    sidebar(current: tab)
                    detail(for: tab)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                homeScreen
            }
        }
        .background(Term.background)
        .frame(minWidth: 900, minHeight: 620)
    }

    private var homeScreen: some View {
        VStack(spacing: 30) {
            Spacer()
            RobotLogo(size: 100)
            VStack(spacing: 4) {
                Text("PECKIT DEV CENTER")
                    .font(Term.monoTitle)
                    .foregroundColor(Term.green)
                Text("by Pablo Sanhueza Rosas")
                    .font(Term.monoSmall)
                    .foregroundColor(Term.dimGreen)
            }
            LazyVGrid(columns: homeColumns, spacing: 24) {
                ForEach(Tab.allCases) { tab in
                    NavButton(icon: tab.icon, label: tab.rawValue, isSelected: false, size: 140) {
                        selectedTab = tab
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func sidebar(current: Tab) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: { selectedTab = nil }) {
                HStack(spacing: 8) {
                    RobotLogo(size: 22)
                    Text("HOME")
                        .font(Term.monoSmall)
                        .foregroundColor(Term.dimGreen)
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 10)

            LazyVGrid(columns: sidebarColumns, spacing: 10) {
                ForEach(Tab.allCases) { tab in
                    NavButton(icon: tab.icon, label: tab.rawValue, isSelected: current == tab, size: 80) {
                        selectedTab = tab
                    }
                }
            }
            Spacer()
        }
        .padding(16)
        .frame(width: 200)
        .background(Term.panel)
        .overlay(Rectangle().frame(width: 1).foregroundColor(Term.border), alignment: .trailing)
    }

    @ViewBuilder
    private func detail(for tab: Tab) -> some View {
        switch tab {
        case .dashboard: DashboardView(metro: metro)
        case .metro: MetroView(metro: metro)
        case .git: GitView()
        case .devices: DevicesView()
        case .buildRun: BuildRunView()
        case .quickActions: QuickActionsView()
        }
    }
}
