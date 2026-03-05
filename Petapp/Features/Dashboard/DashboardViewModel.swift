import Foundation
import Combine

final class DashboardViewModel: ObservableObject {
    @Published var petProfile: PetProfile
    @Published var stats: [HealthStat]
    @Published var petState: PetState
    @Published var petName: String
    @Published var petStyle: PetStyle
    @Published var accessory: PetAccessory
    @Published var moodText: String
    @Published var lastAction: PetAction = .idle
    @Published var tasks: [PawsyTask]
    @Published var actionFeedback: String = "Ready to play."
    @Published var lastActionWasBlocked = false
    @Published private(set) var currentTime: Date = Date()

    private let petProfiles: PetProfilesViewModel
    private let settingsStore: PetSettingsStore
    private let stateStore: PetStateStore
    private let stateEngine: PetStateEngine
    private let taskStore: DailyTaskStore
    private var timerCancellable: AnyCancellable?
    private var profilesCancellable: AnyCancellable?

    init(
        repository: MockRepository,
        petProfiles: PetProfilesViewModel,
        settingsStore: PetSettingsStore,
        stateStore: PetStateStore = UserDefaultsPetStateStore(),
        stateEngine: PetStateEngine = PetStateEngine(),
        taskStore: DailyTaskStore = UserDefaultsDailyTaskStore()
    ) {
        let now = Date()
        self.petProfiles = petProfiles
        let baseProfile = petProfiles.activePet ?? Self.makeFallbackProfile(from: repository.dashboardPet())
        self.petProfile = baseProfile
        self.stateStore = stateStore
        self.stateEngine = stateEngine
        self.taskStore = taskStore
        self.currentTime = now
        let loadedState = stateStore.loadState(for: baseProfile.id) ?? stateEngine.initialState()
        self.petState = loadedState
        self.stats = loadedState.vitals.asHealthStats
        self.settingsStore = settingsStore
        let saved = settingsStore.load(for: baseProfile.id, defaultProfile: baseProfile)
        self.petName = saved.name
        self.petStyle = saved.style
        self.accessory = saved.accessory
        self.moodText = loadedState.mood
        self.lastAction = loadedState.lastAction
        self.tasks = taskStore.loadTasks(for: baseProfile.id, defaults: Self.defaultTasks, now: now)
        self.normalizeTasksForToday()
        self.startCooldownTicker()
        self.observePetSelection()
    }

    func actionTapped(_ action: PetAction) {
        let now = currentTime
        let result = stateEngine.apply(action: action, to: petState, now: now)
        actionFeedback = result.message
        lastActionWasBlocked = result.isBlocked
        guard !result.isBlocked else { return }

        petState = result.state
        lastAction = result.state.lastAction
        moodText = result.state.mood
        stats = result.state.vitals.asHealthStats
        stateStore.saveState(result.state, for: petProfile.id)
        completeTask(for: action, at: now)
    }

    func applyCustomization(name: String, style: PetStyle, accessory: PetAccessory) {
        petName = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Milo" : name
        petStyle = style
        self.accessory = accessory

        settingsStore.save(
            PetCustomization(name: petName, style: style, accessory: accessory),
            for: petProfile.id
        )
        petProfiles.updateActivePet(name: petName, style: style, accessory: accessory)
    }

    func toggleTask(_ taskID: String) {
        guard let idx = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[idx].isDone.toggle()
        tasks[idx].completedAt = tasks[idx].isDone ? currentTime : nil
        taskStore.saveTasks(tasks, for: petProfile.id, now: currentTime)
    }

    func resetPetState() {
        let initial = stateEngine.initialState()
        petState = initial
        stats = initial.vitals.asHealthStats
        moodText = initial.mood
        lastAction = initial.lastAction
        stateStore.saveState(initial, for: petProfile.id)
        actionFeedback = "State reset."
    }

    func resetToday() {
        tasks = Self.defaultTasks
        taskStore.saveTasks(tasks, for: petProfile.id, now: currentTime)
        actionFeedback = "Today's goals reset."
    }

    var dailyProgress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedTaskCount) / Double(tasks.count)
    }

    var canShowPerfectCareBadge: Bool {
        completedTaskCount == tasks.count && !tasks.isEmpty
    }

    func isOnCooldown(_ action: PetAction) -> Bool {
        guard let remaining = stateEngine.cooldownRemaining(for: action, in: petState, now: currentTime) else {
            return false
        }
        return remaining > 0
    }

    func cooldownRemaining(_ action: PetAction) -> TimeInterval {
        stateEngine.cooldownRemaining(for: action, in: petState, now: currentTime) ?? 0
    }

    func cooldownLabel(for action: PetAction) -> String? {
        let remaining = cooldownRemaining(action)
        guard remaining > 0 else { return nil }
        let totalSeconds = Int(remaining.rounded(.up))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "Ready in %02d:%02d", minutes, seconds)
    }

    var recentActivity: [PetActivityEntry] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: currentTime) ?? .distantPast
        return petState.activityLog
            .filter { $0.timestamp >= weekAgo }
            .suffix(50)
            .reversed()
    }

    var petAvatarAsset: String { petProfile.avatarAsset }
    var petSpeciesTitle: String { petProfile.species.title }

    var completedTaskCount: Int {
        tasks.filter(\.isDone).count
    }

    private static var defaultTasks: [PawsyTask] {
        DailyTaskKind.allCases.map { PawsyTask(kind: $0, isDone: false, completedAt: nil) }
    }

    private func completeTask(for action: PetAction, at now: Date) {
        guard let taskKind = action.dailyTaskKind,
              let idx = tasks.firstIndex(where: { $0.kind == taskKind }) else {
            return
        }

        if !tasks[idx].isDone {
            tasks[idx].isDone = true
            tasks[idx].completedAt = now
            taskStore.saveTasks(tasks, for: petProfile.id, now: now)
        }
    }

    private func normalizeTasksForToday() {
        if tasks.count != Self.defaultTasks.count {
            tasks = Self.defaultTasks
            taskStore.saveTasks(tasks, for: petProfile.id, now: currentTime)
            return
        }

        let expectedKinds = Set(DailyTaskKind.allCases)
        let taskKinds = Set(tasks.map(\.kind))
        if taskKinds != expectedKinds {
            tasks = Self.defaultTasks
            taskStore.saveTasks(tasks, for: petProfile.id, now: currentTime)
        }
    }

    private func startCooldownTicker() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                self?.currentTime = now
            }
    }

    private func observePetSelection() {
        profilesCancellable = petProfiles.$activePetID
            .sink { [weak self] _ in
                self?.reloadForActivePet()
            }
    }

    private func reloadForActivePet() {
        guard let active = petProfiles.activePet else { return }
        petProfile = active
        let state = stateStore.loadState(for: active.id) ?? stateEngine.initialState()
        petState = state
        stats = state.vitals.asHealthStats
        moodText = state.mood
        lastAction = state.lastAction
        let customization = settingsStore.load(for: active.id, defaultProfile: active)
        petName = customization.name
        petStyle = customization.style
        accessory = customization.accessory
        tasks = taskStore.loadTasks(for: active.id, defaults: Self.defaultTasks, now: currentTime)
        normalizeTasksForToday()
    }

    private static func makeFallbackProfile(from pet: Pet) -> PetProfile {
        PetProfile(
            id: pet.id,
            name: pet.name,
            species: .dog,
            breed: "",
            sex: .unknown,
            birthDate: nil,
            style: .shiba,
            accessory: .greenCollar,
            avatarAsset: pet.avatarAsset,
            medical: .empty,
            createdAt: Date()
        )
    }
}
