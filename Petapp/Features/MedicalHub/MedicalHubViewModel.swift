import Foundation
import Combine

final class MedicalHubViewModel: ObservableObject {
    @Published var monthTitle: String
    @Published var selectedDate: Int = 4
    @Published var weightPoints: [WeightPoint]
    @Published var events: [VetEvent]
    @Published var selectedEvent: VetEvent?
    @Published var reminders: [MedicalReminder] = []
    @Published var serviceFilter: PartnerServiceType? = nil
    @Published private(set) var completedEventIDs: Set<UUID> = []

    let partnerServices: [PartnerService]

    private let store: MedicalHubStateStore
    private let petProfiles: PetProfilesViewModel
    private var profilesCancellable: AnyCancellable?

    init(
        repository: MockRepository,
        petProfiles: PetProfilesViewModel,
        store: MedicalHubStateStore = UserDefaultsMedicalHubStateStore()
    ) {
        self.monthTitle = repository.monthTitle()
        self.weightPoints = repository.weightHistory()
        self.events = repository.vetEvents()
        self.partnerServices = repository.partnerServices()
        self.store = store
        self.petProfiles = petProfiles
        if let snapshot = store.loadState(for: Self.activePetID(from: petProfiles)) {
            apply(snapshot: snapshot)
        }
        observePetSelection()
    }

    var upcomingEvent: VetEvent? {
        events.sorted { $0.date < $1.date }.first
    }

    var markedReminderDays: Set<Int> {
        Set(reminders.map { Calendar.current.component(.day, from: $0.date) })
    }

    var remindersForSelectedDay: [MedicalReminder] {
        reminders
            .filter { Calendar.current.component(.day, from: $0.date) == selectedDate }
            .sorted { $0.date < $1.date }
    }

    var upcomingReminders: [MedicalReminder] {
        reminders
            .filter { $0.date >= Calendar.current.startOfDay(for: .now) }
            .sorted { $0.date < $1.date }
            .prefix(5)
            .map { $0 }
    }

    var filteredServices: [PartnerService] {
        guard let serviceFilter else { return partnerServices.sorted { $0.distanceKM < $1.distanceKM } }
        return partnerServices
            .filter { $0.type == serviceFilter }
            .sorted { $0.distanceKM < $1.distanceKM }
    }

    func selectDate(_ day: Int) {
        selectedDate = day
        saveState()
    }

    func addReminder(title: String, category: ReminderCategory, date: Date, note: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        reminders.append(
            MedicalReminder(
                id: UUID(),
                title: trimmedTitle,
                category: category,
                date: date,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines),
                isCompleted: false
            )
        )
        reminders.sort { $0.date < $1.date }
        selectedDate = Calendar.current.component(.day, from: date)
        saveState()
    }

    func toggleReminderDone(_ reminder: MedicalReminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        reminders[index].isCompleted.toggle()
        saveState()
    }

    func deleteReminder(_ reminder: MedicalReminder) {
        reminders.removeAll { $0.id == reminder.id }
        saveState()
    }

    func openEvent(_ event: VetEvent) {
        selectedEvent = event
    }

    func isCompleted(_ event: VetEvent) -> Bool {
        completedEventIDs.contains(event.id)
    }

    func markSelectedEventDone() {
        guard let selectedEvent else { return }
        completedEventIDs.insert(selectedEvent.id)
        saveState()
    }

    private func observePetSelection() {
        profilesCancellable = petProfiles.$activePetID
            .sink { [weak self] _ in
                self?.reloadForActivePet()
            }
    }

    private func reloadForActivePet() {
        guard let snapshot = store.loadState(for: Self.activePetID(from: petProfiles)) else {
            selectedDate = 4
            reminders = []
            completedEventIDs = []
            return
        }
        apply(snapshot: snapshot)
    }

    private func apply(snapshot: MedicalHubStateSnapshot) {
        selectedDate = max(1, min(31, snapshot.selectedDate))
        reminders = snapshot.reminders.sorted { $0.date < $1.date }
        let allowed = Set(events.map(\.id))
        completedEventIDs = snapshot.completedEventIDs.intersection(allowed)
    }

    private func saveState() {
        store.saveState(
            MedicalHubStateSnapshot(
                selectedDate: selectedDate,
                completedEventIDs: completedEventIDs,
                reminders: reminders
            ),
            for: Self.activePetID(from: petProfiles)
        )
    }

    private static func activePetID(from profiles: PetProfilesViewModel) -> UUID {
        profiles.activePet?.id ?? UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    }
}

protocol MedicalHubStateStore {
    func loadState(for petID: UUID) -> MedicalHubStateSnapshot?
    func saveState(_ snapshot: MedicalHubStateSnapshot, for petID: UUID)
}

struct MedicalHubStateSnapshot: Codable, Equatable {
    let selectedDate: Int
    let completedEventIDs: Set<UUID>
    let reminders: [MedicalReminder]

    init(selectedDate: Int, completedEventIDs: Set<UUID>, reminders: [MedicalReminder] = []) {
        self.selectedDate = selectedDate
        self.completedEventIDs = completedEventIDs
        self.reminders = reminders
    }

    private enum CodingKeys: String, CodingKey {
        case selectedDate
        case completedEventIDs
        case reminders
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedDate = try container.decode(Int.self, forKey: .selectedDate)
        completedEventIDs = try container.decode(Set<UUID>.self, forKey: .completedEventIDs)
        reminders = try container.decodeIfPresent([MedicalReminder].self, forKey: .reminders) ?? []
    }
}

struct UserDefaultsMedicalHubStateStore: MedicalHubStateStore {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "pawsy.medical.state.v2") {
        self.defaults = defaults
        self.key = key
    }

    func loadState(for petID: UUID) -> MedicalHubStateSnapshot? {
        guard let dictionary = loadDictionary() else { return nil }
        return dictionary[petID.uuidString]
    }

    func saveState(_ snapshot: MedicalHubStateSnapshot, for petID: UUID) {
        var dictionary = loadDictionary() ?? [:]
        dictionary[petID.uuidString] = snapshot
        guard let encoded = try? JSONEncoder().encode(dictionary) else { return }
        defaults.set(encoded, forKey: key)
    }

    private func loadDictionary() -> [String: MedicalHubStateSnapshot]? {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: MedicalHubStateSnapshot].self, from: data) else {
            return nil
        }
        return decoded
    }
}
