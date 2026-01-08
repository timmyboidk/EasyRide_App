import Foundation
import CoreLocation

public struct Location: Codable, Identifiable, Equatable {
    public var id: String
    public var latitude: Double
    public var longitude: Double
    public var address: String
    public var placeId: String?
    public var name: String?
    
    public init(
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
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    public func distance(to other: Location) -> CLLocationDistance {
        return clLocation.distance(from: other.clLocation)
    }
}
