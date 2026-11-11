import XCTest
@testable import DentistGame

final class ToothStateMachineTests: XCTestCase {
    private var stateMachine: ToothStateMachine!
    private var baseTooth: ToothModel!

    override func setUp() {
        super.setUp()
        stateMachine = ToothStateMachine()
        baseTooth = ToothModel(
            id: "T01",
            arch: .upper,
            indexInArch: 0,
            type: .molar,
            normalizedX: 0.28,
            normalizedY: 0.32,
            state: .dirtStained,
            progress: 0.0
        )
    }

    func testToothbrushCleansDirtStainedToothIncrementally() {
        // Step 1: partial progress
        let res1 = stateMachine.applyTool(tooth: baseTooth, tool: .toothbrush, deltaProgress: 0.4)
        switch res1 {
        case .success(let updatedTooth, let isStateChanged, _, _):
            XCTAssertFalse(isStateChanged)
            XCTAssertEqual(updatedTooth.state, .dirtStained)
            XCTAssertEqual(updatedTooth.progress, 0.4, accuracy: 0.001)
        case .rejected:
            XCTFail("Should not be rejected")
        }

        // Step 2: complete progress to clean
        let toothMid = baseTooth.copy(withProgress: 0.4)
        let res2 = stateMachine.applyTool(tooth: toothMid, tool: .toothbrush, deltaProgress: 0.7)
        switch res2 {
        case .success(let updatedTooth, let isStateChanged, let points, _):
            XCTAssertTrue(isStateChanged)
            XCTAssertEqual(updatedTooth.state, .clean)
            XCTAssertEqual(updatedTooth.progress, 0.0)
            XCTAssertEqual(points, 50)
        case .rejected:
            XCTFail("Should not be rejected")
        }
    }

    func testScalerCleansCalculus() {
        let calcTooth = baseTooth.copy(withState: .calculus, progress: 0.0)
        let result = stateMachine.applyTool(tooth: calcTooth, tool: .scaler, deltaProgress: 1.0)
        switch result {
        case .success(let updated, let isStateChanged, _, _):
            XCTAssertTrue(isStateChanged)
            XCTAssertEqual(updated.state, .clean)
        case .rejected:
            XCTFail("Scaler should clean calculus")
        }
    }

    func testDrillTreatsBacteria() {
        let bactTooth = baseTooth.copy(withState: .bacteria, progress: 0.0)
        let result = stateMachine.applyTool(tooth: bactTooth, tool: .drill, deltaProgress: 1.0)
        switch result {
        case .success(let updated, let isStateChanged, _, _):
            XCTAssertTrue(isStateChanged)
            XCTAssertEqual(updated.state, .cavityDrilled)
        case .rejected:
            XCTFail("Drill should remove bacteria")
        }
    }

    func testCavityRestorationPipeline() {
        // Step 1: Cavity drilled -> Resin tube -> Resin filled
        let drilledTooth = baseTooth.copy(withState: .cavityDrilled, progress: 0.0)
        let fillResult = stateMachine.applyTool(tooth: drilledTooth, tool: .resinTube)
        guard case .success(let filledTooth, true, _, _) = fillResult else {
            XCTFail("Resin tube failed")
            return
        }
        XCTAssertEqual(filledTooth.state, .resinFilled)

        // Step 2: Resin filled -> Curing light -> Resin cured
        let cureResult = stateMachine.applyTool(tooth: filledTooth, tool: .curingLight, deltaProgress: 1.0)
        guard case .success(let curedTooth, true, _, _) = cureResult else {
            XCTFail("Curing light failed")
            return
        }
        XCTAssertEqual(curedTooth.state, .resinCured)

        // Step 3: Resin cured -> Water spray (polishing/rinse) -> Clean
        let rinseResult = stateMachine.applyTool(tooth: curedTooth, tool: .waterSpray, deltaProgress: 1.0)
        guard case .success(let finalTooth, true, _, _) = rinseResult else {
            XCTFail("Water spray failed")
            return
        }
        XCTAssertEqual(finalTooth.state, .clean)
    }

    func testExtractionAndImplantPipeline() {
        let necroticTooth = baseTooth.copy(withState: .necroticCracked, progress: 0.0)

        // Extraction
        let extractResult = stateMachine.applyTool(tooth: necroticTooth, tool: .forceps, deltaProgress: 1.0)
        guard case .success(let emptySocket, true, _, _) = extractResult else {
            XCTFail("Forceps failed")
            return
        }
        XCTAssertEqual(emptySocket.state, .socketEmpty)

        // Implant
        let implantResult = stateMachine.applyTool(tooth: emptySocket, tool: .implant)
        guard case .success(let implantTooth, true, _, _) = implantResult else {
            XCTFail("Implant placement failed")
            return
        }
        XCTAssertEqual(implantTooth.state, .implantPlaced)
        XCTAssertTrue(implantTooth.isClean)
    }

    func testInvalidToolApplicationIsRejected() {
        // Toothbrush on clean tooth
        let cleanTooth = baseTooth.copy(withState: .clean, progress: 0.0)
        let res1 = stateMachine.applyTool(tooth: cleanTooth, tool: .toothbrush)
        guard case .rejected = res1 else {
            XCTFail("Toothbrush on clean tooth must be rejected")
            return
        }

        // Drill on clean tooth
        let res2 = stateMachine.applyTool(tooth: cleanTooth, tool: .drill)
        guard case .rejected = res2 else {
            XCTFail("Drill on clean tooth must be rejected")
            return
        }

        // Scaler on bacteria tooth
        let bactTooth = baseTooth.copy(withState: .bacteria, progress: 0.0)
        let res3 = stateMachine.applyTool(tooth: bactTooth, tool: .scaler)
        guard case .rejected = res3 else {
            XCTFail("Scaler on bacteria must be rejected")
            return
        }
    }
}
