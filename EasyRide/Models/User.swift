import Foundation

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let phoneNumber: String?
    let profileImage: String?
    let preferredLanguage: String?
    let createdAt: Date
    var isVerified: Bool
    
    init(
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
    
    var displayName: String {
        return name.isEmpty ? email : name
    }
    
    var initials: String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.prefix(2).joined().uppercased()
    }
}