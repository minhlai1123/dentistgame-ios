import Foundation

public struct FoodItem: Identifiable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let isGoodForTeeth: Bool
    public let imageName: String
    public let points: Int

    public init(
        id: String,
        name: String,
        isGoodForTeeth: Bool,
        imageName: String,
        points: Int = 10
    ) {
        self.id = id
        self.name = name
        self.isGoodForTeeth = isGoodForTeeth
        self.imageName = imageName
        self.points = points
    }
}

public final class HippoFoodEngine: ObservableObject, @unchecked Sendable {
    @Published public private(set) var score: Int = 0
    @Published public private(set) var currentItemIndex: Int = 0

    public let foodList: [FoodItem] = [
        FoodItem(id: "food_apple", name: "Quả Táo Đỏ", isGoodForTeeth: true, imageName: "food_apple"),
        FoodItem(id: "food_candy", name: "Kẹo Dẻo", isGoodForTeeth: false, imageName: "food_candy"),
        FoodItem(id: "food_carrot", name: "Cà Rốt Tươi", isGoodForTeeth: true, imageName: "food_carrot"),
        FoodItem(id: "food_soda", name: "Nước Ngọt Gas", isGoodForTeeth: false, imageName: "food_soda"),
        FoodItem(id: "food_milk", name: "Sữa Tươi", isGoodForTeeth: true, imageName: "food_milk"),
        FoodItem(id: "food_lollipop", name: "Kẹo Mút", isGoodForTeeth: false, imageName: "food_lollipop"),
        FoodItem(id: "food_apple_2", name: "Táo Giòn", isGoodForTeeth: true, imageName: "food_apple"),
        FoodItem(id: "food_candy_2", name: "Kẹo Ngọt", isGoodForTeeth: false, imageName: "food_candy")
    ]

    public init() {}

    public func getCurrentFood() -> FoodItem? {
        guard currentItemIndex < foodList.count else { return nil }
        return foodList[currentItemIndex]
    }

    public func feedToHippo() -> (success: Bool, message: String) {
        guard let food = getCurrentFood() else {
            return (false, "Đã hết thức ăn!")
        }
        currentItemIndex += 1
        if food.isGoodForTeeth {
            score += food.points
            return (true, "Hà mã rất thích \(food.name)! Răng chắc khỏe hơn! (+\(food.points) pts)")
        } else {
            return (false, "Ôi không! \(food.name) chứa nhiều đường gây sâu răng đấy!")
        }
    }

    public func throwInTrash() -> (success: Bool, message: String) {
        guard let food = getCurrentFood() else {
            return (false, "Đã hết thức ăn!")
        }
        currentItemIndex += 1
        if !food.isGoodForTeeth {
            score += food.points
            return (true, "Đúng rồi! Vứt \(food.name) vào thùng rác để bảo vệ răng! (+\(food.points) pts)")
        } else {
            return (false, "Tiếc quá! \(food.name) rất tốt cho men răng mà!")
        }
    }

    public func isGameFinished() -> Bool {
        return currentItemIndex >= foodList.count
    }

    public func isVictory() -> Bool {
        return score >= 50
    }

    public func reset() {
        score = 0
        currentItemIndex = 0
    }
}
