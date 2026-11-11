import SwiftUI

public struct MouthView: View {
    public let teeth: [ToothModel]
    public let debrisList: [ForeignDebris]
    public let activeTool: DentalTool?
    @ObservedObject public var particleSystem: ParticleSystem
    public let onDrag: (CGPoint) -> Void
    public let onDragEnd: () -> Void
    public let onHitDebris: ((ForeignDebris) -> Void)?

    @State private var touchPos: CGPoint? = nil

    public init(
        teeth: [ToothModel],
        debrisList: [ForeignDebris] = [],
        activeTool: DentalTool? = nil,
        particleSystem: ParticleSystem,
        onDrag: @escaping (CGPoint) -> Void,
        onDragEnd: @escaping () -> Void,
        onHitDebris: ((ForeignDebris) -> Void)? = nil
    ) {
        self.teeth = teeth
        self.debrisList = debrisList
        self.activeTool = activeTool
        self.particleSystem = particleSystem
        self.onDrag = onDrag
        self.onDragEnd = onDragEnd
        self.onHitDebris = onHitDebris
    }

    public var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let w = size.width
                    let h = size.height

                    // 1. Draw Mouth Cavity
                    drawMouthCavity(context: &context, w: w, h: h)

                    // 2. Draw 12 Independent Teeth
                    for tooth in teeth {
                        drawTooth(tooth: tooth, in: &context, size: size, activeTool: activeTool)
                    }

                    // 2b. Draw Foreign Debris
                    for debris in debrisList where !debris.isRemoved {
                        let dx = debris.normalizedX * w
                        let dy = debris.normalizedY * h
                        let debrisRect = CGRect(x: dx - 20, y: dy - 20, width: 40, height: 40)
                        context.fill(Path(ellipseIn: debrisRect), with: .color(Color.yellow.opacity(0.8)))
                        context.stroke(Path(ellipseIn: debrisRect), with: .color(Color.brown), lineWidth: 2)
                    }

                    // 3. Draw Active Tool Interaction Glow (UV / Water / Drill)
                    if let pos = touchPos, let tool = activeTool {
                        drawToolEffect(tool: tool, at: pos, in: &context)
                    }

                    // 4. Draw Particle System
                    drawParticles(in: &context)
                }
                .onChange(of: timeline.date) { _, _ in
                    particleSystem.update(dt: 0.016)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        touchPos = value.location
                        // Check hit debris first
                        let pt = value.location
                        for debris in debrisList where !debris.isRemoved {
                            let dx = debris.normalizedX * geo.size.width
                            let dy = debris.normalizedY * geo.size.height
                            let dist = sqrt(pow(pt.x - dx, 2) + pow(pt.y - dy, 2))
                            if dist <= 35 {
                                onHitDebris?(debris)
                                break
                            }
                        }
                        onDrag(value.location)
                    }
                    .onEnded { _ in
                        touchPos = nil
                        onDragEnd()
                    }
            )
        }
    }

    private func drawMouthCavity(context: inout GraphicsContext, w: Double, h: Double) {
        var mouthPath = Path()
        mouthPath.move(to: CGPoint(x: w * 0.12, y: h * 0.56))
        mouthPath.addCurve(
            to: CGPoint(x: w * 0.88, y: h * 0.56),
            control1: CGPoint(x: w * 0.12, y: h * 0.36),
            control2: CGPoint(x: w * 0.88, y: h * 0.36)
        )
        mouthPath.addCurve(
            to: CGPoint(x: w * 0.12, y: h * 0.56),
            control1: CGPoint(x: w * 0.88, y: h * 0.78),
            control2: CGPoint(x: w * 0.12, y: h * 0.78)
        )
        mouthPath.closeSubpath()

        // Dark Interior
        context.fill(mouthPath, with: .color(Color(red: 0.25, green: 0.05, blue: 0.12)))

        // Tongue
        let tongueRect = CGRect(x: w * 0.34, y: h * 0.61, width: w * 0.32, height: h * 0.15)
        context.fill(Path(ellipseIn: tongueRect), with: .color(Color(red: 0.94, green: 0.27, blue: 0.27)))

        // Upper & Lower Gums
        let upperGumsRect = CGRect(x: w * 0.10, y: h * 0.38, width: w * 0.80, height: h * 0.14)
        context.fill(Path(ellipseIn: upperGumsRect), with: .color(Color(red: 0.95, green: 0.48, blue: 0.52)))

        let lowerGumsRect = CGRect(x: w * 0.10, y: h * 0.62, width: w * 0.80, height: h * 0.14)
        context.fill(Path(ellipseIn: lowerGumsRect), with: .color(Color(red: 0.95, green: 0.48, blue: 0.52)))

        // Glossy Lip Contour
        context.stroke(mouthPath, with: .color(Color(red: 0.88, green: 0.11, blue: 0.28)), lineWidth: 12)
    }

    private func drawTooth(tooth: ToothModel, in context: inout GraphicsContext, size: CGSize, activeTool: DentalTool?) {
        let cx = tooth.normalizedX * size.width
        let cy = tooth.normalizedY * size.height
        let tw = tooth.widthRatio * size.width
        let th = tooth.heightRatio * size.height
        let rect = CGRect(x: cx - tw/2, y: cy - th/2, width: tw, height: th)

        // 1. Guidance Cyan Aura Glow matching active tool
        let isMatchingActiveTool: Bool = {
            guard let tool = activeTool else { return tooth.state.requiresTreatment }
            switch tool {
            case .toothbrush: return tooth.state == .dirtStained
            case .scaler: return tooth.state == .calculus
            case .drill: return tooth.state == .bacteria || tooth.state == .necroticCracked
            case .resinTube: return tooth.state == .cavityDrilled
            case .curingLight: return tooth.state == .resinFilled
            case .waterSpray: return tooth.state == .resinCured || tooth.state == .bacteria
            case .forceps: return tooth.state == .necroticCracked
            case .implant: return tooth.state == .socketEmpty
            case .syringe: return tooth.state == .necroticCracked
            case .tweezers: return false
            }
        }()

        if isMatchingActiveTool {
            let haloRect = rect.insetBy(dx: -7, dy: -7)
            context.stroke(
                Path(roundedRect: haloRect, cornerRadius: 16),
                with: .color(Color(red: 0.0, green: 0.95, blue: 1.0, opacity: 0.35)),
                lineWidth: 6
            )
            let coreAura = rect.insetBy(dx: -3, dy: -3)
            context.stroke(
                Path(roundedRect: coreAura, cornerRadius: 14),
                with: .color(Color(red: 0.0, green: 0.90, blue: 1.0)),
                lineWidth: 3.5
            )
        }

        // 2. Tooth Body
        switch tooth.state {
        case .socketEmpty:
            let socketRect = rect.insetBy(dx: tw * 0.15, dy: th * 0.15)
            context.fill(Path(ellipseIn: socketRect), with: .color(Color(red: 0.45, green: 0.10, blue: 0.12)))
            return

        case .necroticCracked:
            // Brown cracked stone calculus
            let stoneColor = Color(red: 0.65, green: 0.55, blue: 0.43)
            let crackColor = Color(red: 0.24, green: 0.15, blue: 0.13)
            context.fill(Path(roundedRect: rect, cornerRadius: 12), with: .color(stoneColor))
            var crackPath = Path()
            crackPath.move(to: CGPoint(x: rect.minX + tw * 0.25, y: rect.minY))
            crackPath.addLine(to: CGPoint(x: cx, y: cy))
            crackPath.addLine(to: CGPoint(x: rect.maxX - tw * 0.15, y: rect.minY + th * 0.35))
            crackPath.move(to: CGPoint(x: cx, y: cy))
            crackPath.addLine(to: CGPoint(x: rect.minX + tw * 0.42, y: rect.maxY))
            context.stroke(crackPath, with: .color(crackColor), lineWidth: 3)
            return

        case .implantPlaced:
            context.fill(Path(roundedRect: rect, cornerRadius: 12), with: .color(Color(red: 0.97, green: 0.98, blue: 1.0)))
            let coreRect = CGRect(x: cx - tw * 0.1, y: rect.minY + th * 0.35, width: tw * 0.2, height: th * 0.35)
            context.fill(Path(coreRect), with: .color(Color(red: 0.58, green: 0.64, blue: 0.72)))
            context.stroke(Path(roundedRect: rect, cornerRadius: 12), with: .color(Color(red: 0.75, green: 0.82, blue: 0.90)), lineWidth: 2)
            return

        default:
            context.fill(Path(roundedRect: rect, cornerRadius: 12), with: .color(Color.white))
            // Specular Reflection
            let shineRect = CGRect(x: rect.minX + tw * 0.15, y: rect.minY + th * 0.15, width: tw * 0.30, height: th * 0.25)
            context.fill(Path(roundedRect: shineRect, cornerRadius: 5), with: .color(Color.white.opacity(0.85)))
            context.stroke(Path(roundedRect: rect, cornerRadius: 12), with: .color(Color(red: 0.82, green: 0.88, blue: 0.94)), lineWidth: 2)
        }

        // 3. Overlay Pathologies
        switch tooth.state {
        case .dirtStained:
            // Black splatter ink/dirt stain
            let core = CGRect(x: cx - tw * 0.20, y: cy - th * 0.20, width: tw * 0.40, height: th * 0.40)
            context.fill(Path(ellipseIn: core), with: .color(Color(red: 0.15, green: 0.09, blue: 0.06)))
            let s1 = CGRect(x: cx - tw * 0.28, y: cy - th * 0.15, width: tw * 0.16, height: th * 0.16)
            let s2 = CGRect(x: cx + tw * 0.18, y: cy - th * 0.20, width: tw * 0.18, height: th * 0.18)
            let s3 = CGRect(x: cx + tw * 0.15, y: cy + th * 0.18, width: tw * 0.17, height: th * 0.17)
            context.fill(Path(ellipseIn: s1), with: .color(Color(red: 0.15, green: 0.09, blue: 0.06)))
            context.fill(Path(ellipseIn: s2), with: .color(Color(red: 0.15, green: 0.09, blue: 0.06)))
            context.fill(Path(ellipseIn: s3), with: .color(Color(red: 0.15, green: 0.09, blue: 0.06)))

        case .calculus:
            // Green mossy scum coating with dark dots
            let cRect = CGRect(x: rect.minX, y: cy - th * 0.1, width: tw, height: th * 0.6)
            context.fill(Path(roundedRect: cRect, cornerRadius: 6), with: .color(Color(red: 0.49, green: 0.55, blue: 0.22)))
            let dot1 = CGRect(x: cx - tw * 0.22, y: cy + th * 0.10, width: 4, height: 4)
            let dot2 = CGRect(x: cx + tw * 0.15, y: cy + th * 0.20, width: 5, height: 5)
            context.fill(Path(ellipseIn: dot1), with: .color(Color(red: 0.22, green: 0.25, blue: 0.06)))
            context.fill(Path(ellipseIn: dot2), with: .color(Color(red: 0.22, green: 0.25, blue: 0.06)))

        case .bacteria:
            if tooth.indexInArch % 2 == 0 {
                // Red Spiky Germ Monster
                let bRect = CGRect(x: cx - tw * 0.28, y: cy - th * 0.28, width: tw * 0.56, height: th * 0.56)
                context.fill(Path(ellipseIn: bRect), with: .color(Color(red: 0.90, green: 0.22, blue: 0.21)))
                let e1 = CGRect(x: cx - tw * 0.12, y: cy - th * 0.08, width: tw * 0.10, height: th * 0.10)
                let e2 = CGRect(x: cx + tw * 0.02, y: cy - th * 0.08, width: tw * 0.10, height: th * 0.10)
                context.fill(Path(ellipseIn: e1), with: .color(.white))
                context.fill(Path(ellipseIn: e2), with: .color(.white))
                let p1 = CGRect(x: cx - tw * 0.10, y: cy - th * 0.06, width: 4, height: 4)
                let p2 = CGRect(x: cx + tw * 0.04, y: cy - th * 0.06, width: 4, height: 4)
                context.fill(Path(ellipseIn: p1), with: .color(.black))
                context.fill(Path(ellipseIn: p2), with: .color(.black))
            } else {
                // Blue Flower Germ Monster
                let fRect = CGRect(x: cx - tw * 0.25, y: cy - th * 0.25, width: tw * 0.50, height: th * 0.50)
                context.fill(Path(ellipseIn: fRect), with: .color(Color(red: 0.0, green: 0.74, blue: 0.83)))
                let e1 = CGRect(x: cx - tw * 0.08, y: cy - th * 0.04, width: tw * 0.07, height: th * 0.07)
                let e2 = CGRect(x: cx + tw * 0.02, y: cy - th * 0.04, width: tw * 0.07, height: th * 0.07)
                context.fill(Path(ellipseIn: e1), with: .color(.white))
                context.fill(Path(ellipseIn: e2), with: .color(.white))
            }

        case .cavityDrilled:
            let hole = CGRect(x: cx - tw * 0.25, y: cy - th * 0.25, width: tw * 0.50, height: th * 0.50)
            context.fill(Path(ellipseIn: hole), with: .color(Color(red: 0.20, green: 0.10, blue: 0.08)))

        case .resinFilled:
            let rRect = CGRect(x: cx - tw * 0.26, y: cy - th * 0.26, width: tw * 0.52, height: th * 0.52)
            context.fill(Path(ellipseIn: rRect), with: .color(Color(red: 0.0, green: 0.90, blue: 1.0)))

        case .resinCured:
            let rcRect = CGRect(x: cx - tw * 0.24, y: cy - th * 0.24, width: tw * 0.48, height: th * 0.48)
            context.fill(Path(ellipseIn: rcRect), with: .color(Color(red: 0.90, green: 0.95, blue: 1.0)))

        case .clean:
            let sRect = CGRect(x: rect.maxX - tw * 0.28, y: rect.minY + th * 0.15, width: tw * 0.18, height: th * 0.18)
            context.fill(Path(ellipseIn: sRect), with: .color(Color.yellow))

        default:
            break
        }
    }

    private func drawToolEffect(tool: DentalTool, at pos: CGPoint, in context: inout GraphicsContext) {
        switch tool {
        case .toothbrush:
            // Foaming blue soap bubbles
            let offsets: [CGPoint] = [
                CGPoint(x: -16, y: -12), CGPoint(x: 12, y: -18), CGPoint(x: 0, y: 15),
                CGPoint(x: -22, y: 8), CGPoint(x: 20, y: 4), CGPoint(x: -8, y: -25)
            ]
            for (idx, off) in offsets.enumerated() {
                let r: CGFloat = CGFloat(10 + (idx % 3) * 5)
                let bRect = CGRect(x: pos.x + off.x - r, y: pos.y + off.y - r, width: r * 2, height: r * 2)
                context.fill(Path(ellipseIn: bRect), with: .color(Color(red: 0.4, green: 0.85, blue: 0.97, opacity: 0.65)))
                context.stroke(Path(ellipseIn: bRect), with: .color(Color.white.opacity(0.85)), lineWidth: 2)
            }
        case .curingLight:
            let glow = CGRect(x: pos.x - 55, y: pos.y - 55, width: 110, height: 110)
            context.fill(Path(ellipseIn: glow), with: .color(Color(red: 0.54, green: 0.17, blue: 0.89, opacity: 0.35)))
        case .waterSpray:
            let spray = CGRect(x: pos.x - 40, y: pos.y - 40, width: 80, height: 80)
            context.fill(Path(ellipseIn: spray), with: .color(Color(red: 0.0, green: 0.9, blue: 1.0, opacity: 0.30)))
        case .drill:
            let burr = CGRect(x: pos.x - 20, y: pos.y - 20, width: 40, height: 40)
            context.stroke(Path(ellipseIn: burr), with: .color(Color.orange.opacity(0.55)), lineWidth: 3)
        default:
            break
        }
    }

    private func drawParticles(in context: inout GraphicsContext) {
        for p in particleSystem.particles {
            guard p.active else { continue }
            let pRect = CGRect(x: p.x - p.size/2, y: p.y - p.size/2, width: p.size, height: p.size)
            context.opacity = p.alpha

            switch p.type {
            case .bubble:
                context.fill(Path(ellipseIn: pRect), with: .color(p.color))
                let hl = CGRect(x: pRect.minX + p.size * 0.15, y: pRect.minY + p.size * 0.15, width: p.size * 0.25, height: p.size * 0.25)
                context.fill(Path(ellipseIn: hl), with: .color(.white))
            case .confetti:
                context.fill(Path(roundedRect: pRect, cornerRadius: 4), with: .color(p.color))
            default:
                context.fill(Path(ellipseIn: pRect), with: .color(p.color))
            }
        }
        context.opacity = 1.0
    }
}
