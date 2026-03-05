import Foundation

struct PetVitals: Codable, Equatable {
    var happiness: Int
    var health: Int
    var hygiene: Int
    var energy: Int
    var hunger: Int

    static let `default` = PetVitals(
        happiness: 90,
        health: 85,
        hygiene: 70,
        energy: 78,
        hunger: 34
    )
}

struct PetState: Codable, Equatable {
    var vitals: PetVitals
    var mood: String
    var lastAction: PetAction
    var updatedAt: Date
    var actionTimestamps: ActionTimestamps
    var completedActionsToday: Set<PetAction>
    var dailyBonusAwarded: Bool
    var activityLog: [PetActivityEntry]
}

struct PetActionResult: Equatable {
    let state: PetState
    let message: String
    let isBlocked: Bool
    let cooldownRemaining: TimeInterval?
    let changedStatTitles: [String]
}

struct ActionTimestamps: Codable, Equatable {
    var feed: Date?
    var walk: Date?
    var play: Date?

    func date(for action: PetAction) -> Date? {
        switch action {
        case .feed: return feed
        case .walk: return walk
        case .play: return play
        case .idle: return nil
        }
    }

    mutating func set(_ date: Date, for action: PetAction) {
        switch action {
        case .feed: feed = date
        case .walk: walk = date
        case .play: play = date
        case .idle: break
        }
    }
}

struct PetActivityEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let action: PetAction
    let timestamp: Date
    let note: String
}

extension PetVitals {
    var asHealthStats: [HealthStat] {
        [
            HealthStat(title: "Happiness", progress: Double(happiness) / 100, colorHex: "#FA8F99"),
            HealthStat(title: "Health", progress: Double(health) / 100, colorHex: "#62BFA1"),
            HealthStat(title: "Hygiene", progress: Double(hygiene) / 100, colorHex: "#72A9EA")
        ]
    }
}
