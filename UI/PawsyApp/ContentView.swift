import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    DashboardView()
                case .calendar:
                    MedicalHubView()
                case .aiChat:
                    AIAssistantView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            CustomTabBar(selectedTab: $selectedTab)
                // Add some padding from the bottom safe area
                .padding(.bottom, 10)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ContentView()
}
