import SwiftUI

public struct FrogBugCatchingView: View {
    @ObservedObject var audioManager: AudioManager
    public let onBack: () -> Void

    @StateObject private var engine = FrogBugEngine()
    @State private var tongueTarget: CGPoint? = nil

    public init(audioManager: AudioManager, onBack: @escaping () -> Void) {
        self.audioManager = audioManager
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.98, blue: 1.0)
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
                            .foregroundColor(.green)
                    }

                    Spacer()

                    Text("ẾCH BẮT VI KHUẨN")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))

                    Spacer()

                    Text("\(engine.caughtCount)/\(engine.targetBugs)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.green)
                }
                .padding(.horizontal)

                Text("Chạm vào các chú vi khuẩn đang bay để ếch phóng lưỡi đớp sạch!")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)

                // Arena
                GeometryReader { geo in
                    ZStack {
                        // Tongue line when tapping
                        if let target = tongueTarget {
                            Path { path in
                                path.move(to: CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.85))
                                path.addLine(to: target)
                            }
                            .stroke(Color.pink, lineWidth: 6)
                        }

                        // Bacteria Bugs
                        ForEach(engine.bugs) { bug in
                            let posX = bug.x * geo.size.width
                            let posY = bug.y * geo.size.height

                            Image("bug_bacteria")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                                .position(x: posX, y: posY)
                                .onTapGesture {
                                    tongueTarget = CGPoint(x: posX, y: posY)
                                    audioManager.playFrogTongue()
                                    _ = engine.catchBug(bugId: bug.id)

                                    if engine.isVictory() {
                                        audioManager.playVictoryCelebration()
                                    }

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                        tongueTarget = nil
                                    }
                                }
                        }

                        // Frog at bottom center
                        VStack {
                            Spacer()
                            Image("frog_face")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 110, height: 110)
                                .padding(.bottom, 16)
                        }
                    }
                }

                if engine.isVictory() {
                    VStack(spacing: 8) {
                        Text("🎉 THẮNG LỢI! BẠN ĐÃ BẮT HẾT VI KHUẨN! 🎉")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)

                        Button(action: {
                            audioManager.playButtonClick()
                            engine.reset()
                        }) {
                            Text("Chơi Lại")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
    }
}
