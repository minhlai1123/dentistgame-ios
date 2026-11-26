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
                friendlyHint = "Please use the Dental Drill to clean the cavity first, then apply resin!"
            } else if tool == .resinTube && tooth.state == .resinFilled {
                friendlyHint = "Resin is already applied! Now use the UV Light to cure and harden it."
            } else if tool == .curingLight && tooth.state == .cavityDrilled {
                friendlyHint = "Fill the cavity with Composite Resin before using the UV Light!"
            } else if tool == .drill && tooth.state == .resinFilled {
                friendlyHint = "Resin is filled! Use the UV Light to cure it."
            } else if tool == .forceps && tooth.state != .necroticCracked {
                friendlyHint = "This tooth is still healthy! Only extract broken necrotic teeth."
            } else {
                friendlyHint = "Tool '\(tool.displayName)' cannot be used on '\(tooth.state.displayName)'."
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
                message: "Applied successfully!"
            )
        }

        // 3. Progressive interaction tools
        let newProgress = tooth.progress + deltaProgress
        if newProgress < 1.0 {
            return .success(
                updatedTooth: tooth.copy(withProgress: newProgress),
                isStateChanged: false,
                pointsEarned: 5,
                message: "Treating tooth..."
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
                message: "Step completed!"
            )
        }
    }
}
