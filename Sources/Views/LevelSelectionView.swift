import SwiftUI

public struct LevelCardItem: Identifiable {
    public let id: String
    public let level: DifficultyLevel
    public let characterId: String
    public let missionTitle: String
    public let requiredStars: Int

    public init(level: DifficultyLevel, characterId: String, missionTitle: String, requiredStars: Int) {
        self.id = characterId
        self.level = level
        self.characterId = characterId
        self.missionTitle = missionTitle
        self.requiredStars = requiredStars
    }
}

public struct LevelSelectionView: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var saveManager: SaveManager
    @ObservedObject var localizationManager: LocalizationManager
    public let characters: [CharacterModel]
    public let onSelectCharacter: (CharacterModel) -> Void
    public let onBack: () -> Void

    public init(
        audioManager: AudioManager,
        saveManager: SaveManager,
        localizationManager: LocalizationManager,
        characters: [CharacterModel] = CharacterModel.createDefaultCharacters(),
        onSelectCharacter: @escaping (CharacterModel) -> Void,
        onBack: @escaping () -> Void
    ) {
        self.audioManager = audioManager
        self.saveManager = saveManager
        self.localizationManager = localizationManager
        self.characters = characters
        self.onSelectCharacter = onSelectCharacter
        self.onBack = onBack
    }

    private let levelItems: [LevelCardItem] = [
        LevelCardItem(level: .tutorial, characterId: "char_01_leo", missionTitle: "Cấp 1: Khởi Động Đánh Răng", requiredStars: 0),
        LevelCardItem(level: .easy, characterId: "char_02_maya", missionTitle: "Cấp 2 (A): Vệ Sinh & Trị Sâu Răng Nhẹ", requiredStars: 1),
        LevelCardItem(level: .easy, characterId: "char_03_kenji", missionTitle: "Cấp 2 (B): Cạo Vôi & Khám Men Răng", requiredStars: 1),
        LevelCardItem(level: .medium, characterId: "char_04_amara", missionTitle: "Cấp 3 (A): Nha Khoa Đa Khoa & Nhổ Răng", requiredStars: 3),
        LevelCardItem(level: .medium, characterId: "char_05_mia", missionTitle: "Cấp 3 (B): Phục Hồi Ổ Sâu Vi Khuẩn", requiredStars: 3),
        LevelCardItem(level: .hard, characterId: "char_06_ben", missionTitle: "Cấp 4: Thử Thách Bác Sĩ Toàn Diện", requiredStars: 6)
    ]

    public var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.98, blue: 1.0)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack(spacing: 12) {
                    Button(action: {
                        audioManager.playButtonClick()
                        onBack()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 42, height: 42)
                                .shadow(color: .black.opacity(0.06), radius: 3)
                            Image(systemName: "arrow.backward")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(localizationManager.t("level_select_title"))
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))
                        Text(localizationManager.t("level_select_subtitle"))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Total Stars pill
                    HStack(spacing: 4) {
                        Text("⭐")
                        Text("\(saveManager.totalStars)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 3)
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Level Cards List
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(levelItems) { item in
                            let isUnlocked = saveManager.isLevelUnlocked(item.level.rawValue)
                            let stars = saveManager.getStarsForCharacter(item.characterId)
                            let highScore = saveManager.getHighScoreForCharacter(item.characterId)
                            let assignedCharacter = characters.first(where: { $0.id == item.characterId }) ?? characters[0]

                            Button(action: {
                                if isUnlocked {
                                    audioManager.playCharacterReaction()
                                    onSelectCharacter(assignedCharacter)
                                }
                            }) {
                                HStack(spacing: 14) {
                                    // Avatar
                                    ZStack {
                                        Circle()
                                            .fill(isUnlocked ? Color(hex: assignedCharacter.skinToneHex) : Color.gray.opacity(0.3))
                                            .frame(width: 54, height: 54)
                                        Text(isUnlocked ? "😊" : "🔒")
                                            .font(.system(size: 24))
                                    }

                                    // Info
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.missionTitle)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(isUnlocked ? Color(red: 0.06, green: 0.09, blue: 0.16) : .secondary)

                                        Text("Bệnh nhân: \(assignedCharacter.name)")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(isUnlocked ? .blue : .gray)

                                        if isUnlocked {
                                            HStack(spacing: 8) {
                                                HStack(spacing: 2) {
                                                    ForEach(1...3, id: \.self) { i in
                                                        Text(i <= stars ? "⭐" : "☆")
                                                            .font(.system(size: 12))
                                                    }
                                                }
                                                if highScore > 0 {
                                                    Text(localizationManager.t("lvl_high_score", highScore))
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        } else {
                                            Text(localizationManager.t("lvl_requires", item.requiredStars))
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.red)
                                        }
                                    }

                                    Spacer()

                                    // Action Indicator
                                    ZStack {
                                        Circle()
                                            .fill(isUnlocked ? Color.blue : Color.gray.opacity(0.3))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: isUnlocked ? "play.fill" : "lock.fill")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(14)
                                .background(isUnlocked ? Color.white : Color(red: 0.92, green: 0.94, blue: 0.96))
                                .cornerRadius(18)
                                .shadow(color: .black.opacity(isUnlocked ? 0.06 : 0.02), radius: 6)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(!isUnlocked)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
