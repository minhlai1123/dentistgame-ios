import SwiftUI

public struct SettingsSheet: View {
    @ObservedObject var audioManager: AudioManager = .shared
    public var saveManager: SaveManager? = nil
    public var localizationManager: LocalizationManager? = nil
    @Environment(\.dismiss) private var dismiss

    @State private var showResetAlert: Bool = false

    public init(
        saveManager: SaveManager? = nil,
        localizationManager: LocalizationManager? = nil
    ) {
        self.saveManager = saveManager
        self.localizationManager = localizationManager
    }

    private func t(_ key: String) -> String {
        return localizationManager?.t(key) ?? key
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("ÂM THANH").font(.system(size: 13, weight: .bold))) {
                    Toggle(isOn: $audioManager.isSfxEnabled) {
                        Label(t("settings_sfx"), systemImage: "speaker.wave.2.fill")
                    }
                    if audioManager.isSfxEnabled {
                        VStack(alignment: .leading) {
                            Text("Âm lượng SFX: \(Int(audioManager.sfxVolume * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Slider(value: $audioManager.sfxVolume, in: 0...1) {
                                Text("SFX Volume")
                            }
                        }
                    }

                    Toggle(isOn: $audioManager.isBgmEnabled) {
                        Label(t("settings_bgm"), systemImage: "music.note")
                    }
                    .onChange(of: audioManager.isBgmEnabled) { _, newValue in
                        audioManager.toggleBgm(newValue)
                    }

                    if audioManager.isBgmEnabled {
                        VStack(alignment: .leading) {
                            Text("Âm lượng BGM: \(Int(audioManager.bgmVolume * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Slider(
                                value: Binding(
                                    get: { audioManager.bgmVolume },
                                    set: { audioManager.setBgmVolume($0) }
                                ),
                                in: 0...1
                            ) {
                                Text("BGM Volume")
                            }
                        }
                    }
                }

                // Language Section
                if let loc = localizationManager {
                    Section(header: Text(t("settings_language")).font(.system(size: 13, weight: .bold))) {
                        Picker(t("settings_language"), selection: Binding(
                            get: { loc.currentLanguage },
                            set: {
                                loc.setLanguage($0)
                                saveManager?.saveLanguage($0)
                            }
                        )) {
                            ForEach(AppLanguage.allCases) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                // Reset Progress Section
                if let save = saveManager {
                    Section {
                        Button(role: .destructive, action: {
                            showResetAlert = true
                        }) {
                            Label(t("settings_reset_btn"), systemImage: "arrow.counterclockwise")
                        }
                    }
                }

                Section(header: Text("CHÍNH SÁCH BẢO MẬT & TRẺ EM").font(.system(size: 13, weight: .bold))) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("100% Không Quảng Cáo (Zero Ads)")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Trò chơi tuyệt đối không chứa quảng cáo, không thu thập dữ liệu cá nhân, an toàn tuyệt đối cho trẻ em.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(t("settings_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(t("btn_close")) {
                        audioManager.playButtonClick()
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .alert(isPresented: $showResetAlert) {
                Alert(
                    title: Text(t("settings_reset_btn")),
                    message: Text(t("settings_reset_confirm")),
                    primaryButton: .destructive(Text("OK")) {
                        saveManager?.resetAllProgress()
                        audioManager.playSuccess()
                    },
                    secondaryButton: .cancel(Text(t("btn_close")))
                )
            }
        }
    }
}
