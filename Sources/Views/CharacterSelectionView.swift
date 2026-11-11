import SwiftUI

public struct CharacterSelectionView: View {
    public let characters: [CharacterModel]
    public let onSelectCharacter: (CharacterModel) -> Void
    public let onOpenMiniGames: (() -> Void)?
    public let onBack: (() -> Void)?

    @State private var showSettings: Bool = false
    @State private var selectedFilter: Int = 0 // 0: All, 1: Easy, 2: Medium, 3: Hard
    @ObservedObject private var audioManager = AudioManager.shared

    public init(
        characters: [CharacterModel] = CharacterModel.createDefaultCharacters(),
        onSelectCharacter: @escaping (CharacterModel) -> Void,
        onOpenMiniGames: (() -> Void)? = nil,
        onBack: (() -> Void)? = nil
    ) {
        self.characters = characters
        self.onSelectCharacter = onSelectCharacter
        self.onOpenMiniGames = onOpenMiniGames
        self.onBack = onBack
    }

    private var filteredCharacters: [CharacterModel] {
        switch selectedFilter {
        case 1:
            return characters.filter {
                let lvl = DifficultyLevel.getLevelForCharacter(characterId: $0.id)
                return lvl == .tutorial || lvl == .easy
            }
        case 2:
            return characters.filter { DifficultyLevel.getLevelForCharacter(characterId: $0.id) == .medium }
        case 3:
            return characters.filter { DifficultyLevel.getLevelForCharacter(characterId: $0.id) == .hard }
        default:
            return characters
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    public var body: some View {
        ZStack {
            Color(red: 0.486, green: 0.835, blue: 0.953) // Pastel Blue
                .ignoresSafeArea()

            VStack(spacing: 12) {
                // Header with Back Button and Settings Gear Button
                HStack {
                    if let onBack = onBack {
                        Button(action: {
                            audioManager.playButtonClick()
                            onBack()
                        }) {
                            Image(systemName: "arrow.backward")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.blue)
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                        }
                    } else {
                        Spacer().frame(width: 40)
                    }

                    Spacer()

                    VStack(spacing: 4) {
                        Text("CHỌN BỆNH NHÂN")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))
                        Text("Khám và chữa trị cho \(characters.count) bệnh nhân hoạt hình")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.20, green: 0.25, blue: 0.33))
                    }

                    Spacer()

                    Button(action: {
                        audioManager.playButtonClick()
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.35, green: 0.45, blue: 0.55))
                            .frame(width: 40, height: 40)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // Educational Mini-games Hub Banner
                if let onMiniGames = onOpenMiniGames {
                    Button(action: {
                        audioManager.playButtonClick()
                        onMiniGames()
                    }) {
                        HStack(spacing: 10) {
                            Text("🎮")
                                .font(.system(size: 20))
                            Text("KHÁM PHÁ 4 MINI-GAMES GIÁO DỤC")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            Text("▶")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.6, green: 0.3, blue: 0.9), Color(red: 0.2, green: 0.6, blue: 0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
                    }
                    .padding(.horizontal, 16)
                }

                // Filter Tabs & Quick Random Picker
                HStack(spacing: 8) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            FilterChip(title: "TẤT CẢ (\(characters.count))", isSelected: selectedFilter == 0) {
                                audioManager.playButtonClick()
                                selectedFilter = 0
                            }
                            FilterChip(title: "DỄ (7)", isSelected: selectedFilter == 1) {
                                audioManager.playButtonClick()
                                selectedFilter = 1
                            }
                            FilterChip(title: "VỪA (7)", isSelected: selectedFilter == 2) {
                                audioManager.playButtonClick()
                                selectedFilter = 2
                            }
                            FilterChip(title: "KHÓ (6)", isSelected: selectedFilter == 3) {
                                audioManager.playButtonClick()
                                selectedFilter = 3
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    if let randomChar = filteredCharacters.randomElement() {
                        Button(action: {
                            audioManager.playCharacterReaction()
                            onSelectCharacter(randomChar)
                        }) {
                            Text("🎲")
                                .font(.system(size: 16))
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
                        }
                        .padding(.trailing, 16)
                    }
                }

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredCharacters) { character in
                            CharacterCard(character: character) {
                                audioManager.playCharacterReaction()
                                onSelectCharacter(character)
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .onAppear {
            audioManager.startBgm(named: "bgm_main_menu")
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet()
        }
    }
}

public struct CharacterCard: View {
    public let character: CharacterModel
    public let onClick: () -> Void

    public var body: some View {
        Button(action: onClick) {
            VStack(spacing: 10) {
                // Character Portrait Avatar
                ZStack {
                    Circle()
                        .fill(Color(hex: character.skinToneHex))
                        .frame(width: 84, height: 84)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: character.shirtColorHex), lineWidth: 3)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)

                    // Cartoon eyes and smile
                    VStack(spacing: 6) {
                        HStack(spacing: 18) {
                            Circle().fill(Color(red: 0.1, green: 0.1, blue: 0.1)).frame(width: 8, height: 8)
                            Circle().fill(Color(red: 0.1, green: 0.1, blue: 0.1)).frame(width: 8, height: 8)
                        }
                        Arc(startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
                            .stroke(Color(red: 0.7, green: 0.2, blue: 0.2), lineWidth: 3)
                            .frame(width: 22, height: 10)
                    }
                }
                .padding(.top, 6)

                Text(character.name)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))

                // Difficulty badge
                let diff = DifficultyLevel.getLevelForCharacter(characterId: character.id)
                Text(diff.title.components(separatedBy: ":").first ?? "Dễ")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(Color(red: 0.02, green: 0.52, blue: 0.88))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(red: 0.02, green: 0.52, blue: 0.88).opacity(0.12))
                    .cornerRadius(8)

                Text(character.description)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.55))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 30)

                Text("KHÁM RĂNG")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.08, green: 0.52, blue: 0.88))
                    .cornerRadius(12)
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct Arc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        return path
    }
}

public struct FilterChip: View {
    public let title: String
    public let isSelected: Bool
    public let action: () -> Void

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? .white : Color(red: 0.20, green: 0.25, blue: 0.33))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? Color(red: 0.08, green: 0.52, blue: 0.88) : Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.06), radius: 2, y: 1)
        }
    }
}
