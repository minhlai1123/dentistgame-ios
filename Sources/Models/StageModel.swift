import Foundation

public enum DentalStage: String, CaseIterable, Codable, Sendable {
    case brushing = "STAGE_BRUSHING"
    case scaling = "STAGE_SCALING"
    case decay = "STAGE_DECAY"
    case surgery = "STAGE_SURGERY"
    case complete = "STAGE_COMPLETE"

    public var displayName: String {
        switch self {
        case .brushing: return "1. Chải Răng"
        case .scaling: return "2. Cạo Vôi"
        case .decay: return "3. Trị Sâu"
        case .surgery: return "4. Phẫu Thuật"
        case .complete: return "Hoàn Tất"
        }
    }

    public var name: String {
        return displayName
    }

    public var description: String {
        switch self {
        case .brushing: return "Dùng bàn chải chà đều lên các răng ố vàng để làm sạch mảng bám thức ăn."
        case .scaling: return "Rê đầu móc cạo vôi siêu âm quanh chân răng để làm vỡ các mảng vôi răng."
        case .decay: return "Nạo sạch sâu răng, bơm keo trám, chiếu đèn UV và xịt nước làm sạch bóng."
        case .surgery: return "Gắp dị vật, tiêm tê không đau, nhổ răng mục và gắn răng sứ thay thế."
        case .complete: return "Toàn bộ hàm răng đã sạch bóng và khỏe mạnh!"
        }
    }
}
