import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static let appMint = Color(hex: "#AEE5CB")
    static let appBeige = Color(hex: "#F7EDDF")
    static let appDarkGreen = Color(hex: "#204631")
    
    // Progress Rings
    static let appPink = Color(hex: "#FA8F99")
    static let appProgressMint = Color(hex: "#62BFA1")
    static let appBlue = Color(hex: "#72A9EA")
    
    // Dashboard Cards
    static let actionPeach = Color(hex: "#FFC5AE")
    static let actionMint = Color(hex: "#B2EDD5")
    static let actionBlue = Color(hex: "#C6DBFC")
    
    // Chat & Additional
    static let chatPeach = Color(hex: "#F9DDD0")
    static let cardBackground = Color.white
    static let textGray = Color(hex: "#7A8C84")
}
