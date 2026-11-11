import Foundation
import SwiftUI

/// The 10 specialized dental tools supported in the game.
public enum DentalTool: String, CaseIterable, Identifiable, Sendable {
    case toothbrush = "tool_toothbrush"
    case scaler = "tool_scaler"
    case drill = "tool_drill"
    case resinTube = "tool_resin_tube"
    case curingLight = "tool_curing_light"
    case waterSpray = "tool_water_spray"
    case syringe = "tool_syringe"
    case forceps = "tool_forceps"
    case implant = "tool_implant"
    case tweezers = "tool_tweezers"

    public var id: String { rawValue }

    public var accentColor: Color {
        switch self {
        case .toothbrush: return Color.blue
        case .scaler: return Color.green
        case .drill: return Color.orange
        case .resinTube: return Color.teal
        case .curingLight: return Color.purple
        case .waterSpray: return Color.cyan
        case .syringe: return Color.red
        case .forceps: return Color.gray
        case .implant: return Color.yellow
        case .tweezers: return Color.indigo
        }
    }

    public var displayName: String {
        switch self {
        case .toothbrush: return "Bàn Chải"
        case .scaler: return "Móc Cạo Vôi"
        case .drill: return "Máy Khoan"
        case .resinTube: return "Keo Trám"
        case .curingLight: return "Đèn UV"
        case .waterSpray: return "Vòi Xịt Nước"
        case .syringe: return "Ống Tiêm"
        case .forceps: return "Kìm Nhổ Răng"
        case .implant: return "Răng Sứ"
        case .tweezers: return "Nhíp Mổ"
        }
    }

    public func canInteract(with state: ToothState) -> Bool {
        switch self {
        case .toothbrush: return state == .dirtStained
        case .scaler: return state == .calculus
        case .drill: return state == .bacteria
        case .resinTube: return state == .cavityDrilled
        case .curingLight: return state == .resinFilled
        case .waterSpray: return state == .resinCured
        case .forceps: return state == .necroticCracked
        case .implant: return state == .socketEmpty
        case .syringe: return state == .necroticCracked
        case .tweezers: return false
        }
    }
}
