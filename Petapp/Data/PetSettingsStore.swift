import Foundation

protocol PetSettingsStore {
    func load(for petID: UUID, defaultProfile: PetProfile) -> PetCustomization
    func save(_ customization: PetCustomization, for petID: UUID)
}

struct UserDefaultsPetSettingsStore: PetSettingsStore {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "pawsy.pet.customization.v1") {
        self.defaults = defaults
        self.key = key
    }

    func load(for petID: UUID, defaultProfile: PetProfile) -> PetCustomization {
        guard let dictionary = loadDictionary(),
              let decoded = dictionary[petID.uuidString] else {
            return PetCustomization(
                name: defaultProfile.name,
                style: defaultProfile.style,
                accessory: defaultProfile.accessory
            )
        }
        return decoded
    }

    func save(_ customization: PetCustomization, for petID: UUID) {
        var dictionary = loadDictionary() ?? [:]
        dictionary[petID.uuidString] = customization
        guard let encoded = try? JSONEncoder().encode(dictionary) else { return }
        defaults.set(encoded, forKey: key)
    }

    private func loadDictionary() -> [String: PetCustomization]? {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: PetCustomization].self, from: data) else {
            return nil
        }
        return decoded
    }
}
