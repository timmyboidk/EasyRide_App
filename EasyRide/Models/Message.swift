import Foundation

public struct Message: Codable, Identifiable {
    public let id: String
    public let orderId: String
    public let senderId: String
    public let senderType: SenderType
    public let content: String
    public let type: MessageType
    public let timestamp: Date
    public var isRead: Bool
    public let location: Location?
    
    public init(
        id: String = UUID().uuidString,
        orderId: String,
        senderId: String,
        senderType: SenderType,
        content: String,
        type: MessageType = .text,
        timestamp: Date = Date(),
        isRead: Bool = false,
        location: Location? = nil
    ) {
        self.id = id
        self.orderId = orderId
        self.senderId = senderId
        self.senderType = senderType
        self.content = content
        self.type = type
        self.timestamp = timestamp
        self.isRead = isRead
        self.location = location
    }
    
    public var isFromCurrentUser: Bool {
        return senderType == .passenger
    }
    
    public var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    public var displayContent: String {
        switch type {
        case .text:
            return content
        case .location:
            return location?.address ?? "📍 Location shared"
        case .image:
            return "📷 Image"
        case .system:
            return content
        }
    }
}

public enum SenderType: String, Codable {
    case passenger = "passenger"
    case driver = "driver"
    case system = "system"
    
    public var displayName: String {
        switch self {
        case .passenger: return "You"
        case .driver: return "Driver"
        case .system: return "System"
        }
    }
}
// Preset message phrases for quick communication
public struct PresetMessage {
    public let id: String
    public let text: String
    public let category: PresetMessageCategory
    
    public init(id: String = UUID().uuidString, text: String, category: PresetMessageCategory) {
        self.id = id
        self.text = text
        self.category = category
    }
}

public enum PresetMessageCategory: String, CaseIterable {
    case arrival = "arrival"
    case location = "location"
    case delay = "delay"
    case general = "general"
    
    public var displayName: String {
        switch self {
        case .arrival: return "Arrival"
        case .location: return "Location"
        case .delay: return "Delay"
        case .general: return "General"
        }
    }
}

// Common preset messages
extension PresetMessage {
    static let commonMessages: [PresetMessage] = [
        // Arrival messages
        PresetMessage(text: "I'm here", category: .arrival),
        PresetMessage(text: "I'll be there in 2 minutes", category: .arrival),
        PresetMessage(text: "I'm waiting outside", category: .arrival),
        
        // Location messages
        PresetMessage(text: "I'm at the main entrance", category: .location),
        PresetMessage(text: "I'm in the parking lot", category: .location),
        PresetMessage(text: "I can't find you", category: .location),
        
        // Delay messages
        PresetMessage(text: "Running 5 minutes late", category: .delay),
        PresetMessage(text: "Traffic is heavy", category: .delay),
        PresetMessage(text: "Almost there", category: .delay),
        
        // General messages
        PresetMessage(text: "Thank you", category: .general),
        PresetMessage(text: "Please wait", category: .general),
        PresetMessage(text: "On my way", category: .general)
    ]
    
    public static func messages(for category: PresetMessageCategory) -> [PresetMessage] {
        return commonMessages.filter { $0.category == category }
    }
}
