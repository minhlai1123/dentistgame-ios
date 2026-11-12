import SwiftUI

/// PatientIntroDialog introduces the selected patient with a large cartoon avatar,
/// emotional reaction, dental condition summary, and difficulty rating.
public struct PatientIntroDialog: View {
    public let character: CharacterModel
    public let difficultyTitle: String
    public var startBtnText: String = "BẮT ĐẦU ĐIỀU TRỊ"
    public let onDismiss: () -> Void
    public let onStartTreatment: () -> Void

    @State private var pulse: Bool = false

    public init(
        character: CharacterModel,
        difficultyTitle: String,
        startBtnText: String = "BẮT ĐẦU ĐIỀU TRỊ",
        onDismiss: @escaping () -> Void,
        onStartTreatment: @escaping () -> Void
    ) {
        self.character = character
        self.difficultyTitle = difficultyTitle
        self.startBtnText = startBtnText
        self.onDismiss = onDismiss
        self.onStartTreatment = onStartTreatment
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 16) {
                // Difficulty Badge
                HStack(spacing: 4) {
                    Text("⭐")
                    Text(difficultyTitle)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.70, green: 0.35, blue: 0.0))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color(red: 1.0, green: 0.95, blue: 0.78))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 0.96, green: 0.62, blue: 0.04), lineWidth: 1)
                )

                // Big Patient Avatar
                ZStack {
                    Circle()
                        .fill(Color(red: 0.88, green: 0.95, blue: 1.0))
                        .frame(width: 130, height: 130)
                        .overlay(
                            Circle().stroke(Color.skyBlueDark, lineWidth: 4)
                        )

                    // Patient portrait / worried expression
                    Image(characterPortraitName(for: character))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                }
                .scaleEffect(pulse ? 1.05 : 0.97)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                }

                // Patient Name
                Text(character.name)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))

                // Backstory & Dental issues
                Text(character.description)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.28, green: 0.33, blue: 0.41))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 12)

                // Mission Pills
                HStack(spacing: 8) {
                    ForEach(character.dentalProblems, id: \.self) { problem in
                        let info = missionInfo(for: problem)
                        Text("• \(info.0)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(info.1)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(info.1.opacity(0.12))
                            .cornerRadius(10)
                    }
                }

                Spacer().frame(height: 8)

                // Start Treatment Button
                Button(action: onStartTreatment) {
                    Text(startBtnText)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.skyBlueDark)
                        .cornerRadius(20)
                        .shadow(color: Color.skyBlueDark.opacity(0.3), radius: 6, x: 0, y: 3)
                }
            }
            .padding(24)
            .background(
                LinearGradient(
                    colors: [Color(hex: "F0F9FF"), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(28)
            .padding(.horizontal, 24)
            .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
        }
    }

    private func characterPortraitName(for char: CharacterModel) -> String {
        return "\(char.id)_portrait"
    }

    private func missionInfo(for state: ToothState) -> (String, Color) {
        switch state {
        case .dirtStained:
            return ("Chải Răng", Color(red: 0.01, green: 0.52, blue: 0.78))
        case .calculus:
            return ("Cạo Vôi", Color(red: 0.02, green: 0.59, blue: 0.41))
        case .bacteria:
            return ("Trị Sâu Răng", Color(red: 0.86, green: 0.15, blue: 0.15))
        case .necroticCracked:
            return ("Trồng Răng Sứ", Color(red: 0.49, green: 0.23, blue: 0.93))
        default:
            return (state.displayName, Color.gray)
        }
    }
}
