import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var router: AppRouter
    @ObservedObject var viewModel: DashboardViewModel
    @State private var petBob = false
    @State private var showPetEditor = false
    @State private var showPawsyTasks = false
    @State private var showTimeline = false
    @State private var showDashboardMenu = false
    @State private var showResetTodayAlert = false
    @State private var showResetAllAlert = false
    @State private var reactionPulse = false

    var body: some View {
        GeometryReader { geo in
            let compact = geo.size.height < 740
            let petSize: CGFloat = compact ? 134 : 150

            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: PawsyTheme.sectionSpacing) {
                        topBar

                        VStack {
                            if viewModel.stats.isEmpty {
                                VStack(spacing: 6) {
                                    Image(systemName: "chart.pie")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundStyle(PawsyTheme.textSecondary)
                                    Text("No health stats yet")
                                        .font(.pawsy(14, .semibold))
                                        .foregroundStyle(PawsyTheme.textSecondary)
                                }
                                .frame(maxWidth: .infinity, minHeight: 108)
                                .accessibilityIdentifier("dashboard.empty.stats")
                            } else {
                                HStack(spacing: 14) {
                                    ForEach(viewModel.stats) { stat in
                                        StatRing(progress: stat.progress, color: Color(hex: stat.colorHex), title: stat.title)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }
                        .padding(14)
                        .glass(radius: 24)
                        .padding(.top, 8)

                        petSection(size: petSize)

                        HStack(spacing: 12) {
                            ActionButton(
                                title: "Feed",
                                subtitle: viewModel.cooldownLabel(for: .feed),
                                systemImage: "fork.knife",
                                color: Color(hex: "#FFD8C4"),
                                isDisabled: viewModel.isOnCooldown(.feed)
                            ) {
                                viewModel.actionTapped(.feed)
                                if !viewModel.lastActionWasBlocked {
                                    playReaction()
                                }
                            }
                            ActionButton(
                                title: "Walk",
                                subtitle: viewModel.cooldownLabel(for: .walk),
                                systemImage: "figure.walk",
                                color: Color(hex: "#CEECD8"),
                                isDisabled: viewModel.isOnCooldown(.walk)
                            ) {
                                viewModel.actionTapped(.walk)
                                if !viewModel.lastActionWasBlocked {
                                    playReaction()
                                }
                            }
                            ActionButton(
                                title: "Play",
                                subtitle: viewModel.cooldownLabel(for: .play),
                                systemImage: "speaker.wave.2",
                                color: Color(hex: "#D6E0FA"),
                                isDisabled: viewModel.isOnCooldown(.play)
                            ) {
                                viewModel.actionTapped(.play)
                                if !viewModel.lastActionWasBlocked {
                                    playReaction()
                                }
                            }
                        }
                        .frame(minHeight: compact ? 112 : 122)
                    }
                    .padding(.horizontal, PawsyTheme.horizontalPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 110)
                }
            }
            .accessibilityIdentifier("screen.dashboard")
            .sheet(isPresented: $showPetEditor) {
                PetCustomizationSheet(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showPawsyTasks) {
                PawsyHubSheet(
                    viewModel: viewModel,
                    onOpenSettings: { showPetEditor = true },
                    onOpenHistory: { showTimeline = true }
                )
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showTimeline) {
                ActivityTimelineSheet(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showDashboardMenu) {
                DashboardQuickMenuSheet(
                    onOpenSettings: {
                        showDashboardMenu = false
                        showPetEditor = true
                    },
                    onOpenAppSettings: {
                        showDashboardMenu = false
                        router.openAppSettings()
                    },
                    onOpenTasks: {
                        showDashboardMenu = false
                        showPawsyTasks = true
                    },
                    onOpenTimeline: {
                        showDashboardMenu = false
                        showTimeline = true
                    },
                    onResetToday: {
                        showDashboardMenu = false
                        showResetTodayAlert = true
                    },
                    onResetAll: {
                        showDashboardMenu = false
                        showResetAllAlert = true
                    }
                )
                .presentationDetents([.fraction(0.48), .medium])
                .presentationDragIndicator(.visible)
            }
            .alert("Reset today goals?", isPresented: $showResetTodayAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    viewModel.resetToday()
                }
            } message: {
                Text("This will clear only today's task progress.")
            }
            .alert("Reset all pet state?", isPresented: $showResetAllAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset All", role: .destructive) {
                    viewModel.resetPetState()
                    viewModel.resetToday()
                }
            } message: {
                Text("Vitals, mood, cooldowns and tasks will be reset.")
            }
            .onChange(of: router.dashboardCommand) { _, command in
                guard let command else { return }
                switch command {
                case .openSettings:
                    showPetEditor = true
                case .openHistory:
                    showTimeline = true
                }
                router.dashboardCommand = nil
            }
        }
    }

    private var topBar: some View {
        HStack {
            iconButton(system: "line.3.horizontal", id: "dashboard.menu") {
                showDashboardMenu = true
            }

            Spacer()

            PawsyWordmark(fontSize: 22, iconSize: 24)
                .accessibilityIdentifier("title.dashboard")

            Spacer()

            ZStack(alignment: .topTrailing) {
                iconButton(system: "bell", id: "dashboard.bell")
                Circle()
                    .fill(PawsyTheme.alertRed)
                    .frame(width: 9, height: 9)
                    .offset(x: 1, y: -1)
            }
        }
    }

    private func iconButton(system: String, id: String, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(PawsyTheme.textPrimary)
                .frame(width: 44, height: 44)
                .glass(radius: 16)
        }
        .buttonStyle(PressableBubbleButtonStyle())
        .accessibilityIdentifier(id)
    }

    private func petSection(size: CGFloat) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Ellipse()
                    .fill(PawsyTheme.petPlatformBottom)
                    .frame(width: size + 132, height: 88)
                    .offset(y: 56)
                    .shadow(color: .black.opacity(0.14), radius: 14, x: 0, y: 10)

                Ellipse()
                    .fill(PawsyTheme.petPlatformTop)
                    .frame(width: size + 132, height: 88)
                    .offset(y: 50)
                    .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)

                ZStack {
                    if UIImage(named: "pet_hero_\(viewModel.petStyle.rawValue)") != nil {
                        Image("pet_hero_\(viewModel.petStyle.rawValue)")
                            .resizable()
                            .scaledToFit()
                    } else if UIImage(named: viewModel.petAvatarAsset) != nil {
                        Image(viewModel.petAvatarAsset)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text(viewModel.petStyle.emoji)
                            .font(.system(size: size * 0.92))
                            .shadow(color: .black.opacity(0.16), radius: 8, x: 0, y: 6)
                    }
                }
                .frame(width: size, height: size)
                .scaleEffect(reactionPulse ? 1.05 : 1)
                .offset(y: petBob ? -8 : 2)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: petBob)
                .animation(.spring(response: 0.28, dampingFraction: 0.62), value: reactionPulse)
            }
            .frame(height: size + 82)
            .onTapGesture {
                showPetEditor = true
            }
            .onAppear {
                petBob = true
            }

            HStack(spacing: 8) {
                Text(viewModel.petName)
                    .font(.pawsy(17, .black))
                Text("•")
                    .foregroundStyle(PawsyTheme.textSecondary)
                Text("\(viewModel.petSpeciesTitle) • \(viewModel.moodText)")
                    .font(.pawsy(14, .semibold))
            }
            .foregroundStyle(PawsyTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .bubble(radius: 16, fill: Color.white.opacity(0.55))
            .accessibilityIdentifier("dashboard.pet.status")

            Text(viewModel.actionFeedback)
                .font(.pawsy(12, .semibold))
                .foregroundStyle(viewModel.lastActionWasBlocked ? Color(hex: "#9B6B4A") : PawsyTheme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .bubbleSoft(radius: 12, fill: Color.white.opacity(0.44))
                .padding(.top, 2)
        }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
    }

    private func playReaction() {
        reactionPulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            reactionPulse = false
        }
    }
}

private struct DashboardQuickMenuSheet: View {
    let onOpenSettings: () -> Void
    let onOpenAppSettings: () -> Void
    let onOpenTasks: () -> Void
    let onOpenTimeline: () -> Void
    let onResetToday: () -> Void
    let onResetAll: () -> Void

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(PawsyTheme.textPrimary)
                        Text("Quick Menu")
                            .font(.pawsy(22, .black))
                            .foregroundStyle(PawsyTheme.textPrimary)
                    }
                    .padding(.bottom, 4)

                    quickActionRow(id: "dashboard.quick.settings", title: "Pet Settings", subtitle: "Name, style, accessory", icon: "slider.horizontal.3", tint: PawsyTheme.accentBlue, action: onOpenSettings)
                    quickActionRow(id: "dashboard.quick.app.settings", title: "App Settings", subtitle: "Theme, reminders, haptics", icon: "gearshape", tint: PawsyTheme.accentGreen, action: onOpenAppSettings)
                    quickActionRow(id: "dashboard.quick.tasks", title: "Daily Tasks", subtitle: "Track today goals", icon: "checklist", tint: PawsyTheme.accentGreen, action: onOpenTasks)
                    quickActionRow(id: "dashboard.quick.timeline", title: "Activity Timeline", subtitle: "Last 7 days actions", icon: "clock.arrow.trianglehead.counterclockwise.rotate.90", tint: Color(hex: "#F8D8C7"), action: onOpenTimeline)
                    quickActionRow(id: "dashboard.quick.resetToday", title: "Reset Today", subtitle: "Clear only today's goals", icon: "arrow.counterclockwise", tint: Color(hex: "#FFE4D6"), action: onResetToday)
                    quickActionRow(id: "dashboard.quick.resetAll", title: "Reset All Pet State", subtitle: "Vitals and cooldowns", icon: "trash", tint: Color(hex: "#FFD4D8"), action: onResetAll)
                }
                .padding(PawsyTheme.horizontalPadding)
            }
        }
        .accessibilityIdentifier("dashboard.quick.menu")
    }

    private func quickActionRow(id: String, title: String, subtitle: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(PawsyTheme.textPrimary)
                    .frame(width: 38, height: 38)
                    .bubble(radius: 12, fill: tint.opacity(0.9))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.pawsy(16, .bold))
                        .foregroundStyle(PawsyTheme.textPrimary)
                    Text(subtitle)
                        .font(.pawsy(12, .medium))
                        .foregroundStyle(PawsyTheme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(PawsyTheme.textSecondary)
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(12)
            .bubble(radius: 18, fill: Color.white.opacity(0.62))
        }
        .buttonStyle(PressableBubbleButtonStyle())
        .accessibilityIdentifier(id)
    }
}

#Preview {
    let profiles = PetProfilesViewModel()
    DashboardView(
        viewModel: DashboardViewModel(
            repository: InMemoryMockRepository(),
            petProfiles: profiles,
            settingsStore: UserDefaultsPetSettingsStore(defaults: .standard, key: "preview.pet.customization")
        )
    )
    .environmentObject(profiles)
    .environmentObject(AppRouter())
}

private struct PetCustomizationSheet: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var style: PetStyle
    @State private var accessory: PetAccessory
    @State private var showStyleSheet = false
    @State private var showAccessorySheet = false

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        _name = State(initialValue: viewModel.petName)
        _style = State(initialValue: viewModel.petStyle)
        _accessory = State(initialValue: viewModel.accessory)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Pet Settings")
                            .font(.pawsy(28, .bold))
                            .foregroundStyle(PawsyTheme.textPrimary)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.pawsy(14, .semibold))
                            TextField("Milo", text: $name)
                                .textInputAutocapitalization(.words)
                                .padding(12)
                                .bubble(radius: 14, fill: Color.white.opacity(0.85))
                                .accessibilityIdentifier("pet.editor.name")
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Style")
                                .font(.pawsy(14, .semibold))
                            BubbleSelectionRow(
                                title: "Style",
                                value: "\(style.emoji) \(style.title)"
                            ) {
                                showStyleSheet = true
                            }
                            .accessibilityIdentifier("pet.editor.style")
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Accessory")
                                .font(.pawsy(14, .semibold))
                            BubbleSelectionRow(
                                title: "Accessory",
                                value: accessory.title
                            ) {
                                showAccessorySheet = true
                            }
                            .accessibilityIdentifier("pet.editor.accessory")
                        }

                        HStack {
                            Spacer()
                            Group {
                                if UIImage(named: "pet_hero_\(style.rawValue)") != nil {
                                    Image("pet_hero_\(style.rawValue)")
                                        .resizable()
                                        .scaledToFit()
                                } else {
                                    Text(style.emoji)
                                        .font(.system(size: 118))
                                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 5)
                                }
                            }
                            .frame(width: 180, height: 170)
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    .padding(18)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("pet.editor.cancel")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        viewModel.applyCustomization(name: name, style: style, accessory: accessory)
                        dismiss()
                    }
                    .font(.pawsy(16, .bold))
                    .accessibilityIdentifier("pet.editor.save")
                }
            }
        }
        .sheet(isPresented: $showStyleSheet) {
            SelectionListSheet(
                title: "Pet Style",
                options: PetStyle.allCases.map { "\($0.emoji) \($0.title)" },
                selected: "\(style.emoji) \(style.title)"
            ) { picked in
                if let next = PetStyle.allCases.first(where: { picked.contains($0.title) }) {
                    style = next
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showAccessorySheet) {
            SelectionListSheet(
                title: "Accessory",
                options: PetAccessory.allCases.map(\.title),
                selected: accessory.title
            ) { picked in
                if let next = PetAccessory.allCases.first(where: { $0.title == picked }) {
                    accessory = next
                }
            }
            .presentationDetents([.medium])
        }
    }
}

private struct ActivityTimelineSheet: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                if viewModel.recentActivity.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "clock.badge.questionmark")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(PawsyTheme.textSecondary)
                        Text("No activity yet")
                            .font(.pawsy(14, .semibold))
                            .foregroundStyle(PawsyTheme.textSecondary)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(viewModel.recentActivity) { item in
                                HStack(spacing: 10) {
                                    Image(systemName: icon(for: item.action))
                                        .frame(width: 26, height: 26)
                                        .bubble(radius: 10, fill: Color.white.opacity(0.7))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.action.rawValue.capitalized)
                                            .font(.pawsy(14, .bold))
                                        Text(item.note)
                                            .font(.pawsy(12, .medium))
                                            .foregroundStyle(PawsyTheme.textSecondary)
                                    }

                                    Spacer()

                                    Text(item.timestamp.formatted(date: .abbreviated, time: .shortened))
                                        .font(.pawsy(11, .medium))
                                        .foregroundStyle(PawsyTheme.textSecondary)
                                }
                                .padding(12)
                                .bubbleSoft(radius: 16, fill: Color.white.opacity(0.65))
                            }
                        }
                        .padding(18)
                    }
                }
            }
            .navigationTitle("Activity Timeline")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func icon(for action: PetAction) -> String {
        switch action {
        case .feed: return "fork.knife"
        case .walk: return "figure.walk"
        case .play: return "gamecontroller"
        case .idle: return "face.smiling"
        }
    }
}
