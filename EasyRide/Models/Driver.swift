import Foundation

public struct Driver: Codable, Identifiable {
    public let id: String
    public let name: String
    public let phoneNumber: String
    public let profileImage: String?
    public let rating: Double
    public let totalTrips: Int
    public let vehicleInfo: VehicleInfo
    public let currentLocation: Location?
    public let isOnline: Bool
    public var estimatedArrival: Date?
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        phoneNumber: String,
        profileImage: String? = nil,
        rating: Double = 5.0,
        totalTrips: Int = 0,
        vehicleInfo: VehicleInfo,
        currentLocation: Location? = nil,
        isOnline: Bool = false,
        estimatedArrival: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.profileImage = profileImage
        self.rating = rating
        self.totalTrips = totalTrips
        self.vehicleInfo = vehicleInfo
        self.currentLocation = currentLocation
        self.isOnline = isOnline
        self.estimatedArrival = estimatedArrival
    }
    
    public var ratingFormatted: String {
        return String(format: "%.1f", rating)
    }
    
    public var isHighRated: Bool {
        return rating >= 4.5
    }
}

public struct VehicleInfo: Codable {
    public let make: String
    public let model: String
    public let year: Int
    public let color: String
    public let licensePlate: String
    public let vehicleType: VehicleType
    
    public var displayName: String {
        return "\(year) \(make) \(model)"
    }
    
    public var fullDescription: String {
        return "\(color) \(displayName) (\(licensePlate))"
    }
}

public enum VehicleType: String, Codable, CaseIterable {
    case sedan = "sedan"
    case suv = "suv"
    case van = "van"
    case luxury = "luxury"
    case electric = "electric"
    
    public var displayName: String {
        switch self {
        case .sedan: return "轿车"
        case .suv: return "SUV"
        case .van: return "商务车"
        case .luxury: return "豪华车"
        case .electric: return "电动车"
        }
    }
    
    public var capacity: Int {
        switch self {
        case .sedan: return 4
        case .suv: return 6
        case .van: return 8
        case .luxury: return 4
        case .electric: return 4
        }
    }
    
    public var icon: String {
        switch self {
        case .sedan: return "car.fill"
        case .suv: return "car.2.fill"
        case .van: return "bus.fill"
        case .luxury: return "car.fill"
        case .electric: return "bolt.car.fill"
        }
    }
}