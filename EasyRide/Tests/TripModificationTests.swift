import Testing
import Foundation
@testable import EasyRide

@Test("Trip modification functionality")
func testTripModification() async throws {
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
    
    // Mock responses
    mockAPIService.mockResponses[.getMessages(orderId: testOrder.id, page: 1, limit: 50)] = MessagesResponse(
        messages: [],
        hasMore: false,
        unreadCount: 0
    )
    
    mockAPIService.mockResponses[.calculateFareAdjustment(orderId: testOrder.id, modification: TripModificationRequest(
        type: .changeDestination,
        newDestination: Location(latitude: 37.6213, longitude: -122.3790, address: "Oakland Airport"),
        additionalStops: [],
        notes: nil
    ))] = FareAdjustmentResponse(
        adjustment: 15.0,
        newTotalFare: 60.0,
        breakdown: [
            PriceBreakdownItem(name: "Base Fare", amount: 45.0, type: "base_fare"),
            PriceBreakdownItem(name: "Destination Change", amount: 15.0, type: "service_fee")
        ]
    )
    
    await viewModel.loadOrder(testOrder)
    
    // Test trip modification request
    let modificationRequest = TripModificationRequest(
        type: .changeDestination,
        newDestination: Location(latitude: 37.6213, longitude: -122.3790, address: "Oakland Airport"),
        additionalStops: [],
        notes: nil
    )
    
    await viewModel.requestTripModification(modificationRequest)
    
    #expect(viewModel.modificationRequest != nil)
    #expect(viewModel.fareAdjustment == 15.0)
    #expect(viewModel.driverConfirmationStatus == .pending)
    #expect(viewModel.formattedFareAdjustment == "+$15.00")
    
    // Test that a system message was added
    #expect(viewModel.messages.last?.type == .system)
    #expect(viewModel.messages.last?.content.contains("Trip modification requested"))
}

@Test("Driver confirmation status tracking")
func testDriverConfirmationStatus() async throws {
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
    
    // Test initial status
    #expect(viewModel.driverConfirmationStatus == .pending)
    #expect(viewModel.driverConfirmationStatus.displayName == "Waiting for driver confirmation")
    
    // Test status changes
    viewModel.driverConfirmationStatus = .accepted
    #expect(viewModel.driverConfirmationStatus.displayName == "Driver accepted")
    
    viewModel.driverConfirmationStatus = .declined
    #expect(viewModel.driverConfirmationStatus.displayName == "Driver declined")
}

@Test("Real-time fare adjustment display")
func testFareAdjustmentDisplay() async throws {
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
    
    // Test positive fare adjustment
    viewModel.fareAdjustment = 15.0
    #expect(viewModel.formattedFareAdjustment == "+$15.00")
    
    // Test negative fare adjustment (discount)
    viewModel.fareAdjustment = -5.0
    #expect(viewModel.formattedFareAdjustment == "-$5.00")
    
    // Test zero adjustment
    viewModel.fareAdjustment = 0.0
    #expect(viewModel.formattedFareAdjustment == "$0.00")
}

@Test("Trip modification cancellation")
func testTripModificationCancellation() async throws {
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
    
    // Set up a modification request
    let modificationRequest = TripModificationRequest(
        type: .changeDestination,
        newDestination: Location(latitude: 37.6213, longitude: -122.3790, address: "Oakland Airport"),
        additionalStops: [],
        notes: nil
    )
    
    viewModel.modificationRequest = modificationRequest
    viewModel.fareAdjustment = 15.0
    viewModel.driverConfirmationStatus = .accepted
    viewModel.showingTripModification = true
    
    // Test cancellation
    viewModel.cancelTripModification()
    
    #expect(viewModel.modificationRequest == nil)
    #expect(viewModel.fareAdjustment == 0.0)
    #expect(viewModel.driverConfirmationStatus == .pending)
    #expect(viewModel.showingTripModification == false)
}

// MARK: - Supporting Models for Testing

extension TripModificationRequest: Equatable {
    public static func == (lhs: TripModificationRequest, rhs: TripModificationRequest) -> Bool {
        return lhs.type == rhs.type &&
               lhs.newDestination?.address == rhs.newDestination?.address &&
               lhs.additionalStops.count == rhs.additionalStops.count &&
               lhs.notes == rhs.notes
    }
}

extension PriceBreakdownItem: Equatable {
    public static func == (lhs: PriceBreakdownItem, rhs: PriceBreakdownItem) -> Bool {
        return lhs.name == rhs.name &&
               lhs.amount == rhs.amount &&
               lhs.type == rhs.type
    }
}