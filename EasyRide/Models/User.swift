import Foundation

public struct User: Codable, Identifiable {
    public let id: String
    public let name: String
    public let email: String
    public let phoneNumber: String?
    public let profileImage: String?
    public let preferredLanguage: String?
    public let createdAt: Date
    public var isVerified: Bool
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        phoneNumber: String? = nil,
        profileImage: String? = nil,
        preferredLanguage: String? = nil,
        createdAt: Date = Date(),
        isVerified: Bool = false
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.profileImage = profileImage
        self.preferredLanguage = preferredLanguage
        self.createdAt = createdAt
        self.isVerified = isVerified
    }
    
    public var displayName: String {
        return name.isEmpty ? email : name
    }
    
    public var initials: String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.prefix(2).joined().uppercased()
    }
}