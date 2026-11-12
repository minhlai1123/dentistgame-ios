import SwiftUI

/// TutorialBubble displays a prominent, child-friendly speech bubble with instructions and a skip button.
public struct TutorialBubble: View {
    public let instructionText: String
    public var skipText: String = "Bỏ qua"
    public let onSkip: () -> Void

    @State private var bounce: Bool = false

    public init(
        instructionText: String,
        skipText: String = "Bỏ qua",
        onSkip: @escaping () -> Void
    ) {
        self.instructionText = instructionText
        self.skipText = skipText
        self.onSkip = onSkip
    }

    public var body: some View {
        HStack(spacing: 10) {
            // Friendly lightbulb icon
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.95, blue: 0.78))
                    .frame(width: 32, height: 32)
                Text("💡")
                    .font(.system(size: 16))
            }

            Text(instructionText)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.47, green: 0.21, blue: 0.06))
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Skip button
            Button(action: onSkip) {
                Text(skipText)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.50))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.95, green: 0.96, blue: 0.96))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.82, green: 0.84, blue: 0.86), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(red: 1.0, green: 0.98, blue: 0.92))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(red: 0.98, green: 0.75, blue: 0.14), lineWidth: 2)
        )
        .padding(.horizontal, 16)
        .offset(y: bounce ? -3 : 3)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                bounce = true
            }
        }
    }
}

/// Pulsating Cyan Ring used to highlight active tools or problem teeth.
public struct CyanPulseIndicator: View {
    @State private var pulse: Bool = false

    public init() {}

    public var body: some View {
        Circle()
            .stroke(Color.accentCyan.opacity(pulse ? 0.3 : 0.8), lineWidth: 3)
            .scaleEffect(pulse ? 1.25 : 0.95)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}
