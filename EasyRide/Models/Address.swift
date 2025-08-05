import Foundation
import CoreLocation

struct Address: Codable, Identifiable, Equatable {
    let id: String
    let name: String?
    let address: String
    let latitude: Double
    let longitude: Double
    let placeId: String?
    let type: AddressType
    var isFavorite: Bool
    
    init(
        id: String = UUID().uuidString,
        name: String? = nil,
        address: String,
        latitude: Double,
        longitude: Double,
        placeId: String? = nil,
        type: AddressType = .general,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.placeId = placeId
        self.type = type
        self.isFavorite = isFavorite
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var displayName: String {
        return name ?? address
    }
    
    func distance(to other: Address) -> CLLocationDistance {
        return clLocation.distance(from: other.clLocation)
    }
    
    // Convert to Location
    func toLocation() -> Location {
        return Location(
            id: id,
            latitude: latitude,
            longitude: longitude,
            address: address,
            placeId: placeId,
            name: name
        )
    }
}

enum AddressPickerType {
    case pickup
    case destination
}

enum AddressType: String, Codable, CaseIterable {
    case home = "home"
    case work = "work"
    case airport = "airport"
    case hotel = "hotel"
    case restaurant = "restaurant"
    case general = "general"
    
    var displayName: String {
        switch self {
        case .home: return "Home"
        case .work: return "Work"
        case .airport: return "Airport"
        case .hotel: return "Hotel"
        case .restaurant: return "Restaurant"
        case .general: return "General"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .work: return "building.2.fill"
        case .airport: return "airplane"
        case .hotel: return "bed.double.fill"
        case .restaurant: return "fork.knife"
        case .general: return "location.fill"
        }
    }
}