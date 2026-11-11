import Foundation

public struct BacteriaBug: Identifiable, Sendable, Equatable {
    public let id: Int
    public var x: Double
    public var y: Double
    public var vx: Double
    public var vy: Double
    public var isCaught: Bool

    public init(
        id: Int,
        x: Double,
        y: Double,
        vx: Double = 0.0,
        vy: Double = 0.0,
        isCaught: Bool = false
    ) {
        self.id = id
        self.x = x
        self.y = y
        self.vx = vx
        self.vy = vy
        self.isCaught = isCaught
    }
}

public final class FrogBugEngine: ObservableObject, @unchecked Sendable {
    public let targetBugs: Int
    @Published public private(set) var caughtCount: Int = 0
    @Published public private(set) var score: Int = 0
    @Published public var bugs: [BacteriaBug] = []

    public init(targetBugs: Int = 10) {
        self.targetBugs = targetBugs
        spawnWave()
    }

    public func spawnWave() {
        bugs.removeAll()
        for i in 0..<4 {
            bugs.append(
                BacteriaBug(
                    id: i,
                    x: Double.random(in: 0.1...0.9),
                    y: Double.random(in: 0.15...0.55),
                    vx: Double.random(in: -0.1...0.1),
                    vy: Double.random(in: -0.1...0.1)
                )
            )
        }
    }

    public func catchBug(bugId: Int) -> Bool {
        guard let index = bugs.firstIndex(where: { $0.id == bugId && !$0.isCaught }) else {
            return false
        }
        bugs[index].isCaught = true
        caughtCount += 1
        score += 10

        // Respawn bug at new position
        bugs[index].x = Double.random(in: 0.1...0.9)
        bugs[index].y = Double.random(in: 0.15...0.55)
        bugs[index].isCaught = false
        return true
    }

    public func isVictory() -> Bool {
        return caughtCount >= targetBugs
    }

    public func reset() {
        caughtCount = 0
        score = 0
        spawnWave()
    }
}
