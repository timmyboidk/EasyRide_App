import XCTest
import Foundation
@testable import EasyRide

class OrderTrackingViewModelTests: XCTestCase {
    
    // MARK: - Test Setup
    
    func createTestViewModel() -> (OrderTrackingViewModel, MockAPIService) {
        let mockAPIService = MockAPIService()
        let viewModel = OrderTrackingViewModel(apiService: mockAPIService)
        return (viewModel, mockAPIService)
    }
    
    // MARK: - Order Tracking Tests
    
    func testStartTrackingSuccess() async throws {
        let (viewModel, mockAPIService) = createTestViewModel()
        
        // Setup mock response
        let mockOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .matched,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0,
            driver: Driver(
                id: "driver-123",
                name: "John Driver",
                phoneNumber: "+1234567890",
                rating: 4.8,
                profileImage: "https://example.com/driver.jpg",
                carModel: "Tesla Model Y",
                carColor: "White",
                licensePlate: "ABC123",
                estimatedArrival: Date().addingTimeInterval(300)
            )
        )
        mockAPIService.setMockResponse(mockOrder, for: .getOrder(orderId: "test-order-123"))
        
        // Test tracking start
        await viewModel.startTracking(orderId: "test-order-123")
        
        // Verify results
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNotNil(viewModel.currentOrder)
        XCTAssertEqual(viewModel.currentOrder?.id, "test-order-123")
        XCTAssertTrue(viewModel.isTrackingActive)
        XCTAssertFalse(viewModel.isMatching)
    }
    
    func testStartTrackingWithMatchingStatus() async throws {
        let (viewModel, mockAPIService) = createTestViewModel()
        
        // Setup mock response with matching status
        let mockOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .matching,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0
        )
        mockAPIService.setMockResponse(mockOrder, for: .getOrder(orderId: "test-order-123"))
        
        // Test tracking start
        await viewModel.startTracking(orderId: "test-order-123")
        
        // Verify results
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNotNil(viewModel.currentOrder)
        XCTAssertEqual(viewModel.currentOrder?.id, "test-order-123")
        XCTAssertTrue(viewModel.isMatching)
        XCTAssertFalse(viewModel.isTrackingActive)
    }
    
    func testStartTrackingWithCompletedStatus() async throws {
        let (viewModel, mockAPIService) = createTestViewModel()
        
        // Setup mock response with completed status
        let mockOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .completed,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0
        )
        mockAPIService.setMockResponse(mockOrder, for: .getOrder(orderId: "test-order-123"))
        
        // Test tracking start
        await viewModel.startTracking(orderId: "test-order-123")
        
        // Verify results
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNotNil(viewModel.currentOrder)
        XCTAssertEqual(viewModel.currentOrder?.id, "test-order-123")
        XCTAssertFalse(viewModel.isMatching)
        XCTAssertFalse(viewModel.isTrackingActive)
    }
    
    func testStartTrackingError() async throws {
        let (viewModel, mockAPIService) = createTestViewModel()
        
        // Setup mock error
        mockAPIService.setMockError(EasyRideError.orderNotFound, for: .getOrder(orderId: "nonexistent-order"))
        
        // Test tracking start with error
        await viewModel.startTracking(orderId: "nonexistent-order")
        
        // Verify error handling
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.currentOrder)
        XCTAssertFalse(viewModel.isTrackingActive)
        XCTAssertFalse(viewModel.isMatching)
    }
    
    func testStopTracking() async throws {
        let (viewModel, mockAPIService) = createTestViewModel()
        
        // Setup mock response
        let mockOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .matched,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0
        )
        mockAPIService.setMockResponse(mockOrder, for: .getOrder(orderId: "test-order-123"))
        
        // Start tracking first
        await viewModel.startTracking(orderId: "test-order-123")
        XCTAssertTrue(viewModel.isTrackingActive)
        
        // Test stop tracking
        await viewModel.stopTracking()
        
        // Verify results
        XCTAssertFalse(viewModel.isTrackingActive)
        XCTAssertFalse(viewModel.isMatching)
        XCTAssertEqual(viewModel.matchingProgress, 0.0)
    }
    
    // MARK: - Order Status Update Tests
    
    func testRefreshOrderStatus() async throws {
        let (viewModel, mockAPIService) = createTestViewModel()
        
        // Setup initial order
        let initialOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .matched,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0
        )
        mockAPIService.setMockResponse(initialOrder, for: .getOrder(orderId: "test-order-123"))
        
        // Start tracking
        await viewModel.startTracking(orderId: "test-order-123")
        
        // Setup updated order with different status
        let updatedOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .driverEnRoute,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0,
            driver: Driver(
                id: "driver-123",
                name: "John Driver",
                phoneNumber: "+1234567890",
                rating: 4.8,
                profileImage: "https://example.com/driver.jpg",
                carModel: "Tesla Model Y",
                carColor: "White",
                licensePlate: "ABC123",
                estimatedArrival: Date().addingTimeInterval(300)
            )
        )
        mockAPIService.setMockResponse(updatedOrder, for: .getOrder(orderId: "test-order-123"))
        
        // Test refresh order status
        await viewModel.refreshOrderStatus()
        
        // Verify results
        XCTAssertEqual(viewModel.currentOrder?.status, .driverEnRoute)
        XCTAssertNotNil(viewModel.currentOrder?.driver)
        XCTAssertTrue(viewModel.isTrackingActive)
    }
    
    func testRefreshOrderStatusWithError() async throws {
        let (viewModel, mockAPIService) = createTestViewModel()
        
        // Setup initial order
        let initialOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .matched,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0
        )
        mockAPIService.setMockResponse(initialOrder, for: .getOrder(orderId: "test-order-123"))
        
        // Start tracking
        await viewModel.startTracking(orderId: "test-order-123")
        
        // Setup error for refresh
        mockAPIService.setMockError(EasyRideError.networkError("Connection failed"), for: .getOrder(orderId: "test-order-123"))
        
        // Test refresh order status with error
        await viewModel.refreshOrderStatus()
        
        // Verify error handling
        XCTAssertNotNil(viewModel.errorMessage)
        // Original order should still be there
        XCTAssertEqual(viewModel.currentOrder?.status, .matched)
    }
    
    // MARK: - Driver Location Update Tests
    
    func testUpdateDriverLocation() async throws {
        let (viewModel, mockAPIService) = createTestViewModel()
        
        // Setup initial order with driver
        let initialOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .driverEnRoute,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0,
            driver: Driver(
                id: "driver-123",
                name: "John Driver",
                phoneNumber: "+1234567890",
                rating: 4.8,
                profileImage: "https://example.com/driver.jpg",
                carModel: "Tesla Model Y",
                carColor: "White",
                licensePlate: "ABC123",
                estimatedArrival: Date().addingTimeInterval(600) // 10 minutes
            )
        )
        mockAPIService.setMockResponse(initialOrder, for: .getOrder(orderId: "test-order-123"))
        
        // Start tracking
        await viewModel.startTracking(orderId: "test-order-123")
        
        // Setup location update response
        let locationUpdate = LocationUpdateResponse(
            location: Location(latitude: 37.7759, longitude: -122.4184, address: "Updated Driver Location"),
            estimatedArrival: Date().addingTimeInterval(300), // 5 minutes (closer now)
            status: .driverEnRoute
        )
        mockAPIService.setMockResponse(locationUpdate, for: .getDriverLocation(orderId: "test-order-123"))
        
        // Use reflection to access private method
        let updateDriverLocationMethod = viewModel.perform(
            NSSelectorFromString("updateDriverLocation")
        )
        
        // Verify results
        XCTAssertEqual(viewModel.driverLocation?.latitude, 37.7759)
        XCTAssertEqual(viewModel.driverLocation?.longitude, -122.4184)
        XCTAssertEqual(viewModel.currentOrder?.driver?.estimatedArrival?.timeIntervalSince1970.rounded(),
                      Date().addingTimeInterval(300).timeIntervalSince1970.rounded())
    }
    
    func testUpdateDriverLocationWithStatusChange() async throws {
        let (viewModel, mockAPIService) = createTestViewModel()
        
        // Setup initial order with driver
        let initialOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .driverEnRoute,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0,
            driver: Driver(
                id: "driver-123",
                name: "John Driver",
                phoneNumber: "+1234567890",
                rating: 4.8,
                profileImage: "https://example.com/driver.jpg",
                carModel: "Tesla Model Y",
                carColor: "White",
                licensePlate: "ABC123",
                estimatedArrival: Date().addingTimeInterval(300)
            )
        )
        mockAPIService.setMockResponse(initialOrder, for: .getOrder(orderId: "test-order-123"))
        
        // Start tracking
        await viewModel.startTracking(orderId: "test-order-123")
        
        // Setup location update response with status change
        let locationUpdate = LocationUpdateResponse(
            location: Location(latitude: 37.7749, longitude: -122.4194, address: "Driver at Pickup"),
            estimatedArrival: nil, // No ETA needed, driver arrived
            status: .arrived
        )
        mockAPIService.setMockResponse(locationUpdate, for: .getDriverLocation(orderId: "test-order-123"))
        
        // Use reflection to access private method
        let updateDriverLocationMethod = viewModel.perform(
            NSSelectorFromString("updateDriverLocation")
        )
        
        // Verify results
        XCTAssertEqual(viewModel.currentOrder?.status, .arrived)
        XCTAssertEqual(viewModel.driverLocation?.address, "Driver at Pickup")
    }
    
    // MARK: - Status Change Handling Tests
    
    func testHandleStatusChangeToMatched() async throws {
        let (viewModel, mockAPIService) = createTestViewModel()
        
        // Setup initial order
        let initialOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .matching,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0
        )
        mockAPIService.setMockResponse(initialOrder, for: .getOrder(orderId: "test-order-123"))
        
        // Start tracking in matching state
        await viewModel.startTracking(orderId: "test-order-123")
        XCTAssertTrue(viewModel.isMatching)
        
        // Setup updated order with matched status
        let updatedOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .matched,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0,
            driver: Driver(
                id: "driver-123",
                name: "John Driver",
                phoneNumber: "+1234567890",
                rating: 4.8,
                profileImage: "https://example.com/driver.jpg",
                carModel: "Tesla Model Y",
                carColor: "White",
                licensePlate: "ABC123",
                estimatedArrival: Date().addingTimeInterval(300)
            )
        )
        mockAPIService.setMockResponse(updatedOrder, for: .getOrder(orderId: "test-order-123"))
        
        // Test refresh to trigger status change
        await viewModel.refreshOrderStatus()
        
        // Verify results
        XCTAssertFalse(viewModel.isMatching)
        XCTAssertEqual(viewModel.matchingProgress, 1.0)
        XCTAssertTrue(viewModel.isTrackingActive)
    }
    
    func testHandleStatusChangeToCompleted() async throws {
        let (viewModel, mockAPIService) = createTestViewModel()
        
        // Setup initial order
        let initialOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .inProgress,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0,
            driver: Driver(
                id: "driver-123",
                name: "John Driver",
                phoneNumber: "+1234567890",
                rating: 4.8,
                profileImage: "https://example.com/driver.jpg",
                carModel: "Tesla Model Y",
                carColor: "White",
                licensePlate: "ABC123"
            )
        )
        mockAPIService.setMockResponse(initialOrder, for: .getOrder(orderId: "test-order-123"))
        
        // Start tracking
        await viewModel.startTracking(orderId: "test-order-123")
        XCTAssertTrue(viewModel.isTrackingActive)
        
        // Setup updated order with completed status
        let updatedOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .completed,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0,
            driver: initialOrder.driver
        )
        mockAPIService.setMockResponse(updatedOrder, for: .getOrder(orderId: "test-order-123"))
        
        // Test refresh to trigger status change
        await viewModel.refreshOrderStatus()
        
        // Verify results
        XCTAssertFalse(viewModel.isTrackingActive)
        XCTAssertFalse(viewModel.isMatching)
    }
    
    // MARK: - Helper Methods Tests
    
    func testIsDriverAssigned() async throws {
        let (viewModel, mockAPIService) = createTestViewModel()
        
        // Test with no order
        XCTAssertFalse(viewModel.isDriverAssigned)
        
        // Setup order with driver
        let orderWithDriver = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .matched,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0,
            driver: Driver(
                id: "driver-123",
                name: "John Driver",
                phoneNumber: "+1234567890",
                rating: 4.8,
                profileImage: "https://example.com/driver.jpg",
                carModel: "Tesla Model Y",
                carColor: "White",
                licensePlate: "ABC123"
            )
        )
        mockAPIService.setMockResponse(orderWithDriver, for: .getOrder(orderId: "test-order-123"))
        
        // Start tracking
        await viewModel.startTracking(orderId: "test-order-123")
        
        // Test with driver assigned
        XCTAssertTrue(viewModel.isDriverAssigned)
        
        // Setup order without driver
        let orderWithoutDriver = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .matching,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0
        )
        mockAPIService.setMockResponse(orderWithoutDriver, for: .getOrder(orderId: "test-order-123"))
        
        // Refresh to update order
        await viewModel.refreshOrderStatus()
        
        // Test with no driver assigned
        XCTAssertFalse(viewModel.isDriverAssigned)
    }
    
    func testCanCommunicateWithDriver() async throws {
        let (viewModel, _) = createTestViewModel()
        
        // Test with no order
        XCTAssertFalse(viewModel.canCommunicateWithDriver)
        
        // Test with different order statuses
        let statuses: [OrderStatus] = [.pending, .matching, .matched, .driverEnRoute, .arrived, .inProgress, .completed, .cancelled]
        let expectedResults: [Bool] = [false, false, true, true, true, true, false, false]
        
        for (index, status) in statuses.enumerated() {
            viewModel.currentOrder = Order(
                id: "test-order-123",
                serviceType: .airport,
                status: status,
                pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
                estimatedPrice: 25.0
            )
            
            XCTAssertEqual(viewModel.canCommunicateWithDriver, expectedResults[index], "Failed for status: \(status)")
        }
    }
    
    func testStatusDisplayText() async throws {
        let (viewModel, _) = createTestViewModel()
        
        // Test with no order
        XCTAssertEqual(viewModel.statusDisplayText, "Unknown")
        
        // Test with different order statuses
        let statuses: [OrderStatus] = [.pending, .matching, .matched, .driverEnRoute, .arrived, .inProgress, .completed, .cancelled]
        let expectedTexts: [String] = [
            "Order Confirmed",
            "Finding Driver...",
            "Driver Assigned",
            "Driver En Route",
            "Driver Arrived",
            "Trip in Progress",
            "Trip Completed",
            "Trip Cancelled"
        ]
        
        for (index, status) in statuses.enumerated() {
            viewModel.currentOrder = Order(
                id: "test-order-123",
                serviceType: .airport,
                status: status,
                pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
                estimatedPrice: 25.0
            )
            
            XCTAssertEqual(viewModel.statusDisplayText, expectedTexts[index], "Failed for status: \(status)")
        }
    }
    
    func testEstimatedArrivalText() async throws {
        let (viewModel, _) = createTestViewModel()
        
        // Test with no driver
        XCTAssertNil(viewModel.estimatedArrivalText)
        
        // Test with driver but no ETA
        viewModel.currentOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .matched,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0,
            driver: Driver(
                id: "driver-123",
                name: "John Driver",
                phoneNumber: "+1234567890",
                rating: 4.8,
                profileImage: "https://example.com/driver.jpg",
                carModel: "Tesla Model Y",
                carColor: "White",
                licensePlate: "ABC123"
            )
        )
        XCTAssertNil(viewModel.estimatedArrivalText)
        
        // Test with driver and ETA
        let arrivalTime = Date().addingTimeInterval(300) // 5 minutes from now
        viewModel.currentOrder?.driver?.estimatedArrival = arrivalTime
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let expectedText = "ETA: \(formatter.string(from: arrivalTime))"
        
        XCTAssertEqual(viewModel.estimatedArrivalText, expectedText)
    }
}