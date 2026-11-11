import XCTest
@testable import DentistGame

final class SaveAndLocalizationTests: XCTestCase {

    func testLocalizationManagerVietnamese() {
        let loc = LocalizationManager(language: .vietnamese)
        XCTAssertEqual(loc.t("app_name"), "Bác Sĩ Nha Khoa Trẻ Em")
        XCTAssertEqual(loc.t("char_select_title"), "CHỌN BỆNH NHÂN")
        XCTAssertEqual(loc.t("stage_1"), "1. Chải Răng")
    }

    func testLocalizationManagerEnglish() {
        let loc = LocalizationManager(language: .english)
        XCTAssertEqual(loc.t("app_name"), "Children's Doctor Dentist")
        XCTAssertEqual(loc.t("char_select_title"), "CHOOSE PATIENT")
        XCTAssertEqual(loc.t("stage_1"), "1. Teeth Brushing")
    }

    func testLocalizationFormatArgs() {
        let locVi = LocalizationManager(language: .vietnamese)
        XCTAssertEqual(locVi.t("lvl_requires", 3), "Cần 3 sao để mở")

        let locEn = LocalizationManager(language: .english)
        XCTAssertEqual(locEn.t("lvl_requires", 3), "Requires 3 stars to unlock")
    }

    func testCharacterIdentityConsistency() {
        let characters = CharacterModel.createDefaultCharacters()
        XCTAssertEqual(characters.count, 20)

        // Leo: energetic dark-skinned boy
        let leo = characters.first { $0.id == "char_01_leo" }!
        XCTAssertEqual(leo.name, "Leo")
        XCTAssertEqual(leo.gender, "male")
        XCTAssertEqual(leo.skinToneHex, "#8D5524")
        XCTAssertTrue(leo.description.contains("Cậu bé"))

        // Maya: blonde girl
        let maya = characters.first { $0.id == "char_02_maya" }!
        XCTAssertEqual(maya.name, "Maya")
        XCTAssertEqual(maya.gender, "female")
        XCTAssertEqual(maya.skinToneHex, "#FFDBAC")
        XCTAssertEqual(maya.hairColorHex, "#FAD02C")

        // Kenji: dark-haired boy
        let kenji = characters.first { $0.id == "char_03_kenji" }!
        XCTAssertEqual(kenji.name, "Kenji")
        XCTAssertEqual(kenji.gender, "male")
        XCTAssertEqual(kenji.skinToneHex, "#F1C27D")

        // Amara: afro girl
        let amara = characters.first { $0.id == "char_04_amara" }!
        XCTAssertEqual(amara.name, "Amara")
        XCTAssertEqual(amara.gender, "female")
        XCTAssertEqual(amara.skinToneHex, "#5C3836")

        // Mia: pink-haired girl
        let mia = characters.first { $0.id == "char_05_mia" }!
        XCTAssertEqual(mia.name, "Mia")
        XCTAssertEqual(mia.gender, "female")
        XCTAssertEqual(mia.skinToneHex, "#FFDFC4")
        XCTAssertEqual(mia.hairColorHex, "#FF4081")

        // Ben: grey-haired elderly man
        let ben = characters.first { $0.id == "char_06_ben" }!
        XCTAssertEqual(ben.name, "Bác Ben")
        XCTAssertEqual(ben.gender, "male")
        XCTAssertEqual(ben.skinToneHex, "#C68642")
        XCTAssertEqual(ben.hairColorHex, "#E0E0E0")
    }

    func testLevelDefinitionsProgression() {
        XCTAssertEqual(DifficultyLevel.tutorial.targetScore, 250)
        XCTAssertEqual(DifficultyLevel.easy.targetScore, 400)
        XCTAssertEqual(DifficultyLevel.medium.targetScore, 550)
        XCTAssertEqual(DifficultyLevel.hard.targetScore, 750)
    }

    func testStarScoringThresholdsDetailed() {
        // Star calculation boundaries:
        // Incomplete => 0 stars regardless of score
        XCTAssertEqual(ProgressManager.calculateStars(isCompleted: false, score: 0), 0)
        XCTAssertEqual(ProgressManager.calculateStars(isCompleted: false, score: 299), 0)
        XCTAssertEqual(ProgressManager.calculateStars(isCompleted: false, score: 500), 0)
        XCTAssertEqual(ProgressManager.calculateStars(isCompleted: false, score: 800), 0)

        // Completed with score < 300 => 1 star (base completion)
        XCTAssertEqual(ProgressManager.calculateStars(isCompleted: true, score: 0), 1)
        XCTAssertEqual(ProgressManager.calculateStars(isCompleted: true, score: 150), 1)
        XCTAssertEqual(ProgressManager.calculateStars(isCompleted: true, score: 299), 1)

        // Completed with 300 <= score < 500 => 2 stars
        XCTAssertEqual(ProgressManager.calculateStars(isCompleted: true, score: 300), 2)
        XCTAssertEqual(ProgressManager.calculateStars(isCompleted: true, score: 450), 2)
        XCTAssertEqual(ProgressManager.calculateStars(isCompleted: true, score: 499), 2)

        // Completed with score >= 500 => 3 stars
        XCTAssertEqual(ProgressManager.calculateStars(isCompleted: true, score: 500), 3)
        XCTAssertEqual(ProgressManager.calculateStars(isCompleted: true, score: 650), 3)
        XCTAssertEqual(ProgressManager.calculateStars(isCompleted: true, score: 1000), 3)
    }

    func testKenjiAndMiaPlayableAndSaveable() {
        let saveManager = SaveManager.shared
        saveManager.resetAllProgress()

        // Kenji (Level 2B)
        saveManager.recordGameResult(levelId: "LVL_02_EASY", characterId: "char_03_kenji", score: 350, stars: 2)
        XCTAssertEqual(saveManager.getHighScoreForCharacter("char_03_kenji"), 350)
        XCTAssertEqual(saveManager.getStarsForCharacter("char_03_kenji"), 2)

        // Mia (Level 3B)
        saveManager.recordGameResult(levelId: "LVL_03_MEDIUM", characterId: "char_05_mia", score: 520, stars: 3)
        XCTAssertEqual(saveManager.getHighScoreForCharacter("char_05_mia"), 520)
        XCTAssertEqual(saveManager.getStarsForCharacter("char_05_mia"), 3)

        // Verify total stars calculation incorporates both Kenji and Mia
        XCTAssertEqual(saveManager.totalStars, 5)
        XCTAssertEqual(saveManager.totalPatientsCured, 2)

        saveManager.resetAllProgress()
    }
}
