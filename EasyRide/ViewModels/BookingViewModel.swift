import Foundation
import Observation

@Observable
class BookingViewModel {
    // MARK: - Dependencies
    private let apiService: APIService
    private let appState: AppState
    
    // MARK: - Order Creation State
    var isCreatingOrder: Bool = false
    var orderCreationError: EasyRideError?
    var createdOrder: Order?
    
    // MARK: - Order Tracking State
    var isTrackingOrder: Bool = false
    var trackingError: EasyRideError?
    var orderStatusUpdates: [String: OrderStatus] = [:]
    
    // MARK: - Order History State
    var orderHistory: [Order] = []
    var isLoadingHistory: Bool = false
    var historyError: EasyRideError?
    var currentHistoryPage: Int = 1
    var hasMoreHistory: Bool = true
    
    // MARK: - Order Cancellation State
    var isCancellingOrder: Bool = false
    var cancellationError: EasyRideError?
    
    init(apiService: APIService = EasyRideAPIService.shared, appState: AppState) {
        self.apiService = apiService
        self.appState = appState
        
        // Load initial order history
        Task {
            await loadOrderHistory()
        }
    }
    
    // MARK: - Order Creation
    
    /// Creates a new order based on current booking state
    func createOrder() async {
        guard let selectedService = appState.selectedService,
              let tripConfig = appState.tripConfiguration else {
            await MainActor.run {
                orderCreationError = .invalidRequest("Missing service type or trip configuration")
            }
            return
        }
        
        await MainActor.run {
            isCreatingOrder = true
            orderCreationError = nil
        }
        
        let orderRequest = OrderRequest(
            serviceType: selectedService,
            pickupLocation: tripConfig.pickupLocation,
            destination: tripConfig.destination,
            scheduledTime: tripConfig.scheduledTime,
            passengerCount: tripConfig.passengerCount,
            notes: tripConfig.notes,
            stops: tripConfig.stops,
            serviceOptions: tripConfig.serviceOptions
        )
        
        do {
            let order: Order = try await apiService.request(.createOrder(orderRequest))
            
            await MainActor.run {
                createdOrder = order
                appState.createOrder(order)
                isCreatingOrder = false
                
                // Start tracking the new order
                Task {
                    await startOrderTracking(orderId: order.id)
                }
            }
        } catch {
            await MainActor.run {
                if let easyRideError = error as? EasyRideError {
                    orderCreationError = easyRideError
                } else {
                    orderCreationError = .networkError(error.localizedDescription)
                }
                isCreatingOrder = false
                appState.handleError(error)
            }
        }
    }
    
    /// Creates an order with custom parameters
    func createOrder(
        serviceType: ServiceType,
        pickupLocation: Location,
        destination: Location?,
        scheduledTime: Date? = nil,
        passengerCount: Int = 1,
        notes: String? = nil,
        stops: [TripStop] = [],
        serviceOptions: [ServiceOption] = []
    ) async {
        await MainActor.run {
            isCreatingOrder = true
            orderCreationError = nil
        }
        
        let orderRequest = OrderRequest(
            serviceType: serviceType,
            pickupLocation: pickupLocation,
            destination: destination,
            scheduledTime: scheduledTime,
            passengerCount: passengerCount,
            notes: notes,
            stops: stops,
            serviceOptions: serviceOptions
        )
        
        do {
            let order: Order = try await apiService.request(.createOrder(orderRequest))
            
            await MainActor.run {
                createdOrder = order
                appState.createOrder(order)
                isCreatingOrder = false
                
                // Start tracking the new order
                Task {
                    await startOrderTracking(orderId: order.id)
                }
            }
        } catch {
            await MainActor.run {
                if let easyRideError = error as? EasyRideError {
                    orderCreationError = easyRideError
                } else {
                    orderCreationError = .networkError(error.localizedDescription)
                }
                isCreatingOrder = false
                appState.handleError(error)
            }
        }
    }
    
    // MARK: - Order Status Tracking
    
    /// Starts tracking an order's status with periodic updates
    func startOrderTracking(orderId: String) async {
        await MainActor.run {
            isTrackingOrder = true
            trackingError = nil
        }
        
        // Start periodic status checking
        while isTrackingOrder {
            await updateOrderStatus(orderId: orderId)
            
            // Check if order is still active
            if let currentStatus = orderStatusUpdates[orderId],
               !currentStatus.isActive {
                await MainActor.run {
                    isTrackingOrder = false
                }
                break
            }
            
            // Wait 10 seconds before next update
            try? await Task.sleep(nanoseconds: 10_000_000_000)
        }
    }
    
    /// Updates the status of a specific order
    func updateOrderStatus(orderId: String) async {
        do {
            let order: Order = try await apiService.request(.getOrder(orderId: orderId))
            
            await MainActor.run {
                orderStatusUpdates[orderId] = order.status
                
                // Update active order if this is the current one
                if appState.activeOrder?.id == orderId {
                    appState.updateOrderStatus(order.status)
                    appState.activeOrder = order
                }
                
                // Update order in history
                if let index = orderHistory.firstIndex(where: { $0.id == orderId }) {
                    orderHistory[index] = order
                }
                
                trackingError = nil
            }
        } catch {
            await MainActor.run {
                if let easyRideError = error as? EasyRideError {
                    trackingError = easyRideError
                } else {
                    trackingError = .networkError(error.localizedDescription)
                }
            }
        }
    }
    
    /// Stops tracking order status updates
    func stopOrderTracking() {
        isTrackingOrder = false
    }
    
    /// Gets the current status of an order
    func getOrderStatus(orderId: String) -> OrderStatus? {
        return orderStatusUpdates[orderId]
    }
    
    // MARK: - Order Cancellation
    
    /// Cancels an order with optional reason
    func cancelOrder(orderId: String, reason: String? = nil) async {
        await MainActor.run {
            isCancellingOrder = true
            cancellationError = nil
        }
        
        do {
            try await apiService.requestWithoutResponse(.cancelOrder(orderId: orderId, reason: reason))
            
            await MainActor.run {
                // Update order status locally
                orderStatusUpdates[orderId] = .cancelled
                
                // Update active order if this is the current one
                if appState.activeOrder?.id == orderId {
                    appState.cancelOrder()
                }
                
                // Update order in history
                if let index = orderHistory.firstIndex(where: { $0.id == orderId }) {
                    orderHistory[index].status = .cancelled
                }
                
                isCancellingOrder = false
            }
        } catch {
            await MainActor.run {
                if let easyRideError = error as? EasyRideError {
                    cancellationError = easyRideError
                } else {
                    cancellationError = .networkError(error.localizedDescription)
                }
                isCancellingOrder = false
                appState.handleError(error)
            }
        }
    }
    
    /// Cancels the current active order
    func cancelActiveOrder(reason: String? = nil) async {
        guard let activeOrder = appState.activeOrder else {
            await MainActor.run {
                cancellationError = .orderNotFound
            }
            return
        }
        
        await cancelOrder(orderId: activeOrder.id, reason: reason)
    }
    
    // MARK: - Order History
    
    /// Loads order history with pagination
    func loadOrderHistory(page: Int = 1, limit: Int = 20) async {
        await MainActor.run {
            isLoadingHistory = true
            historyError = nil
        }
        
        do {
            let historyResponse: OrderHistoryResponse = try await apiService.request(
                .getOrderHistory(page: page, limit: limit)
            )
            
            await MainActor.run {
                if page == 1 {
                    // First page - replace existing history
                    orderHistory = historyResponse.orders
                    appState.orderHistory = historyResponse.orders
                } else {
                    // Subsequent pages - append to existing history
                    orderHistory.append(contentsOf: historyResponse.orders)
                    appState.orderHistory.append(contentsOf: historyResponse.orders)
                }
                
                currentHistoryPage = page
                hasMoreHistory = historyResponse.hasMore
                isLoadingHistory = false
            }
        } catch {
            await MainActor.run {
                if let easyRideError = error as? EasyRideError {
                    historyError = easyRideError
                } else {
                    historyError = .networkError(error.localizedDescription)
                }
                isLoadingHistory = false
            }
        }
    }
    
    /// Loads the next page of order history
    func loadMoreHistory() async {
        guard hasMoreHistory && !isLoadingHistory else { return }
        await loadOrderHistory(page: currentHistoryPage + 1)
    }
    
    /// Refreshes the order history
    func refreshOrderHistory() async {
        await loadOrderHistory(page: 1)
    }
    
    // MARK: - Helper Methods
    
    /// Checks if an order can be cancelled
    func canCancelOrder(_ order: Order) -> Bool {
        switch order.status {
        case .pending, .matching, .matched:
            return true
        case .driverEnRoute, .arrived:
            // Can still cancel but might incur fees
            return true
        case .inProgress, .completed, .cancelled:
            return false
        }
    }
    
    /// Gets orders filtered by status
    func getOrdersByStatus(_ status: OrderStatus) -> [Order] {
        return orderHistory.filter { $0.status == status }
    }
    
    /// Gets active orders (not completed or cancelled)
    func getActiveOrders() -> [Order] {
        return orderHistory.filter { $0.status.isActive }
    }
    
    /// Gets completed orders
    func getCompletedOrders() -> [Order] {
        return orderHistory.filter { $0.status == .completed }
    }
    
    /// Clears all errors
    func clearErrors() {
        orderCreationError = nil
        trackingError = nil
        historyError = nil
        cancellationError = nil
    }
    
    /// Resets booking state
    func resetBookingState() {
        createdOrder = nil
        orderCreationError = nil
        isCreatingOrder = false
        stopOrderTracking()
    }
}

