import SwiftUI

public struct CharacterSelectionView: View {
    public let characters: [CharacterModel]
    public let onSelectCharacter: (CharacterModel) -> Void
    public let onOpenMiniGames: (() -> Void)?
    public let onBack: (() -> Void)?

    @State private var showSettings: Bool = false
    @State private var selectedFilter: Int = 0 // 0: All, 1: Easy, 2: Medium, 3: Hard
    @State private var selectedPatient: CharacterModel? = nil
    @ObservedObject private var audioManager = AudioManager.shared

    public init(
        characters: [CharacterModel] = CharacterModel.createDefaultCharacters(),
        onSelectCharacter: @escaping (CharacterModel) -> Void,
        onOpenMiniGames: (() -> Void)? = nil,
        onBack: (() -> Void)? = nil
    ) {
        self.characters = characters
        self.onSelectCharacter = onSelectCharacter
        self.onOpenMiniGames = onOpenMiniGames
        self.onBack = onBack
    }

    private var filteredCharacters: [CharacterModel] {
        switch selectedFilter {
        case 1:
            return characters.filter {
                let lvl = DifficultyLevel.getLevelForCharacter(characterId: $0.id)
                return lvl == .tutorial || lvl == .easy
            }
        case 2:
            return characters.filter { DifficultyLevel.getLevelForCharacter(characterId: $0.id) == .medium }
        case 3:
            return characters.filter { DifficultyLevel.getLevelForCharacter(characterId: $0.id) == .hard }
        default:
            return characters
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    public var body: some View {
        ZStack {
            // Soft gradient background matching Android (SoftPeach -> PastelLavender -> SkyBlue)
            LinearGradient(
                colors: [Color.softPeach, Color.pastelLavender, Color.skyBlue],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                // Header with Back Button and Settings Gear Button
                HStack {
                    if let onBack = onBack {
                        Button(action: {
                            audioManager.playButtonClick()
                            onBack()
                        }) {
                            Image(systemName: "arrow.backward")
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(Color.skyBlueDark)
                                .frame(width: 42, height: 42)
                                .background(Color.white)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.skyBlueDark.opacity(0.3), lineWidth: 1.5))
                                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                        }
                    } else {
                        Spacer().frame(width: 42)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("CHỌN BỆNH NHÂN")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))
                        Text("20 bé hoạt hình đang chờ khám nha khoa")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.28, green: 0.33, blue: 0.41))
                    }

                    Spacer()

                    Button(action: {
                        audioManager.playButtonClick()
                        showSettings = true
                    }) {
                        Text("⚙️")
                            .font(.system(size: 18))
                            .frame(width: 42, height: 42)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(red: 0.4, green: 0.45, blue: 0.55).opacity(0.3), lineWidth: 1.5))
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Educational Mini-games Hub Banner
                if let onMiniGames = onOpenMiniGames {
                    Button(action: {
                        audioManager.playButtonClick()
                        onMiniGames()
                    }) {
                        HStack(spacing: 10) {
                            Text("🎮")
                                .font(.system(size: 20))
                            Text("KHÁM PHÁ 4 MINI-GAMES GIÁO DỤC")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                            Text("▶")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "F43F5E"), Color(hex: "FB7185")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color(hex: "F43F5E").opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .padding(.horizontal, 16)
                }

                // Filter Tabs (Tất Cả, Dễ, Vừa, Khó)
                HStack(spacing: 8) {
                    FilterChip(title: "Tất Cả (20)", isSelected: selectedFilter == 0) {
                        audioManager.playButtonClick()
                        selectedFilter = 0
                    }
                    FilterChip(title: "Dễ (7)", isSelected: selectedFilter == 1) {
                        audioManager.playButtonClick()
                        selectedFilter = 1
                    }
                    FilterChip(title: "Vừa (7)", isSelected: selectedFilter == 2) {
                        audioManager.playButtonClick()
                        selectedFilter = 2
                    }
                    FilterChip(title: "Khó (6)", isSelected: selectedFilter == 3) {
                        audioManager.playButtonClick()
                        selectedFilter = 3
                    }
                }
                .padding(.horizontal, 16)

                // 20 Patients Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(filteredCharacters) { character in
                            CharacterCard(character: character) {
                                audioManager.playCharacterReaction()
                                selectedPatient = character
                            }
                        }
                    }
                    .padding(14)
                }
            }

            // Patient Intro Dialog
            if let patient = selectedPatient {
                let diff = DifficultyLevel.getLevelForCharacter(characterId: patient.id)
                PatientIntroDialog(
                    character: patient,
                    difficultyTitle: diff.title.components(separatedBy: ":").first ?? "Bệnh nhân",
                    onDismiss: {
                        selectedPatient = nil
                    },
                    onStartTreatment: {
                        let selected = patient
                        selectedPatient = nil
                        onSelectCharacter(selected)
                    }
                )
            }
        }
        .onAppear {
            audioManager.startBgm(named: "bgm_main_menu")
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet()
        }
    }
}

public struct CharacterCard: View {
    public let character: CharacterModel
    public let onClick: () -> Void

    public var body: some View {
        Button(action: onClick) {
            VStack(spacing: 8) {
                // Character Portrait Avatar
                ZStack {
                    Circle()
                        .fill(Color(hex: character.skinToneHex))
                        .frame(width: 84, height: 84)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: character.shirtColorHex), lineWidth: 3)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)

                    if let uiImage = UIImage(named: "\(character.id)_portrait") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 76, height: 76)
                            .clipShape(Circle())
                    } else {
                        // Fallback cute face
                        VStack(spacing: 4) {
                            HStack(spacing: 16) {
                                Circle().fill(Color(red: 0.1, green: 0.1, blue: 0.1)).frame(width: 8, height: 8)
                                Circle().fill(Color(red: 0.1, green: 0.1, blue: 0.1)).frame(width: 8, height: 8)
                            }
                            Arc(startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
                                .stroke(Color(red: 0.7, green: 0.2, blue: 0.2), lineWidth: 2.5)
                                .frame(width: 20, height: 8)
                        }
                    }
                }
                .padding(.top, 4)

                Text(character.name)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))

                // Difficulty badge
                let diff = DifficultyLevel.getLevelForCharacter(characterId: character.id)
                Text(diff.title.components(separatedBy: ":").first ?? "Dễ")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.skyBlueDark)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.skyBlueDark.opacity(0.12))
                    .cornerRadius(8)

                Text(character.description)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.55))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 28)

                Text("KHÁM RĂNG")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.skyBlueDark)
                    .cornerRadius(14)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

struct Arc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        return path
    }
}

public struct FilterChip: View {
    public let title: String
    public let isSelected: Bool
    public let action: () -> Void

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(isSelected ? .white : Color(red: 0.20, green: 0.25, blue: 0.33))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? Color.skyBlueDark : Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
        }
    }
}
