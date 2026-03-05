import Foundation
import CoreLocation

struct InMemoryMockRepository: MockRepository {
    func dashboardPet() -> Pet {
        Pet(id: UUID(), name: "Milo", avatarAsset: "pet_shiba")
    }

    func healthStats() -> [HealthStat] {
        [
            HealthStat(title: "Happiness", progress: 0.90, colorHex: "#FA8F99"),
            HealthStat(title: "Health", progress: 0.85, colorHex: "#62BFA1"),
            HealthStat(title: "Hygiene", progress: 0.70, colorHex: "#72A9EA")
        ]
    }

    func monthTitle() -> String {
        "Rombrer 2024"
    }

    func weightHistory() -> [WeightPoint] {
        [
            WeightPoint(dayLabel: "Mon", value: 104),
            WeightPoint(dayLabel: "Tue", value: 118),
            WeightPoint(dayLabel: "Wed", value: 121),
            WeightPoint(dayLabel: "Thu", value: 122),
            WeightPoint(dayLabel: "Fri", value: 136),
            WeightPoint(dayLabel: "Sat", value: 142)
        ]
    }

    func vetEvents() -> [VetEvent] {
        [
            VetEvent(
                id: UUID(uuidString: "A2E8335D-58C1-4CA1-A360-2DBB1A6C59D1")!,
                title: "Vet Visit - Dr. Lee",
                subtitle: "Checkup",
                icon: "stethoscope",
                date: .now
            ),
            VetEvent(
                id: UUID(uuidString: "12E081ED-423B-4F2B-B521-4A58A18F13E8")!,
                title: "Flea Treatment",
                subtitle: "Monthly",
                icon: "cross.case",
                date: .now.addingTimeInterval(3600 * 24 * 3)
            )
        ]
    }

    func partnerServices() -> [PartnerService] {
        [
            PartnerService(
                id: UUID(uuidString: "3E84A84B-5CC6-4A62-BE8B-D2D3AB41DDE1")!,
                name: "Happy Tails Vet Clinic",
                type: .veterinary,
                distanceKM: 1.2,
                address: "Market Street 42",
                isOpenNow: true
            ),
            PartnerService(
                id: UUID(uuidString: "AB29FF30-6AAB-409C-8921-5A72E42D804A")!,
                name: "PawMart Pet Store",
                type: .petShop,
                distanceKM: 0.8,
                address: "River Avenue 10",
                isOpenNow: true
            ),
            PartnerService(
                id: UUID(uuidString: "E8898DAF-A671-4A72-BB3C-7E3EA9683EA0")!,
                name: "CityVet 24/7",
                type: .veterinary,
                distanceKM: 3.6,
                address: "Elm Boulevard 89",
                isOpenNow: false
            ),
            PartnerService(
                id: UUID(uuidString: "FA23FC76-C00E-40F3-8A5A-635DEF630C0D")!,
                name: "ZooNest Supplies",
                type: .petShop,
                distanceKM: 2.1,
                address: "Sunset Road 17",
                isOpenNow: false
            )
        ]
    }

    func initialChatMessages() -> [ChatMessage] {
        [
            ChatMessage(
                id: UUID(),
                sender: .ai,
                text: "Hi. I am Vetty AI. Tell me what your pet ate or describe symptoms.",
                isWarning: false,
                imageData: nil
            )
        ]
    }

    func pets() -> [Pet] {
        [
            Pet(id: UUID(), name: "Milo", avatarAsset: "pet_shiba"),
            Pet(id: UUID(), name: "Luna", avatarAsset: "pet_cat"),
            Pet(id: UUID(), name: "Rocky", avatarAsset: "pet_dog2")
        ]
    }

    func communityUsers() -> [CommunityUser] {
        [
            CommunityUser(id: UUID(), name: "Mia", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), avatarEmoji: "🐩"),
            CommunityUser(id: UUID(), name: "Leo", coordinate: CLLocationCoordinate2D(latitude: 37.7766, longitude: -122.4142), avatarEmoji: "🐕"),
            CommunityUser(id: UUID(), name: "Nora", coordinate: CLLocationCoordinate2D(latitude: 37.7724, longitude: -122.4174), avatarEmoji: "🐕‍🦺")
        ]
    }
}
