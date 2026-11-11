import Foundation

public struct BlasterTarget: Identifiable, Sendable, Equatable {
    public let id: Int
    public var x: Double
    public var y: Double
    public var radius: Double
    public var isHit: Bool

    public init(
        id: Int,
        x: Double,
        y: Double,
        radius: Double = 0.08,
        isHit: Bool = false
    ) {
        self.id = id
        self.x = x
        self.y = y
        self.radius = radius
        self.isHit = isHit
    }
}

public final class BacteriaBlasterEngine: ObservableObject, @unchecked Sendable {
    public let targetHitCount: Int
    public let initialTimeSeconds: Int

    @Published public private(set) var hits: Int = 0
    @Published public private(set) var score: Int = 0
    @Published public private(set) var remainingTime: Double
    @Published public var targets: [BlasterTarget] = []

    public init(targetHitCount: Int = 15, initialTimeSeconds: Int = 30) {
        self.targetHitCount = targetHitCount
        self.initialTimeSeconds = initialTimeSeconds
        self.remainingTime = Double(initialTimeSeconds)
        spawnTargets()
    }

    public func spawnTargets() {
        targets.removeAll()
        for i in 0..<5 {
            targets.append(
                BlasterTarget(
                    id: i,
                    x: Double.random(in: 0.15...0.85),
                    y: Double.random(in: 0.2...0.7)
                )
            )
        }
    }

    public func updateTimer(dt: Double) {
        if remainingTime > 0 && !isVictory() {
            remainingTime = max(0, remainingTime - dt)
        }
    }

    public func shootLaser(touchX: Double, touchY: Double) -> Bool {
        guard !isGameOver() else { return false }

        for i in targets.indices {
            let dx = touchX - targets[i].x
            let dy = touchY - targets[i].y
            let dist = sqrt(dx * dx + dy * dy)
            if dist <= targets[i].radius {
                hits += 1
                score += 10
                targets[i].x = Double.random(in: 0.15...0.85)
                targets[i].y = Double.random(in: 0.2...0.7)
                return true
            }
        }
        return false
    }

    public func isVictory() -> Bool {
        return hits >= targetHitCount
    }

    public func isGameOver() -> Bool {
        return remainingTime <= 0 || isVictory()
    }

    public func reset() {
        hits = 0
        score = 0
        remainingTime = Double(initialTimeSeconds)
        spawnTargets()
    }
}
