import SwiftUI

enum Term {
    static let background = Color(red: 0.02, green: 0.02, blue: 0.03)
    static let panel = Color(red: 0.05, green: 0.06, blue: 0.05)
    static let border = Color(red: 0.12, green: 0.28, blue: 0.06)
    static let green = Color(red: 0.22, green: 1.0, blue: 0.08)      // #39ff14
    static let dimGreen = Color(red: 0.12, green: 0.68, blue: 0.04)  // #1fae0a
    static let amber = Color(red: 0.54, green: 1.0, blue: 0.36)      // warning
    static let red = Color(red: 1.0, green: 0.23, blue: 0.19)        // #ff3b30
    static let gray = Color(red: 0.4, green: 0.45, blue: 0.4)

    static let mono = Font.custom("Menlo", size: 13)
    static let monoSmall = Font.custom("Menlo", size: 11)
    static let monoTitle = Font.custom("Menlo", size: 15).weight(.bold)
}

struct TermPanel<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("▓▓ \(title) ▓▓")
                .font(Term.monoSmall)
                .foregroundColor(Term.dimGreen)
            content
        }
        .padding(14)
        .background(Term.panel)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Term.border, lineWidth: 1)
        )
    }
}

struct TermButton: View {
    let label: String
    var danger: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("[ \(label) ]")
                .font(Term.mono)
                .foregroundColor(danger ? Term.red : Term.green)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: 3)
                .stroke(danger ? Term.red.opacity(0.5) : Term.border, lineWidth: 1)
        )
    }
}

struct NavButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    var size: CGFloat = 80
    let action: () -> Void

    private var cornerRadius: CGFloat { max(4, size * 0.05) }

    var body: some View {
        Button(action: action) {
            VStack(spacing: size * 0.08) {
                Image(systemName: icon)
                    .font(.system(size: size * 0.26, weight: .semibold))
                Text(label)
                    .font(.custom("Menlo", size: max(9, size * 0.115)))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: size, height: size)
            .foregroundColor(isSelected ? Term.background : Term.green)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: isSelected
                                ? [Term.green, Term.dimGreen]
                                : [Color(red: 0.09, green: 0.11, blue: 0.09), Color(red: 0.03, green: 0.04, blue: 0.03)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Term.green.opacity(isSelected ? 0.9 : 0.35), lineWidth: 1.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(isSelected ? 0.35 : 0.15), .clear],
                            startPoint: .top,
                            endPoint: .center
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: isSelected ? Term.green.opacity(0.65) : .black.opacity(0.7),
                    radius: isSelected ? 8 : 3,
                    x: isSelected ? 0 : 2,
                    y: isSelected ? 0 : 3)
        }
        .buttonStyle(.plain)
    }
}

struct StatusDot: View {
    enum State { case ok, warn, err, unknown }
    let state: State

    var color: Color {
        switch state {
        case .ok: return Term.green
        case .warn: return Term.amber
        case .err: return Term.red
        case .unknown: return Term.gray
        }
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .shadow(color: color.opacity(0.8), radius: 4)
    }
}
