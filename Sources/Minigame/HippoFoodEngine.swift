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
        FoodItem(id: "food_apple", name: "Red Apple", isGoodForTeeth: true, imageName: "food_apple"),
        FoodItem(id: "food_candy", name: "Gummy Candy", isGoodForTeeth: false, imageName: "food_candy"),
        FoodItem(id: "food_carrot", name: "Fresh Carrot", isGoodForTeeth: true, imageName: "food_carrot"),
        FoodItem(id: "food_soda", name: "Fizzy Soda", isGoodForTeeth: false, imageName: "food_soda"),
        FoodItem(id: "food_milk", name: "Fresh Milk", isGoodForTeeth: true, imageName: "food_milk"),
        FoodItem(id: "food_lollipop", name: "Lollipop", isGoodForTeeth: false, imageName: "food_lollipop"),
        FoodItem(id: "food_apple_2", name: "Crisp Apple", isGoodForTeeth: true, imageName: "food_apple"),
        FoodItem(id: "food_candy_2", name: "Sweet Candy", isGoodForTeeth: false, imageName: "food_candy")
    ]

    public init() {}

    public func getCurrentFood() -> FoodItem? {
        guard currentItemIndex < foodList.count else { return nil }
        return foodList[currentItemIndex]
    }

    public func feedToHippo() -> (success: Bool, message: String) {
        guard let food = getCurrentFood() else {
            return (false, "No more food!")
        }
        currentItemIndex += 1
        if food.isGoodForTeeth {
            score += food.points
            return (true, "Hippo loves \(food.name)! Teeth grow stronger! (+\(food.points) pts)")
        } else {
            return (false, "Oh no! \(food.name) is full of sugar and causes cavities!")
        }
    }

    public func throwInTrash() -> (success: Bool, message: String) {
        guard let food = getCurrentFood() else {
            return (false, "No more food!")
        }
        currentItemIndex += 1
        if !food.isGoodForTeeth {
            score += food.points
            return (true, "Great job! Discarding \(food.name) protects teeth! (+\(food.points) pts)")
        } else {
            return (false, "Oops! \(food.name) is actually healthy for teeth!")
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
