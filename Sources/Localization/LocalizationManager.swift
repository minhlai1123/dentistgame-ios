import Foundation
import SwiftUI

public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case vietnamese = "vi"
    case english = "en"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .vietnamese: return "Tiếng Việt"
        case .english: return "English"
        }
    }
}

public final class LocalizationManager: ObservableObject, @unchecked Sendable {
    public static let shared = LocalizationManager()

    @Published public var currentLanguage: AppLanguage = .vietnamese

    public init(language: AppLanguage = .vietnamese) {
        self.currentLanguage = language
    }

    public func setLanguage(_ language: AppLanguage) {
        self.currentLanguage = language
    }

    private let viStrings: [String: String] = [
        "app_name": "Bác Sĩ Nha Khoa Trẻ Em",
        "splash_tap": "Chạm vào màn hình để bắt đầu",
        "menu_play": "BẮT ĐẦU CHƠI",
        "menu_level_select": "CHỌN CẤP ĐỘ",
        "menu_minigames": "MINI-GAMES GIÁO DỤC",
        "menu_settings": "CÀI ĐẶT",
        "stats_stars": "sao",
        "stats_patients": "bệnh nhân",

        "char_select_title": "CHỌN BỆNH NHÂN",
        "char_select_subtitle": "Khám và chữa trị cho 6 bạn nhỏ đáng yêu",
        "char_treat_btn": "KHÁM RĂNG",

        "level_select_title": "CHỌN CẤP ĐỘ",
        "level_select_subtitle": "Vượt qua từng thử thách để trở thành Nha sĩ tài ba",
        "lvl_tutorial_title": "Tập Sự: Khởi Động Đánh Răng",
        "lvl_easy_title": "Dễ: Cạo Vôi & Trị Sâu Răng Nhẹ",
        "lvl_medium_title": "Trung Bình: Nha Khoa Tổng Hợp",
        "lvl_hard_title": "Khó: Thử Thách Bác Sĩ Toàn Diện",
        "lvl_locked": "Khóa",
        "lvl_requires": "Cần %d sao để mở",
        "lvl_high_score": "Điểm cao: %d điểm",

        "stage_1": "1. Chải Răng",
        "stage_2": "2. Cạo Vôi",
        "stage_3": "3. Trị Sâu",
        "stage_4": "4. Phẫu Thuật",
        "stage_complete": "Hoàn Tất",

        "result_title": "🎉 XUẤT SẮC! 🎉",
        "result_subtitle": "Hàm răng của bé đã hoàn toàn sạch khỏe và sáng bóng!",
        "result_score": "Điểm số: %d điểm",
        "result_btn_replay": "Chơi Lại",
        "result_btn_next": "Màn Tiếp Theo",
        "result_btn_menu": "Về Trang Chủ",

        "settings_title": "CÀI ĐẶT",
        "settings_bgm": "Nhạc Nền (BGM)",
        "settings_sfx": "Hiệu Ứng (SFX)",
        "settings_language": "Ngôn Ngữ",
        "settings_reset_btn": "Đặt Lại Tiến Trình",
        "settings_reset_confirm": "Bạn có chắc muốn đặt lại toàn bộ tiến trình không?",
        "btn_close": "Đóng",
        "btn_back": "Quay Lại"
    ]

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
        "char_select_subtitle": "Examine and treat 6 friendly patients",
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
        let dict = (currentLanguage == .vietnamese) ? viStrings : enStrings
        guard let format = dict[key] else { return key }
        if !args.isEmpty {
            return String(format: format, arguments: args)
        }
        return format
    }
}
