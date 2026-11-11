import SwiftUI

public enum ParticleType: Sendable {
    case bubble
    case waterDrop
    case calculusFlake
    case sparkle
    case confetti
}

public struct Particle: Identifiable, Sendable {
    public let id: Int
    public var active: Bool = false
    public var x: Double = 0
    public var y: Double = 0
    public var vx: Double = 0
    public var vy: Double = 0
    public var size: Double = 10
    public var color: Color = .white
    public var alpha: Double = 1.0
    public var rotation: Double = 0
    public var vRot: Double = 0
    public var life: Double = 1.0
    public var maxLife: Double = 1.0
    public var type: ParticleType = .bubble

    public mutating func update(dt: Double) -> Bool {
        guard active else { return false }
        life -= dt
        if life <= 0 {
            active = false
            return false
        }
        x += vx * dt
        y += vy * dt
        rotation += vRot * dt
        alpha = max(0.0, min(1.0, life / maxLife))

        switch type {
        case .bubble:
            vy -= 25.0 * dt // floats upward
        case .confetti, .calculusFlake:
            vy += 180.0 * dt // falls downward
        case .waterDrop:
            vy += 120.0 * dt
        case .sparkle:
            vx *= 0.92
            vy *= 0.92
        }
        return true
    }
}

/// Lightweight, object-pooled particle manager for iOS SwiftUI Canvas
public final class ParticleSystem: ObservableObject, @unchecked Sendable {
    @Published public var particles: [Particle]
    private let maxParticles: Int

    private let confettiColors: [Color] = [
        Color(red: 1.0, green: 0.32, blue: 0.32),
        Color(red: 0.27, green: 0.54, blue: 1.0),
        Color(red: 1.0, green: 0.84, blue: 0.25),
        Color(red: 0.41, green: 0.94, blue: 0.68),
        Color(red: 0.88, green: 0.25, blue: 0.98)
    ]

    public init(maxParticles: Int = 100) {
        self.maxParticles = maxParticles
        self.particles = (0..<maxParticles).map { Particle(id: $0) }
    }

    public func spawnToolParticles(type: ParticleType, originX: Double, originY: Double, count: Int = 4) {
        let clamped = min(count, 8)
        var spawned = 0
        for i in 0..<particles.count {
            if !particles[i].active {
                particles[i].active = true
                particles[i].type = type
                particles[i].x = originX + Double.random(in: -10...10)
                particles[i].y = originY + Double.random(in: -10...10)
                particles[i].maxLife = Double.random(in: 0.45...0.80)
                particles[i].life = particles[i].maxLife
                particles[i].rotation = Double.random(in: 0...360)
                particles[i].vRot = Double.random(in: -90...90)

                switch type {
                case .bubble:
                    particles[i].vx = Double.random(in: -40...40)
                    particles[i].vy = -Double.random(in: 30...90)
                    particles[i].size = Double.random(in: 12...24)
                    particles[i].color = Color.white.opacity(0.85)
                case .waterDrop:
                    particles[i].vx = Double.random(in: -60...60)
                    particles[i].vy = -Double.random(in: 20...90)
                    particles[i].size = Double.random(in: 8...16)
                    particles[i].color = Color(red: 0.31, green: 0.76, blue: 0.97)
                case .calculusFlake:
                    particles[i].vx = Double.random(in: -50...50)
                    particles[i].vy = -Double.random(in: 40...100)
                    particles[i].size = Double.random(in: 6...12)
                    particles[i].color = Color(red: 0.83, green: 0.78, blue: 0.51)
                case .sparkle:
                    particles[i].vx = Double.random(in: -70...70)
                    particles[i].vy = Double.random(in: -70...70)
                    particles[i].size = Double.random(in: 10...20)
                    particles[i].color = Color(red: 1.0, green: 0.84, blue: 0.31)
                case .confetti:
                    particles[i].vx = Double.random(in: -130...130)
                    particles[i].vy = -Double.random(in: 150...350)
                    particles[i].size = Double.random(in: 12...22)
                    particles[i].color = confettiColors.randomElement() ?? .yellow
                }

                spawned += 1
                if spawned >= clamped { break }
            }
        }
    }

    public func spawnConfettiBurst(width: Double, height: Double, count: Int = 45) {
        var spawned = 0
        for i in 0..<particles.count {
            if !particles[i].active {
                particles[i].active = true
                particles[i].type = .confetti
                particles[i].x = width * Double.random(in: 0.2...0.8)
                particles[i].y = height * Double.random(in: 0.3...0.6)
                particles[i].vx = Double.random(in: -150...150)
                particles[i].vy = -Double.random(in: 150...400)
                particles[i].maxLife = Double.random(in: 1.2...2.0)
                particles[i].life = particles[i].maxLife
                particles[i].size = Double.random(in: 12...24)
                particles[i].rotation = Double.random(in: 0...360)
                particles[i].vRot = Double.random(in: -180...180)
                particles[i].color = confettiColors.randomElement() ?? .yellow
                spawned += 1
                if spawned >= count { break }
            }
        }
    }

    public func update(dt: Double) {
        for i in 0..<particles.count {
            if particles[i].active {
                _ = particles[i].update(dt: dt)
            }
        }
    }

    public func clear() {
        for i in 0..<particles.count {
            particles[i].active = false
        }
    }
}
