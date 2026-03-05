import Foundation

enum PetAction: String, CaseIterable, Codable {
    case idle
    case feed
    case walk
    case play
}

extension PetAction {
    var cooldownSeconds: TimeInterval {
        switch self {
        case .feed: return 20 * 60
        case .walk: return 45 * 60
        case .play: return 30 * 60
        case .idle: return 0
        }
    }

    var dailyTaskKind: DailyTaskKind? {
        switch self {
        case .feed: return .feed
        case .walk: return .walk
        case .play: return .play
        case .idle: return nil
        }
    }
}

enum PetStyle: String, CaseIterable, Codable, Identifiable {
    case shiba
    case golden
    case husky

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shiba: return "Shiba"
        case .golden: return "Golden"
        case .husky: return "Husky"
        }
    }

    var emoji: String {
        switch self {
        case .shiba: return "🐕"
        case .golden: return "🐶"
        case .husky: return "🐺"
        }
    }
}

enum PetAccessory: String, CaseIterable, Codable, Identifiable {
    case none
    case greenCollar
    case blueCollar
    case peachBandana

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none: return "None"
        case .greenCollar: return "Green Collar"
        case .blueCollar: return "Blue Collar"
        case .peachBandana: return "Peach Bandana"
        }
    }
}

struct PetCustomization: Codable, Equatable {
    let name: String
    let style: PetStyle
    let accessory: PetAccessory
}
