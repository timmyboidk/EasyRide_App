import Foundation

public enum ServiceType: String, Codable, CaseIterable, Identifiable {
    case airport = "airport"
    case longDistance = "long_distance"
    case charter = "charter"
    case carpooling = "carpooling"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .airport: return NSLocalizedString("Airport_Pickup", comment: "")
        case .longDistance: return NSLocalizedString("Long_Distance", comment: "")
        case .charter: return NSLocalizedString("Charter", comment: "")
        case .carpooling: return NSLocalizedString("Carpooling", comment: "")
        }
    }
    
    public var icon: String {
        switch self {
        case .airport: return "airplane"
        case .longDistance: return "road.lanes"
        case .charter: return "clock.fill" // Was specific to charter durations, using generic clock or car
        case .carpooling: return "person.2.fill"
        }
    }
    
    public var description: String {
        switch self {
        case .airport: return NSLocalizedString("Airport_Desc", comment: "Airport transfer service")
        case .longDistance: return NSLocalizedString("Long_Distance_Desc", comment: "Inter-city travel")
        case .charter: return NSLocalizedString("Charter_Desc", comment: "Hourly or daily booking")
        case .carpooling: return NSLocalizedString("Carpool_Desc", comment: "Shared ride")
        }
    }
    
    public var passengerCount: String {
        switch self {
        case .airport: return "1-6人"
        case .longDistance: return "1-6人"
        case .charter: return "1-8人"
        case .carpooling: return "1-4人"
        }
    }
    
    public var scenarios: [String] {
        switch self {
        case .airport:
            return [NSLocalizedString("Airport_Scenario", comment: "")]
        case .longDistance:
            return [NSLocalizedString("Travel_Scenario", comment: "")]
        case .charter:
            return [NSLocalizedString("Business_Scenario", comment: ""), NSLocalizedString("Travel_Scenario", comment: "")]
        case .carpooling:
            return [NSLocalizedString("Commute_Scenario", comment: "")]
        }
    }
    
    /// Accessibility-friendly description for screen readers
    public var accessibilityDescription: String {
        switch self {
        case .airport: return "Airport transfer service"
        case .longDistance: return "Long distance travel service"
        case .charter: return "Charter service by hour or day"
        case .carpooling: return "Carpooling shared ride service"
        }
    }
    
    public var basePrice: Double {
        switch self {
        case .airport: return 200.0
        case .longDistance: return 500.0
        case .charter: return 800.0
        case .carpooling: return 50.0
        }
    }
}