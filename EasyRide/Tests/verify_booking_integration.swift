import Foundation
@testable import EasyRide

// Simple verification script to check BookingViewModel integration
func verifyBookingViewModelIntegration() {
    print("🔍 Verifying BookingViewModel integration...")
    
    // Test 1: Verify BookingViewModel can be instantiated
    let appState = AppState()
    let apiService = EasyRideAPIService.shared
    let viewModel = BookingViewModel(apiService: apiService, appState: appState)
    
    print("✅ BookingViewModel instantiated successfully")
    
    // Test 2: Verify initial state
    assert(viewModel.isCreatingOrder == false, "Initial isCreatingOrder should be false")
    assert(viewModel.orderCreationError == nil, "Initial orderCreationError should be nil")
    assert(viewModel.createdOrder == nil, "Initial createdOrder should be nil")
    assert(viewModel.isTrackingOrder == false, "Initial isTrackingOrder should be false")
    assert(viewModel.orderHistory.isEmpty, "Initial orderHistory should be empty")
    
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
    assert(canCancel == true, "Should be able to cancel pending order")
    
    print("✅ Helper methods verification passed")
    
    // Test 4: Verify error clearing
    viewModel.clearErrors()
    assert(viewModel.orderCreationError == nil, "Errors should be cleared")
    assert(viewModel.trackingError == nil, "Tracking error should be cleared")
    assert(viewModel.historyError == nil, "History error should be cleared")
    assert(viewModel.cancellationError == nil, "Cancellation error should be cleared")
    
    print("✅ Error clearing verification passed")
    
    // Test 5: Verify state reset
    viewModel.resetBookingState()
    assert(viewModel.createdOrder == nil, "Created order should be reset")
    assert(viewModel.orderCreationError == nil, "Order creation error should be reset")
    assert(viewModel.isCreatingOrder == false, "isCreatingOrder should be reset")
    assert(viewModel.isTrackingOrder == false, "isTrackingOrder should be reset")
    
    print("✅ State reset verification passed")
    
    // Test 6: Verify order filtering methods
    let orders = [
        Order(id: "1", serviceType: .airport, status: .completed, pickupLocation: Location(latitude: 0, longitude: 0, address: "Test"), estimatedPrice: 25.0),
        Order(id: "2", serviceType: .longDistance, status: .cancelled, pickupLocation: Location(latitude: 0, longitude: 0, address: "Test"), estimatedPrice: 45.0),
        Order(id: "3", serviceType: .charter, status: .pending, pickupLocation: Location(latitude: 0, longitude: 0, address: "Test"), estimatedPrice: 75.0)
    ]
    
    // Simulate having order history
    viewModel.orderHistory = orders
    
    let completedOrders = viewModel.getCompletedOrders()
    let activeOrders = viewModel.getActiveOrders()
    let pendingOrders = viewModel.getOrdersByStatus(.pending)
    
    assert(completedOrders.count == 1, "Should have 1 completed order")
    assert(activeOrders.count == 1, "Should have 1 active order")
    assert(pendingOrders.count == 1, "Should have 1 pending order")
    
    print("✅ Order filtering verification passed")
    
    print("🎉 All BookingViewModel integration tests passed!")
}

// Run the verification
verifyBookingViewModelIntegration()