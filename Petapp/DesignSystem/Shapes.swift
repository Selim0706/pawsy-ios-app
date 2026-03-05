import SwiftUI

struct TopCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 60))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.maxY - 20),
            control: CGPoint(x: rect.midX, y: rect.maxY + 36)
        )
        path.closeSubpath()
        return path
    }
}

struct WaveTabBarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let baseTopY: CGFloat = 30
        let hillWidth: CGFloat = min(132, rect.width * 0.42)
        let hillStartX = rect.midX - hillWidth / 2
        let hillEndX = rect.midX + hillWidth / 2

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: baseTopY + 16))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + 18, y: baseTopY),
            control: CGPoint(x: rect.minX, y: baseTopY)
        )
        path.addLine(to: CGPoint(x: hillStartX, y: baseTopY))
        path.addCurve(
            to: CGPoint(x: hillEndX, y: baseTopY),
            control1: CGPoint(x: rect.midX - hillWidth * 0.28, y: -4),
            control2: CGPoint(x: rect.midX + hillWidth * 0.28, y: -4)
        )
        path.addLine(to: CGPoint(x: rect.maxX - 18, y: baseTopY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: baseTopY + 16),
            control: CGPoint(x: rect.maxX, y: baseTopY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
