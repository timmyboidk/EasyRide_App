import XCTest
@testable import EasyRide

class BookingIntegrationTests: XCTestCase {
    
    // Simple verification checking BookingViewModel integration
    func testBookingViewModelIntegration() {
        print("🔍 Verifying BookingViewModel integration...")
        
        // Test 1: Verify BookingViewModel can be instantiated
        let appState = AppState()
        let apiService = MockAPIService()
        let viewModel = BookingViewModel(apiService: apiService, appState: appState)
        
        print("✅ BookingViewModel instantiated successfully")
        
        // Test 2: Verify initial state
        XCTAssertFalse(viewModel.isCreatingOrder, "Initial isCreatingOrder should be false")
        XCTAssertNil(viewModel.orderCreationError, "Initial orderCreationError should be nil")
        XCTAssertNil(viewModel.createdOrder, "Initial createdOrder should be nil")
        XCTAssertFalse(viewModel.isTrackingOrder, "Initial isTrackingOrder should be false")
        XCTAssertTrue(viewModel.orderHistory.isEmpty, "Initial orderHistory should be empty")
        
        print("✅ Initial state verification passed")
        
        // Test 3: Verify helper methods work
        let testOrder = Order(
            id: "test-123",
            serviceType: .airport,
            status: .pending,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Location"),
            estimatedPrice: 25.0
        )
        
        let canCancel = viewModel.canCancelOrder(testOrder)
        XCTAssertTrue(canCancel, "Should be able to cancel pending order")
        
        print("✅ Helper methods verification passed")
        
        // Test 4: Verify error clearing
        viewModel.clearErrors()
        XCTAssertNil(viewModel.orderCreationError, "Errors should be cleared")
        XCTAssertNil(viewModel.trackingError, "Tracking error should be cleared")
        XCTAssertNil(viewModel.historyError, "History error should be cleared")
        XCTAssertNil(viewModel.cancellationError, "Cancellation error should be cleared")
        
        print("✅ Error clearing verification passed")
        
        // Test 5: Verify state reset
        viewModel.resetBookingState()
        XCTAssertNil(viewModel.createdOrder, "Created order should be reset")
        XCTAssertNil(viewModel.orderCreationError, "Order creation error should be reset")
        XCTAssertFalse(viewModel.isCreatingOrder, "isCreatingOrder should be reset")
        XCTAssertFalse(viewModel.isTrackingOrder, "isTrackingOrder should be reset")
        
        print("✅ State reset verification passed")
        
        // Test 6: Verify order filtering methods
        let orders = [
            Order(id: "1", serviceType: .airport, status: .completed, pickupLocation: Location(latitude: 0, longitude: 0, address: "Test"), estimatedPrice: 25.0),
            Order(id: "2", serviceType: .longDistance, status: .cancelled, pickupLocation: Location(latitude: 0, longitude: 0, address: "Test"), estimatedPrice: 45.0),
            Order(id: "3", serviceType: .charter, status: .pending, pickupLocation: Location(latitude: 0, longitude: 0, address: "Test"), estimatedPrice: 75.0)
        ]
        
        // Simulate having order history
        var mutableViewModel = viewModel
        mutableViewModel.orderHistory = orders
        
        let completedOrders = mutableViewModel.getCompletedOrders()
        let activeOrders = mutableViewModel.getActiveOrders()
        let pendingOrders = mutableViewModel.getOrdersByStatus(.pending)
        
        XCTAssertEqual(completedOrders.count, 1, "Should have 1 completed order")
        XCTAssertEqual(activeOrders.count, 1, "Should have 1 active order")
        XCTAssertEqual(pendingOrders.count, 1, "Should have 1 pending order")
        
        print("✅ Order filtering verification passed")
        
        print("🎉 All BookingViewModel integration tests passed!")
    }
}