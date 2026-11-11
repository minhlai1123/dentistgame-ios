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
        case .clean: return "Răng Sạch"
        case .dirtStained: return "Dính Vết Bẩn"
        case .calculus: return "Bám Vôi Răng"
        case .bacteria: return "Quái Vật Vi Khuẩn"
        case .cavityDrilled: return "Lỗ Sâu Đã Khoan"
        case .resinFilled: return "Đã Bơm Keo Trám"
        case .resinCured: return "Keo Trám Đã Đông Cứng"
        case .necroticCracked: return "Hoại Tử Nứt Nẻ"
        case .socketEmpty: return "Ổ Răng Trống"
        case .implantPlaced: return "Đã Trồng Răng Mới"
        }
    }

    public var isHealthy: BooleanLiteralType {
        return self == .clean || self == .implantPlaced
    }

    public var requiresTreatment: Bool {
        return !isHealthy
    }
}
