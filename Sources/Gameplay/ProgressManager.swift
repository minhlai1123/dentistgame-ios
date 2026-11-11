import Foundation

public struct ProgressState: Sendable {
    public let totalTeeth: Int
    public let healthyTeeth: Int
    public let totalScore: Int
    public let progressPercentage: Double
    public let isVictory: Bool
    public let starRating: Int

    public init(
        totalTeeth: Int,
        healthyTeeth: Int,
        totalScore: Int,
        progressPercentage: Double,
        isVictory: Bool,
        starRating: Int
    ) {
        self.totalTeeth = totalTeeth
        self.healthyTeeth = healthyTeeth
        self.totalScore = totalScore
        self.progressPercentage = progressPercentage
        self.isVictory = isVictory
        self.starRating = starRating
    }
}

/// Tracks score, progress percentage, and victory completion states for iOS.
public final class ProgressManager {
    public private(set) var score: Int = 0

    public init() {}

    public func addScore(_ points: Int) {
        score = max(0, score + points)
    }

    public func resetScore() {
        score = 0
    }

    public static func calculateStars(isCompleted: Bool, score: Int) -> Int {
        guard isCompleted else { return 0 }
        if score >= 500 {
            return 3
        } else if score >= 300 {
            return 2
        } else {
            return 1
        }
    }

    public func calculateStars(isCompleted: Bool, score: Int) -> Int {
        return Self.calculateStars(isCompleted: isCompleted, score: score)
    }

    public func calculateProgress(for teeth: [ToothModel]) -> ProgressState {
        let total = teeth.count
        guard total > 0 else {
            return ProgressState(totalTeeth: 0, healthyTeeth: 0, totalScore: score, progressPercentage: 1.0, isVictory: true, starRating: calculateStars(isCompleted: true, score: score))
        }

        let healthy = teeth.filter { $0.isClean }.count
        let percentage = Double(healthy) / Double(total)
        let isVictory = (healthy == total)

        let stars = calculateStars(isCompleted: isVictory, score: score)

        return ProgressState(
            totalTeeth: total,
            healthyTeeth: healthy,
            totalScore: score,
            progressPercentage: percentage,
            isVictory: isVictory,
            starRating: stars
        )
    }
}
