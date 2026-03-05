import SwiftUI

struct BubbleStyle: ViewModifier {
    var radius: CGFloat = PawsyTheme.radiusCard
    var fill: Color = PawsyTheme.glassFill
    var depth: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(PawsyTheme.glassStroke, lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Color.white.opacity(0.65), lineWidth: 1)
                    .blur(radius: 0.2)
                    .offset(x: -0.5, y: -0.5)
                    .mask(RoundedRectangle(cornerRadius: radius, style: .continuous).fill(
                        LinearGradient(colors: [.white, .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                    ))
            )
            .shadow(color: PawsyTheme.shadowDark.opacity(0.45 * depth), radius: 10 * depth, x: 0, y: 6 * depth)
            .shadow(color: PawsyTheme.shadowLight.opacity(0.75 * depth), radius: 3 * depth, x: 0, y: -1)
            .shadow(color: Color.white.opacity(0.28 * depth), radius: 1, x: -0.5, y: -0.5)
    }
}

struct PressableBubbleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.26, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

extension View {
    func bubble(radius: CGFloat = PawsyTheme.radiusCard, fill: Color = PawsyTheme.glassFill, depth: CGFloat = 1.0) -> some View {
        modifier(BubbleStyle(radius: radius, fill: fill, depth: depth))
    }

    func bubbleSoft(radius: CGFloat = PawsyTheme.radiusCard, fill: Color = PawsyTheme.glassFill) -> some View {
        bubble(radius: radius, fill: fill, depth: 0.85)
    }

    func bubbleStrong(radius: CGFloat = PawsyTheme.radiusCard, fill: Color = PawsyTheme.glassFill) -> some View {
        bubble(radius: radius, fill: fill, depth: 1.2)
    }
}
