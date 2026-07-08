import SwiftUI

/// A small geometric robot-face mark drawn from shapes, in terminal green.
struct RobotLogo: View {
    var size: CGFloat = 120

    var body: some View {
        ZStack {
            // antenna
            Rectangle()
                .fill(Term.green)
                .frame(width: size * 0.03, height: size * 0.14)
                .offset(y: -size * 0.21)
            Circle()
                .fill(Term.green)
                .frame(width: size * 0.1, height: size * 0.1)
                .shadow(color: Term.green.opacity(0.85), radius: size * 0.06)
                .offset(y: -size * 0.29)

            // head
            RoundedRectangle(cornerRadius: size * 0.08)
                .stroke(Term.green, lineWidth: size * 0.045)
                .frame(width: size * 0.72, height: size * 0.58)
                .offset(y: size * 0.15)

            // eyes
            HStack(spacing: size * 0.14) {
                RoundedRectangle(cornerRadius: size * 0.02)
                    .fill(Term.green)
                    .frame(width: size * 0.13, height: size * 0.13)
                RoundedRectangle(cornerRadius: size * 0.02)
                    .fill(Term.green)
                    .frame(width: size * 0.13, height: size * 0.13)
            }
            .offset(y: size * 0.12)

            // mouth
            RoundedRectangle(cornerRadius: size * 0.02)
                .fill(Term.green)
                .frame(width: size * 0.34, height: size * 0.05)
                .offset(y: size * 0.31)
        }
        .frame(width: size, height: size)
    }
}
