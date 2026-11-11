import SwiftUI

public struct FashionBracesView: View {
    @ObservedObject var audioManager: AudioManager
    public let onBack: () -> Void

    @StateObject private var engine = FashionBracesEngine()
    @State private var showSavedAlert: Bool = false

    public init(audioManager: AudioManager, onBack: @escaping () -> Void) {
        self.audioManager = audioManager
        self.onBack = onBack
    }

    private func colorFromHex(_ hex: String) -> Color {
        switch hex {
        case "#FF4081": return Color.pink
        case "#00E5FF": return Color.cyan
        case "#76FF03": return Color.green
        case "#FFD600": return Color.yellow
        case "#7C4DFF": return Color.purple
        default: return Color.pink
        }
    }

    public var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.94, blue: 0.96)
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
                            .foregroundColor(.pink)
                    }

                    Spacer()

                    Text("NIỀNG RĂNG THỜI TRANG")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))

                    Spacer()

                    Text("Điểm: \(engine.getScore())")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.pink)
                }
                .padding(.horizontal)

                Text("Chọn màu sắc mắc cài và kiểu đá quý, rồi chạm vào từng răng để trang trí!")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Color palette selector
                HStack(spacing: 12) {
                    Text("Màu sắc:")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)

                    ForEach(engine.availableColors, id: \.self) { colorHex in
                        Circle()
                            .fill(colorFromHex(colorHex))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: engine.selectedColor == colorHex ? 3 : 0)
                            )
                            .shadow(radius: engine.selectedColor == colorHex ? 4 : 1)
                            .onTapGesture {
                                engine.selectedColor = colorHex
                                audioManager.playButtonClick()
                            }
                    }
                }
                .padding(.vertical, 4)

                // Gem selector
                HStack(spacing: 12) {
                    Text("Đá quý:")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)

                    ForEach(engine.availableGems, id: \.self) { gem in
                        Text(gemIcon(gem))
                            .font(.system(size: 20))
                            .padding(8)
                            .background(engine.selectedGem == gem ? Color.pink.opacity(0.2) : Color.white)
                            .cornerRadius(10)
                            .onTapGesture {
                                engine.selectedGem = gem
                                audioManager.playButtonClick()
                            }
                    }
                }

                Spacer()

                // Teeth display with Braces
                VStack(spacing: 16) {
                    // Upper Teeth
                    HStack(spacing: 12) {
                        ForEach(0..<4) { index in
                            toothDecorationCard(index: index)
                        }
                    }

                    // Lower Teeth
                    HStack(spacing: 16) {
                        ForEach(4..<6) { index in
                            toothDecorationCard(index: index)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.06), radius: 8)

                Spacer()

                // Action buttons
                HStack(spacing: 16) {
                    Button(action: {
                        audioManager.playButtonClick()
                        engine.reset()
                    }) {
                        Text("Làm Lại")
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.pink.opacity(0.12))
                            .cornerRadius(14)
                    }

                    Button(action: {
                        audioManager.playSuccess()
                        showSavedAlert = true
                    }) {
                        Text("Lưu Tác Phẩm ✨")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.pink)
                            .cornerRadius(14)
                    }
                }
                .padding(.bottom, 10)
            }
            .padding()
        }
        .alert(isPresented: $showSavedAlert) {
            Alert(
                title: Text("Đã Lưu Tác Phẩm!"),
                message: Text("Nụ cười của bệnh nhân giờ đây thật tỏa sáng và phong cách với bộ niềng răng rực rỡ!"),
                dismissButton: .default(Text("Tuyệt Vời!"))
            )
        }
    }

    private func gemIcon(_ gem: String) -> String {
        switch gem {
        case "star": return "⭐"
        case "heart": return "💖"
        case "diamond": return "💎"
        case "flower": return "🌸"
        default: return "✨"
        }
    }

    @ViewBuilder
    private func toothDecorationCard(index: Int) -> some View {
        let t = engine.teeth[index]
        ZStack {
            Image("tooth_clean")
                .resizable()
                .scaledToFit()
                .frame(width: 58, height: 68)

            if t.hasBrace {
                Image("brace_bracket")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
                    .colorMultiply(colorFromHex(t.bracketColorHex))

                Text(gemIcon(t.gemStyle))
                    .font(.system(size: 14))
            }
        }
        .padding(6)
        .background(t.hasBrace ? Color.pink.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(12)
        .onTapGesture {
            _ = engine.applyBrace(toothIndex: index)
            audioManager.playBraceSnap()
            if engine.isAllDecorated() {
                audioManager.playVictoryCelebration()
            }
        }
    }
}
