import Foundation

public enum TransitionResult: Equatable {
    case success(updatedTooth: ToothModel, isStateChanged: Bool, pointsEarned: Int, message: String)
    case rejected(currentTooth: ToothModel, reason: String)
}

/// Strict finite state machine governing dental procedures on iOS.
public final class ToothStateMachine: Sendable {
    public init() {}

    public func applyTool(
        tooth: ToothModel,
        tool: DentalTool,
        deltaProgress: Double = 0.35
    ) -> TransitionResult {
        // 1. Tool-to-target validation with child-friendly guidance
        guard tool.canInteract(with: tooth.state) else {
            let friendlyHint: String
            if tool == .resinTube && tooth.state == .bacteria {
                friendlyHint = "Bé hãy dùng Máy Khoan nạo sạch vết sâu trước, rồi mới bơm keo trám nhé!"
            } else if tool == .resinTube && tooth.state == .resinFilled {
                friendlyHint = "Răng đã có keo trám rồi! Giờ hãy dùng Đèn UV chiếu đông cứng men răng nhé."
            } else if tool == .curingLight && tooth.state == .cavityDrilled {
                friendlyHint = "Hãy dùng Ống Keo Trám bơm đầy lỗ sâu trước khi chiếu đèn UV nhé!"
            } else if tool == .drill && tooth.state == .resinFilled {
                friendlyHint = "Răng đã được trám keo! Hãy dùng Đèn UV chiếu đông cứng nhé."
            } else if tool == .forceps && tooth.state != .necroticCracked {
                friendlyHint = "Răng này còn tốt, không cần nhổ! Chỉ nhổ răng hoại tử nứt vỡ thôi nhé."
            } else {
                friendlyHint = "Dụng cụ '\(tool.displayName)' không thể dùng cho trạng thái '\(tooth.state.displayName)'."
            }
            return .rejected(
                currentTooth: tooth,
                reason: friendlyHint
            )
        }

        // 2. Immediate single-step tools (Resin tube, Implant)
        if tool == .resinTube || tool == .implant {
            let nextState: ToothState
            switch tooth.state {
            case .cavityDrilled: nextState = .resinFilled
            case .socketEmpty: nextState = .implantPlaced
            default: nextState = tooth.state
            }
            let points = (nextState == .implantPlaced) ? 100 : 30
            return .success(
                updatedTooth: tooth.copy(withState: nextState, progress: 0.0),
                isStateChanged: true,
                pointsEarned: points,
                message: "Đặt vật liệu thành công!"
            )
        }

        // 3. Progressive interaction tools
        let newProgress = tooth.progress + deltaProgress
        if newProgress < 1.0 {
            return .success(
                updatedTooth: tooth.copy(withProgress: newProgress),
                isStateChanged: false,
                pointsEarned: 5,
                message: "Đang thao tác..."
            )
        } else {
            let nextState: ToothState
            let points: Int
            switch tooth.state {
            case .dirtStained:
                nextState = .clean
                points = 50
            case .calculus:
                nextState = .clean
                points = 50
            case .bacteria:
                nextState = .cavityDrilled
                points = 40
            case .resinFilled:
                nextState = .resinCured
                points = 30
            case .resinCured:
                nextState = .clean
                points = 40
            case .necroticCracked:
                nextState = .socketEmpty
                points = 60
            default:
                nextState = tooth.state
                points = 0
            }
            return .success(
                updatedTooth: tooth.copy(withState: nextState, progress: 0.0),
                isStateChanged: true,
                pointsEarned: points,
                message: "Hoàn thành công đoạn!"
            )
        }
    }
}
