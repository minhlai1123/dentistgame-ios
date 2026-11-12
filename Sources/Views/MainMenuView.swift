import SwiftUI

public struct MainMenuView: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var saveManager: SaveManager
    @ObservedObject var localizationManager: LocalizationManager
    public let onStartGame: () -> Void
    public let onOpenLevelSelect: () -> Void
    public let onOpenMiniGames: () -> Void

    @State private var showSettings: Bool = false
    @State private var heroPulse: Bool = false

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
            // Soft gradient background matching Android (SoftPeach -> PastelLavender -> SkyBlue)
            LinearGradient(
                colors: [Color.softPeach, Color.pastelLavender, Color.skyBlue],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Top Bar: Stats Pill & Settings Button
                HStack {
                    // Stats pill
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Text("⭐")
                            Text("\(saveManager.totalStars) \(localizationManager.t("stats_stars"))")
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(hex: "D97706"))
                        }

                        HStack(spacing: 4) {
                            Text("🦷")
                            Text("\(saveManager.totalPatientsCured) \(localizationManager.t("stats_patients"))")
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                                .foregroundColor(Color.skyBlueDark)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "FDE68A"), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)

                    Spacer()

                    // Settings Button
                    Button(action: {
                        audioManager.playButtonClick()
                        showSettings = true
                    }) {
                        Text("⚙️")
                            .font(.system(size: 20))
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black.opacity(0.08), lineWidth: 1))
                            .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)

                Spacer()

                // Hero Logo & Title
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle().stroke(Color.skyBlueDark.opacity(0.3), lineWidth: 4)
                            )
                            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)

                        Text("🏥")
                            .font(.system(size: 56))
                    }
                    .scaleEffect(heroPulse ? 1.05 : 0.95)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            heroPulse = true
                        }
                    }

                    VStack(spacing: 4) {
                        Text("BÁC SĨ NHA KHOA")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(Color.skyBlueDark)

                        Text("CHĂM SÓC RĂNG MIỆNG CHO BÉ")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.28, green: 0.33, blue: 0.41))
                            .tracking(1.2)
                    }
                }

                Spacer()

                // Action Buttons
                VStack(spacing: 14) {
                    // Start Treatment Button
                    Button(action: {
                        audioManager.playButtonClick()
                        onStartGame()
                    }) {
                        HStack(spacing: 10) {
                            Text("▶")
                                .font(.system(size: 18, weight: .heavy))
                            Text("BẮT ĐẦU CHỮA RĂNG")
                                .font(.system(size: 17, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "0284C7"), Color(hex: "0369A1")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(22)
                        .shadow(color: Color(hex: "0284C7").opacity(0.35), radius: 8, x: 0, y: 4)
                    }

                    // 4 Mini-games Hub Button
                    Button(action: {
                        audioManager.playButtonClick()
                        onOpenMiniGames()
                    }) {
                        HStack(spacing: 10) {
                            Text("🎮")
                                .font(.system(size: 20))
                            Text("4 MINI-GAMES GIÁO DỤC")
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "F43F5E"), Color(hex: "E11D48")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color(hex: "F43F5E").opacity(0.3), radius: 6, x: 0, y: 3)
                    }

                    // Level Select Button
                    Button(action: {
                        audioManager.playButtonClick()
                        onOpenLevelSelect()
                    }) {
                        HStack(spacing: 8) {
                            Text("🗺️")
                                .font(.system(size: 18))
                            Text("BẢN ĐỒ THỬ THÁCH (CẤP ĐỘ)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "334155"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(hex: "CBD5E1"), lineWidth: 1.5)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            audioManager.startBgm(named: "bgm_main_menu")
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(
                saveManager: saveManager,
                localizationManager: localizationManager
            )
        }
    }
}
