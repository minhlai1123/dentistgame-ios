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
                HStack(spacing: 12) {
                    ForEach(tools) { tool in
                        ToolButton(
                            tool: tool,
                            isSelected: tool == activeTool,
                            onClick: { onSelectTool(tool) }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .background(
            Color(red: 0.94, green: 0.96, blue: 0.98)
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -4)
        )
    }
}

public struct ToolButton: View {
    public let tool: DentalTool
    public let isSelected: Bool
    public let onClick: () -> Void

    public var body: some View {
        Button(action: onClick) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color(red: 1.0, green: 0.97, blue: 0.88) : Color.white)
                        .frame(width: 72, height: 72)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? Color(red: 1.0, green: 0.70, blue: 0.0) : Color(red: 0.88, green: 0.91, blue: 0.94), lineWidth: isSelected ? 3 : 1)
                        )
                        .shadow(color: isSelected ? Color(red: 1.0, green: 0.70, blue: 0.0).opacity(0.3) : Color.black.opacity(0.04), radius: isSelected ? 6 : 2, x: 0, y: 2)

                    // Tool Icon / Symbol
                    VStack(spacing: 2) {
                        Image(systemName: toolSystemIcon(for: tool))
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(tool.accentColor)

                        Circle()
                            .fill(isSelected ? Color(red: 1.0, green: 0.70, blue: 0.0) : Color.clear)
                            .frame(width: 6, height: 6)
                    }
                }

                Text(tool.displayName)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? Color(red: 0.70, green: 0.35, blue: 0.0) : Color(red: 0.12, green: 0.16, blue: 0.23))
                    .lineLimit(1)
            }
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
