import Foundation

struct PawsyTask: Identifiable, Codable, Equatable {
    let kind: DailyTaskKind
    var isDone: Bool
    var completedAt: Date?

    var id: String { kind.rawValue }
    var title: String { kind.title }
    var icon: String { kind.icon }
}

enum DailyTaskKind: String, CaseIterable, Codable {
    case feed
    case walk
    case play

    var title: String {
        switch self {
        case .feed: return "Feed once"
        case .walk: return "Walk once"
        case .play: return "Play 15 min"
        }
    }

    var icon: String {
        switch self {
        case .feed: return "fork.knife"
        case .walk: return "figure.walk"
        case .play: return "gamecontroller"
        }
    }
}
