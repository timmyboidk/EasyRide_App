import Foundation
import SwiftUI

struct Order: Codable, Identifiable {
    let id: String
    let serviceType: ServiceType
    var status: OrderStatus
    let pickupLocation: Location
    let destination: Location?
    let estimatedPrice: Double
    var actualPrice: Double?
    var driver: Driver?
    let createdAt: Date
    let scheduledTime: Date?
    var completedAt: Date?
    let passengerCount: Int
    let luggageCount: Int
    let notes: String?
    let specialInstructions: String?
    var stops: [TripStop]
    
    // Charter-specific fields
    let tripMode: TripMode
    let duration: TimeInterval? // For charter services
    
    // Value-added services
    var airportPickup: Bool
    var airportPickupName: String?
    var checkinAssistance: Bool
    var tripSharing: Bool
    var childSeat: Bool
    var interpreter: Bool
    var elderlyCompanion: Bool
    
    init(
        id: String = UUID().uuidString,
        serviceType: ServiceType,
        status: OrderStatus = .pending,
        pickupLocation: Location,
        destination: Location? = nil,
        estimatedPrice: Double,
        actualPrice: Double? = nil,
        driver: Driver? = nil,
        createdAt: Date = Date(),
        scheduledTime: Date? = nil,
        completedAt: Date? = nil,
        passengerCount: Int = 1,
        luggageCount: Int = 0,
        notes: String? = nil,
        specialInstructions: String? = nil,
        stops: [TripStop] = [],
        tripMode: TripMode = TripMode.freeRoute,
        duration: TimeInterval? = nil,
        airportPickup: Bool = false,
        airportPickupName: String? = nil,
        checkinAssistance: Bool = false,
        tripSharing: Bool = false,
        childSeat: Bool = false,
        interpreter: Bool = false,
        elderlyCompanion: Bool = false
    ) {
        self.id = id
        self.serviceType = serviceType
        self.status = status
        self.pickupLocation = pickupLocation
        self.destination = destination
        self.estimatedPrice = estimatedPrice
        self.actualPrice = actualPrice
        self.driver = driver
        self.createdAt = createdAt
        self.scheduledTime = scheduledTime
        self.completedAt = completedAt
        self.passengerCount = passengerCount
        self.luggageCount = luggageCount
        self.notes = notes
        self.specialInstructions = specialInstructions
        self.stops = stops
        self.tripMode = tripMode
        self.duration = duration
        self.airportPickup = airportPickup
        self.airportPickupName = airportPickupName
        self.checkinAssistance = checkinAssistance
        self.tripSharing = tripSharing
        self.childSeat = childSeat
        self.interpreter = interpreter
        self.elderlyCompanion = elderlyCompanion
    }
    
    // MARK: - Computed Properties
    
    var isCharterService: Bool {
        return serviceType == .charter
    }
    
    var hasValueAddedServices: Bool {
        return airportPickup || checkinAssistance || tripSharing || childSeat || interpreter || elderlyCompanion
    }
    
    var valueAddedServicesCount: Int {
        var count = 0
        if airportPickup { count += 1 }
        if checkinAssistance { count += 1 }
        if tripSharing { count += 1 }
        if childSeat { count += 1 }
        if interpreter { count += 1 }
        if elderlyCompanion { count += 1 }
        return count
    }
    
    var durationFormatted: String {
        guard let duration = duration else { return "未指定" }
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if minutes == 0 {
            return "\(hours)小时"
        } else {
            return "\(hours)小时\(minutes)分钟"
        }
    }
    
    var vehicleModel: String {
        return driver?.vehicleInfo.displayName ?? "待分配"
    }
    static var sample: Order {
        Order(
            serviceType: ServiceType.charter,
            pickupLocation: Location(latitude: 39.9042, longitude: 116.4074, address: "北京市中心"),
            destination: Location(latitude: 40.0799, longitude: 116.6031, address: "北京首都国际机场"),
            estimatedPrice: 500.0,
            driver: Driver(name: "王师傅", phoneNumber: "138-0013-8000", vehicleInfo: VehicleInfo(make: "奔驰", model: "V级", year: 2023, color: "黑色", licensePlate: "京A12345", vehicleType: VehicleType.van)),
            passengerCount: 4,
            luggageCount: 2,
            notes: "市区游览+晚上机场接送",
            specialInstructions: "需要中文司机",
            tripMode: TripMode.freeRoute,
            duration: 8 * 3600, // 8 hours
            airportPickup: true,
            airportPickupName: "张先生",
            checkinAssistance: true,
            tripSharing: true
        )
    }
}

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case matching = "matching"
    case matched = "matched"
    case driverEnRoute = "driver_en_route"
    case arrived = "arrived"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "待处理"
        case .matching: return "正在匹配司机"
        case .matched: return "司机已分配"
        case .driverEnRoute: return "司机正在前往"
        case .arrived: return "司机已到达"
        case .inProgress: return "行程进行中"
        case .completed: return "已完成"
        case .cancelled: return "已取消"
        }
    }
    
    var isActive: Bool {
        switch self {
        case .pending, .matching, .matched, .driverEnRoute, .arrived, .inProgress:
            return true
        case .completed, .cancelled:
            return false
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .matching: return "magnifyingglass"
        case .matched: return "checkmark.circle.fill"
        case .driverEnRoute: return "car.fill"
        case .arrived: return "location.fill"
        case .inProgress: return "play.circle.fill"
        case .completed: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .matching: return .blue
        case .matched: return .green
        case .driverEnRoute: return .blue
        case .arrived: return .green
        case .inProgress: return .purple
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}
