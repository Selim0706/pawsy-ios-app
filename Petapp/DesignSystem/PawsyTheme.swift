import SwiftUI
import UIKit

enum PawsyTheme {
    static let backgroundMint = Color.dynamic(light: "#BCE6D4", dark: "#1F3631")
    static let backgroundCream = Color.dynamic(light: "#FAFAF9", dark: "#171A1B")
    static let accentPeach = Color.dynamic(light: "#FFD7C4", dark: "#5A3A32")
    static let accentBlue = Color.dynamic(light: "#D6E0FA", dark: "#2E3F5D")
    static let accentGreen = Color.dynamic(light: "#CEECD8", dark: "#2A4B3B")
    static let accentEmerald = Color.dynamic(light: "#2FB37C", dark: "#55D9A2")
    static let textPrimary = Color.dynamic(light: "#2D3436", dark: "#EEF3F5")
    static let textSecondary = Color.dynamic(light: "#6E7677", dark: "#AEB8BB")
    static let alertRed = Color(hex: "#FF6B6B")

    static let glassFill = Color.dynamic(light: "#FFFFFF", dark: "#233038").opacity(0.68)
    static let glassStroke = Color.dynamic(light: "#FFFFFF", dark: "#91A6AF").opacity(0.42)

    static let petPlatformTop = Color(hex: "#A5D172")
    static let petPlatformBottom = Color(hex: "#9C6D53")

    static let shadowDark = Color.black.opacity(0.2)
    static let shadowLight = Color.white.opacity(0.5)

    static let radiusXL: CGFloat = 30
    static let radiusCard: CGFloat = 24
    static let radiusButton: CGFloat = 18

    static let horizontalPadding: CGFloat = 18
    static let sectionSpacing: CGFloat = 14
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 45, 52, 54)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static func dynamic(light: String, dark: String) -> Color {
        Color(
            UIColor { trait in
                if trait.userInterfaceStyle == .dark {
                    return UIColor(Color(hex: dark))
                }
                return UIColor(Color(hex: light))
            }
        )
    }
}

extension Font {
    static func pawsy(_ size: CGFloat, _ weight: Weight = .regular) -> Font {
        let adjustedSize: CGFloat
        switch size {
        case ..<13:
            adjustedSize = size + 0.5
        case ..<18:
            adjustedSize = size + 1
        case ..<26:
            adjustedSize = size + 1.5
        default:
            adjustedSize = size + 1
        }

        let resolvedWeight: Weight = (weight == .regular) ? .medium : weight
        return .system(size: adjustedSize, weight: resolvedWeight, design: .rounded)
    }
}

struct AppBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(
            colors: [
                colorScheme == .dark ? Color(hex: "#1D3530") : Color(hex: "#BCE6D4"),
                colorScheme == .dark ? Color(hex: "#26343A") : Color(hex: "#DDF0E8"),
                colorScheme == .dark ? Color(hex: "#181B1D") : Color(hex: "#F3EBE2")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

struct PawsyLogoMark: View {
    var size: CGFloat = 34

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.9), Color(hex: "#BFEBDD"), Color(hex: "#A8DEC8")],
                        center: .topLeading,
                        startRadius: 2,
                        endRadius: size
                    )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.9), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.13), radius: 8, x: 0, y: 5)
                .shadow(color: Color.white.opacity(0.8), radius: 3, x: 0, y: -1)

            Image(systemName: "pawprint.fill")
                .font(.system(size: size * 0.44, weight: .black))
                .foregroundStyle(Color(hex: "#1B3A2F"))
        }
        .frame(width: size, height: size)
    }
}

struct PawsyWordmark: View {
    var fontSize: CGFloat = 22
    var iconSize: CGFloat = 24

    var body: some View {
        HStack(spacing: 7) {
            PawsyLogoMark(size: iconSize)
            Text("Pawsy")
                .font(.pawsy(fontSize, .black))
                .foregroundStyle(PawsyTheme.textPrimary)
        }
    }
}
