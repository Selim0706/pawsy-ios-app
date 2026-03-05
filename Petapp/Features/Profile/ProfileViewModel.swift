import Foundation
import MapKit
import Combine

final class PetProfilesViewModel: ObservableObject {
    @Published var pets: [PetProfile]
    @Published var activePetID: UUID?
    @Published private(set) var hasCompletedOnboarding: Bool

    private let store: PetProfilesStore

    init(store: PetProfilesStore = UserDefaultsPetProfilesStore()) {
        self.store = store
        let snapshot = store.load()
        self.pets = snapshot.pets
        self.activePetID = snapshot.activePetID ?? snapshot.pets.first?.id
        self.hasCompletedOnboarding = !snapshot.pets.isEmpty
    }

    var activePet: PetProfile? {
        guard let activePetID else { return pets.first }
        return pets.first(where: { $0.id == activePetID }) ?? pets.first
    }

    func addPet(_ profile: PetProfile, makeActive: Bool = true) {
        pets.append(profile)
        if makeActive || activePetID == nil {
            activePetID = profile.id
        }
        hasCompletedOnboarding = !pets.isEmpty
        persist()
    }

    func updatePet(_ profile: PetProfile) {
        guard let idx = pets.firstIndex(where: { $0.id == profile.id }) else { return }
        pets[idx] = profile
        persist()
    }

    func updateActivePet(name: String, style: PetStyle, accessory: PetAccessory) {
        guard let active = activePet else { return }
        var updated = active
        updated.name = name
        updated.style = style
        updated.accessory = accessory
        updatePet(updated)
    }

    func setActive(_ petID: UUID) {
        guard pets.contains(where: { $0.id == petID }) else { return }
        activePetID = petID
        persist()
    }

    func deletePet(_ petID: UUID) {
        pets.removeAll { $0.id == petID }
        if activePetID == petID {
            activePetID = pets.first?.id
        }
        hasCompletedOnboarding = !pets.isEmpty
        persist()
    }

    private func persist() {
        store.save(PetProfilesSnapshot(pets: pets, activePetID: activePetID))
    }
}

protocol PetProfilesStore {
    func load() -> PetProfilesSnapshot
    func save(_ snapshot: PetProfilesSnapshot)
}

struct PetProfilesSnapshot: Codable, Equatable {
    var pets: [PetProfile]
    var activePetID: UUID?
}

struct UserDefaultsPetProfilesStore: PetProfilesStore {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "pawsy.pet.profiles.v1") {
        self.defaults = defaults
        self.key = key
    }

    func load() -> PetProfilesSnapshot {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode(PetProfilesSnapshot.self, from: data) else {
            return PetProfilesSnapshot(pets: [], activePetID: nil)
        }
        return decoded
    }

    func save(_ snapshot: PetProfilesSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: key)
    }
}

final class ProfileViewModel: ObservableObject {
    @Published var nearbyUsers: [CommunityUser]
    @Published var region: MKCoordinateRegion
    private let defaultRegion: MKCoordinateRegion
    private let stateStore: ProfileStateStore
    let petProfiles: PetProfilesViewModel
    private var cancellables: Set<AnyCancellable> = []

    init(
        repository: MockRepository,
        petProfiles: PetProfilesViewModel,
        stateStore: ProfileStateStore = UserDefaultsProfileStateStore()
    ) {
        self.nearbyUsers = repository.communityUsers()
        self.stateStore = stateStore
        self.petProfiles = petProfiles
        let fallbackRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        self.defaultRegion = fallbackRegion
        self.region = stateStore.loadRegion() ?? fallbackRegion
    }

    var activePet: PetProfile? {
        petProfiles.activePet
    }

    var pets: [PetProfile] {
        petProfiles.pets
    }

    func setActivePet(_ petID: UUID) {
        petProfiles.setActive(petID)
    }

    func addPet(_ profile: PetProfile) {
        petProfiles.addPet(profile)
    }

    func updatePet(_ profile: PetProfile) {
        petProfiles.updatePet(profile)
    }

    func deletePet(_ petID: UUID) {
        petProfiles.deletePet(petID)
    }

    func recenter() {
        updateRegion(defaultRegion)
    }

    func updateRegion(_ region: MKCoordinateRegion) {
        self.region = region
        stateStore.saveRegion(region)
    }
}

protocol ProfileStateStore {
    func loadRegion() -> MKCoordinateRegion?
    func saveRegion(_ region: MKCoordinateRegion)
}

struct UserDefaultsProfileStateStore: ProfileStateStore {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "pawsy.profile.region.v1") {
        self.defaults = defaults
        self.key = key
    }

    func loadRegion() -> MKCoordinateRegion? {
        guard let data = defaults.data(forKey: key),
              let snapshot = try? JSONDecoder().decode(ProfileRegionSnapshot.self, from: data) else {
            return nil
        }
        return snapshot.region
    }

    func saveRegion(_ region: MKCoordinateRegion) {
        let snapshot = ProfileRegionSnapshot(region: region)
        guard let encoded = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(encoded, forKey: key)
    }
}

private struct ProfileRegionSnapshot: Codable {
    let centerLatitude: Double
    let centerLongitude: Double
    let latitudeDelta: Double
    let longitudeDelta: Double

    init(region: MKCoordinateRegion) {
        self.centerLatitude = region.center.latitude
        self.centerLongitude = region.center.longitude
        self.latitudeDelta = region.span.latitudeDelta
        self.longitudeDelta = region.span.longitudeDelta
    }

    var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude),
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        )
    }
}
