import Foundation

/// Discrete clinical state of an individual tooth in the dental game.
/// Enforces a strict Finite State Machine with approved transitions only.
public enum ToothState: String, CaseIterable, Codable, Sendable {
    case clean = "CLEAN"
    case dirtStained = "DIRT_STAINED"
    case calculus = "CALCULUS"
    case bacteria = "BACTERIA"
    case cavityDrilled = "CAVITY_DRILLED"
    case resinFilled = "RESIN_FILLED"
    case resinCured = "RESIN_CURED"
    case necroticCracked = "NECROTIC_CRACKED"
    case socketEmpty = "SOCKET_EMPTY"
    case implantPlaced = "IMPLANT_PLACED"

    public var displayName: String {
        switch self {
        case .clean: return "Clean Tooth"
        case .dirtStained: return "Dirt Stained"
        case .calculus: return "Calculus Plaque"
        case .bacteria: return "Bacteria Monster"
        case .cavityDrilled: return "Cavity Drilled"
        case .resinFilled: return "Resin Filled"
        case .resinCured: return "Resin Cured"
        case .necroticCracked: return "Necrotic Decay"
        case .socketEmpty: return "Empty Socket"
        case .implantPlaced: return "New Implant"
        }
    }

    public var isHealthy: BooleanLiteralType {
        return self == .clean || self == .implantPlaced
    }

    public var requiresTreatment: Bool {
        return !isHealthy
    }
}
