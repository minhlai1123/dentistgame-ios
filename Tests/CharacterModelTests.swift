import XCTest
@testable import DentistGame

final class CharacterModelTests: XCTestCase {
    private var characters: [CharacterModel]!
    private var progressManager: ProgressManager!

    override func setUp() {
        super.setUp()
        characters = CharacterModel.createDefaultCharacters()
        progressManager = ProgressManager()
    }

    func testSixCharactersCreated() {
        XCTAssertEqual(characters.count, 6)
        let expectedIds = [
            "char_01_leo",
            "char_02_maya",
            "char_03_kenji",
            "char_04_amara",
            "char_05_mia",
            "char_06_ben"
        ]
        let actualIds = characters.map { $0.id }
        XCTAssertEqual(actualIds, expectedIds)
    }

    func testAllCharactersHave12Teeth() {
        for character in characters {
            XCTAssertEqual(character.initialTeeth.count, 12, "Character \(character.id) must have 12 teeth")
            let upper = character.initialTeeth.filter { $0.arch == .upper }
            let lower = character.initialTeeth.filter { $0.arch == .lower }
            XCTAssertEqual(upper.count, 6, "Character \(character.id) must have 6 upper teeth")
            XCTAssertEqual(lower.count, 6, "Character \(character.id) must have 6 lower teeth")
        }
    }

    func testCharacterDifferentiation() {
        let leo = characters.first { $0.id == "char_01_leo" }!
        let maya = characters.first { $0.id == "char_02_maya" }!
        let kenji = characters.first { $0.id == "char_03_kenji" }!

        XCTAssertTrue(leo.dentalProblems.contains(.dirtStained))
        XCTAssertTrue(maya.dentalProblems.contains(.calculus))
        XCTAssertTrue(kenji.dentalProblems.contains(.bacteria))
    }

    func testCharacterIsolation() {
        var char1 = characters[0]
        var char2 = characters[1]

        char1.initialTeeth[0] = char1.initialTeeth[0].copy(withState: .clean, progress: 0.0)
        XCTAssertNotEqual(char1.initialTeeth[0].state, char2.initialTeeth[0].state)
    }

    func testProgressManagerCalculation() {
        let leo = characters.first { $0.id == "char_01_leo" }!
        let initialProgress = progressManager.calculateProgress(for: leo.initialTeeth)

        XCTAssertFalse(initialProgress.isAllComplete)
        XCTAssertTrue(initialProgress.remainingIssuesCount > 0)
        XCTAssertEqual(initialProgress.totalTeethCount, 12)

        // All clean scenario
        let allCleanTeeth = leo.initialTeeth.map { $0.copy(withState: .clean, progress: 0.0) }
        let completedProgress = progressManager.calculateProgress(for: allCleanTeeth)

        XCTAssertTrue(completedProgress.isAllComplete)
        XCTAssertEqual(completedProgress.remainingIssuesCount, 0)
        XCTAssertEqual(completedProgress.starCount, 3)
        XCTAssertEqual(completedProgress.progressPercentage, 100)
    }
}
