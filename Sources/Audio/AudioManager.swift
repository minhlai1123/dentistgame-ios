import Foundation
import AVFoundation
import SwiftUI

/// Native iOS Audio Manager using AVFoundation for sound effects and background music.
public final class AudioManager: ObservableObject, @unchecked Sendable {
    public static let shared = AudioManager()

    @Published public var isSfxEnabled: Bool = true
    @Published public var isBgmEnabled: Bool = true
    @Published public var sfxVolume: Float = 0.85
    @Published public var bgmVolume: Float = 0.55

    private var bgmPlayer: AVAudioPlayer?
    private var sfxPlayers: [String: AVAudioPlayer] = [:]
    private var currentBgmName: String = ""

    public init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
        } catch {
            print("[AudioManager] Failed to configure audio session: \(error)")
        }
    }

    public func playSfx(named name: String) {
        guard isSfxEnabled else { return }

        // Look for audio in bundle or Assets
        if let url = Bundle.main.url(forResource: name, withExtension: "wav", subdirectory: "Assets/Audio") ??
                     Bundle.main.url(forResource: name, withExtension: "wav") {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = sfxVolume
                player.prepareToPlay()
                player.play()
                sfxPlayers[name] = player
            } catch {
                print("[AudioManager] Could not play SFX \(name): \(error)")
            }
        }
    }

    public func playToolSfx(_ tool: DentalTool) {
        let soundName: String
        switch tool {
        case .toothbrush: soundName = "sfx_tooth_brushing"
        case .scaler: soundName = "sfx_dental_scaling"
        case .drill: soundName = "sfx_dental_drilling"
        case .resinTube: soundName = "sfx_resin_application"
        case .curingLight: soundName = "sfx_uv_curing"
        case .waterSpray: soundName = "sfx_water_spray"
        case .syringe: soundName = "sfx_character_reaction"
        case .forceps: soundName = "sfx_tooth_extraction"
        case .implant: soundName = "sfx_tooth_replacement"
        case .tweezers: soundName = "sfx_button_click"
        }
        playSfx(named: soundName)
    }

    public func playLaserShot() {
        playSfx(named: "sfx_laser_shot")
    }

    public func playFoodCrunch() {
        playSfx(named: "sfx_food_crunch")
    }

    public func playWrongBuzz() {
        playSfx(named: "sfx_wrong_buzz")
    }

    public func playFrogTongue() {
        playSfx(named: "sfx_frog_tongue")
    }

    public func playBraceSnap() {
        playSfx(named: "sfx_brace_snap")
    }

    public func playButtonClick() {
        playSfx(named: "sfx_button_click")
    }

    public func playSuccess() {
        playSfx(named: "sfx_success")
    }

    public func playStarReward() {
        playSfx(named: "sfx_star_reward")
    }

    public func playVictoryCelebration() {
        playSfx(named: "sfx_victory_celebration")
    }

    public func playCharacterReaction() {
        playSfx(named: "sfx_character_reaction")
    }

    public func startBgm(named name: String) {
        if currentBgmName == name && bgmPlayer?.isPlaying == true {
            return
        }
        stopBgm()
        currentBgmName = name
        guard isBgmEnabled else { return }

        if let url = Bundle.main.url(forResource: name, withExtension: "wav", subdirectory: "Assets/Audio") ??
                     Bundle.main.url(forResource: name, withExtension: "wav") {
            do {
                bgmPlayer = try AVAudioPlayer(contentsOf: url)
                bgmPlayer?.numberOfLoops = -1 // Infinite loop
                bgmPlayer?.volume = bgmVolume
                bgmPlayer?.prepareToPlay()
                bgmPlayer?.play()
            } catch {
                print("[AudioManager] Could not start BGM \(name): \(error)")
            }
        }
    }

    public func stopBgm() {
        bgmPlayer?.stop()
        bgmPlayer = nil
    }

    public func pauseBgm() {
        bgmPlayer?.pause()
    }

    public func resumeBgm() {
        guard isBgmEnabled else { return }
        if let player = bgmPlayer, !player.isPlaying {
            player.play()
        } else if !currentBgmName.isEmpty {
            startBgm(named: currentBgmName)
        }
    }

    public func toggleSfx(_ enabled: Bool) {
        isSfxEnabled = enabled
    }

    public func toggleBgm(_ enabled: Bool) {
        isBgmEnabled = enabled
        if enabled {
            resumeBgm()
        } else {
            pauseBgm()
        }
    }

    public func setSfxVolume(_ volume: Float) {
        sfxVolume = max(0.0, min(1.0, volume))
    }

    public func setBgmVolume(_ volume: Float) {
        bgmVolume = max(0.0, min(1.0, volume))
        bgmPlayer?.volume = bgmVolume
    }
}
