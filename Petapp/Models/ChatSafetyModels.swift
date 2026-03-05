import Foundation

enum SafetyLevel: String, Codable, Equatable {
    case safe
    case caution
    case danger
}

enum ChatIntent: String, Codable, Equatable {
    case food
    case symptom
    case toxicItem
    case generic
}

struct SafetyAssessment: Equatable {
    let level: SafetyLevel
    let intent: ChatIntent
    let explanation: String
    let advice: String

    var composedMessage: String {
        "\(explanation) \(advice)"
    }
}
