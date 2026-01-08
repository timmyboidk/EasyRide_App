import Foundation

public enum TripMode: String, Codable, CaseIterable, Identifiable {
    case freeRoute = "free_route"
    case customRoute = "custom_route"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .freeRoute: return NSLocalizedString("free_trip", comment: "")
        case .customRoute: return NSLocalizedString("custom_route", comment: "")
        }
    }
    
    public var icon: String {
        switch self {
        case .freeRoute: return "location.circle.fill"
        case .customRoute: return "map.fill"
        }
    }
}

public struct TripStop: Identifiable, Codable {
    public let id: UUID
    public var location: Location
    public var duration: TimeInterval // in minutes
    public var notes: String?
    public var order: Int
    
    public init(id: UUID = UUID(), location: Location, duration: TimeInterval = 30, notes: String? = nil, order: Int = 0) {
        self.id = id
        self.location = location
        self.duration = duration
        self.notes = notes
        self.order = order
    }
}

