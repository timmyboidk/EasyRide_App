import Foundation
import MapKit
import Observation
#if os(iOS)
import UIKit
#endif

@Observable
class OrderTrackingViewModel {
    private let apiService: APIService
    
    // Order tracking state
    var currentOrder: Order?
    var driverLocation: Location?
    var isTrackingActive: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?
    
    // Driver matching state
    var isMatching: Bool = false
    var matchingProgress: Double = 0.0
    var estimatedWaitTime: TimeInterval = 0
    
    // Location tracking
    private var locationUpdateTimer: Timer?
    private let locationUpdateInterval: TimeInterval = 10.0 // Update every 10 seconds
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    deinit {
        Task { @MainActor in
            await stopTracking()
        }
    }
    
    // MARK: - Order Tracking
    
    @MainActor
    func startTracking(orderId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get initial order details
            let order: Order = try await apiService.request(.getOrder(orderId: orderId))
            currentOrder = order
            
            // Start appropriate tracking based on order status
            switch order.status {
            case .pending, .matching:
                startDriverMatching()
            case .matched, .driverEnRoute, .arrived, .inProgress:
                startLocationTracking()
                isTrackingActive = true
            case .completed, .cancelled:
                // No tracking needed for completed orders
                break
            }
            
        } catch {
            errorMessage = "Failed to load order details: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func stopTracking() async {
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
        isTrackingActive = false
        isMatching = false
        matchingProgress = 0.0
    }
    
    @MainActor
    func refreshOrderStatus() async {
        guard let orderId = currentOrder?.id else { return }
        
        do {
            let updatedOrder: Order = try await apiService.request(.getOrder(orderId: orderId))
            let previousStatus = currentOrder?.status
            currentOrder = updatedOrder
            
            // Handle status changes
            if previousStatus != updatedOrder.status {
                await handleStatusChange(from: previousStatus, to: updatedOrder.status)
            }
            
        } catch {
            errorMessage = "Failed to refresh order status: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Driver Matching
    
    @MainActor
    private func startDriverMatching() {
        isMatching = true
        matchingProgress = 0.0
        
        // Simulate matching progress with timer
        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                self.matchingProgress += 0.1
                
                if self.matchingProgress >= 1.0 {
                    timer.invalidate()
                    // Check for actual driver match
                    await self.refreshOrderStatus()
                }
            }
        }
        
        // Also refresh order status periodically during matching
        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshOrderStatus()
            }
        }
    }
    
    // MARK: - Location Tracking
    
    @MainActor
    private func startLocationTracking() {
        guard let orderId = currentOrder?.id else { return }
        
        // Start periodic location updates
        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: locationUpdateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.updateDriverLocation()
            }
        }
        
        // Get initial location
        Task {
            await updateDriverLocation()
        }
    }
    
    @MainActor
    private func updateDriverLocation() async {
        guard let orderId = currentOrder?.id else { return }
        
        do {
            let locationResponse: LocationUpdateResponse = try await apiService.request(.getDriverLocation(orderId: orderId))
            
            // Update driver location with animation
            let previousLocation = driverLocation
            driverLocation = locationResponse.location
            
            // Update estimated arrival if provided
            if let estimatedArrival = locationResponse.estimatedArrival {
                currentOrder?.driver?.estimatedArrival = estimatedArrival
            }
            
            // Update order status if it changed
            if locationResponse.status != currentOrder?.status {
                let previousStatus = currentOrder?.status
                currentOrder?.status = locationResponse.status
                await handleStatusChange(from: previousStatus, to: locationResponse.status)
            }
            
            // Log location update for debugging
            if let prevLoc = previousLocation, let newLoc = driverLocation {
                let distance = prevLoc.distance(to: newLoc)
                print("Driver moved \(Int(distance))m to \(newLoc.address)")
            }
            
        } catch {
            // Handle specific errors
            if let easyRideError = error as? EasyRideError {
                switch easyRideError {
                case .orderNotFound:
                    errorMessage = "Order not found"
                    await stopTracking()
                case .networkError:
                    // Don't show network errors for location updates to avoid spam
                    print("Network error updating driver location: \(error.localizedDescription)")
                default:
                    print("Failed to update driver location: \(error.localizedDescription)")
                }
            } else {
                print("Failed to update driver location: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Status Change Handling
    
    @MainActor
    private func handleStatusChange(from previousStatus: OrderStatus?, to newStatus: OrderStatus) async {
        // Send notification for status change
        sendStatusChangeNotification(from: previousStatus, to: newStatus)
        
        switch newStatus {
        case .matched:
            // Driver found, stop matching and start location tracking
            isMatching = false
            matchingProgress = 1.0
            startLocationTracking()
            isTrackingActive = true
            
        case .driverEnRoute:
            // Driver is on the way
            if !isTrackingActive {
                startLocationTracking()
                isTrackingActive = true
            }
            
        case .arrived:
            // Driver has arrived
            sendDriverArrivedNotification()
            
        case .inProgress:
            // Trip started
            break
            
        case .completed, .cancelled:
            // Trip finished, stop tracking
            await stopTracking()
            
        default:
            break
        }
    }
    
    // MARK: - Notifications
    
    @MainActor
    private func sendStatusChangeNotification(from previousStatus: OrderStatus?, to newStatus: OrderStatus) {
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
        
        // In a real app, you would send push notifications here
        print("Order status changed from \(previousStatus?.displayName ?? "Unknown") to \(newStatus.displayName)")
    }
    
    @MainActor
    private func sendDriverArrivedNotification() {
        #if os(iOS)
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        #endif
        
        // In a real app, you would send a push notification here
        print("Driver has arrived at pickup location")
    }
    
    // MARK: - Communication Actions
    
    @MainActor
    func callDriver() {
        guard let phoneNumber = currentOrder?.driver?.phoneNumber else { return }
        
        if let url = URL(string: "tel:\(phoneNumber)") {
            #if os(iOS)
            UIApplication.shared.open(url)
            #endif
        }
    }
    
    @MainActor
    func messageDriver() {
        guard let phoneNumber = currentOrder?.driver?.phoneNumber else { return }
        
        if let url = URL(string: "sms:\(phoneNumber)") {
            #if os(iOS)
            UIApplication.shared.open(url)
            #endif
        }
    }
    
    // MARK: - Helper Methods
    
    var isDriverAssigned: Bool {
        currentOrder?.driver != nil
    }
    
    var canCommunicateWithDriver: Bool {
        guard let status = currentOrder?.status else { return false }
        return [OrderStatus.matched, OrderStatus.driverEnRoute, OrderStatus.arrived, OrderStatus.inProgress].contains(status)
    }
    
    var statusDisplayText: String {
        guard let status = currentOrder?.status else { return "Unknown" }
        
        switch status {
        case .pending:
            return "Order Confirmed"
        case .matching:
            return "Finding Driver..."
        case .matched:
            return "Driver Assigned"
        case .driverEnRoute:
            return "Driver En Route"
        case .arrived:
            return "Driver Arrived"
        case .inProgress:
            return "Trip in Progress"
        case .completed:
            return "Trip Completed"
        case .cancelled:
            return "Trip Cancelled"
        }
    }
    
    var estimatedArrivalText: String? {
        guard let estimatedArrival = currentOrder?.driver?.estimatedArrival else { return nil }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "ETA: \(formatter.string(from: estimatedArrival))"
    }
}

// MARK: - Response Models

struct LocationUpdateResponse: Codable {
    let location: Location
    let estimatedArrival: Date?
    let status: OrderStatus
}