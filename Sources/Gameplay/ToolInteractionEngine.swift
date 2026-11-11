import Foundation
import CoreGraphics

public struct HitTestResult: Sendable {
    public let tooth: ToothModel?
    public let isDirectHit: Bool
    public let distance: Double

    public init(tooth: ToothModel?, isDirectHit: Bool, distance: Double) {
        self.tooth = tooth
        self.isDirectHit = isDirectHit
        self.distance = distance
    }
}

/// Controller managing drag & drop, proximity detection, and magnetic snapping on iOS.
public final class ToolInteractionEngine {
    public var activeTool: DentalTool?
    public var isDragging: Bool = false
    public var dragLocation: CGPoint = .zero
    private let stateMachine: ToothStateMachine

    public init(stateMachine: ToothStateMachine = ToothStateMachine()) {
        self.stateMachine = stateMachine
    }

    public func selectTool(_ tool: DentalTool) {
        activeTool = tool
    }

    public func deselectTool() {
        activeTool = nil
        isDragging = false
    }

    public func updateDragLocation(_ point: CGPoint) {
        dragLocation = point
        isDragging = true
    }

    public func endDrag() {
        isDragging = false
    }

    public func findTargetTooth(
        in teeth: [ToothModel],
        canvasSize: CGSize,
        touchPoint: CGPoint,
        proximityThreshold: Double = 95.0
    ) -> HitTestResult {
        var closestTooth: ToothModel? = nil
        var minDistance: Double = .greatestFiniteMagnitude

        for tooth in teeth {
            let cx = tooth.normalizedX * Double(canvasSize.width)
            let cy = tooth.normalizedY * Double(canvasSize.height)
            let halfW = (tooth.widthRatio * Double(canvasSize.width)) / 2.0
            let halfH = (tooth.heightRatio * Double(canvasSize.height)) / 2.0

            let inBounds = (Double(touchPoint.x) >= cx - halfW && Double(touchPoint.x) <= cx + halfW) &&
                           (Double(touchPoint.y) >= cy - halfH && Double(touchPoint.y) <= cy + halfH)

            if inBounds {
                return HitTestResult(tooth: tooth, isDirectHit: true, distance: 0.0)
            }

            let dx = Double(touchPoint.x) - cx
            let dy = Double(touchPoint.y) - cy
            let dist = sqrt(dx * dx + dy * dy)

            if dist < minDistance && dist <= proximityThreshold {
                minDistance = dist
                closestTooth = tooth
            }
        }

        return HitTestResult(tooth: closestTooth, isDirectHit: false, distance: minDistance)
    }

    public func applyActiveTool(to tooth: ToothModel) -> TransitionResult {
        guard let tool = activeTool else {
            return .rejected(currentTooth: tooth, reason: "Chưa chọn dụng cụ nào.")
        }
        return stateMachine.applyTool(tooth: tooth, tool: tool)
    }
}
