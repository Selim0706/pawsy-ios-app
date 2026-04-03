import SwiftUI

struct RootTabView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var appPreferences = AppPreferencesStore()
    @StateObject private var petProfilesViewModel: PetProfilesViewModel

    @StateObject private var dashboardViewModel: DashboardViewModel
    @StateObject private var medicalHubViewModel: MedicalHubViewModel
    @StateObject private var aiAssistantViewModel: AIAssistantViewModel
    @StateObject private var profileViewModel: ProfileViewModel

    init() {
        let repository = InMemoryMockRepository()
        let petProfiles = PetProfilesViewModel()
        let petSettingsStore = UserDefaultsPetSettingsStore()
        let petStateStore = UserDefaultsPetStateStore()
        let chatHistoryStore = UserDefaultsChatHistoryStore()
        _petProfilesViewModel = StateObject(wrappedValue: petProfiles)
        _dashboardViewModel = StateObject(
            wrappedValue: DashboardViewModel(
                repository: repository,
                petProfiles: petProfiles,
                settingsStore: petSettingsStore,
                stateStore: petStateStore
            )
        )
        _medicalHubViewModel = StateObject(
            wrappedValue: MedicalHubViewModel(
                repository: repository,
                petProfiles: petProfiles
            )
        )
        _aiAssistantViewModel = StateObject(
            wrappedValue: AIAssistantViewModel(
                repository: repository,
                petProfiles: petProfiles,
                chatHistoryStore: chatHistoryStore
            )
        )
        _profileViewModel = StateObject(
            wrappedValue: ProfileViewModel(
                repository: repository,
                petProfiles: petProfiles
            )
        )
    }

    var body: some View {
        let env = ProcessInfo.processInfo.environment
        let isPreview = env["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
            || env["XCODE_RUNNING_FOR_PLAYGROUNDS"] == "1"
            || env["DYLD_INSERT_LIBRARIES"]?.contains("PreviewsInjection") == true

        let rootContent = ZStack {
            screen(DashboardView(viewModel: dashboardViewModel), for: .home)
            screen(MedicalHubView(viewModel: medicalHubViewModel), for: .calendar)
            screen(AIAssistantView(viewModel: aiAssistantViewModel), for: .aiChat)
            screen(ProfileView(viewModel: profileViewModel), for: .profile)
        }
        .environmentObject(router)
        .environmentObject(petProfilesViewModel)
        .environmentObject(appPreferences)
        .animation(.easeInOut(duration: 0.18), value: router.selectedTab)

        Group {
            if isPreview {
                rootContent
                    .overlay(alignment: .bottom) {
                        if router.isTabBarVisible {
                            CustomTabBar(
                                selectedTab: $router.selectedTab,
                                onPawsyTap: { router.pawsyButtonTapped() }
                            )
                                .padding(.horizontal, 16)
                                .padding(.bottom, 4)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
            } else {
                rootContent
                    .safeAreaInset(edge: .bottom) {
                        if router.isTabBarVisible {
                            CustomTabBar(
                                selectedTab: $router.selectedTab,
                                onPawsyTap: { router.pawsyButtonTapped() }
                            )
                                .padding(.horizontal, 16)
                                .padding(.top, 4)
                                .padding(.bottom, 2)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
            }
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.86), value: router.isTabBarVisible)
        .sheet(isPresented: $router.isPawsyHubPresented) {
            PawsyHubSheet(
                viewModel: dashboardViewModel,
                onOpenSettings: { router.openDashboardSettings() },
                onOpenHistory: { router.openDashboardHistory() }
            )
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $router.isAppSettingsPresented) {
            AppSettingsSheet(
                preferences: appPreferences,
                onClearChatHistory: { aiAssistantViewModel.clearHistory() }
            )
            .presentationDetents([.medium, .large])
        }
        .fullScreenCover(
            isPresented: Binding(
                get: { !petProfilesViewModel.hasCompletedOnboarding },
                set: { _ in }
            )
        ) {
            PetOnboardingView(mode: .firstRun) { profile in
                petProfilesViewModel.addPet(profile, makeActive: true)
            }
        }
        .preferredColorScheme(appPreferences.preferredColorScheme)
    }

    private func screen<V: View>(_ view: V, for tab: AppTab) -> some View {
        let active = router.selectedTab == tab
        return view
            .opacity(active ? 1 : 0)
            .allowsHitTesting(active)
            .accessibilityHidden(!active)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@MainActor
final class AppPreferencesStore: ObservableObject {
    @Published var themeMode: AppThemeMode {
        didSet { defaults.set(themeMode.rawValue, forKey: themeModeKey) }
    }
    @Published var remindersEnabled: Bool {
        didSet { defaults.set(remindersEnabled, forKey: remindersEnabledKey) }
    }
    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: hapticsEnabledKey) }
    }

    private let defaults: UserDefaults
    private let themeModeKey = "pawsy.preferences.themeMode"
    private let remindersEnabledKey = "pawsy.preferences.remindersEnabled"
    private let hapticsEnabledKey = "pawsy.preferences.hapticsEnabled"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.themeMode = AppThemeMode(rawValue: defaults.string(forKey: themeModeKey) ?? AppThemeMode.system.rawValue) ?? .system
        self.remindersEnabled = defaults.object(forKey: remindersEnabledKey) as? Bool ?? true
        self.hapticsEnabled = defaults.object(forKey: hapticsEnabledKey) as? Bool ?? true
    }

    var preferredColorScheme: ColorScheme? {
        switch themeMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

private struct AppSettingsSheet: View {
    @ObservedObject var preferences: AppPreferencesStore
    let onClearChatHistory: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showClearChatConfirm = false
    @State private var showThemeSheet = false

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Settings")
                            .font(.pawsy(24, .black))
                            .foregroundStyle(PawsyTheme.textPrimary)
                        Spacer()
                        Button("Done") { dismiss() }
                            .font(.pawsy(14, .bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .bubble(radius: 12, fill: PawsyTheme.accentGreen)
                    }

                    GlassCard(radius: 22) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Appearance")
                                .font(.pawsy(16, .semibold))
                                .foregroundStyle(PawsyTheme.textPrimary)

                            BubbleSelectionRow(
                                title: "Theme",
                                value: preferences.themeMode.title,
                                icon: "paintbrush"
                            ) {
                                showThemeSheet = true
                            }
                        }
                    }

                    GlassCard(radius: 22) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Behavior")
                                .font(.pawsy(16, .semibold))
                                .foregroundStyle(PawsyTheme.textPrimary)
                            BubbleToggleRow(
                                title: "Medical reminders",
                                subtitle: "Keep reminder cards and day markers active",
                                isOn: $preferences.remindersEnabled
                            )
                            BubbleToggleRow(
                                title: "Haptics",
                                subtitle: "Use tactile feedback for pet actions and controls",
                                isOn: $preferences.hapticsEnabled
                            )
                        }
                    }

                    GlassCard(radius: 22) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Data")
                                .font(.pawsy(16, .semibold))
                                .foregroundStyle(PawsyTheme.textPrimary)
                            Button {
                                showClearChatConfirm = true
                            } label: {
                                Label("Clear chat history", systemImage: "trash")
                                    .font(.pawsy(14, .bold))
                                    .foregroundStyle(PawsyTheme.textPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 9)
                                    .bubble(radius: 12, fill: Color(hex: "#FFD9D8"))
                            }
                            .buttonStyle(PressableBubbleButtonStyle())
                        }
                    }
                }
                .padding(PawsyTheme.horizontalPadding)
                .padding(.bottom, 30)
            }
        }
        .alert("Clear all chat history?", isPresented: $showClearChatConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                onClearChatHistory()
            }
        } message: {
            Text("This action removes all saved AI chat messages for the active pet.")
        }
        .sheet(isPresented: $showThemeSheet) {
            SelectionListSheet(
                title: "Theme",
                options: AppThemeMode.allCases.map(\.title),
                selected: preferences.themeMode.title
            ) { picked in
                if let next = AppThemeMode.allCases.first(where: { $0.title == picked }) {
                    preferences.themeMode = next
                }
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    RootTabView()
}
