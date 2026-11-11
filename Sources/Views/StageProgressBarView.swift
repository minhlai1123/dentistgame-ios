import SwiftUI

public struct StageProgressBarView: View {
    public let currentStage: DentalStage

    public init(currentStage: DentalStage) {
        self.currentStage = currentStage
    }

    private let stages: [(DentalStage, String)] = [
        (.brushing, "1. Chải Răng"),
        (.scaling, "2. Cạo Vôi"),
        (.decay, "3. Trị Sâu"),
        (.surgery, "4. Phẫu Thuật")
    ]

    private func stageIndex(_ stage: DentalStage) -> Int {
        switch stage {
        case .brushing: return 0
        case .scaling: return 1
        case .decay: return 2
        case .surgery: return 3
        case .complete: return 4
        }
    }

    public var body: some View {
        HStack(spacing: 6) {
            ForEach(stages, id: \.0) { stage, name in
                let currentIdx = stageIndex(currentStage)
                let thisIdx = stageIndex(stage)
                let isCurrent = stage == currentStage
                let isCompleted = thisIdx < currentIdx || currentStage == .complete

                let bgColor: Color = {
                    if isCompleted { return Color.green }
                    if isCurrent { return Color.blue }
                    return Color.gray.opacity(0.3)
                }()

                let textColor: Color = (isCompleted || isCurrent) ? .white : .secondary

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(bgColor)
                    Text(isCompleted ? "✓ \(name)" : name)
                        .font(.system(size: 11, weight: isCurrent ? .heavy : .bold))
                        .foregroundColor(textColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 4)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}
