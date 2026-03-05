import Foundation

enum AppTab: String, CaseIterable {
    case home = "Home"
    case calendar = "Calendar"
    case aiChat = "AI Chat"
    case profile = "Profile"

    var icon: String {
        switch self {
        case .home: return "house"
        case .calendar: return "calendar"
        case .aiChat: return "message"
        case .profile: return "person"
        }
    }

    var testID: String {
        switch self {
        case .home: return "home"
        case .calendar: return "calendar"
        case .aiChat: return "aiChat"
        case .profile: return "profile"
        }
    }

    var localizedTitle: String {
        switch self {
        case .home: return "Home"
        case .calendar: return "Calendar"
        case .aiChat: return "AI Chat"
        case .profile: return "Profile"
        }
    }
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var isTabBarVisible: Bool = true
    @Published var isPawsyHubPresented: Bool = false
    @Published var isAppSettingsPresented: Bool = false
    @Published var dashboardCommand: DashboardCommand?
    @Published var selectedTab: AppTab = .home {
        didSet {
            isTabBarVisible = selectedTab != .aiChat
        }
    }

    func goHome() {
        selectedTab = .home
    }

    func pawsyButtonTapped() {
        if isPawsyHubPresented {
            isPawsyHubPresented = false
            return
        }

        if selectedTab == .home {
            isPawsyHubPresented = true
        } else {
            selectedTab = .home
            isPawsyHubPresented = true
        }
    }

    func openDashboardSettings() {
        selectedTab = .home
        dashboardCommand = .openSettings
    }

    func openDashboardHistory() {
        selectedTab = .home
        dashboardCommand = .openHistory
    }

    func openAppSettings() {
        isAppSettingsPresented = true
    }
}

enum DashboardCommand {
    case openSettings
    case openHistory
}
