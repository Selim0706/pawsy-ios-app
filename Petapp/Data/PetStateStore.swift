import Foundation

protocol PetStateStore {
    func loadState(for petID: UUID) -> PetState?
    func saveState(_ state: PetState, for petID: UUID)
}

struct UserDefaultsPetStateStore: PetStateStore {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "pawsy.pet.state.v1") {
        self.defaults = defaults
        self.key = key
    }

    func loadState(for petID: UUID) -> PetState? {
        guard let dictionary = loadDictionary() else { return nil }
        return dictionary[petID.uuidString]
    }

    func saveState(_ state: PetState, for petID: UUID) {
        var dictionary = loadDictionary() ?? [:]
        dictionary[petID.uuidString] = state
        guard let encoded = try? JSONEncoder().encode(dictionary) else { return }
        defaults.set(encoded, forKey: key)
    }

    private func loadDictionary() -> [String: PetState]? {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: PetState].self, from: data) else {
            return nil
        }
        return decoded
    }
}
