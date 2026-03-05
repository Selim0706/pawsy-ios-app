import Foundation

protocol DailyTaskStore {
    func loadTasks(for petID: UUID, defaults: [PawsyTask], now: Date) -> [PawsyTask]
    func saveTasks(_ tasks: [PawsyTask], for petID: UUID, now: Date)
}

struct UserDefaultsDailyTaskStore: DailyTaskStore {
    private let defaults: UserDefaults
    private let key: String
    private let calendar: Calendar

    init(
        defaults: UserDefaults = .standard,
        key: String = "pawsy.daily.tasks.v2",
        calendar: Calendar = .current
    ) {
        self.defaults = defaults
        self.key = key
        self.calendar = calendar
    }

    func loadTasks(for petID: UUID, defaults fallback: [PawsyTask], now: Date) -> [PawsyTask] {
        guard let dictionary = loadDictionary(),
              let snapshot = dictionary[petID.uuidString] else {
            return fallback
        }

        if calendar.isDate(snapshot.day, inSameDayAs: now) {
            return snapshot.tasks
        }
        return fallback
    }

    func saveTasks(_ tasks: [PawsyTask], for petID: UUID, now: Date) {
        let snapshot = DailyTaskSnapshot(day: calendar.startOfDay(for: now), tasks: tasks)
        var dictionary = loadDictionary() ?? [:]
        dictionary[petID.uuidString] = snapshot
        guard let encoded = try? JSONEncoder().encode(dictionary) else { return }
        defaults.set(encoded, forKey: key)
    }

    private func loadDictionary() -> [String: DailyTaskSnapshot]? {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: DailyTaskSnapshot].self, from: data) else {
            return nil
        }
        return decoded
    }
}

private struct DailyTaskSnapshot: Codable {
    let day: Date
    let tasks: [PawsyTask]
}
