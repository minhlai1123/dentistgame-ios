import SwiftUI

public struct ResultView: View {
    public let character: CharacterModel
    public let score: Int
    public let stars: Int
    public let hasNextLevel: Bool
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var localizationManager: LocalizationManager
    public let onReplay: () -> Void
    public let onNextLevel: () -> Void
    public let onBackToMenu: () -> Void

    @State private var pulse: Bool = false

    public init(
        character: CharacterModel,
        score: Int,
        stars: Int,
        hasNextLevel: Bool,
        audioManager: AudioManager,
        localizationManager: LocalizationManager,
        onReplay: @escaping () -> Void,
        onNextLevel: @escaping () -> Void,
        onBackToMenu: @escaping () -> Void
    ) {
        self.character = character
        self.score = score
        self.stars = stars
        self.hasNextLevel = hasNextLevel
        self.audioManager = audioManager
        self.localizationManager = localizationManager
        self.onReplay = onReplay
        self.onNextLevel = onNextLevel
        self.onBackToMenu = onBackToMenu
    }

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.92), Color(red: 0.06, green: 0.09, blue: 0.16).opacity(0.96)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Card
                VStack(spacing: 16) {
                    // Victorious Avatar
                    ZStack {
                        Circle()
                            .fill(Color(hex: character.skinToneHex))
                            .frame(width: 88, height: 88)
                            .overlay(
                                Circle().stroke(Color.yellow, lineWidth: 4)
                            )
                        Text("😄")
                            .font(.system(size: 46))
                    }

                    Text(localizationManager.t("result_title"))
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))

                    Text("Bệnh nhân \(character.name) đã có nụ cười rạng rỡ!")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    // Stars Display with Animation
                    HStack(spacing: 8) {
                        ForEach(1...3, id: \.self) { i in
                            Text(i <= stars ? "⭐" : "☆")
                                .font(.system(size: 36))
                                .scaleEffect(pulse ? 1.08 : 0.92)
                        }
                    }

                    // Score pill
                    Text(localizationManager.t("result_score", score))
                        .font(.system(size: 17, weight: .black))
                        .foregroundColor(Color.orange)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Color.yellow.opacity(0.18))
                        .cornerRadius(14)

                    // Action buttons
                    VStack(spacing: 10) {
                        if hasNextLevel {
                            Button(action: {
                                audioManager.playButtonClick()
                                onNextLevel()
                            }) {
                                HStack {
                                    Text("▶")
                                    Text(localizationManager.t("result_btn_next"))
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.green)
                                .cornerRadius(14)
                            }
                        }

                        Button(action: {
                            audioManager.playButtonClick()
                            onReplay()
                        }) {
                            HStack {
                                Text("🔄")
                                Text(localizationManager.t("result_btn_replay"))
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.blue)
                            .cornerRadius(14)
                        }

                        Button(action: {
                            audioManager.playButtonClick()
                            onBackToMenu()
                        }) {
                            HStack {
                                Text("🏠")
                                Text(localizationManager.t("result_btn_menu"))
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(14)
                        }
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(26)
                .shadow(color: .black.opacity(0.15), radius: 12)
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            audioManager.playVictoryCelebration()
            withAnimation(Animation.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
