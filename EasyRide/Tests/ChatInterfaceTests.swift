import Testing
import Foundation
@testable import EasyRide

@Test("Chat interface functionality")
func testChatInterface() async throws {
    // Create mock API service
    let mockAPIService = MockAPIService()
    
    // Create test order
    let testOrder = Order(
        serviceType: .airport,
        pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "San Francisco, CA"),
        destination: Location(latitude: 37.6213, longitude: -122.3790, address: "SFO Airport"),
        estimatedPrice: 45.0,
        driver: Driver(
            name: "John Smith",
            phoneNumber: "+1234567890",
            rating: 4.8,
            totalTrips: 1250,
            vehicleInfo: VehicleInfo(
                make: "Toyota",
                model: "Camry",
                year: 2022,
                color: "Silver",
                licensePlate: "ABC123",
                vehicleType: .sedan
            )
        )
    )
    
    // Create view model
    let viewModel = OrderDetailViewModel(apiService: mockAPIService)
    
    // Mock messages response
    let mockMessages = [
        Message(
            orderId: testOrder.id,
            senderId: "driver_123",
            senderType: .driver,
            content: "I'm on my way to pick you up",
            timestamp: Date().addingTimeInterval(-300)
        ),
        Message(
            orderId: testOrder.id,
            senderId: "passenger_456",
            senderType: .passenger,
            content: "Thank you, I'll be waiting outside",
            timestamp: Date().addingTimeInterval(-240)
        )
    ]
    
    mockAPIService.mockResponses[.getMessages(orderId: testOrder.id, page: 1, limit: 50)] = MessagesResponse(
        messages: mockMessages,
        hasMore: false,
        unreadCount: 1
    )
    
    // Test loading order and messages
    await viewModel.loadOrder(testOrder)
    
    #expect(viewModel.currentOrder?.id == testOrder.id)
    #expect(viewModel.messages.count == 2)
    #expect(viewModel.unreadMessageCount == 1)
    
    // Test sending message
    let testMessage = "I'm here now"
    await viewModel.sendMessage(testMessage)
    
    #expect(viewModel.messages.last?.content == testMessage)
    #expect(viewModel.messages.last?.senderType == .passenger)
    #expect(viewModel.messageText.isEmpty)
}

@Test("Preset messages functionality")
func testPresetMessages() async throws {
    let mockAPIService = MockAPIService()
    let viewModel = OrderDetailViewModel(apiService: mockAPIService)
    
    let testOrder = Order(
        serviceType: .airport,
        pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "San Francisco, CA"),
        destination: Location(latitude: 37.6213, longitude: -122.3790, address: "SFO Airport"),
        estimatedPrice: 45.0
    )
    
    mockAPIService.mockResponses[.getMessages(orderId: testOrder.id, page: 1, limit: 50)] = MessagesResponse(
        messages: [],
        hasMore: false,
        unreadCount: 0
    )
    
    await viewModel.loadOrder(testOrder)
    
    // Test preset message categories
    let arrivalMessages = PresetMessage.messages(for: .arrival)
    #expect(arrivalMessages.count > 0)
    #expect(arrivalMessages.first?.category == .arrival)
    
    let locationMessages = PresetMessage.messages(for: .location)
    #expect(locationMessages.count > 0)
    #expect(locationMessages.first?.category == .location)
    
    // Test sending preset message
    let presetMessage = PresetMessage(text: "I'm here", category: .arrival)
    await viewModel.sendPresetMessage(presetMessage)
    
    #expect(viewModel.messages.last?.content == "I'm here")
    #expect(viewModel.showingPresetMessages == false)
}

@Test("Location sharing functionality")
func testLocationSharing() async throws {
    let mockAPIService = MockAPIService()
    let viewModel = OrderDetailViewModel(apiService: mockAPIService)
    
    let testOrder = Order(
        serviceType: .airport,
        pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "San Francisco, CA"),
        destination: Location(latitude: 37.6213, longitude: -122.3790, address: "SFO Airport"),
        estimatedPrice: 45.0
    )
    
    mockAPIService.mockResponses[.getMessages(orderId: testOrder.id, page: 1, limit: 50)] = MessagesResponse(
        messages: [],
        hasMore: false,
        unreadCount: 0
    )
    
    await viewModel.loadOrder(testOrder)
    
    // Set current location
    let currentLocation = Location(latitude: 37.7849, longitude: -122.4094, address: "Union Square, San Francisco")
    viewModel.updateCurrentLocation(currentLocation)
    viewModel.enableLocationSharing()
    
    #expect(viewModel.isLocationSharingEnabled == true)
    #expect(viewModel.currentLocation?.address == "Union Square, San Francisco")
    
    // Test sharing location
    await viewModel.shareLocation()
    
    #expect(viewModel.messages.last?.type == .location)
    #expect(viewModel.messages.last?.location?.address == "Union Square, San Francisco")
}

@Test("Typing indicator functionality")
func testTypingIndicator() async throws {
    let mockAPIService = MockAPIService()
    let viewModel = OrderDetailViewModel(apiService: mockAPIService)
    
    let testOrder = Order(
        serviceType: .airport,
        pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "San Francisco, CA"),
        destination: Location(latitude: 37.6213, longitude: -122.3790, address: "SFO Airport"),
        estimatedPrice: 45.0
    )
    
    mockAPIService.mockResponses[.getMessages(orderId: testOrder.id, page: 1, limit: 50)] = MessagesResponse(
        messages: [],
        hasMore: false,
        unreadCount: 0
    )
    
    await viewModel.loadOrder(testOrder)
    
    // Test typing indicator
    #expect(viewModel.isTyping == false)
    
    viewModel.messageText = "Hello"
    viewModel.handleMessageTextChange()
    
    #expect(viewModel.isTyping == true)
    
    // Test stopping typing indicator
    viewModel.messageText = ""
    viewModel.handleMessageTextChange()
    
    #expect(viewModel.isTyping == false)
}

@Test("Unread message badge system")
func testUnreadMessageBadge() async throws {
    let mockAPIService = MockAPIService()
    let viewModel = OrderDetailViewModel(apiService: mockAPIService)
    
    let testOrder = Order(
        serviceType: .airport,
        pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "San Francisco, CA"),
        destination: Location(latitude: 37.6213, longitude: -122.3790, address: "SFO Airport"),
        estimatedPrice: 45.0
    )
    
    // Mock messages with unread driver messages
    let mockMessages = [
        Message(
            orderId: testOrder.id,
            senderId: "driver_123",
            senderType: .driver,
            content: "I'm on my way",
            isRead: false
        ),
        Message(
            orderId: testOrder.id,
            senderId: "driver_123",
            senderType: .driver,
            content: "Almost there",
            isRead: false
        ),
        Message(
            orderId: testOrder.id,
            senderId: "passenger_456",
            senderType: .passenger,
            content: "Thank you",
            isRead: true
        )
    ]
    
    mockAPIService.mockResponses[.getMessages(orderId: testOrder.id, page: 1, limit: 50)] = MessagesResponse(
        messages: mockMessages,
        hasMore: false,
        unreadCount: 2
    )
    
    await viewModel.loadOrder(testOrder)
    
    #expect(viewModel.unreadMessageCount == 2)
    #expect(viewModel.hasUnreadMessages == true)
    
    // Test marking messages as read
    let unreadMessageIds = mockMessages.filter { !$0.isRead && !$0.isFromCurrentUser }.map { $0.id }
    await viewModel.markMessagesAsRead(messageIds: unreadMessageIds)
    
    #expect(viewModel.unreadMessageCount == 0)
    #expect(viewModel.hasUnreadMessages == false)
}

// MARK: - Mock API Service for Testing

class MockAPIService: APIService {
    var mockResponses: [APIEndpoint: Any] = [:]
    
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        if let response = mockResponses[endpoint] as? T {
            return response
        }
        throw EasyRideError.networkError("Mock response not found")
    }
    
    func requestWithoutResponse(_ endpoint: APIEndpoint) async throws {
        // Mock implementation - just return success
    }
    
    func uploadImage(_ endpoint: APIEndpoint, imageData: Data) async throws -> String {
        return "https://example.com/mock-image.jpg"
    }
}

// MARK: - APIEndpoint Equatable Extension for Testing

extension APIEndpoint: Equatable {
    static func == (lhs: APIEndpoint, rhs: APIEndpoint) -> Bool {
        switch (lhs, rhs) {
        case (.getMessages(let lhsOrderId, let lhsPage, let lhsLimit), .getMessages(let rhsOrderId, let rhsPage, let rhsLimit)):
            return lhsOrderId == rhsOrderId && lhsPage == rhsPage && lhsLimit == rhsLimit
        case (.sendMessage(let lhsOrderId, let lhsMessage, let lhsType), .sendMessage(let rhsOrderId, let rhsMessage, let rhsType)):
            return lhsOrderId == rhsOrderId && lhsMessage == rhsMessage && lhsType == rhsType
        case (.markMessagesAsRead(let lhsOrderId, let lhsIds), .markMessagesAsRead(let rhsOrderId, let rhsIds)):
            return lhsOrderId == rhsOrderId && lhsIds == rhsIds
        case (.sendTypingIndicator(let lhsOrderId, let lhsTyping), .sendTypingIndicator(let rhsOrderId, let rhsTyping)):
            return lhsOrderId == rhsOrderId && lhsTyping == rhsTyping
        default:
            return false
        }
    }
}

extension APIEndpoint: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(httpMethod.rawValue)
    }
}