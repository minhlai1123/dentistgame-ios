import SwiftUI

public enum MiniGameType: String, Identifiable, CaseIterable {
    case hippoFood = "HIPPO_FOOD"
    case frogBug = "FROG_BUG"
    case bacteriaBlaster = "BACTERIA_BLASTER"
    case fashionBraces = "FASHION_BRACES"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .hippoFood: return "🦛 Hippo Food Sorting"
        case .frogBug: return "🐸 Frog Bug Catching"
        case .bacteriaBlaster: return "🔫 Bacteria Laser Shooter"
        case .fashionBraces: return "✨ Fashion Braces Studio"
        }
    }

    public var badge: String {
        switch self {
        case .hippoFood: return "Nutrition"
        case .frogBug: return "Reflexes"
        case .bacteriaBlaster: return "Action"
        case .fashionBraces: return "Creativity"
        }
    }

    public var description: String {
        switch self {
        case .hippoFood: return "Sort healthy tooth-strengthening food from cavity-causing sweets."
        case .frogBug: return "Use the frog's tongue to catch pesky bacteria flying around teeth."
        case .bacteriaBlaster: return "Shoot bouncy cavity monsters with the laser blaster before time runs out!"
        case .fashionBraces: return "Design colorful brackets and shiny gems for a fashionable smile."
        }
    }

    public var themeColor: Color {
        switch self {
        case .hippoFood: return Color.purple
        case .frogBug: return Color.green
        case .bacteriaBlaster: return Color.orange
        case .fashionBraces: return Color.pink
        }
    }
}

public struct MiniGameHubView: View {
    @ObservedObject var audioManager: AudioManager
    public let onSelectGame: (MiniGameType) -> Void
    public let onBack: () -> Void

    public init(
        audioManager: AudioManager,
        onSelectGame: @escaping (MiniGameType) -> Void,
        onBack: @escaping () -> Void
    ) {
        self.audioManager = audioManager
        self.onSelectGame = onSelectGame
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.98, blue: 1.0)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                // Header
                HStack(spacing: 14) {
                    Button(action: {
                        audioManager.playButtonClick()
                        onBack()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                                .shadow(color: .black.opacity(0.08), radius: 3)
                            Image(systemName: "arrow.backward")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("EDUCATIONAL MINI-GAMES")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))
                        Text("4 interactive games for healthy dental habits")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Cards list
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(MiniGameType.allCases) { game in
                            Button(action: {
                                audioManager.playButtonClick()
                                onSelectGame(game)
                            }) {
                                HStack(spacing: 14) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack(spacing: 8) {
                                            Text(game.title)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))

                                            Text(game.badge)
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(game.themeColor)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(game.themeColor.opacity(0.15))
                                                .cornerRadius(6)
                                        }

                                        Text(game.description)
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }

                                    Spacer()

                                    ZStack {
                                        Circle()
                                            .fill(game.themeColor)
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(18)
                                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
