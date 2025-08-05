import Foundation

struct ServiceOption: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let isSelected: Bool
    let category: ServiceOptionCategory
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        price: Double,
        isSelected: Bool = false,
        category: ServiceOptionCategory
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.isSelected = isSelected
        self.category = category
    }
}

enum ServiceOptionCategory: String, Codable, CaseIterable {
    case comfort = "comfort"
    case convenience = "convenience"
    case safety = "safety"
    case premium = "premium"
    
    var displayName: String {
        switch self {
        case .comfort: return "Comfort"
        case .convenience: return "Convenience"
        case .safety: return "Safety"
        case .premium: return "Premium"
        }
    }
}

// Common service options
extension ServiceOption {
    static let childSeat = ServiceOption(
        name: "Child Seat",
        description: "Safe child seat for passengers under 8 years old",
        price: 5.0,
        category: .safety
    )
    
    static let wifiHotspot = ServiceOption(
        name: "WiFi Hotspot",
        description: "High-speed internet access during your trip",
        price: 3.0,
        category: .convenience
    )
    
    static let premiumVehicle = ServiceOption(
        name: "Premium Vehicle",
        description: "Upgrade to a luxury vehicle",
        price: 15.0,
        category: .premium
    )
    
    static let extraLuggage = ServiceOption(
        name: "Extra Luggage",
        description: "Additional luggage space for large items",
        price: 8.0,
        category: .convenience
    )
    
    static let petFriendly = ServiceOption(
        name: "Pet Friendly",
        description: "Vehicle equipped for traveling with pets",
        price: 10.0,
        category: .comfort
    )
    
    static let wheelchairAccessible = ServiceOption(
        name: "Wheelchair Accessible",
        description: "Vehicle with wheelchair accessibility features",
        price: 0.0,
        category: .safety
    )
}