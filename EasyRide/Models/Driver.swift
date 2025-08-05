import Foundation

struct Driver: Codable, Identifiable {
    let id: String
    let name: String
    let phoneNumber: String
    let profileImage: String?
    let rating: Double
    let totalTrips: Int
    let vehicleInfo: VehicleInfo
    let currentLocation: Location?
    let isOnline: Bool
    var estimatedArrival: Date?
    
    init(
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
    
    var ratingFormatted: String {
        return String(format: "%.1f", rating)
    }
    
    var isHighRated: Bool {
        return rating >= 4.5
    }
}

struct VehicleInfo: Codable {
    let make: String
    let model: String
    let year: Int
    let color: String
    let licensePlate: String
    let vehicleType: VehicleType
    
    var displayName: String {
        return "\(year) \(make) \(model)"
    }
    
    var fullDescription: String {
        return "\(color) \(displayName) (\(licensePlate))"
    }
}

enum VehicleType: String, Codable, CaseIterable {
    case sedan = "sedan"
    case suv = "suv"
    case van = "van"
    case luxury = "luxury"
    case electric = "electric"
    
    var displayName: String {
        switch self {
        case .sedan: return "轿车"
        case .suv: return "SUV"
        case .van: return "商务车"
        case .luxury: return "豪华车"
        case .electric: return "电动车"
        }
    }
    
    var capacity: Int {
        switch self {
        case .sedan: return 4
        case .suv: return 6
        case .van: return 8
        case .luxury: return 4
        case .electric: return 4
        }
    }
    
    var icon: String {
        switch self {
        case .sedan: return "car.fill"
        case .suv: return "car.2.fill"
        case .van: return "bus.fill"
        case .luxury: return "car.fill"
        case .electric: return "bolt.car.fill"
        }
    }
}