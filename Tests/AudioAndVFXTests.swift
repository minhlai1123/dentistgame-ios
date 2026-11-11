import XCTest
@testable import DentistGame

final class AudioAndVFXTests: XCTestCase {
    private var particleSystem: ParticleSystem!
    private var audioManager: AudioManager!

    override func setUp() {
        super.setUp()
        particleSystem = ParticleSystem(maxParticles: 50)
        audioManager = AudioManager.shared
    }

    func testAudioManagerInitialState() {
        XCTAssertTrue(audioManager.isSfxEnabled)
        XCTAssertTrue(audioManager.isBgmEnabled)
        XCTAssertGreaterThan(audioManager.sfxVolume, 0.0)
        XCTAssertGreaterThan(audioManager.bgmVolume, 0.0)
    }

    func testAudioTogglesAndVolume() {
        audioManager.toggleSfx(false)
        XCTAssertFalse(audioManager.isSfxEnabled)
        audioManager.toggleSfx(true)
        XCTAssertTrue(audioManager.isSfxEnabled)

        audioManager.setSfxVolume(0.5)
        XCTAssertEqual(audioManager.sfxVolume, 0.5, accuracy: 0.01)

        audioManager.setBgmVolume(0.7)
        XCTAssertEqual(audioManager.bgmVolume, 0.7, accuracy: 0.01)
    }

    func testParticleSystemSpawnsAndUpdates() {
        particleSystem.clear()
        let activeBefore = particleSystem.particles.filter { $0.active }.count
        XCTAssertEqual(activeBefore, 0)

        particleSystem.spawnToolParticles(type: .bubble, originX: 100, originY: 100, count: 5)
        let activeAfter = particleSystem.particles.filter { $0.active }.count
        XCTAssertEqual(activeAfter, 5)

        // Step simulation forward
        particleSystem.update(dt: 0.1)
        for p in particleSystem.particles where p.active {
            XCTAssertLessThan(p.life, p.maxLife)
        }

        // Expire all particles
        particleSystem.update(dt: 2.5)
        let activeFinal = particleSystem.particles.filter { $0.active }.count
        XCTAssertEqual(activeFinal, 0)
    }

    func testConfettiBurstSpawns() {
        particleSystem.clear()
        particleSystem.spawnConfettiBurst(width: 400, height: 800, count: 30)
        let confettiCount = particleSystem.particles.filter { $0.active && $0.type == .confetti }.count
        XCTAssertEqual(confettiCount, 30)
    }
}
