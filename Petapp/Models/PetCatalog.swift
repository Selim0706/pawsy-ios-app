import Foundation

enum PetCatalog {
    static func breeds(for species: PetSpecies) -> [String] {
        switch species {
        case .dog:
            return ["Shiba Inu", "Golden Retriever", "Labrador", "Poodle", "French Bulldog", "Corgi", "Husky", "German Shepherd", "Mixed"]
        case .cat:
            return ["British Shorthair", "Scottish Fold", "Maine Coon", "Siamese", "Bengal", "Sphynx", "Persian", "Mixed"]
        case .bird:
            return ["Canary", "Finch", "Budgie", "Cockatiel", "Lovebird", "Mixed"]
        case .parrot:
            return ["Budgie", "Cockatiel", "Conure", "African Grey", "Macaw", "Lovebird", "Mixed"]
        case .rabbit:
            return ["Holland Lop", "Mini Rex", "Lionhead", "Netherland Dwarf", "Mixed"]
        case .hamster:
            return ["Syrian", "Dwarf", "Roborovski", "Chinese", "Mixed"]
        case .guineaPig:
            return ["American", "Abyssinian", "Peruvian", "Silkie", "Mixed"]
        case .ferret:
            return ["Standard", "Angora", "Mixed"]
        case .chinchilla:
            return ["Standard", "Velvet", "White", "Mixed"]
        case .horse:
            return ["Arabian", "Thoroughbred", "Quarter Horse", "Appaloosa", "Mixed"]
        case .pig:
            return ["Mini Pig", "Pot-Bellied", "KuneKune", "Mixed"]
        case .turtle:
            return ["Red-Eared Slider", "Russian Tortoise", "Box Turtle", "Mixed"]
        case .fish:
            return ["Betta", "Goldfish", "Guppy", "Molly", "Tetra", "Mixed"]
        case .hedgehog:
            return ["African Pygmy", "Mixed"]
        case .goat:
            return ["Nigerian Dwarf", "Pygmy", "Boer", "Mixed"]
        case .sheep:
            return ["Merino", "Suffolk", "Dorper", "Mixed"]
        case .cow:
            return ["Holstein", "Jersey", "Angus", "Hereford", "Mixed"]
        case .other:
            return []
        }
    }
}
