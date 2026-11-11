import Foundation

public struct StageStatus: Sendable, Equatable {
    public let currentStage: DentalStage
    public let stageProgressPercentage: Float
    public let isCurrentStageFinished: Bool
    public let activeTools: [DentalTool]
    public let guidancePrompt: String

    public init(
        currentStage: DentalStage,
        stageProgressPercentage: Float,
        isCurrentStageFinished: Bool,
        activeTools: [DentalTool],
        guidancePrompt: String
    ) {
        self.currentStage = currentStage
        self.stageProgressPercentage = stageProgressPercentage
        self.isCurrentStageFinished = isCurrentStageFinished
        self.activeTools = activeTools
        self.guidancePrompt = guidancePrompt
    }
}

public final class StageCoordinator: ObservableObject, @unchecked Sendable {
    @Published public private(set) var isAnesthetized: Bool = false

    public init() {}

    public func applyAnesthesia() -> Bool {
        isAnesthetized = true
        return true
    }

    public func resetAnesthesia() {
        isAnesthetized = false
    }

    public func determineCurrentStage(
        teeth: [ToothModel],
        debrisList: [ForeignDebris] = []
    ) -> DentalStage {
        let hasDirt = teeth.contains { $0.state == .dirtStained }
        if hasDirt { return .brushing }

        let hasCalculus = teeth.contains { $0.state == .calculus }
        if hasCalculus { return .scaling }

        let hasDecay = teeth.contains {
            $0.state == .bacteria ||
            $0.state == .cavityDrilled ||
            $0.state == .resinFilled ||
            $0.state == .resinCured
        }
        if hasDecay { return .decay }

        let hasDebris = debrisList.contains { !$0.isRemoved }
        let hasSurgeryTeeth = teeth.contains {
            $0.state == .necroticCracked || $0.state == .socketEmpty
        }
        if hasDebris || hasSurgeryTeeth { return .surgery }

        return .complete
    }

    public func getAvailableToolsForStage(stage: DentalStage) -> [DentalTool] {
        switch stage {
        case .brushing:
            return [.toothbrush, .waterSpray]
        case .scaling:
            return [.scaler, .waterSpray]
        case .decay:
            return [.drill, .resinTube, .curingLight, .waterSpray]
        case .surgery:
            return [.tweezers, .syringe, .forceps, .implant]
        case .complete:
            return DentalTool.allCases
        }
    }

    public func getStageStatus(
        teeth: [ToothModel],
        debrisList: [ForeignDebris] = []
    ) -> StageStatus {
        let stage = determineCurrentStage(teeth: teeth, debrisList: debrisList)
        let activeTools = getAvailableToolsForStage(stage: stage)

        let (progress, prompt): (Float, String) = {
            switch stage {
            case .brushing:
                let totalDirt = teeth.filter { $0.state == .dirtStained }.count
                let initialDirt = 5
                let pct = Float(max(0, initialDirt - totalDirt)) / Float(initialDirt)
                return (min(max(pct, 0.0), 1.0), "Dùng bàn chải chà đều lên các răng ố vàng để làm sạch!")

            case .scaling:
                let totalCalc = teeth.filter { $0.state == .calculus }.count
                let initialCalc = 4
                let pct = Float(max(0, initialCalc - totalCalc)) / Float(initialCalc)
                return (min(max(pct, 0.0), 1.0), "Rê đầu móc cạo vôi siêu âm để loại bỏ mảng bám vôi quanh nướu!")

            case .decay:
                let cleanInDecay = teeth.filter { $0.state == .clean }.count
                let pct = Float(cleanInDecay) / Float(max(1, teeth.count))
                return (min(max(pct, 0.0), 1.0), "Dùng máy khoan nạo sạch sâu răng, bơm keo, chiếu đèn UV và xịt nước!")

            case .surgery:
                let remainingDebris = debrisList.filter { !$0.isRemoved }.count
                let remainingSurgery = teeth.filter { $0.state == .necroticCracked || $0.state == .socketEmpty }.count
                let pct: Float = (remainingDebris == 0 && remainingSurgery == 0) ? 1.0 : 0.5
                let msg: String
                if remainingDebris > 0 {
                    msg = "Dùng nhíp gắp sạch dị vật trong khoang miệng!"
                } else if !isAnesthetized {
                    msg = "Dùng ống tiêm gây tê nướu trước khi nhổ răng hỏng nhé!"
                } else if remainingSurgery > 0 {
                    msg = "Dùng kìm nhổ răng hư rồi gắn răng sứ thay thế vào!"
                } else {
                    msg = "Ca phẫu thuật hoàn thành xuất sắc!"
                }
                return (pct, msg)

            case .complete:
                return (1.0, "Tuyệt vời! Hàm răng đã hoàn toàn sạch bóng và khỏe mạnh!")
            }
        }()

        return StageStatus(
            currentStage = stage,
            stageProgressPercentage: progress,
            isCurrentStageFinished: stage == .complete,
            activeTools = activeTools,
            guidancePrompt: prompt
        )
    }

    public func canExtractTooth() -> Bool {
        return isAnesthetized
    }
}
