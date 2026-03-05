import SwiftUI

struct GlassStyle: ViewModifier {
    var radius: CGFloat = PawsyTheme.radiusButton

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(PawsyTheme.glassStroke, lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Color.white.opacity(0.58), lineWidth: 1)
                    .blur(radius: 0.2)
                    .offset(x: -0.5, y: -0.5)
                    .mask(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(LinearGradient(colors: [.white, .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
            )
            .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 7)
            .shadow(color: Color.white.opacity(0.56), radius: 3, x: 0, y: -1)
    }
}

extension View {
    func glass(radius: CGFloat = PawsyTheme.radiusButton) -> some View {
        modifier(GlassStyle(radius: radius))
    }
}
