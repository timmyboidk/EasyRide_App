import XCTest
import Foundation
@testable import EasyRide

class BookingViewModelTests: XCTestCase {
    
    // MARK: - Mock Dependencies
    
    class MockAPIService: APIService {
        var mockResponses: [String: Any] = [:]
        var shouldThrowError = false
        var errorToThrow: Error = EasyRideError.networkError("Mock error")
        
        func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
            if shouldThrowError {
                throw errorToThrow
            }
            
            let key = "\(endpoint.path)-\(endpoint.httpMethod.rawValue)"
            
            if let mockData = mockResponses[key] as? T {
                return mockData
            }
            
            // Return default mock data based on endpoint
            switch endpoint {
            case .createOrder:
                let mockOrder = Order(
                    id: "test-order-123",
                    serviceType: .airport,
                    pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
                    estimatedPrice: 25.0
                )
                return mockOrder as! T
                
            case .getOrder:
                let mockOrder = Order(
                    id: "test-order-123",
                    serviceType: .airport,
                    status: .matched,
                    pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
                    estimatedPrice: 25.0
                )
                return mockOrder as! T
                
            case .getOrderHistory:
                let mockHistory = OrderHistoryResponse(
                    orders: [
                        Order(
                            id: "order-1",
                            serviceType: .airport,
                            status: .completed,
                            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup 1"),
                            estimatedPrice: 25.0
                        ),
                        Order(
                            id: "order-2",
                            serviceType: .longDistance,
                            status: .cancelled,
                            pickupLocation: Location(latitude: 37.7849, longitude: -122.4294, address: "Test Pickup 2"),
                            estimatedPrice: 45.0
                        )
                    ],
                    hasMore: false,
                    totalCount: 2,
                    currentPage: 1
                )
                return mockHistory as! T
                
            default:
                throw EasyRideError.unknownError
            }
        }
        
        func requestWithoutResponse(_ endpoint: APIEndpoint) async throws {
            if shouldThrowError {
                throw errorToThrow
            }
            // Success - no response needed
        }
        
        func uploadImage(_ endpoint: APIEndpoint, imageData: Data) async throws -> String {
            if shouldThrowError {
                throw errorToThrow
            }
            return "https://example.com/uploaded-image.jpg"
        }
    }
    
    // MARK: - Test Setup
    
    func createTestViewModel() -> (BookingViewModel, MockAPIService, AppState) {
        let mockAPIService = MockAPIService()
        let appState = AppState()
        let viewModel = BookingViewModel(apiService: mockAPIService, appState: appState)
        return (viewModel, mockAPIService, appState)
    }
    
    // MARK: - Order Creation Tests
    
    func testOrderCreationSuccess() async throws {
        let (viewModel, mockAPIService, appState) = createTestViewModel()
        
        // Setup app state with required data
        appState.selectedService = .airport
        appState.tripConfiguration = TripConfiguration(
            mode: .freeRoute,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            destination: Location(latitude: 37.7849, longitude: -122.4094, address: "Test Destination"),
            passengerCount: 2
        )
        
        // Test order creation
        await viewModel.createOrder()
        
        // Verify results
        XCTAssertFalse(viewModel.isCreatingOrder)
        XCTAssertNil(viewModel.orderCreationError)
        XCTAssertNotNil(viewModel.createdOrder)
        XCTAssertEqual(viewModel.createdOrder?.id, "test-order-123")
        XCTAssertNotNil(appState.activeOrder)
    }
    
    func testOrderCreationWithMissingData() async throws {
        let (viewModel, _, appState) = createTestViewModel()
        
        // Don't set required data in app state
        appState.selectedService = nil
        appState.tripConfiguration = nil
        
        // Test order creation
        await viewModel.createOrder()
        
        // Verify error handling
        XCTAssertFalse(viewModel.isCreatingOrder)
        XCTAssertNotNil(viewModel.orderCreationError)
        XCTAssertNil(viewModel.createdOrder)
    }
    
    func testOrderCreationNetworkError() async throws {
        let (viewModel, mockAPIService, appState) = createTestViewModel()
        
        // Setup app state with required data
        appState.selectedService = .airport
        appState.tripConfiguration = TripConfiguration(
            mode: .freeRoute,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            destination: Location(latitude: 37.7849, longitude: -122.4094, address: "Test Destination")
        )
        
        // Configure mock to throw error
        mockAPIService.shouldThrowError = true
        mockAPIService.errorToThrow = EasyRideError.networkError("Connection failed")
        
        // Test order creation
        await viewModel.createOrder()
        
        // Verify error handling
        XCTAssertFalse(viewModel.isCreatingOrder)
        XCTAssertNotNil(viewModel.orderCreationError)
        XCTAssertNil(viewModel.createdOrder)
    }
    
    // MARK: - Order Status Tracking Tests
    
    func testOrderStatusTracking() async throws {
        let (viewModel, _, _) = createTestViewModel()
        
        let orderId = "test-order-123"
        
        // Test status update
        await viewModel.updateOrderStatus(orderId: orderId)
        
        // Verify status was updated
        XCTAssertEqual(viewModel.getOrderStatus(orderId: orderId), .matched)
        XCTAssertNil(viewModel.trackingError)
    }
    
    func testOrderStatusTrackingError() async throws {
        let (viewModel, mockAPIService, _) = createTestViewModel()
        
        // Configure mock to throw error
        mockAPIService.shouldThrowError = true
        mockAPIService.errorToThrow = EasyRideError.orderNotFound
        
        let orderId = "nonexistent-order"
        
        // Test status update
        await viewModel.updateOrderStatus(orderId: orderId)
        
        // Verify error handling
        XCTAssertNotNil(viewModel.trackingError)
        XCTAssertNil(viewModel.getOrderStatus(orderId: orderId))
    }
    
    // MARK: - Order Cancellation Tests
    
    func testOrderCancellationSuccess() async throws {
        let (viewModel, _, appState) = createTestViewModel()
        
        // Setup active order
        let testOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .matched,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0
        )
        appState.activeOrder = testOrder
        
        // Test cancellation
        await viewModel.cancelOrder(orderId: testOrder.id, reason: "Changed plans")
        
        // Verify results
        XCTAssertFalse(viewModel.isCancellingOrder)
        XCTAssertNil(viewModel.cancellationError)
        XCTAssertEqual(viewModel.getOrderStatus(orderId: testOrder.id), .cancelled)
    }
    
    func testActiveOrderCancellation() async throws {
        let (viewModel, _, appState) = createTestViewModel()
        
        // Setup active order
        let testOrder = Order(
            id: "test-order-123",
            serviceType: .airport,
            status: .matched,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            estimatedPrice: 25.0
        )
        appState.activeOrder = testOrder
        
        // Test active order cancellation
        await viewModel.cancelActiveOrder(reason: "Emergency")
        
        // Verify results
        XCTAssertFalse(viewModel.isCancellingOrder)
        XCTAssertNil(viewModel.cancellationError)
    }
    
    func testCancellationWithoutActiveOrder() async throws {
        let (viewModel, _, appState) = createTestViewModel()
        
        // Ensure no active order
        appState.activeOrder = nil
        
        // Test cancellation
        await viewModel.cancelActiveOrder()
        
        // Verify error handling
        XCTAssertEqual(viewModel.cancellationError, .orderNotFound)
    }
    
    // MARK: - Order History Tests
    
    func testOrderHistoryLoading() async throws {
        let (viewModel, _, _) = createTestViewModel()
        
        // Test loading history
        await viewModel.loadOrderHistory()
        
        // Verify results
        XCTAssertFalse(viewModel.isLoadingHistory)
        XCTAssertNil(viewModel.historyError)
        XCTAssertEqual(viewModel.orderHistory.count, 2)
        XCTAssertFalse(viewModel.hasMoreHistory)
        XCTAssertEqual(viewModel.currentHistoryPage, 1)
    }
    
    func testOrderHistoryPagination() async throws {
        let (viewModel, mockAPIService, _) = createTestViewModel()
        
        // Setup mock for second page
        let secondPageResponse = OrderHistoryResponse(
            orders: [
                Order(
                    id: "order-3",
                    serviceType: .charter,
                    status: .completed,
                    pickupLocation: Location(latitude: 37.7949, longitude: -122.4394, address: "Test Pickup 3"),
                    estimatedPrice: 75.0
                )
            ],
            hasMore: false,
            totalCount: 3,
            currentPage: 2
        )
        mockAPIService.mockResponses["/api/order/history-GET"] = secondPageResponse
        
        // Load first page
        await viewModel.loadOrderHistory(page: 1)
        let firstPageCount = viewModel.orderHistory.count
        
        // Load second page
        await viewModel.loadOrderHistory(page: 2)
        
        // Verify pagination
        XCTAssertGreaterThan(viewModel.orderHistory.count, firstPageCount)
        XCTAssertEqual(viewModel.currentHistoryPage, 2)
    }
    
    func testOrderHistoryRefresh() async throws {
        let (viewModel, _, _) = createTestViewModel()
        
        // Load initial history
        await viewModel.loadOrderHistory()
        let initialCount = viewModel.orderHistory.count
        
        // Refresh history
        await viewModel.refreshOrderHistory()
        
        // Verify refresh (should reset to page 1)
        XCTAssertEqual(viewModel.currentHistoryPage, 1)
        XCTAssertEqual(viewModel.orderHistory.count, initialCount) // Same mock data
    }
    
    // MARK: - Helper Methods Tests
    
    func testCanCancelOrderLogic() {
        let (viewModel, _, _) = createTestViewModel()
        
        // Test different order statuses
        let pendingOrder = Order(id: "1", serviceType: .airport, status: .pending, pickupLocation: Location(latitude: 0, longitude: 0, address: "Test"), estimatedPrice: 25.0)
        let matchingOrder = Order(id: "2", serviceType: .airport, status: .matching, pickupLocation: Location(latitude: 0, longitude: 0, address: "Test"), estimatedPrice: 25.0)
        let inProgressOrder = Order(id: "3", serviceType: .airport, status: .inProgress, pickupLocation: Location(latitude: 0, longitude: 0, address: "Test"), estimatedPrice: 25.0)
        let completedOrder = Order(id: "4", serviceType: .airport, status: .completed, pickupLocation: Location(latitude: 0, longitude: 0, address: "Test"), estimatedPrice: 25.0)
        
        XCTAssertTrue(viewModel.canCancelOrder(pendingOrder))
        XCTAssertTrue(viewModel.canCancelOrder(matchingOrder))
        XCTAssertFalse(viewModel.canCancelOrder(inProgressOrder))
        XCTAssertFalse(viewModel.canCancelOrder(completedOrder))
    }
    
    func testOrderFilteringByStatus() async throws {
        let (viewModel, _, _) = createTestViewModel()
        
        // Load order history first
        await viewModel.loadOrderHistory()
        
        // Test filtering
        let completedOrders = viewModel.getOrdersByStatus(.completed)
        let cancelledOrders = viewModel.getOrdersByStatus(.cancelled)
        let activeOrders = viewModel.getActiveOrders()
        let completedOrdersMethod = viewModel.getCompletedOrders()
        
        XCTAssertEqual(completedOrders.count, 1)
        XCTAssertEqual(cancelledOrders.count, 1)
        XCTAssertEqual(activeOrders.count, 0) // No active orders in mock data
        XCTAssertEqual(completedOrdersMethod.count, 1)
    }
    
    func testErrorClearing() async throws {
        let (viewModel, mockAPIService, appState) = createTestViewModel()
        
        // Generate some errors
        mockAPIService.shouldThrowError = true
        await viewModel.createOrder()
        await viewModel.loadOrderHistory()
        
        // Verify errors exist
        XCTAssertNotNil(viewModel.orderCreationError)
        XCTAssertNotNil(viewModel.historyError)
        
        // Clear errors
        viewModel.clearErrors()
        
        // Verify errors are cleared
        XCTAssertNil(viewModel.orderCreationError)
        XCTAssertNil(viewModel.historyError)
        XCTAssertNil(viewModel.trackingError)
        XCTAssertNil(viewModel.cancellationError)
    }
    
    func testBookingStateReset() async throws {
        let (viewModel, _, appState) = createTestViewModel()
        
        // Setup some booking state
        appState.selectedService = .airport
        appState.tripConfiguration = TripConfiguration(
            mode: .freeRoute,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            destination: Location(latitude: 37.7849, longitude: -122.4094, address: "Test Destination")
        )
        
        await viewModel.createOrder()
        
        // Verify state exists
        XCTAssertNotNil(viewModel.createdOrder)
        
        // Reset booking state
        viewModel.resetBookingState()
        
        // Verify state is reset
        XCTAssertNil(viewModel.createdOrder)
        XCTAssertNil(viewModel.orderCreationError)
        XCTAssertFalse(viewModel.isCreatingOrder)
        XCTAssertFalse(viewModel.isTrackingOrder)
    }
}