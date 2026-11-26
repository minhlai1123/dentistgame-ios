import Foundation
import SwiftUI

public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case english = "en"

    public var id: String { rawValue }

    public var displayName: String {
        return "English"
    }
}

public final class LocalizationManager: ObservableObject, @unchecked Sendable {
    public static let shared = LocalizationManager()

    @Published public var currentLanguage: AppLanguage = .english

    public init(language: AppLanguage = .english) {
        self.currentLanguage = .english
    }

    public func setLanguage(_ language: AppLanguage) {
        self.currentLanguage = .english
    }

    private let enStrings: [String: String] = [
        "app_name": "Children's Doctor Dentist",
        "splash_tap": "Tap screen to begin",
        "menu_play": "START PLAYING",
        "menu_level_select": "LEVEL SELECT",
        "menu_minigames": "EDUCATIONAL MINI-GAMES",
        "menu_settings": "SETTINGS",
        "stats_stars": "stars",
        "stats_patients": "patients",

        "char_select_title": "CHOOSE PATIENT",
        "char_select_subtitle": "Examine and treat friendly patients",
        "char_treat_btn": "TREAT TEETH",

        "level_select_title": "LEVEL SELECTION",
        "level_select_subtitle": "Complete each challenge to become a master dentist",
        "lvl_tutorial_title": "Tutorial: Tooth Brushing",
        "lvl_easy_title": "Easy: Scaling & Mild Cavities",
        "lvl_medium_title": "Medium: Comprehensive Clinic",
        "lvl_hard_title": "Hard: Ultimate Master Challenge",
        "lvl_locked": "Locked",
        "lvl_requires": "Requires %d stars to unlock",
        "lvl_high_score": "High score: %d pts",

        "stage_1": "1. Teeth Brushing",
        "stage_2": "2. Scaling",
        "stage_3": "3. Cavity Treatment",
        "stage_4": "4. Gentle Surgery",
        "stage_complete": "Complete",

        "result_title": "🎉 EXCELLENT! 🎉",
        "result_subtitle": "Patient's smile is completely clean, bright and healthy!",
        "result_score": "Score: %d pts",
        "result_btn_replay": "Replay",
        "result_btn_next": "Next Level",
        "result_btn_menu": "Main Menu",

        "settings_title": "SETTINGS",
        "settings_bgm": "Background Music (BGM)",
        "settings_sfx": "Sound Effects (SFX)",
        "settings_language": "Language",
        "settings_reset_btn": "Reset Progress",
        "settings_reset_confirm": "Are you sure you want to reset all progress?",
        "btn_close": "Close",
        "btn_back": "Back"
    ]

    public func t(_ key: String, _ args: CVarArg...) -> String {
        guard let format = enStrings[key] else { return key }
        if !args.isEmpty {
            return String(format: format, arguments: args)
        }
        return format
    }
}
}
