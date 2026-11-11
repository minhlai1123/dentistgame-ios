import SwiftUI

public struct HippoFoodSortingView: View {
    @ObservedObject var audioManager: AudioManager
    public let onBack: () -> Void

    @StateObject private var engine = HippoFoodEngine()
    @State private var message: String = "Kéo hoặc chọn đưa thức ăn tốt cho Hà mã, kẹo ngọt vào thùng rác!"
    @State private var isGameFinished: Bool = false

    public init(audioManager: AudioManager, onBack: @escaping () -> Void) {
        self.audioManager = audioManager
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.98, blue: 1.0)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack {
                    Button(action: {
                        audioManager.playButtonClick()
                        onBack()
                    }) {
                        Image(systemName: "arrow.backward.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    Text("CHO HÀ MÃ ĂN")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))

                    Spacer()

                    Text("\(engine.score) pts")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal)

                // Message banner
                Text(message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4)

                Spacer()

                // Playing area: Hippo on left, Trash on right
                HStack(spacing: 30) {
                    VStack {
                        Image("hippo_mouth")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .background(Color.purple.opacity(0.1))
                            .clipShape(Circle())
                        Text("Hà Mã Thích Táo & Rau")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.purple)
                    }

                    VStack {
                        Image("trash_can")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                        Text("Thùng Rác Chứa Kẹo")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                // Current Food Card
                if let food = engine.getCurrentFood() {
                    VStack(spacing: 12) {
                        Image(food.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .shadow(radius: 4)

                        Text(food.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))

                        HStack(spacing: 20) {
                            Button(action: {
                                let result = engine.feedToHippo()
                                message = result.message
                                if result.success {
                                    audioManager.playFoodCrunch()
                                } else {
                                    audioManager.playWrongBuzz()
                                }
                                if engine.isGameFinished() {
                                    isGameFinished = true
                                    audioManager.playVictoryCelebration()
                                }
                            }) {
                                HStack {
                                    Text("🦛")
                                    Text("Cho Hà Mã Ăn")
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .cornerRadius(14)
                            }

                            Button(action: {
                                let result = engine.throwInTrash()
                                message = result.message
                                if result.success {
                                    audioManager.playStarReward()
                                } else {
                                    audioManager.playWrongBuzz()
                                }
                                if engine.isGameFinished() {
                                    isGameFinished = true
                                    audioManager.playVictoryCelebration()
                                }
                            }) {
                                HStack {
                                    Text("🗑️")
                                    Text("Vứt Vào Rác")
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.orange)
                                .cornerRadius(14)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.08), radius: 8)
                }

                Spacer()
            }
            .padding()

            // Completion Overlay
            if isGameFinished {
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack(spacing: 16) {
                    Text("🎉 XUẤT SẮC! 🎉")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.yellow)
                    Text("Bạn đã hoàn thành phân loại thức ăn!")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    Text("Điểm số: \(engine.score) điểm")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Button(action: {
                        audioManager.playButtonClick()
                        engine.reset()
                        isGameFinished = false
                    }) {
                        Text("Chơi Lại")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding(24)
                .background(Color(red: 0.1, green: 0.15, blue: 0.25))
                .cornerRadius(20)
            }
        }
    }
}
