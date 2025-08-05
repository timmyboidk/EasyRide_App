import Foundation

enum ServiceType: String, Codable, CaseIterable, Identifiable {
    case halfDay = "half_day"
    case fullDay = "full_day"
    case multiDay = "multi_day"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .halfDay: return NSLocalizedString("half_day_charter", comment: "")
        case .fullDay: return NSLocalizedString("full_day_charter", comment: "")
        case .multiDay: return NSLocalizedString("multi_day_charter", comment: "")
        }
    }
    
    var icon: String {
        switch self {
        case .halfDay: return "clock.fill"
        case .fullDay: return "sun.max.fill"
        case .multiDay: return "calendar.badge.plus"
        }
    }
    
    var description: String {
        switch self {
        case .halfDay: return NSLocalizedString("half_day_desc", comment: "")
        case .fullDay: return NSLocalizedString("full_day_desc", comment: "")
        case .multiDay: return NSLocalizedString("multi_day_desc", comment: "")
        }
    }
    
    var passengerCount: String {
        switch self {
        case .halfDay: return "1-4人"
        case .fullDay: return "1-6人"
        case .multiDay: return "1-8人"
        }
    }
    
    var scenarios: [String] {
        return [
            NSLocalizedString("business_scenario", comment: ""),
            NSLocalizedString("travel_scenario", comment: ""),
            NSLocalizedString("airport_scenario", comment: "")
        ]
    }
    
    /// Accessibility-friendly description for screen readers
    var accessibilityDescription: String {
        switch self {
        case .halfDay: return "半日包车服务，适合4小时以内的短途出行"
        case .fullDay: return "全日包车服务，适合10小时以内的全天出行"
        case .multiDay: return "多日包车服务，适合跨日长途旅行"
        }
    }
    
    var basePrice: Double {
        switch self {
        case .halfDay: return 200.0
        case .fullDay: return 500.0
        case .multiDay: return 800.0 // per day
        }
    }
}