import Foundation

public final class SaveManager: ObservableObject, @unchecked Sendable {
    public static let shared = SaveManager()

    private let defaults = UserDefaults.standard

    @Published public private(set) var unlockedLevels: Set<String>
    @Published public private(set) var totalStars: Int = 0
    @Published public private(set) var totalPatientsCured: Int = 0

    public init() {
        let savedUnlocked = defaults.stringArray(forKey: "unlocked_levels") ?? ["LVL_01_TUTORIAL"]
        self.unlockedLevels = Set(savedUnlocked)
        self.totalStars = calculateTotalStars()
        self.totalPatientsCured = calculateTotalPatientsCured()
    }

    public func isLevelUnlocked(_ levelId: String) -> Bool {
        if levelId == "LVL_01_TUTORIAL" { return true }
        return unlockedLevels.contains(levelId)
    }

    public func unlockLevel(_ levelId: String) {
        unlockedLevels.insert(levelId)
        defaults.set(Array(unlockedLevels), forKey: "unlocked_levels")
    }

    public func getStarsForLevel(_ levelId: String) -> Int {
        return defaults.integer(forKey: "stars_\(levelId)")
    }

    public func getHighScoreForLevel(_ levelId: String) -> Int {
        return defaults.integer(forKey: "high_score_\(levelId)")
    }

    public func getStarsForCharacter(_ characterId: String) -> Int {
        return defaults.integer(forKey: "char_stars_\(characterId)")
    }

    public func getHighScoreForCharacter(_ characterId: String) -> Int {
        return defaults.integer(forKey: "char_high_score_\(characterId)")
    }

    public static let allCharacterIds: [String] = [
        "char_01_leo", "char_02_maya", "char_03_kenji", "char_04_amara", "char_05_mia", "char_06_ben",
        "char_07_lucas", "char_08_hana", "char_09_toby", "char_10_zoe", "char_11_aarav", "char_12_elena",
        "char_13_kai", "char_14_fatima", "char_15_sam", "char_16_oliver", "char_17_zara", "char_18_mateo",
        "char_19_linh", "char_20_arthur"
    ]

    private func calculateTotalStars() -> Int {
        return Self.allCharacterIds.reduce(0) { $0 + getStarsForCharacter($1) }
    }

    private func calculateTotalPatientsCured() -> Int {
        return Self.allCharacterIds.filter { getStarsForCharacter($0) > 0 }.count
    }

    public func recordGameResult(levelId: String, characterId: String, score: Int, stars: Int) {
        let currentBestScore = getHighScoreForLevel(levelId)
        let currentBestStars = getStarsForLevel(levelId)
        let newBestScore = max(currentBestScore, score)
        let newBestStars = max(currentBestStars, stars)

        let currentBestCharScore = getHighScoreForCharacter(characterId)
        let currentBestCharStars = getStarsForCharacter(characterId)
        let newBestCharScore = max(currentBestCharScore, score)
        let newBestCharStars = max(currentBestCharStars, stars)

        defaults.set(newBestScore, forKey: "high_score_\(levelId)")
        defaults.set(newBestStars, forKey: "stars_\(levelId)")
        defaults.set(newBestCharStars, forKey: "char_stars_\(characterId)")
        defaults.set(newBestCharScore, forKey: "char_high_score_\(characterId)")

        self.totalStars = calculateTotalStars()
        self.totalPatientsCured = calculateTotalPatientsCured()

        // Progression unlocks
        if totalStars >= 1 { unlockLevel("LVL_02_EASY") }
        if totalStars >= 3 { unlockLevel("LVL_03_MEDIUM") }
        if totalStars >= 6 { unlockLevel("LVL_04_HARD") }
    }

    public func getSavedLanguage() -> AppLanguage {
        let code = defaults.string(forKey: "app_language") ?? "vi"
        return (code == "en") ? .english : .vietnamese
    }

    public func saveLanguage(_ language: AppLanguage) {
        defaults.set(language.rawValue, forKey: "app_language")
    }

    public func resetAllProgress() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        unlockedLevels = ["LVL_01_TUTORIAL"]
        totalStars = 0
        totalPatientsCured = 0
    }
}
