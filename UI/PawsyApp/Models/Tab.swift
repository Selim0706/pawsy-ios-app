import Foundation

enum Tab: String, CaseIterable {
    case home = "Home"
    case calendar = "Calendar"
    case aiChat = "AI Chat"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .calendar: return "calendar"
        case .aiChat: return "bubble.left.and.bubble.right"
        case .profile: return "person"
        }
    }
}
