import Foundation

struct VetRuleEngine {
    private let dangerKeywords = [
        "chocolate", "grapes", "xylitol", "onion", "garlic", "raisin", "ibuprofen"
    ]
    private let cautionKeywords = [
        "vomit", "vomiting", "itch", "diarrhea", "diarrhoea", "cough", "limp", "rash"
    ]
    private let foodKeywords = [
        "eat", "food", "snack", "treat", "can i give", "safe for", "is this safe"
    ]

    func assess(text: String) -> SafetyAssessment {
        let normalized = text.lowercased()

        if containsAny(dangerKeywords, in: normalized) {
            return SafetyAssessment(
                level: .danger,
                intent: .toxicItem,
                explanation: "That item is toxic for dogs.",
                advice: "Keep it away and contact a vet if your pet already ingested it."
            )
        }

        if containsAny(cautionKeywords, in: normalized) {
            return SafetyAssessment(
                level: .caution,
                intent: .symptom,
                explanation: "That symptom needs observation.",
                advice: "Monitor closely for 24h and call a vet if it worsens."
            )
        }

        if containsAny(foodKeywords, in: normalized) {
            return SafetyAssessment(
                level: .safe,
                intent: .food,
                explanation: "This looks generally safe in small amounts.",
                advice: "Introduce slowly and watch for any unusual reaction."
            )
        }

        return SafetyAssessment(
            level: .caution,
            intent: .generic,
            explanation: "I can help with pet safety checks and symptoms.",
            advice: "Share what your pet ate or the symptom details for a precise recommendation."
        )
    }

    func assess(labels: [String]) -> SafetyAssessment {
        let merged = labels.joined(separator: " ").lowercased()
        if containsAny(dangerKeywords, in: merged) {
            return SafetyAssessment(
                level: .danger,
                intent: .toxicItem,
                explanation: "Detected a potentially toxic item in the photo.",
                advice: "Do not offer it and clean the area around your pet."
            )
        }
        return SafetyAssessment(
            level: .caution,
            intent: .generic,
            explanation: "I cannot verify the item with high confidence from this photo.",
            advice: "Share a clearer photo or type the exact product name."
        )
    }

    private func containsAny(_ keywords: [String], in value: String) -> Bool {
        keywords.contains { value.contains($0) }
    }
}
