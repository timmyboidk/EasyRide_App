import Foundation

enum TripMode: String, Codable, CaseIterable, Identifiable {
    case freeRoute = "free_route"
    case customRoute = "custom_route"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .freeRoute: return NSLocalizedString("free_trip", comment: "")
        case .customRoute: return NSLocalizedString("custom_route", comment: "")
        }
    }
    
    var icon: String {
        switch self {
        case .freeRoute: return "location.circle.fill"
        case .customRoute: return "map.fill"
        }
    }
}

struct TripStop: Identifiable, Codable {
    let id: UUID
    var location: Location
    var duration: TimeInterval // in minutes
    var notes: String?
    var order: Int
    
    init(id: UUID = UUID(), location: Location, duration: TimeInterval = 30, notes: String? = nil, order: Int = 0) {
        self.id = id
        self.location = location
        self.duration = duration
        self.notes = notes
        self.order = order
    }
}

