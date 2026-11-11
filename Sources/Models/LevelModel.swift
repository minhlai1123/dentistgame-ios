import Foundation

public enum DifficultyLevel: String, CaseIterable, Codable, Sendable {
    case tutorial = "LVL_01_TUTORIAL"
    case easy = "LVL_02_EASY"
    case medium = "LVL_03_MEDIUM"
    case hard = "LVL_04_HARD"

    public var title: String {
        switch self {
        case .tutorial: return "Tập Sự: Khởi Động Đánh Răng"
        case .easy: return "Dễ: Cạo Vôi & Trị Sâu Răng Nhẹ"
        case .medium: return "Trung Bình: Nha Khoa Tổng Hợp"
        case .hard: return "Khó: Thử Thách Bác Sĩ Toàn Diện"
        }
    }

    public var targetScore: Int {
        switch self {
        case .tutorial: return 250
        case .easy: return 400
        case .medium: return 550
        case .hard: return 750
        }
    }

    public var stages: [DentalStage] {
        switch self {
        case .tutorial: return [.brushing]
        case .easy: return [.brushing, .scaling, .decay]
        case .medium: return [.scaling, .decay, .surgery]
        case .hard: return [.brushing, .scaling, .decay, .surgery]
        }
    }

    public static func getLevelForCharacter(characterId: String) -> DifficultyLevel {
        switch characterId {
        case "char_01_leo": return .tutorial
        case "char_02_maya", "char_03_kenji", "char_07_lucas", "char_08_hana", "char_09_toby", "char_10_zoe": return .easy
        case "char_04_amara", "char_05_mia", "char_11_aarav", "char_12_elena", "char_13_kai", "char_14_fatima", "char_15_sam": return .medium
        case "char_06_ben", "char_16_oliver", "char_17_zara", "char_18_mateo", "char_19_linh", "char_20_arthur": return .hard
        default: return .easy
        }
    }
}
