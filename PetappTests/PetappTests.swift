import XCTest
import UIKit
import MapKit
@testable import Petapp

final class PetappTests: XCTestCase {
    private func makePetProfiles(_ name: String = "Milo") -> PetProfilesViewModel {
        let store = InMemoryPetProfilesStore()
        let profile = PetProfile(
            id: UUID(),
            name: name,
            species: .dog,
            breed: "Shiba",
            sex: .unknown,
            birthDate: nil,
            style: .shiba,
            accessory: .greenCollar,
            avatarAsset: "pet_shiba",
            medical: .empty,
            createdAt: Date()
        )
        store.save(PetProfilesSnapshot(pets: [profile], activePetID: profile.id))
        return PetProfilesViewModel(store: store)
    }

    @MainActor
    func testRouterGoHomeAndTabBarVisibility() {
        let router = AppRouter()

        router.selectedTab = .aiChat
        XCTAssertFalse(router.isTabBarVisible)

        router.goHome()
        XCTAssertEqual(router.selectedTab, .home)
        XCTAssertTrue(router.isTabBarVisible)
    }

    @MainActor
    func testPawsyButtonFromNonHomeReturnsHomeAndOpensHub() {
        let router = AppRouter()
        router.selectedTab = .profile
        let expectation = expectation(description: "Hub opens after returning home")

        router.pawsyButtonTapped()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            XCTAssertEqual(router.selectedTab, .home)
            XCTAssertTrue(router.isPawsyHubPresented)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testMedicalHubUpcomingEventAndDateSelection() {
        let vm = MedicalHubViewModel(repository: InMemoryMockRepository(), petProfiles: makePetProfiles())

        vm.selectDate(17)

        XCTAssertEqual(vm.selectedDate, 17)
        XCTAssertNotNil(vm.upcomingEvent)
        XCTAssertEqual(vm.upcomingEvent?.title, "Vet Visit - Dr. Lee")
    }

    func testMedicalHubStatePersistenceSelectedDateAndCompletedEvents() {
        let store = InMemoryMedicalHubStateStore()
        let repo = InMemoryMockRepository()
        let petProfiles = makePetProfiles()
        let vm = MedicalHubViewModel(repository: repo, petProfiles: petProfiles, store: store)

        vm.selectDate(21)
        let firstEvent = try! XCTUnwrap(vm.events.first)
        vm.openEvent(firstEvent)
        vm.markSelectedEventDone()

        let restored = MedicalHubViewModel(repository: repo, petProfiles: petProfiles, store: store)
        XCTAssertEqual(restored.selectedDate, 21)
        XCTAssertTrue(restored.isCompleted(firstEvent))
    }

    @MainActor
    func testAIAssistantSendAndAttachImageCreatesAIResponses() {
        let historyStore = InMemoryChatHistoryStore()
        let vm = AIAssistantViewModel(
            repository: InMemoryMockRepository(),
            petProfiles: makePetProfiles(),
            chatHistoryStore: historyStore,
            vetRuleEngine: VetRuleEngine(),
            imageHeuristics: ImageSafetyHeuristics()
        )
        let initialCount = vm.messages.count

        vm.send(text: "Can dogs eat chocolate?")
        vm.attachImage(UIImage(systemName: "photo") ?? UIImage())

        XCTAssertEqual(vm.messages.count, initialCount + 4)
        XCTAssertEqual(vm.messages[initialCount].sender, .user)
        XCTAssertEqual(vm.messages[initialCount + 1].sender, .ai)
        XCTAssertTrue(vm.messages[initialCount + 1].isWarning)
        XCTAssertFalse(historyStore.saved.isEmpty)
    }

    func testProfileViewModelLoadsData() {
        let vm = ProfileViewModel(repository: InMemoryMockRepository(), petProfiles: makePetProfiles())

        XCTAssertFalse(vm.pets.isEmpty)
        XCTAssertFalse(vm.nearbyUsers.isEmpty)
        XCTAssertNotEqual(vm.region.center.latitude, 0)
    }

    func testProfileRegionStoreRoundTrip() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = UserDefaultsProfileStateStore(defaults: defaults, key: "test.profile.region")
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.0, longitude: -73.0),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.25)
        )

        store.saveRegion(region)
        let loaded = try! XCTUnwrap(store.loadRegion())
        XCTAssertEqual(loaded.center.latitude, region.center.latitude, accuracy: 0.0001)
        XCTAssertEqual(loaded.center.longitude, region.center.longitude, accuracy: 0.0001)
        XCTAssertEqual(loaded.span.latitudeDelta, region.span.latitudeDelta, accuracy: 0.0001)
        XCTAssertEqual(loaded.span.longitudeDelta, region.span.longitudeDelta, accuracy: 0.0001)
    }

    func testDashboardCustomizationPersistenceThroughStore() {
        let settingsStore = InMemoryPetSettingsStore(
            initial: PetCustomization(name: "Milo", style: .shiba, accessory: .none)
        )
        let profiles = makePetProfiles()
        let vm = DashboardViewModel(
            repository: InMemoryMockRepository(),
            petProfiles: profiles,
            settingsStore: settingsStore,
            stateStore: InMemoryPetStateStore(initial: nil),
            stateEngine: PetStateEngine()
        )

        vm.applyCustomization(name: "Nova", style: .husky, accessory: .blueCollar)

        XCTAssertEqual(settingsStore.savedValue.count, 1)
        let saved = settingsStore.savedValue.values.first
        XCTAssertEqual(saved?.name, "Nova")
        XCTAssertEqual(saved?.style, .husky)
        XCTAssertEqual(saved?.accessory, .blueCollar)
    }

    func testDashboardActionUpdatesAndPersistsPetState() {
        let stateStore = InMemoryPetStateStore(initial: nil)
        let taskStore = InMemoryDailyTaskStore()
        let profiles = makePetProfiles()
        let vm = DashboardViewModel(
            repository: InMemoryMockRepository(),
            petProfiles: profiles,
            settingsStore: InMemoryPetSettingsStore(initial: PetCustomization(name: "Milo", style: .shiba, accessory: .none)),
            stateStore: stateStore,
            stateEngine: PetStateEngine(),
            taskStore: taskStore
        )

        vm.actionTapped(.feed)

        XCTAssertEqual(vm.lastAction, .feed)
        XCTAssertFalse(vm.moodText.isEmpty)
        XCTAssertFalse(stateStore.savedState.isEmpty)
        XCTAssertEqual(vm.stats.count, 3)
        XCTAssertEqual(vm.completedTaskCount, 1)
        XCTAssertGreaterThan(vm.dailyProgress, 0)
    }

    func testPetStateEngineClampsValues() {
        let engine = PetStateEngine()
        let state = PetState(
            vitals: PetVitals(happiness: 99, health: 99, hygiene: 1, energy: 1, hunger: 1),
            mood: "Ready",
            lastAction: .idle,
            updatedAt: .now,
            actionTimestamps: ActionTimestamps(),
            completedActionsToday: [],
            dailyBonusAwarded: false,
            activityLog: []
        )

        let fed = engine.apply(action: .feed, to: state).state

        XCTAssertLessThanOrEqual(fed.vitals.happiness, 100)
        XCTAssertLessThanOrEqual(fed.vitals.health, 100)
        XCTAssertGreaterThanOrEqual(fed.vitals.hygiene, 0)
        XCTAssertGreaterThanOrEqual(fed.vitals.hunger, 0)
    }

    func testPetStateEngineCooldownBlocksRepeatedAction() {
        let engine = PetStateEngine()
        let base = engine.initialState()
        let now = Date()

        let first = engine.apply(action: .feed, to: base, now: now)
        let second = engine.apply(action: .feed, to: first.state, now: now.addingTimeInterval(30))

        XCTAssertFalse(first.isBlocked)
        XCTAssertTrue(second.isBlocked)
        XCTAssertNotNil(second.cooldownRemaining)
        XCTAssertEqual(second.state, first.state)
    }

    func testPerfectCareDayAppliesBonus() {
        let engine = PetStateEngine()
        let calendar = Calendar(identifier: .gregorian)
        let now = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10, hour: 12, minute: 0))!

        let feed = engine.apply(action: .feed, to: engine.initialState(), now: now)
        let walk = engine.apply(action: .walk, to: feed.state, now: now.addingTimeInterval(3600))
        let play = engine.apply(action: .play, to: walk.state, now: now.addingTimeInterval(7200))

        XCTAssertTrue(play.state.dailyBonusAwarded)
        XCTAssertEqual(play.state.completedActionsToday.count, 3)
    }

    func testVetRuleEngineDangerKeyword() {
        let engine = VetRuleEngine()

        let assessment = engine.assess(text: "My dog ate chocolate")

        XCTAssertEqual(assessment.level, .danger)
        XCTAssertEqual(assessment.intent, .toxicItem)
    }

    func testChatHistoryStoreRoundTrip() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)

        let store = UserDefaultsChatHistoryStore(defaults: defaults, key: "test.chat.history")
        let messages = [
            ChatMessage(id: UUID(), sender: .user, text: "Hello", isWarning: false, imageData: nil),
            ChatMessage(id: UUID(), sender: .ai, text: "Hi", isWarning: false, imageData: nil)
        ]
        let petID = UUID()
        store.saveMessages(messages, for: petID)
        let loaded = store.loadMessages(for: petID)

        XCTAssertEqual(loaded, messages)
    }

    func testUserDefaultsStoreFallbackWhenMissing() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)

        let store = UserDefaultsPetSettingsStore(defaults: defaults, key: "test.pet.settings")
        let petID = UUID()
        let profile = PetProfile(
            id: petID,
            name: "Milo",
            species: .dog,
            breed: "",
            sex: .unknown,
            birthDate: nil,
            style: .shiba,
            accessory: .greenCollar,
            avatarAsset: "pet_shiba",
            medical: .empty,
            createdAt: Date()
        )
        let fallback = store.load(for: petID, defaultProfile: profile)

        XCTAssertEqual(fallback.name, "Milo")
        XCTAssertEqual(fallback.style, .shiba)
        XCTAssertEqual(fallback.accessory, .greenCollar)
    }

    func testUserDefaultsStoreRoundTrip() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)

        let store = UserDefaultsPetSettingsStore(defaults: defaults, key: "test.pet.settings.roundtrip")
        let input = PetCustomization(name: "Baxter", style: .golden, accessory: .peachBandana)
        let petID = UUID()
        let profile = PetProfile(
            id: petID,
            name: "Milo",
            species: .dog,
            breed: "",
            sex: .unknown,
            birthDate: nil,
            style: .shiba,
            accessory: .greenCollar,
            avatarAsset: "pet_shiba",
            medical: .empty,
            createdAt: Date()
        )
        store.save(input, for: petID)
        let output = store.load(for: petID, defaultProfile: profile)

        XCTAssertEqual(output, input)
    }
}

private final class InMemoryPetSettingsStore: PetSettingsStore {
    private let initial: PetCustomization
    private(set) var savedValue: [UUID: PetCustomization] = [:]

    init(initial: PetCustomization) {
        self.initial = initial
    }

    func load(for petID: UUID, defaultProfile: PetProfile) -> PetCustomization {
        savedValue[petID] ?? initial
    }

    func save(_ customization: PetCustomization, for petID: UUID) {
        savedValue[petID] = customization
    }
}

private final class InMemoryPetStateStore: PetStateStore {
    private let initialState: PetState?
    private(set) var savedState: [UUID: PetState] = [:]

    init(initial: PetState?) {
        self.initialState = initial
    }

    func loadState(for petID: UUID) -> PetState? {
        savedState[petID] ?? initialState
    }

    func saveState(_ state: PetState, for petID: UUID) {
        savedState[petID] = state
    }
}

private final class InMemoryChatHistoryStore: ChatHistoryStore {
    private(set) var saved: [UUID: [ChatMessage]] = [:]

    func loadMessages(for petID: UUID) -> [ChatMessage] {
        saved[petID] ?? []
    }

    func saveMessages(_ messages: [ChatMessage], for petID: UUID) {
        saved[petID] = messages
    }
}

private final class InMemoryDailyTaskStore: DailyTaskStore {
    private var snapshotByPet: [UUID: [PawsyTask]] = [:]

    func loadTasks(for petID: UUID, defaults: [PawsyTask], now: Date) -> [PawsyTask] {
        snapshotByPet[petID] ?? defaults
    }

    func saveTasks(_ tasks: [PawsyTask], for petID: UUID, now: Date) {
        snapshotByPet[petID] = tasks
    }
}

private final class InMemoryMedicalHubStateStore: MedicalHubStateStore {
    private var snapshotByPet: [UUID: MedicalHubStateSnapshot] = [:]

    func loadState(for petID: UUID) -> MedicalHubStateSnapshot? {
        snapshotByPet[petID]
    }

    func saveState(_ snapshot: MedicalHubStateSnapshot, for petID: UUID) {
        snapshotByPet[petID] = snapshot
    }
}

private final class InMemoryPetProfilesStore: PetProfilesStore {
    private var snapshot = PetProfilesSnapshot(pets: [], activePetID: nil)

    func load() -> PetProfilesSnapshot { snapshot }
    func save(_ snapshot: PetProfilesSnapshot) { self.snapshot = snapshot }
}
