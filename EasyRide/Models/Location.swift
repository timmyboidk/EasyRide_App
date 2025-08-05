import Foundation
import CoreLocation

struct Location: Codable, Identifiable, Equatable {
    var id: String
    var latitude: Double
    var longitude: Double
    var address: String
    var placeId: String?
    var name: String?
    
    init(
        id: String = UUID().uuidString,
        latitude: Double,
        longitude: Double,
        address: String,
        placeId: String? = nil,
        name: String? = nil
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.placeId = placeId
        self.name = name
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func distance(to other: Location) -> CLLocationDistance {
        return clLocation.distance(from: other.clLocation)
    }
}
