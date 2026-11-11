import Foundation

public enum ArchType: String, Codable, Sendable {
    case upper
    case lower
}

public enum ToothType: String, Codable, Sendable {
    case incisor
    case premolar
    case molar
}

/// Individual tooth representation on the dental arch.
public struct ToothModel: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let arch: ArchType
    public let indexInArch: Int
    public let type: ToothType
    public let normalizedX: Double
    public let normalizedY: Double
    public let widthRatio: Double
    public let heightRatio: Double
    public var state: ToothState
    public var progress: Double

    public init(
        id: String,
        arch: ArchType,
        indexInArch: Int,
        type: ToothType,
        normalizedX: Double,
        normalizedY: Double,
        widthRatio: Double = 0.09,
        heightRatio: Double = 0.10,
        state: ToothState,
        progress: Double = 0.0
    ) {
        self.id = id
        self.arch = arch
        self.indexInArch = indexInArch
        self.type = type
        self.normalizedX = normalizedX
        self.normalizedY = normalizedY
        self.widthRatio = widthRatio
        self.heightRatio = heightRatio
        self.state = state
        self.progress = progress
    }

    public var isClean: Bool {
        return state.isHealthy
    }

    public func copy(withState newState: ToothState, progress: Double = 0.0) -> ToothModel {
        return ToothModel(
            id: id,
            arch: arch,
            indexInArch: indexInArch,
            type: type,
            normalizedX: normalizedX,
            normalizedY: normalizedY,
            widthRatio: widthRatio,
            heightRatio: heightRatio,
            state: newState,
            progress: max(0.0, min(1.0, progress))
        )
    }

    public func copyWithState(_ newState: ToothState) -> ToothModel {
        return copy(withState: newState)
    }

    public func copy(withProgress newProgress: Double) -> ToothModel {
        return ToothModel(
            id: id,
            arch: arch,
            indexInArch: indexInArch,
            type: type,
            normalizedX: normalizedX,
            normalizedY: normalizedY,
            widthRatio: widthRatio,
            heightRatio: heightRatio,
            state: state,
            progress: max(0.0, min(1.0, newProgress))
        )
    }
}
