import Foundation

protocol KeychainService {
    func save(_ data: Data, for key: String) throws
    func load(for key: String) throws -> Data?
    func delete(for key: String) throws
}

enum KeychainServiceError: Error {
    case unsupportedInMVP
}

struct PlaceholderKeychainService: KeychainService {
    func save(_ data: Data, for key: String) throws {
        throw KeychainServiceError.unsupportedInMVP
    }

    func load(for key: String) throws -> Data? {
        throw KeychainServiceError.unsupportedInMVP
    }

    func delete(for key: String) throws {
        throw KeychainServiceError.unsupportedInMVP
    }
}
