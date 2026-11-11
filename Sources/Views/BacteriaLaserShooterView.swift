import SwiftUI

public struct BacteriaLaserShooterView: View {
    @ObservedObject var audioManager: AudioManager
    public let onBack: () -> Void

    @StateObject private var engine = BacteriaBlasterEngine()
    @State private var laserBeamTarget: CGPoint? = nil
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    public init(audioManager: AudioManager, onBack: @escaping () -> Void) {
        self.audioManager = audioManager
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.12, blue: 0.2)
                .ignoresSafeArea()

            VStack {
                // Header
                HStack {
                    Button(action: {
                        audioManager.playButtonClick()
                        onBack()
                    }) {
                        Image(systemName: "arrow.backward.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.orange)
                    }

                    Spacer()

                    Text("BẮN TIA LASER")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.white)

                    Spacer()

                    HStack(spacing: 12) {
                        Text(String(format: "⏱️ %.1fs", engine.remainingTime))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.yellow)

                        Text("🎯 \(engine.hits)/\(engine.targetHitCount)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal)

                Text("Chạm vào màn hình để khai hỏa tia laser diệt trừ vi khuẩn!")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 4)

                // Arena
                GeometryReader { geo in
                    ZStack {
                        // Background mouth glow
                        Circle()
                            .fill(Color.red.opacity(0.15))
                            .frame(width: geo.size.width * 0.8, height: geo.size.height * 0.8)
                            .position(x: geo.size.width * 0.5, y: geo.size.height * 0.45)

                        // Laser Beam effect
                        if let beam = laserBeamTarget {
                            Path { path in
                                path.move(to: CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.9))
                                path.addLine(to: beam)
                            }
                            .stroke(
                                LinearGradient(colors: [.orange, .yellow, .white], startPoint: .bottom, endPoint: .top),
                                lineWidth: 5
                            )
                        }

                        // Targets
                        ForEach(engine.targets) { t in
                            let posX = t.x * geo.size.width
                            let posY = t.y * geo.size.height

                            Image("bug_bacteria")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 46, height: 46)
                                .position(x: posX, y: posY)
                        }

                        // Laser Gun at bottom
                        VStack {
                            Spacer()
                            Image("laser_gun")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .padding(.bottom, 10)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        guard !engine.isGameOver() else { return }
                        laserBeamTarget = location
                        audioManager.playLaserShot()

                        let normX = Double(location.x / geo.size.width)
                        let normY = Double(location.y / geo.size.height)
                        let hit = engine.shootLaser(touchX: normX, touchY: normY)
                        if hit && engine.isVictory() {
                            audioManager.playVictoryCelebration()
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                            laserBeamTarget = nil
                        }
                    }
                }

                // Game Over Overlay
                if engine.isGameOver() {
                    VStack(spacing: 12) {
                        Text(engine.isVictory() ? "🎉 THẮNG LỢI! DIỆT SẠCH VI KHUẨN! 🎉" : "⏰ HẾT GIỜ RỒI! ⏰")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(engine.isVictory() ? .green : .orange)

                        Button(action: {
                            audioManager.playButtonClick()
                            engine.reset()
                        }) {
                            Text("Chơi Lại")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 8)
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
        .onReceive(timer) { _ in
            engine.updateTimer(dt: 0.1)
        }
    }
}
