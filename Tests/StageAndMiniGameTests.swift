import XCTest
@testable import DentistGame

final class StageAndMiniGameTests: XCTestCase {

    func testStageProgressionPipeline() {
        let coordinator = StageCoordinator()

        // Clean slate teeth
        var teeth = CharacterModel.createDefaultCharacters()[0].initialTeeth.map {
            ToothModel(
                id: $0.id,
                arch: $0.arch,
                normalizedX: $0.normalizedX,
                normalizedY: $0.normalizedY,
                widthRatio: $0.widthRatio,
                heightRatio: $0.heightRatio,
                state: .clean
            )
        }
        var debris = ForeignDebris.createDefaultDebris()

        // 1. Brushing stage
        teeth[0] = ToothModel(id: teeth[0].id, arch: teeth[0].arch, normalizedX: teeth[0].normalizedX, normalizedY: teeth[0].normalizedY, widthRatio: teeth[0].widthRatio, heightRatio: teeth[0].heightRatio, state: .dirtStained)
        XCTAssertEqual(coordinator.determineCurrentStage(teeth: teeth, debrisList: debris), .brushing)

        // Clean dirt -> Scaling stage
        teeth[0] = ToothModel(id: teeth[0].id, arch: teeth[0].arch, normalizedX: teeth[0].normalizedX, normalizedY: teeth[0].normalizedY, widthRatio: teeth[0].widthRatio, heightRatio: teeth[0].heightRatio, state: .clean)
        teeth[1] = ToothModel(id: teeth[1].id, arch: teeth[1].arch, normalizedX: teeth[1].normalizedX, normalizedY: teeth[1].normalizedY, widthRatio: teeth[1].widthRatio, heightRatio: teeth[1].heightRatio, state: .calculus)
        XCTAssertEqual(coordinator.determineCurrentStage(teeth: teeth, debrisList: debris), .scaling)

        // Clean calculus -> Decay stage
        teeth[1] = ToothModel(id: teeth[1].id, arch: teeth[1].arch, normalizedX: teeth[1].normalizedX, normalizedY: teeth[1].normalizedY, widthRatio: teeth[1].widthRatio, heightRatio: teeth[1].heightRatio, state: .clean)
        teeth[2] = ToothModel(id: teeth[2].id, arch: teeth[2].arch, normalizedX: teeth[2].normalizedX, normalizedY: teeth[2].normalizedY, widthRatio: teeth[2].widthRatio, heightRatio: teeth[2].heightRatio, state: .bacteria)
        XCTAssertEqual(coordinator.determineCurrentStage(teeth: teeth, debrisList: debris), .decay)

        // Clean decay -> Surgery stage (due to foreign debris)
        teeth[2] = ToothModel(id: teeth[2].id, arch: teeth[2].arch, normalizedX: teeth[2].normalizedX, normalizedY: teeth[2].normalizedY, widthRatio: teeth[2].widthRatio, heightRatio: teeth[2].heightRatio, state: .clean)
        XCTAssertEqual(coordinator.determineCurrentStage(teeth: teeth, debrisList: debris), .surgery)

        // Clear debris -> Complete stage
        for i in debris.indices {
            debris[i] = ForeignDebris(id: debris[i].id, name: debris[i].name, normalizedX: debris[i].normalizedX, normalizedY: debris[i].normalizedY, imageName: debris[i].imageName, isRemoved: true)
        }
        XCTAssertEqual(coordinator.determineCurrentStage(teeth: teeth, debrisList: debris), .complete)
    }

    func testSyringeAnesthesiaGating() {
        let coordinator = StageCoordinator()
        XCTAssertFalse(coordinator.canExtractTooth())

        let success = coordinator.applyAnesthesia()
        XCTAssertTrue(success)
        XCTAssertTrue(coordinator.canExtractTooth())

        coordinator.resetAnesthesia()
        XCTAssertFalse(coordinator.canExtractTooth())
    }

    func testForeignDebrisGating() {
        let debrisList = ForeignDebris.createDefaultDebris()
        XCTAssertEqual(debrisList.count, 4)
        XCTAssertTrue(debrisList.allSatisfy { !$0.isRemoved })
        XCTAssertEqual(debrisList[0].id, "debris_banana")
    }

    func testLevelMappingAndDifficulty() {
        XCTAssertEqual(DifficultyLevel.getLevelForCharacter(characterId: "char_01_leo"), .tutorial)
        XCTAssertEqual(DifficultyLevel.getLevelForCharacter(characterId: "char_02_maya"), .easy)
        XCTAssertEqual(DifficultyLevel.getLevelForCharacter(characterId: "char_03_kenji"), .easy)
        XCTAssertEqual(DifficultyLevel.getLevelForCharacter(characterId: "char_04_amara"), .medium)
        XCTAssertEqual(DifficultyLevel.getLevelForCharacter(characterId: "char_05_mia"), .medium)
        XCTAssertEqual(DifficultyLevel.getLevelForCharacter(characterId: "char_06_ben"), .hard)
    }

    func testHippoFoodSortingEngine() {
        let engine = HippoFoodEngine()
        XCTAssertEqual(engine.score, 0)
        XCTAssertEqual(engine.currentItemIndex, 0)

        // Item 0 is apple (good)
        let appleFeed = engine.feedToHippo()
        XCTAssertTrue(appleFeed.success)
        XCTAssertEqual(engine.score, 10)

        // Item 1 is candy (bad)
        let candyTrash = engine.throwInTrash()
        XCTAssertTrue(candyTrash.success)
        XCTAssertEqual(engine.score, 20)
    }

    func testFrogBugCatchingEngine() {
        let engine = FrogBugEngine(targetBugs: 5)
        XCTAssertEqual(engine.caughtCount, 0)
        XCTAssertEqual(engine.bugs.count, 4)

        let caught = engine.catchBug(bugId: 0)
        XCTAssertTrue(caught)
        XCTAssertEqual(engine.caughtCount, 1)
        XCTAssertEqual(engine.score, 10)
    }

    func testBacteriaLaserShooterEngine() {
        let engine = BacteriaBlasterEngine(targetHitCount: 5, initialTimeSeconds: 30)
        XCTAssertEqual(engine.hits, 0)
        XCTAssertEqual(engine.targets.count, 5)

        let first = engine.targets[0]
        let hit = engine.shootLaser(touchX: first.x, touchY: first.y)
        XCTAssertTrue(hit)
        XCTAssertEqual(engine.hits, 1)
        XCTAssertEqual(engine.score, 10)
    }

    func testFashionBracesEngine() {
        let engine = FashionBracesEngine()
        XCTAssertEqual(engine.teeth.count, 6)
        XCTAssertFalse(engine.isAllDecorated())

        engine.selectedColor = "#FF4081"
        engine.selectedGem = "diamond"
        let applied = engine.applyBrace(toothIndex: 0)
        XCTAssertTrue(applied)
        XCTAssertTrue(engine.teeth[0].hasBrace)
        XCTAssertEqual(engine.teeth[0].bracketColorHex, "#FF4081")
        XCTAssertEqual(engine.teeth[0].gemStyle, "diamond")
    }
}
