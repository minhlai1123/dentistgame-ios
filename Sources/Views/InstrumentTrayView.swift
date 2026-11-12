import SwiftUI

public struct InstrumentTrayView: View {
    public let tools: [DentalTool]
    public let activeTool: DentalTool?
    public let onSelectTool: (DentalTool) -> Void

    public init(
        tools: [DentalTool] = DentalTool.allCases,
        activeTool: DentalTool?,
        onSelectTool: @escaping (DentalTool) -> Void
    ) {
        self.tools = tools
        self.activeTool = activeTool
        self.onSelectTool = onSelectTool
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(tools) { tool in
                        ToolItemView(
                            tool: tool,
                            isSelected: tool == activeTool,
                            onClick: { onSelectTool(tool) }
                        )
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }
        }
        .frame(height: 118)
        .background(Color.trayWood)
        .overlay(
            VStack {
                Rectangle()
                    .fill(Color.trayBorder)
                    .frame(height: 2)
                Spacer()
            }
        )
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: -3)
    }
}

public struct ToolItemView: View {
    public let tool: DentalTool
    public let isSelected: Bool
    public let onClick: () -> Void

    private var borderColor: Color {
        isSelected ? Color(hex: "FFB300") : Color(hex: "B0BEC5").opacity(0.3)
    }

    private var bgColor: Color {
        isSelected ? Color(hex: "FFF8E1") : Color.white
    }

    public var body: some View {
        Button(action: onClick) {
            VStack(spacing: 4) {
                // High-resolution tool graphic with fallback
                ZStack {
                    if let uiImage = UIImage(named: isSelected ? "\(tool.rawValue)_selected" : tool.rawValue) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 52)
                    } else if let fallbackImg = UIImage(named: tool.rawValue) {
                        Image(uiImage: fallbackImg)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 52)
                    } else {
                        // Fallback SF Symbol
                        Image(systemName: toolSystemIcon(for: tool))
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(tool.accentColor)
                            .frame(width: 52, height: 52)
                    }
                }

                Text(tool.displayName)
                    .font(.system(size: 10, weight: isSelected ? .heavy : .bold, design: .rounded))
                    .foregroundColor(isSelected ? Color(hex: "B45309") : Color(hex: "1E293B"))
                    .lineLimit(1)
            }
            .frame(width: 82, height: 96)
            .background(bgColor)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(borderColor, lineWidth: isSelected ? 3 : 1)
            )
            .shadow(color: isSelected ? Color(hex: "FFB300").opacity(0.25) : Color.black.opacity(0.04), radius: isSelected ? 5 : 2, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func toolSystemIcon(for tool: DentalTool) -> String {
        switch tool {
        case .toothbrush: return "paintbrush.pointed.fill"
        case .scaler: return "waveform.path.ecg"
        case .drill: return "tornado"
        case .resinTube: return "drop.fill"
        case .curingLight: return "flashlight.on.fill"
        case .waterSpray: return "humidity.fill"
        case .syringe: return "cross.vial.fill"
        case .forceps: return "scissors"
        case .implant: return "cross.fill"
        case .tweezers: return "hand.point.up.fill"
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
