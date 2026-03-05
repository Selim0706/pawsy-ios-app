import Foundation

protocol ChatHistoryStore {
    func loadMessages(for petID: UUID) -> [ChatMessage]
    func saveMessages(_ messages: [ChatMessage], for petID: UUID)
}

struct UserDefaultsChatHistoryStore: ChatHistoryStore {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "pawsy.chat.history.v1") {
        self.defaults = defaults
        self.key = key
    }

    func loadMessages(for petID: UUID) -> [ChatMessage] {
        guard let dictionary = loadDictionary(),
              let messages = dictionary[petID.uuidString] else {
            return []
        }
        return messages
    }

    func saveMessages(_ messages: [ChatMessage], for petID: UUID) {
        var dictionary = loadDictionary() ?? [:]
        dictionary[petID.uuidString] = messages
        guard let encoded = try? JSONEncoder().encode(dictionary) else { return }
        defaults.set(encoded, forKey: key)
    }

    private func loadDictionary() -> [String: [ChatMessage]]? {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: [ChatMessage]].self, from: data) else {
            return nil
        }
        return decoded
    }
}
