import Foundation

public enum DentalStage: String, CaseIterable, Codable, Sendable {
    case brushing = "STAGE_BRUSHING"
    case scaling = "STAGE_SCALING"
    case decay = "STAGE_DECAY"
    case surgery = "STAGE_SURGERY"
    case complete = "STAGE_COMPLETE"

    public var displayName: String {
        switch self {
        case .brushing: return "1. Brushing"
        case .scaling: return "2. Scaling"
        case .decay: return "3. Cavity Care"
        case .surgery: return "4. Surgery"
        case .complete: return "Complete"
        }
    }

    public var name: String {
        return displayName
    }

    public var description: String {
        switch self {
        case .brushing: return "Use the toothbrush to brush off dirt and food stains."
        case .scaling: return "Use the ultrasonic scaler to remove tartar and plaque around teeth."
        case .decay: return "Drill away cavities, apply composite resin, cure with UV light, and rinse clean."
        case .surgery: return "Remove debris with tweezers, numb gently, extract necrotic teeth, and place implants."
        case .complete: return "All teeth are sparkling clean, strong, and healthy!"
        }
    }
}
