import Foundation

public struct DecoratedTooth: Identifiable, Sendable, Equatable {
    public let id: String
    public let toothName: String
    public var bracketColorHex: String
    public var gemStyle: String
    public var hasBrace: Bool

    public init(
        id: String,
        toothName: String,
        bracketColorHex: String = "#FF4081",
        gemStyle: String = "star",
        hasBrace: Bool = false
    ) {
        self.id = id
        self.toothName = toothName
        self.bracketColorHex = bracketColorHex
        self.gemStyle = gemStyle
        self.hasBrace = hasBrace
    }
}

public final class FashionBracesEngine: ObservableObject, @unchecked Sendable {
    @Published public var teeth: [DecoratedTooth] = [
        DecoratedTooth(id: "T02", toothName: "Răng R-Tiền Hàm"),
        DecoratedTooth(id: "T03", toothName: "Răng R-Cửa"),
        DecoratedTooth(id: "T04", toothName: "Răng L-Cửa"),
        DecoratedTooth(id: "T05", toothName: "Răng L-Tiền Hàm"),
        DecoratedTooth(id: "T09", toothName: "Răng Dưới R-Cửa"),
        DecoratedTooth(id: "T10", toothName: "Răng Dưới L-Cửa")
    ]

    public let availableColors: [String] = [
        "#FF4081", // Pink
        "#00E5FF", // Cyan
        "#76FF03", // Lime
        "#FFD600", // Yellow
        "#7C4DFF"  // Purple
    ]

    public let availableGems: [String] = ["star", "heart", "diamond", "flower"]

    @Published public var selectedColor: String = "#FF4081"
    @Published public var selectedGem: String = "star"

    public init() {}

    public func applyBrace(toothIndex: Int) -> Bool {
        guard toothIndex >= 0 && toothIndex < teeth.count else { return false }
        teeth[toothIndex].hasBrace = true
        teeth[toothIndex].bracketColorHex = selectedColor
        teeth[toothIndex].gemStyle = selectedGem
        return true
    }

    public func isAllDecorated() -> Bool {
        return teeth.allSatisfy { $0.hasBrace }
    }

    public func getScore() -> Int {
        if isAllDecorated() {
            return 100
        } else {
            return teeth.filter { $0.hasBrace }.count * 15
        }
    }

    public func reset() {
        for i in teeth.indices {
            teeth[i].hasBrace = false
        }
    }
}
