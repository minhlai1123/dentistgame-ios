import SwiftUI

public struct SplashView: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var localizationManager: LocalizationManager
    public let onEnterGame: () -> Void

    @State private var pulse: Bool = false

    public init(
        audioManager: AudioManager,
        localizationManager: LocalizationManager,
        onEnterGame: @escaping () -> Void
    ) {
        self.audioManager = audioManager
        self.localizationManager = localizationManager
        self.onEnterGame = onEnterGame
    }

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.49, green: 0.83, blue: 0.99), Color(red: 0.01, green: 0.52, blue: 0.78)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Animated Tooth Emblem
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 140, height: 140)
                        .scaleEffect(pulse ? 1.06 : 0.94)
                        .shadow(color: .black.opacity(0.12), radius: 10, y: 4)

                    Text("🦷")
                        .font(.system(size: 64))
                }

                VStack(spacing: 8) {
                    Text(localizationManager.t("app_name"))
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("✨ Nụ Cười Sáng - Bé Khỏe Vui ✨")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.9))
                }

                Spacer().frame(height: 30)

                Text(localizationManager.t("splash_tap"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.8))
            }
            .padding()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onEnterGame()
        }
        .onAppear {
            audioManager.playStarReward()
            withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                onEnterGame()
            }
        }
    }
}
