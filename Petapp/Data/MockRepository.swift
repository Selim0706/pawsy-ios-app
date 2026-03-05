import Foundation

protocol MockRepository {
    func dashboardPet() -> Pet
    func healthStats() -> [HealthStat]

    func monthTitle() -> String
    func weightHistory() -> [WeightPoint]
    func vetEvents() -> [VetEvent]
    func partnerServices() -> [PartnerService]

    func initialChatMessages() -> [ChatMessage]

    func pets() -> [Pet]
    func communityUsers() -> [CommunityUser]
}
