import SwiftUI

public struct ClinicRoomView: View {
    public let character: CharacterModel
    public let onFinishTreatment: ((Int, Int) -> Void)?
    public let onBack: () -> Void

    @State private var teeth: [ToothModel]
    @State private var debrisList: [ForeignDebris]
    @State private var activeTool: DentalTool? = .toothbrush
    @State private var currentScore: Int = 0
    @State private var messageBanner: String = "Chào mừng! Cùng chăm sóc hàm răng thật sạch đẹp nhé!"
    @State private var showVictory: Bool = false
    @State private var showSettings: Bool = false
    @State private var showTutorial: Bool = true
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

    private var stageStatus: StageStatus {
        stageCoordinator.getStageStatus(teeth: teeth, debrisList: debrisList)
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
                StageProgressBarView(currentStage: stageStatus.currentStage)
                    .padding(.top, 2)

                // Guidance message / Tutorial bubble
                if showTutorial {
                    TutorialBubble(
                        instructionText: messageBanner,
                        skipText: "Bỏ qua",
                        onSkip: { showTutorial = false }
                    )
                    .padding(.top, 4)
                } else {
                    Text(messageBanner)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.23))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 7)
                        .background(Color.white.opacity(0.92))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                }

                // 2. Central Mouth View framed inside Patient's Cartoon Face
                GeometryReader { geo in
                    CharacterFaceView(character: character, expression: expression) {
                        MouthView(
                            teeth: teeth,
                            debrisList: debrisList,
                            activeTool: activeTool,
                            particleSystem: particleSystem,
                            onDrag: { point in
                                handleToolDrag(point: point, canvasSize: geo.size)
                            },
                            onDragEnd: {
                                expression = "worried"
                                toolEngine.endDrag()
                            },
                            onHitDebris: { debris in
                                handleDebrisHit(debris: debris)
                            }
                        )
                    }
                }
                .padding(.horizontal, 8)

                // 3. Bottom Instrument Tray
                InstrumentTrayView(
                    tools: stageStatus.activeTools.isEmpty ? DentalTool.allCases : stageStatus.activeTools,
                    activeTool: activeTool,
                    onSelectTool: { tool in
                        audioManager.playButtonClick()
                        activeTool = tool
                        toolEngine.selectTool(tool)
                    }
                )
            }

            // Victory Dialog Overlay
            if showVictory {
                VictoryCelebrationDialog(
                    score: currentScore,
                    patientName: character.name,
                    onContinue: {
                        showVictory = false
                        let stars = (currentScore >= 500) ? 3 : ((currentScore >= 300) ? 2 : 1)
                        onFinishTreatment?(currentScore, stars)
                    }
                )
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(
                saveManager: SaveManager.shared,
                localizationManager: LocalizationManager.shared
            )
        }
        .onAppear {
            audioManager.startBgm(named: "bgm_dental_clinic")
            updateAutoAdvanceTool()
        }
        .onChange(of: teeth) { _ in
            updateAutoAdvanceTool()
        }
    }

    private func handleToolDrag(point: CGPoint, canvasSize: CGSize) {
        expression = "treatment"
        guard let tool = activeTool else { return }
        toolEngine.selectTool(tool)

        let hit = toolEngine.findTargetTooth(
            in: teeth,
            canvasSize: canvasSize,
            touchPoint: point,
            proximityThreshold: 95.0
        )

        guard let target = hit.tooth else { return }

        // Syringe anesthesia special handling
        if tool == .syringe && target.state == .necroticCracked {
            if stageCoordinator.applyAnesthesia() {
                audioManager.playCharacterReaction()
                particleSystem.spawnToolParticles(
                    type: .bubble,
                    originX: target.normalizedX * canvasSize.width,
                    originY: target.normalizedY * canvasSize.height,
                    count: 15
                )
                messageBanner = "Đã gây tê giảm đau! Giờ có thể dùng kìm nhổ răng."
            }
            return
        }

        // Forceps anesthesia gating check
        if tool == .forceps && !stageCoordinator.canExtractTooth() {
            audioManager.playWrongBuzz()
            messageBanner = "Bé hãy dùng Ống Tiêm gây tê trước khi nhổ răng để bạn không bị đau nhé!"
            return
        }

        // Friendly advice for resin without drilling
        if tool == .resinTube && target.state == .bacteria {
            messageBanner = "Bé hãy dùng Máy Khoan nạo sạch vết sâu trước, rồi mới bơm keo trám nhé!"
            return
        }

        let result = toolEngine.applyActiveTool(to: target)
        switch result {
        case .success(let nextTooth, let changed, let points, _):
            if changed {
                teeth = teeth.map { $0.id == nextTooth.id ? nextTooth : $0 }
                currentScore += points
                playToolSound(for: tool)

                let tx = nextTooth.normalizedX * canvasSize.width
                let ty = nextTooth.normalizedY * canvasSize.height
                let pType: ParticleType = {
                    switch tool {
                    case .toothbrush: return .bubble
                    case .scaler: return .calculusFlake
                    case .waterSpray: return .waterDrop
                    default: return .sparkle
                    }
                }()
                particleSystem.spawnToolParticles(type: pType, originX: tx, originY: ty, count: 12)

                let newStatus = stageCoordinator.getStageStatus(teeth: teeth, debrisList: debrisList)
                if newStatus.isCompleted {
                    audioManager.playSuccess()
                    messageBanner = "Tuyệt vời! Giai đoạn \(newStatus.currentStage.name) đã hoàn thành!"
                } else {
                    messageBanner = newStatus.guidancePrompt
                }

                let p = progressManager.calculateProgress(for: teeth)
                if p.isComplete {
                    audioManager.playVictoryCelebration()
                    particleSystem.spawnConfettiBurst(width: canvasSize.width, height: canvasSize.height, count: 45)
                    expression = "happy"
                    showVictory = true
                }
            } else {
                teeth = teeth.map { $0.id == nextTooth.id ? nextTooth : $0 }
            }

        case .rejected(_, let reason):
            messageBanner = reason
        }
    }

    private func handleDebrisHit(debris: ForeignDebris) {
        guard activeTool == .tweezers else {
            messageBanner = "Dùng Nhíp Mổ gắp dị vật ra khỏi miệng nhé!"
            return
        }
        debrisList = debrisList.map { $0.id == debris.id ? $0.copy(isRemoved: true) : $0 }
        currentScore += 30
        audioManager.playSuccess()
        messageBanner = "Đã gắp dị vật thành công! Bỏ vào thùng rác."
        updateAutoAdvanceTool()
    }

    private func updateAutoAdvanceTool() {
        switch stageStatus.currentStage {
        case .decay:
            let hasBacteria = teeth.contains { $0.state == .bacteria }
            let hasDrilled = teeth.contains { $0.state == .cavityDrilled }
            let hasResinFilled = teeth.contains { $0.state == .resinFilled }
            let hasResinCured = teeth.contains { $0.state == .resinCured }

            if hasBacteria {
                activeTool = .drill
                toolEngine.selectTool(.drill)
                messageBanner = "Bước 1/4: Dùng Máy Khoan nạo sạch vi khuẩn/đốm đen!"
            } else if hasDrilled {
                activeTool = .resinTube
                toolEngine.selectTool(.resinTube)
                messageBanner = "Bước 2/4: Đã khoan sạch! Chạm Ống Keo Trám vào lỗ sâu để bơm men sứ!"
            } else if hasResinFilled {
                activeTool = .curingLight
                toolEngine.selectTool(.curingLight)
                messageBanner = "Bước 3/4: Rê Đèn Quang sấy đông cứng vết keo trám!"
            } else if hasResinCured {
                activeTool = .waterSpray
                toolEngine.selectTool(.waterSpray)
                messageBanner = "Bước 4/4: Dùng Vòi Xịt rửa sạch hoàn tất hàm răng!"
            }

        case .surgery:
            let hasNecrotic = teeth.contains { $0.state == .necroticCracked }
            let hasEmptySocket = teeth.contains { $0.state == .socketEmpty }
            let hasImplant = teeth.contains { $0.state == .implantPlaced }

            if hasNecrotic && !stageCoordinator.canExtractTooth() {
                activeTool = .syringe
                toolEngine.selectTool(.syringe)
                messageBanner = "Bước 1/4: Dùng Ống Tiêm gây tê để bé không đau trước khi nhổ răng!"
            } else if hasNecrotic && stageCoordinator.canExtractTooth() {
                activeTool = .forceps
                toolEngine.selectTool(.forceps)
                messageBanner = "Bước 2/4: Thuốc tê đã ngấm! Dùng Kìm nhổ chiếc răng sâu vỡ ra!"
            } else if hasEmptySocket {
                activeTool = .implant
                toolEngine.selectTool(.implant)
                messageBanner = "Bước 3/4: Đặt Răng Sứ mới vào chân răng vừa nhổ!"
            } else if hasImplant {
                activeTool = .waterSpray
                toolEngine.selectTool(.waterSpray)
                messageBanner = "Bước 4/4: Dùng Vòi Xịt nước rửa sạch hoàn tất!"
            }

        case .hygiene:
            let hasDirt = teeth.contains { $0.state == .dirtStained }
            let hasCalculus = teeth.contains { $0.state == .calculus }

            if hasDirt {
                activeTool = .toothbrush
                toolEngine.selectTool(.toothbrush)
                messageBanner = "Dùng Bàn Chải chải sạch mảng bám thức ăn trên răng!"
            } else if hasCalculus {
                activeTool = .scaler
                toolEngine.selectTool(.scaler)
                messageBanner = "Dùng Cây Cạo Vôi cạo sạch các mảng vôi răng cứng đầu!"
            } else {
                activeTool = .waterSpray
                toolEngine.selectTool(.waterSpray)
                messageBanner = "Dùng Vòi Xịt nước xịt trôi bọt kem và làm trắng bóng răng!"
            }

        case .diagnosis:
            activeTool = .mirror
            toolEngine.selectTool(.mirror)
            messageBanner = "Dùng Gương Nha Khoa soi kiểm tra toàn bộ hàm răng!"

        case .debris:
            activeTool = .tweezers
            toolEngine.selectTool(.tweezers)
            messageBanner = "Dùng Nhíp gắp các dị vật mắc trong miệng bỏ vào thùng rác!"
        }
    }

    private func playToolSound(for tool: DentalTool) {
        audioManager.playToolSfx(tool)
    }
}

public struct ClinicHUDView: View {
    public let character: CharacterModel
    public let expression: String
    public let progressPercentage: Double
    public let score: Int
    public let onBack: () -> Void
    public let onOpenSettings: () -> Void

    public var body: some View {
        HStack(spacing: 12) {
            // Back Button
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(Color.skyBlueDark)
                    .frame(width: 42, height: 42)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.skyBlueDark.opacity(0.3), lineWidth: 1.5))
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }

            // Character reaction avatar badge
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: character.skinToneHex))
                    .frame(width: 38, height: 38)
                    .overlay(
                        Text(expressionEmoji(for: expression))
                            .font(.system(size: 20))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(character.name)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))
                    Text("\(score) pts")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.95, green: 0.60, blue: 0.0))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.92))
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.06), lineWidth: 1))

            Spacer()

            // Progress bar
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(Int(progressPercentage * 100))% Sạch")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.05, green: 0.60, blue: 0.40))

                ProgressView(value: progressPercentage, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.05, green: 0.75, blue: 0.45)))
                    .frame(width: 86)
            }

            // Settings Button
            Button(action: onOpenSettings) {
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

public struct VictoryCelebrationDialog: View {
    public let score: Int
    public let patientName: String
    public let onContinue: () -> Void

    @State private var starScale: Bool = false

    public var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Trophy header
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.95, blue: 0.78))
                        .frame(width: 80, height: 80)
                    Text("🏆")
                        .font(.system(size: 42))
                }
                .scaleEffect(starScale ? 1.15 : 0.95)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        starScale = true
                    }
                }

                Text("HOÀN THÀNH XUẤT SẮC!")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.02, green: 0.59, blue: 0.41))
                    .multilineTextAlignment(.center)

                Text("Bé đã chữa lành hàm răng cho \(patientName) thật sáng bóng!")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.28, green: 0.33, blue: 0.41))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 12)

                // 3 Stars rating
                HStack(spacing: 6) {
                    let starCount = (score >= 500) ? 3 : ((score >= 300) ? 2 : 1)
                    ForEach(1...3, id: \.self) { i in
                        Text(i <= starCount ? "⭐" : "☆")
                            .font(.system(size: 32))
                            .foregroundColor(i <= starCount ? Color(hex: "F59E0B") : Color(hex: "CBD5E1"))
                    }
                }

                Text("Tổng Điểm: \(score)")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.skyBlueDark)

                Button(action: onContinue) {
                    Text("TIẾP TỤC")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.02, green: 0.59, blue: 0.41))
                        .cornerRadius(20)
                        .shadow(color: Color(red: 0.02, green: 0.59, blue: 0.41).opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .padding(.horizontal, 8)
            }
            .padding(24)
            .background(
                LinearGradient(
                    colors: [Color(hex: "F0FDF4"), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(28)
            .padding(.horizontal, 24)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
}
