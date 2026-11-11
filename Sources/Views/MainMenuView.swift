import SwiftUI

public struct MainMenuView: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var saveManager: SaveManager
    @ObservedObject var localizationManager: LocalizationManager
    public let onStartGame: () -> Void
    public let onOpenLevelSelect: () -> Void
    public let onOpenMiniGames: () -> Void

    @State private var showSettings: Bool = false

    public init(
        audioManager: AudioManager,
        saveManager: SaveManager,
        localizationManager: LocalizationManager,
        onStartGame: @escaping () -> Void,
        onOpenLevelSelect: @escaping () -> Void,
        onOpenMiniGames: @escaping () -> Void
    ) {
        self.audioManager = audioManager
        self.saveManager = saveManager
        self.localizationManager = localizationManager
        self.onStartGame = onStartGame
        self.onOpenLevelSelect = onOpenLevelSelect
        self.onOpenMiniGames = onOpenMiniGames
    }

    public var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.98, blue: 1.0)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Top Bar
                HStack {
                    // Stats pill
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Text("⭐")
                            Text("\(saveManager.totalStars) \(localizationManager.t("stats_stars"))")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.orange)
                        }

                        HStack(spacing: 4) {
                            Text("🦷")
                            Text("\(saveManager.totalPatientsCured) \(localizationManager.t("stats_patients"))")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.blue)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.06), radius: 4)

                    Spacer()

                    // Settings Button
                    Button(action: {
                        audioManager.playButtonClick()
                        showSettings = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                                .shadow(color: .black.opacity(0.06), radius: 4)
                            Text("⚙️")
                                .font(.system(size: 20))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Spacer()

                // Hero Logo
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 110, height: 110)
                            .overlay(
                                Circle().stroke(Color.blue.opacity(0.3), lineWidth: 4)
                            )
                            .shadow(color: .black.opacity(0.08), radius: 6)
                        Text("🏥")
                            .font(.system(size: 52))
                    }

                    Text(localizationManager.t("app_name"))
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))

                    Text(localizationManager.t("char_select_subtitle"))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Action Buttons
                VStack(spacing: 14) {
                    // Play Button
                    Button(action: {
                        audioManager.playButtonClick()
                        onStartGame()
                    }) {
                        HStack(spacing: 10) {
                            Text("▶")
                                .font(.system(size: 18, weight: .bold))
                            Text(localizationManager.t("menu_play"))
                                .font(.system(size: 16, weight: .black))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(colors: [Color.blue, Color(red: 0.2, green: 0.7, blue: 0.95)], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(18)
                        .shadow(color: .blue.opacity(0.3), radius: 6, y: 3)
                    }

                    // Level Select Button
                    Button(action: {
                        audioManager.playButtonClick()
                        onOpenLevelSelect()
                    }) {
                        HStack(spacing: 8) {
                            Text("🗺️")
                            Text(localizationManager.t("menu_level_select"))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.06), radius: 4)
                    }

                    // Mini-Games Hub Button
                    Button(action: {
                        audioManager.playButtonClick()
                        onOpenMiniGames()
                    }) {
                        HStack(spacing: 8) {
                            Text("🎮")
                            Text(localizationManager.t("menu_minigames"))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.purple)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.06), radius: 4)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            audioManager.startBgm(named: "bgm_main_menu")
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(saveManager: saveManager, localizationManager: localizationManager)
        }
    }
}
