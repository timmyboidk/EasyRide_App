import Foundation

public enum UserRole: String, Codable {
    case passenger = "PASSENGER"
    case driver = "DRIVER"
}

public struct User: Codable, Identifiable {
    public let userId: Int64
    public let phoneNumber: String
    public let nickname: String?
    public let role: UserRole
    public let accessToken: String?
    
    // Additional fields for UI
    public let profileImage: String?
    public let preferredLanguage: String?
    public let createdAt: String?
    public let isVerified: Bool?
    
    // Legacy support/Convenience properties
    public var id: String { String(userId) }
    public var name: String { nickname ?? phoneNumber }
    public var email: String { "" } 
    
    public init(
        userId: Int64,
        phoneNumber: String,
        nickname: String?,
        role: UserRole,
        accessToken: String?,
        profileImage: String? = nil,
        preferredLanguage: String? = nil,
        createdAt: String? = nil,
        isVerified: Bool? = nil
    ) {
        self.userId = userId
        self.phoneNumber = phoneNumber
        self.nickname = nickname
        self.role = role
        self.accessToken = accessToken
        self.profileImage = profileImage
        self.preferredLanguage = preferredLanguage
        self.createdAt = createdAt
        self.isVerified = isVerified
    }
    
    // Computed for UI compatibility
    public var displayName: String {
        return nickname ?? phoneNumber
    }
    
    public var initials: String {
        let nameToUse = nickname ?? "User"
        let components = nameToUse.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.prefix(2).joined().uppercased()
    }
}