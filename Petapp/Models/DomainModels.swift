import Foundation
import CoreLocation

enum PetSpecies: String, Codable, CaseIterable, Identifiable {
    case dog
    case cat
    case bird
    case horse
    case pig
    case rabbit
    case hamster
    case guineaPig
    case ferret
    case chinchilla
    case parrot
    case turtle
    case fish
    case hedgehog
    case goat
    case sheep
    case cow
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dog: return "Dog"
        case .cat: return "Cat"
        case .bird: return "Bird"
        case .horse: return "Horse"
        case .pig: return "Pig"
        case .rabbit: return "Rabbit"
        case .hamster: return "Hamster"
        case .guineaPig: return "Guinea Pig"
        case .ferret: return "Ferret"
        case .chinchilla: return "Chinchilla"
        case .parrot: return "Parrot"
        case .turtle: return "Turtle"
        case .fish: return "Fish"
        case .hedgehog: return "Hedgehog"
        case .goat: return "Goat"
        case .sheep: return "Sheep"
        case .cow: return "Cow"
        case .other: return "Other"
        }
    }
}

enum PetSex: String, Codable, CaseIterable, Identifiable {
    case unknown
    case male
    case female

    var id: String { rawValue }

    var title: String {
        switch self {
        case .unknown: return "Unknown"
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}

struct PetMedicalInfo: Codable, Equatable {
    var operations: String
    var diseases: String
    var vaccinations: String
    var allergies: String
    var medications: String
    var notes: String

    static let empty = PetMedicalInfo(
        operations: "",
        diseases: "",
        vaccinations: "",
        allergies: "",
        medications: "",
        notes: ""
    )
}

struct PetProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var species: PetSpecies
    var breed: String
    var sex: PetSex
    var birthDate: Date?
    var style: PetStyle
    var accessory: PetAccessory
    var avatarAsset: String
    var medical: PetMedicalInfo
    var createdAt: Date

    var displayBreed: String {
        breed.isEmpty ? "Not specified" : breed
    }

    static func draftDefault() -> PetProfile {
        PetProfile(
            id: UUID(),
            name: "",
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
    }
}

struct Pet: Identifiable, Equatable {
    let id: UUID
    let name: String
    let avatarAsset: String
}

struct HealthStat: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let progress: Double
    let colorHex: String
}

struct VetEvent: Identifiable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let icon: String
    let date: Date
}

enum ReminderCategory: String, Codable, CaseIterable, Identifiable {
    case vaccination
    case vetVisit
    case medication
    case grooming
    case note

    var id: String { rawValue }

    var title: String {
        switch self {
        case .vaccination: return "Vaccination"
        case .vetVisit: return "Vet Visit"
        case .medication: return "Medication"
        case .grooming: return "Grooming"
        case .note: return "Note"
        }
    }

    var icon: String {
        switch self {
        case .vaccination: return "syringe"
        case .vetVisit: return "stethoscope"
        case .medication: return "pills"
        case .grooming: return "scissors"
        case .note: return "note.text"
        }
    }
}

struct MedicalReminder: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var category: ReminderCategory
    var date: Date
    var note: String
    var isCompleted: Bool
}

struct WeightPoint: Identifiable, Equatable {
    let id = UUID()
    let dayLabel: String
    let value: Double
}

enum PartnerServiceType: String, Codable, CaseIterable, Identifiable {
    case veterinary
    case petShop

    var id: String { rawValue }

    var title: String {
        switch self {
        case .veterinary: return "Vet"
        case .petShop: return "Pet Shop"
        }
    }

    var icon: String {
        switch self {
        case .veterinary: return "cross.case.fill"
        case .petShop: return "cart.fill"
        }
    }
}

struct PartnerService: Identifiable, Equatable {
    let id: UUID
    let name: String
    let type: PartnerServiceType
    let distanceKM: Double
    let address: String
    let isOpenNow: Bool
}

enum ChatSender: String, Codable, Equatable {
    case user
    case ai
}

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let sender: ChatSender
    let text: String
    let isWarning: Bool
    let imageData: Data?
}

struct CommunityUser: Identifiable, Equatable {
    let id: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D
    let avatarEmoji: String

    static func == (lhs: CommunityUser, rhs: CommunityUser) -> Bool {
        lhs.id == rhs.id
        && lhs.name == rhs.name
        && lhs.coordinate.latitude == rhs.coordinate.latitude
        && lhs.coordinate.longitude == rhs.coordinate.longitude
        && lhs.avatarEmoji == rhs.avatarEmoji
    }
}

extension PetProfile {
    var asLegacyPet: Pet {
        Pet(id: id, name: name, avatarAsset: avatarAsset)
    }
}

enum AppThemeMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}
