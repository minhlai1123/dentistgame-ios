import SwiftUI

public struct ClinicRoomView: View {
    public let character: CharacterModel
    public let onFinishTreatment: ((Int, Int) -> Void)?
    public let onBack: () -> Void

    @State private var teeth: [ToothModel]
    @State private var debrisList: [ForeignDebris]
    @State private var activeTool: DentalTool? = .toothbrush
    @State private var currentScore: Int = 0
    @State private var messageBanner: String = "Chọn dụng cụ và kéo lên răng để điều trị"
    @State private var showVictory: Bool = false
    @State private var showSettings: Bool = false
    @State private var expression: String = "worried"

    @StateObject private var particleSystem = ParticleSystem()
    @ObservedObject private var audioManager = AudioManager.shared
    @StateObject private var stageCoordinator = StageCoordinator()

    private let progressManager = ProgressManager()
    private let toolEngine = ToolInteractionEngine()

    public init(
        character: CharacterModel,
        onFinishTreatment: ((Int, Int) -> Void)? = nil,
        onBack: @escaping () -> Void
    ) {
        self.character = character
        self.onFinishTreatment = onFinishTreatment
        self.onBack = onBack
        self._teeth = State(initialValue: character.initialTeeth)
        self._debrisList = State(initialValue: character.id == "char_06_ben" ? ForeignDebris.createDefaultDebris() : [])
    }

    private var progressState: ProgressState {
        progressManager.calculateProgress(for: teeth)
    }

    private var currentStage: DentalStage {
        stageCoordinator.determineCurrentStage(teeth: teeth, debrisList: debrisList)
    }

    public var body: some View {
        ZStack {
            Color(red: 0.486, green: 0.835, blue: 0.953) // Pastel Blue
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 1. Top HUD
                ClinicHUDView(
                    character: character,
                    expression: expression,
                    progressPercentage: progressState.progressPercentage,
                    score: currentScore,
                    onBack: {
                        audioManager.playButtonClick()
                        onBack()
                    },
                    onOpenSettings: {
                        audioManager.playButtonClick()
                        showSettings = true
                    }
                )

                // Stage Progress Bar
                StageProgressBarView(currentStage: currentStage)

                // Guidance message
                Text(messageBanner)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.23))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.90))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                // 2. Central Mouth View
                GeometryReader { geo in
                    MouthView(
                        teeth: teeth,
                        debrisList: debrisList,
                        activeTool: activeTool,
                        particleSystem: particleSystem,
                        onDrag: { point in
                            expression = "treatment"
                            guard let tool = activeTool else { return }
                            toolEngine.selectTool(tool)

                            // Syringe anesthesia special handling
                            if tool == .syringe {
                                let hit = toolEngine.findTargetTooth(in: teeth, canvasSize: geo.size, touchPoint: point)
                                if let target = hit.tooth, target.state == .necroticCracked {
                                    _ = stageCoordinator.applyAnesthesia()
                                    audioManager.playCharacterReaction()
                                    messageBanner = "Đã gây tê giảm đau! Giờ có thể dùng kìm nhổ răng."
                                }
                                return
                            }

                            // Forceps anesthesia gating check
                            if tool == .forceps && !stageCoordinator.canExtractTooth() {
                                messageBanner = "Phải dùng ống tiêm gây tê trước khi nhổ răng để bé không đau!"
                                return
                            }

                            let hit = toolEngine.findTargetTooth(
                                in: teeth,
                                canvasSize: geo.size,
                                touchPoint: point
                            )
                            if let target = hit.tooth {
                                let result = toolEngine.applyActiveTool(to: target)
                                switch result {
                                case .success(let updatedTooth, let isStateChanged, let points, let msg):
                                    if let idx = teeth.firstIndex(where: { $0.id == updatedTooth.id }) {
                                        teeth[idx] = updatedTooth
                                    }
                                    if points > 0 {
                                        progressManager.addScore(points)
                                        currentScore = progressManager.score
                                    }
                                    messageBanner = msg

                                    // Play sound & particles
                                    audioManager.playToolSfx(tool)
                                    switch tool {
                                    case .toothbrush:
                                        particleSystem.spawnToolParticles(type: .bubble, originX: point.x, originY: point.y, count: 3)
                                    case .waterSpray:
                                        particleSystem.spawnToolParticles(type: .waterDrop, originX: point.x, originY: point.y, count: 4)
                                    case .scaler:
                                        particleSystem.spawnToolParticles(type: .calculusFlake, originX: point.x, originY: point.y, count: 3)
                                    default:
                                        break
                                    }

                                    // Clean reward
                                    if isStateChanged && (updatedTooth.state == .clean || updatedTooth.state == .implantPlaced) {
                                        audioManager.playSuccess()
                                        particleSystem.spawnToolParticles(type: .sparkle, originX: point.x, originY: point.y, count: 8)
                                    }

                                    let allDebrisGone = debrisList.allSatisfy { $0.isRemoved }
                                    if progressManager.calculateProgress(for: teeth).isVictory && allDebrisGone {
                                        showVictory = true
                                        expression = "happy"
                                        audioManager.playVictoryCelebration()
                                        particleSystem.spawnConfettiBurst(width: geo.size.width, height: geo.size.height, count: 60)
                                    }
                                case .rejected(_, let reason):
                                    messageBanner = reason
                                }
                            }
                        },
                        onDragEnd: {
                            toolEngine.endDrag()
                            if !progressState.isVictory {
                                expression = (progressState.remainingIssuesCount > 0) ? "worried" : "normal"
                            }
                        },
                        onHitDebris: { debris in
                            if activeTool == .tweezers {
                                if let idx = debrisList.firstIndex(where: { $0.id == debris.id }) {
                                    debrisList[idx].isRemoved = true
                                    progressManager.addScore(debris.points)
                                    currentScore = progressManager.score
                                    audioManager.playButtonClick()
                                    messageBanner = "Đã gắp sạch \(debris.name)! (+25 pts)"
                                }
                            } else {
                                messageBanner = "Hãy dùng nhíp mổ để gắp \(debris.name) ra khỏi miệng!"
                            }
                        }
                    )
                }

                // 3. Bottom Instrument Tray
                InstrumentTrayView(
                    activeTool: activeTool,
                    onSelectTool: { tool in
                        audioManager.playButtonClick()
                        activeTool = tool
                        messageBanner = "Đã chọn \(tool.displayName). Hãy kéo vào răng phù hợp!"
                    }
                )
            }

            // 4. Victory Overlay
            if showVictory {
                let stars = currentScore >= 500 ? 3 : (currentScore >= 300 ? 2 : 1)
                VictoryOverlayView(
                    score: currentScore,
                    patientName: character.name,
                    onContinue: {
                        if let onFinish = onFinishTreatment {
                            onFinish(currentScore, stars)
                        } else {
                            onBack()
                        }
                    }
                )
            }
        }
        .onAppear {
            audioManager.startBgm(named: "bgm_dental_clinic")
        }
        .onChange(of: teeth) { newTeeth in
            let stage = stageCoordinator.determineCurrentStage(teeth: newTeeth, debrisList: debrisList)
            if stage == .decay {
                let hasBacteria = newTeeth.contains { $0.state == .bacteria }
                let hasDrilled = newTeeth.contains { $0.state == .cavityDrilled }
                let hasResinFilled = newTeeth.contains { $0.state == .resinFilled }
                let hasResinCured = newTeeth.contains { $0.state == .resinCured }

                if !hasBacteria && hasDrilled && activeTool != .resinTube {
                    activeTool = .resinTube
                    toolEngine.selectTool(.resinTube)
                    messageBanner = "Bước 2/4: Đã khoan sạch! Chạm Ống Keo Trám vào lỗ sâu để bơm men sứ!"
                    audioManager.playSuccess()
                } else if !hasBacteria && !hasDrilled && hasResinFilled && activeTool != .curingLight {
                    activeTool = .curingLight
                    toolEngine.selectTool(.curingLight)
                    messageBanner = "Bước 3/4: Đã bơm keo! Dùng Đèn Quang chiếu vào keo để đông cứng men răng!"
                    audioManager.playSuccess()
                } else if !hasBacteria && !hasDrilled && !hasResinFilled && hasResinCured && activeTool != .waterSpray {
                    activeTool = .waterSpray
                    toolEngine.selectTool(.waterSpray)
                    messageBanner = "Bước 4/4: Men răng đã đông! Dùng Vòi Xịt Nước xịt sạch để răng sáng bóng!"
                    audioManager.playSuccess()
                }
            } else if stage == .surgery {
                let hasNecrotic = newTeeth.contains { $0.state == .necroticCracked }
                let hasSocketEmpty = newTeeth.contains { $0.state == .socketEmpty }
                if !hasNecrotic && hasSocketEmpty && activeTool != .implant {
                    activeTool = .implant
                    toolEngine.selectTool(.implant)
                    messageBanner = "Đã nhổ răng hư! Giờ hãy gắp Răng Sứ đặt vào để phục hồi hàm răng nhé!"
                    audioManager.playSuccess()
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(saveManager: SaveManager.shared, localizationManager: LocalizationManager.shared)
        }
    }
}

struct ClinicHUDView: View {
    let character: CharacterModel
    let expression: String
    let progressPercentage: Double
    let score: Int
    let onBack: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.12, green: 0.53, blue: 0.90))
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }

            // Character reaction avatar badge
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: character.skinToneHex))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(expressionEmoji(for: expression))
                            .font(.system(size: 20))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(character.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))
                    Text("\(score) pts")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.95, green: 0.65, blue: 0.0))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.9))
            .cornerRadius(18)

            Spacer()

            // Progress bar
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(Int(progressPercentage * 100))% Sạch")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.05, green: 0.60, blue: 0.40))

                ProgressView(value: progressPercentage, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.10, green: 0.75, blue: 0.50)))
                    .frame(width: 90)
            }

            // Settings Gear Button
            Button(action: onOpenSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.35, green: 0.45, blue: 0.55))
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func expressionEmoji(for exp: String) -> String {
        switch exp {
        case "happy": return "😄"
        case "treatment": return "😮"
        case "worried": return "🥺"
        default: return "🙂"
        }
    }
}

struct VictoryOverlayView: View {
    let score: Int
    let patientName: String
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("🎉 XUẤT SẮC! 🎉")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 0.05, green: 0.60, blue: 0.40))

                Text("Hàm răng của \(patientName) đã được chữa trị sạch bóng và khỏe mạnh!")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.20, green: 0.25, blue: 0.33))
                    .padding(.horizontal, 16)

                // 3 Stars
                HStack(spacing: 8) {
                    ForEach(0..<3) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 34))
                            .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.0))
                    }
                }

                Text("Tổng điểm: \(score) pts")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.08, green: 0.40, blue: 0.75))

                Button(action: onContinue) {
                    Text("TIẾP TỤC")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.05, green: 0.60, blue: 0.40))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(24)
            .padding(32)
            .shadow(radius: 20)
        }
    }
}
