import SwiftUI

/// CharacterFaceView renders the patient's cartoon face framing the dental cavity.
/// Features natural eye blinking, reactive eyebrows, and skin/hair matching the character model.
public struct CharacterFaceView<Content: View>: View {
    public let character: CharacterModel
    public let expression: String // "normal", "worried", "treatment", "happy"
    public let mouthContent: Content

    @State private var isBlinking: Bool = false
    @State private var headOffset: CGFloat = 0

    public init(
        character: CharacterModel,
        expression: String,
        @ViewBuilder mouthContent: () -> Content
    ) {
        self.character = character
        self.expression = expression
        self.mouthContent = mouthContent()
    }

    private var skinColor: Color {
        Color(hex: character.skinToneHex)
    }

    private var hairColor: Color {
        Color(hex: character.hairColorHex)
    }

    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // 1. Head Background & Facial Features
                Canvas { context, size in
                    drawHead(in: &context, size: size)
                }

                // 2. Open Mouth Slot (Contains the interactive MouthView)
                mouthContent
                    .frame(width: w, height: h)
            }
            .offset(y: headOffset)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                    headOffset = 4
                }
                startBlinkLoop()
            }
        }
    }

    private func startBlinkLoop() {
        Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 3_200_000_000)
                isBlinking = true
                try? await Task.sleep(nanoseconds: 160_000_000)
                isBlinking = false
            }
        }
    }

    private func drawHead(in context: inout GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        // Ears
        let earRadius = w * 0.08
        let leftEar = CGRect(x: w * 0.08 - earRadius, y: h * 0.45 - earRadius, width: earRadius * 2, height: earRadius * 2)
        let rightEar = CGRect(x: w * 0.92 - earRadius, y: h * 0.45 - earRadius, width: earRadius * 2, height: earRadius * 2)
        context.fill(Path(ellipseIn: leftEar), with: .color(skinColor))
        context.fill(Path(ellipseIn: rightEar), with: .color(skinColor))

        // Head Contour (Soft Rounded Oval)
        let headRect = CGRect(x: w * 0.08, y: h * 0.08, width: w * 0.84, height: h * 0.88)
        context.fill(
            Path(roundedRect: headRect, cornerSize: CGSize(width: w * 0.42, height: h * 0.44)),
            with: .color(skinColor)
        )

        // Cheeks (Rosy Blush)
        let blushRadius = w * 0.09
        let leftCheek = CGRect(x: w * 0.18 - blushRadius, y: h * 0.52 - blushRadius, width: blushRadius * 2, height: blushRadius * 2)
        let rightCheek = CGRect(x: w * 0.82 - blushRadius, y: h * 0.52 - blushRadius, width: blushRadius * 2, height: blushRadius * 2)
        context.fill(Path(ellipseIn: leftCheek), with: .color(Color(red: 1.0, green: 0.54, blue: 0.50, opacity: 0.28)))
        context.fill(Path(ellipseIn: rightCheek), with: .color(Color(red: 1.0, green: 0.54, blue: 0.50, opacity: 0.28)))

        // Eyebrows
        drawEyebrows(in: &context, size: size)

        // Eyes
        drawEyes(in: &context, size: size)

        // Cute small nose
        let noseRadius = w * 0.025
        let noseRect = CGRect(x: w * 0.50 - noseRadius, y: h * 0.36 - noseRadius, width: noseRadius * 2, height: noseRadius * 2)
        context.fill(Path(ellipseIn: noseRect), with: .color(skinColor.opacity(0.85)))
    }

    private func drawEyebrows(in context: inout GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let strokeW = w * 0.02

        switch expression {
        case "worried":
            // Eyebrows tilted inwards/upwards (worried look)
            var left = Path()
            left.move(to: CGPoint(x: w * 0.22, y: h * 0.21))
            left.addLine(to: CGPoint(x: w * 0.38, y: h * 0.18))
            context.stroke(left, with: .color(hairColor), style: StrokeStyle(lineWidth: strokeW, lineCap: .round))

            var right = Path()
            right.move(to: CGPoint(x: w * 0.62, y: h * 0.18))
            right.addLine(to: CGPoint(x: w * 0.78, y: h * 0.21))
            context.stroke(right, with: .color(hairColor), style: StrokeStyle(lineWidth: strokeW, lineCap: .round))

        case "treatment":
            // Eyebrows furrowed tight
            var left = Path()
            left.move(to: CGPoint(x: w * 0.22, y: h * 0.20))
            left.addLine(to: CGPoint(x: w * 0.38, y: h * 0.22))
            context.stroke(left, with: .color(hairColor), style: StrokeStyle(lineWidth: strokeW * 1.1, lineCap: .round))

            var right = Path()
            right.move(to: CGPoint(x: w * 0.62, y: h * 0.22))
            right.addLine(to: CGPoint(x: w * 0.78, y: h * 0.20))
            context.stroke(right, with: .color(hairColor), style: StrokeStyle(lineWidth: strokeW * 1.1, lineCap: .round))

        case "happy":
            // High arched joyful eyebrows
            var left = Path()
            left.addArc(
                center: CGPoint(x: w * 0.30, y: h * 0.20),
                radius: w * 0.08,
                startAngle: .degrees(190),
                endAngle: .degrees(350),
                clockwise: false
            )
            context.stroke(left, with: .color(hairColor), style: StrokeStyle(lineWidth: strokeW, lineCap: .round))

            var right = Path()
            right.addArc(
                center: CGPoint(x: w * 0.70, y: h * 0.20),
                radius: w * 0.08,
                startAngle: .degrees(190),
                endAngle: .degrees(350),
                clockwise: false
            )
            context.stroke(right, with: .color(hairColor), style: StrokeStyle(lineWidth: strokeW, lineCap: .round))

        default: // Normal
            var left = Path()
            left.move(to: CGPoint(x: w * 0.22, y: h * 0.19))
            left.addLine(to: CGPoint(x: w * 0.38, y: h * 0.19))
            context.stroke(left, with: .color(hairColor), style: StrokeStyle(lineWidth: strokeW, lineCap: .round))

            var right = Path()
            right.move(to: CGPoint(x: w * 0.62, y: h * 0.19))
            right.addLine(to: CGPoint(x: w * 0.78, y: h * 0.19))
            context.stroke(right, with: .color(hairColor), style: StrokeStyle(lineWidth: strokeW, lineCap: .round))
        }
    }

    private func drawEyes(in context: inout GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let leftEyeCenter = CGPoint(x: w * 0.30, y: h * 0.28)
        let rightEyeCenter = CGPoint(x: w * 0.70, y: h * 0.28)
        let eyeRadius = w * 0.065

        if isBlinking || expression == "treatment" {
            // Closed squint / blink lines
            let strokeW = w * 0.018
            var left = Path()
            left.move(to: CGPoint(x: w * 0.24, y: h * 0.28))
            left.addLine(to: CGPoint(x: w * 0.36, y: h * 0.28))
            context.stroke(left, with: .color(Color(red: 0.12, green: 0.16, blue: 0.23)), style: StrokeStyle(lineWidth: strokeW, lineCap: .round))

            var right = Path()
            right.move(to: CGPoint(x: w * 0.64, y: h * 0.28))
            right.addLine(to: CGPoint(x: w * 0.76, y: h * 0.28))
            context.stroke(right, with: .color(Color(red: 0.12, green: 0.16, blue: 0.23)), style: StrokeStyle(lineWidth: strokeW, lineCap: .round))
        } else {
            // Open Big Cartoon Eyes
            let leftSclera = CGRect(x: leftEyeCenter.x - eyeRadius, y: leftEyeCenter.y - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2)
            let rightSclera = CGRect(x: rightEyeCenter.x - eyeRadius, y: rightEyeCenter.y - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2)
            context.fill(Path(ellipseIn: leftSclera), with: .color(.white))
            context.fill(Path(ellipseIn: rightSclera), with: .color(.white))

            // Iris
            let irisRadius = eyeRadius * 0.65
            let irisColor = Color(red: 0.17, green: 0.24, blue: 0.31)
            let leftIris = CGRect(x: leftEyeCenter.x - irisRadius, y: leftEyeCenter.y - irisRadius, width: irisRadius * 2, height: irisRadius * 2)
            let rightIris = CGRect(x: rightEyeCenter.x - irisRadius, y: rightEyeCenter.y - irisRadius, width: irisRadius * 2, height: irisRadius * 2)
            context.fill(Path(ellipseIn: leftIris), with: .color(irisColor))
            context.fill(Path(ellipseIn: rightIris), with: .color(irisColor))

            // Catchlight reflections (giving eyes sparkle & life)
            let sp1 = eyeRadius * 0.25
            let sp2 = eyeRadius * 0.12
            let leftSp1 = CGRect(x: leftEyeCenter.x - eyeRadius * 0.2 - sp1/2, y: leftEyeCenter.y - eyeRadius * 0.2 - sp1/2, width: sp1, height: sp1)
            let leftSp2 = CGRect(x: leftEyeCenter.x + eyeRadius * 0.2 - sp2/2, y: leftEyeCenter.y + eyeRadius * 0.2 - sp2/2, width: sp2, height: sp2)
            let rightSp1 = CGRect(x: rightEyeCenter.x - eyeRadius * 0.2 - sp1/2, y: rightEyeCenter.y - eyeRadius * 0.2 - sp1/2, width: sp1, height: sp1)
            let rightSp2 = CGRect(x: rightEyeCenter.x + eyeRadius * 0.2 - sp2/2, y: rightEyeCenter.y + eyeRadius * 0.2 - sp2/2, width: sp2, height: sp2)
            context.fill(Path(ellipseIn: leftSp1), with: .color(.white))
            context.fill(Path(ellipseIn: leftSp2), with: .color(.white))
            context.fill(Path(ellipseIn: rightSp1), with: .color(.white))
            context.fill(Path(ellipseIn: rightSp2), with: .color(.white))
        }
    }
}
