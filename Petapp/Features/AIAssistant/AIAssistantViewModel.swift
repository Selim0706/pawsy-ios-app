import Foundation
import SwiftUI
import PhotosUI
import UIKit
import Combine

@MainActor
final class AIAssistantViewModel: ObservableObject {
    @Published var messages: [ChatMessage]
    @Published var draft: String = ""

    private let petProfiles: PetProfilesViewModel
    private let repository: MockRepository
    private let chatHistoryStore: ChatHistoryStore
    private let vetRuleEngine: VetRuleEngine
    private let imageHeuristics: ImageSafetyHeuristics
    private var profilesCancellable: AnyCancellable?

    init(
        repository: MockRepository,
        petProfiles: PetProfilesViewModel,
        chatHistoryStore: ChatHistoryStore = UserDefaultsChatHistoryStore(),
        vetRuleEngine: VetRuleEngine = VetRuleEngine(),
        imageHeuristics: ImageSafetyHeuristics = ImageSafetyHeuristics()
    ) {
        self.repository = repository
        self.petProfiles = petProfiles
        self.chatHistoryStore = chatHistoryStore
        self.vetRuleEngine = vetRuleEngine
        self.imageHeuristics = imageHeuristics
        let restored = chatHistoryStore.loadMessages(for: Self.activePetID(from: petProfiles))
        self.messages = restored.isEmpty ? repository.initialChatMessages() : restored
        observePetSelection()
    }

    func send(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let petName = petProfiles.activePet?.name ?? "your pet"
        messages.append(
            ChatMessage(id: UUID(), sender: .user, text: trimmed, isWarning: false, imageData: nil)
        )
        let assessment = vetRuleEngine.assess(text: "\(trimmed). Pet: \(petName)")
        messages.append(
            ChatMessage(
                id: UUID(),
                sender: .ai,
                text: assessment.composedMessage,
                isWarning: assessment.level == .danger,
                imageData: nil
            )
        )
        draft = ""
        persistHistory()
    }

    func attachPhoto(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              UIImage(data: data) != nil else {
            return
        }

        messages.append(
            ChatMessage(
                id: UUID(),
                sender: .user,
                text: "Is this safe for \(petProfiles.activePet?.name ?? "my pet")?",
                isWarning: false,
                imageData: data
            )
        )

        let heuristics = imageHeuristics
        let labels = await Task.detached(priority: .userInitiated) {
            heuristics.detectLabels(from: data)
        }.value
        let assessment = vetRuleEngine.assess(labels: labels)
        messages.append(
            ChatMessage(
                id: UUID(),
                sender: .ai,
                text: assessment.composedMessage,
                isWarning: assessment.level == .danger,
                imageData: nil
            )
        )
        persistHistory()
    }

    func attachImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
        messages.append(
            ChatMessage(id: UUID(), sender: .user, text: "Photo uploaded", isWarning: false, imageData: data)
        )
        let labels = imageHeuristics.detectLabels(from: data)
        let assessment = vetRuleEngine.assess(labels: labels)
        messages.append(
            ChatMessage(
                id: UUID(),
                sender: .ai,
                text: assessment.composedMessage,
                isWarning: assessment.level == .danger,
                imageData: nil
            )
        )
        persistHistory()
    }

    func clearHistory() {
        messages = repository.initialChatMessages()
        persistHistory()
    }

    private func persistHistory() {
        chatHistoryStore.saveMessages(messages, for: Self.activePetID(from: petProfiles))
    }

    private func observePetSelection() {
        profilesCancellable = petProfiles.$activePetID
            .sink { [weak self] _ in
                guard let self else { return }
                let restored = self.chatHistoryStore.loadMessages(for: Self.activePetID(from: self.petProfiles))
                self.messages = restored.isEmpty ? self.repository.initialChatMessages() : restored
            }
    }

    private static func activePetID(from profiles: PetProfilesViewModel) -> UUID {
        profiles.activePet?.id ?? UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    }
}
