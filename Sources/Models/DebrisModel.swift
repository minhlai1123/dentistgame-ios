import Foundation

public struct ForeignDebris: Identifiable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let normalizedX: Double
    public let normalizedY: Double
    public let imageName: String
    public var isRemoved: Bool
    public let points: Int

    public init(
        id: String,
        name: String,
        normalizedX: Double,
        normalizedY: Double,
        imageName: String,
        isRemoved: Bool = false,
        points: Int = 25
    ) {
        self.id = id
        self.name = name
        self.normalizedX = normalizedX
        self.normalizedY = normalizedY
        self.imageName = imageName
        self.isRemoved = isRemoved
        self.points = points
    }

    public static func createDefaultDebris() -> [ForeignDebris] {
        return [
            ForeignDebris(id: "debris_banana", name: "Vỏ chuối", normalizedX: 0.42, normalizedY: 0.48, imageName: "debris_banana"),
            ForeignDebris(id: "debris_twig", name: "Cành cây nhỏ", normalizedX: 0.58, normalizedY: 0.50, imageName: "debris_twig"),
            ForeignDebris(id: "debris_bone", name: "Xương cá nhỏ", normalizedX: 0.36, normalizedY: 0.55, imageName: "debris_bone"),
            ForeignDebris(id: "debris_biscuit", name: "Vụn bánh quy", normalizedX: 0.64, normalizedY: 0.54, imageName: "debris_biscuit")
        ]
    }

    public func copy(isRemoved: Bool? = nil) -> ForeignDebris {
        return ForeignDebris(
            id: self.id,
            name: self.name,
            normalizedX: self.normalizedX,
            normalizedY: self.normalizedY,
            imageName: self.imageName,
            isRemoved: isRemoved ?? self.isRemoved,
            points: self.points
        )
    }
}
