import Foundation
import SwiftUI

#if os(iOS)
// Example usage of BookingViewModel in a SwiftUI View
struct BookingFlowView: View {
    @State private var appState = AppState()
    @State private var bookingViewModel: BookingViewModel
    
    init() {
        let appState = AppState()
        self.appState = appState
        self.bookingViewModel = BookingViewModel(appState: appState)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Order Creation Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Create Order")
                        .font(.headline)
                    
                    if bookingViewModel.isCreatingOrder {
                        ProgressView("Creating order...")
                    } else {
                        Button("Create Order") {
                            Task {
                                await createSampleOrder()
                            }
                        }
                        .disabled(!canCreateOrder)
                        .buttonStyle(.borderedProminent)
                    }
                    
                    if let error = bookingViewModel.orderCreationError {
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    if let order = bookingViewModel.createdOrder {
                        Text("Order created: \(order.id)")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Order History Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Order History")
                        .font(.headline)
                    
                    if bookingViewModel.isLoadingHistory {
                        ProgressView("Loading history...")
                    } else {
                        Button("Load History") {
                            Task {
                                await bookingViewModel.loadOrderHistory()
                            }
                        }
                        .buttonStyle(.bordered)
                        
                        if !bookingViewModel.orderHistory.isEmpty {
                            Text("\(bookingViewModel.orderHistory.count) orders found")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let error = bookingViewModel.historyError {
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Active Order Section
                if let activeOrder = appState.activeOrder {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Active Order")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ID: \(activeOrder.id)")
                                .font(.caption)
                            Text("Service: \(activeOrder.serviceType.displayName)")
                                .font(.caption)
                            Text("Status: \(activeOrder.status.displayName)")
                                .font(.caption)
                            Text("Price: $\(Int(activeOrder.estimatedPrice))")
                                .font(.caption)
                        }
                        
                        HStack {
                            if bookingViewModel.canCancelOrder(activeOrder) {
                                Button("Cancel Order") {
                                    Task {
                                        await bookingViewModel.cancelActiveOrder(reason: "User requested")
                                    }
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.red)
                                .disabled(bookingViewModel.isCancellingOrder)
                            }
                            
                            Button("Track Order") {
                                Task {
                                    await bookingViewModel.startOrderTracking(orderId: activeOrder.id)
                                }
                            }
                            .buttonStyle(.bordered)
                            .disabled(bookingViewModel.isTrackingOrder)
                        }
                        
                        if bookingViewModel.isCancellingOrder {
                            ProgressView("Cancelling...")
                                .scaleEffect(0.8)
                        }
                        
                        if let error = bookingViewModel.cancellationError {
                            Text(error.localizedDescription)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Booking Management")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear Errors") {
                        bookingViewModel.clearErrors()
                    }
                }
            }
        }
    }
    
    private var canCreateOrder: Bool {
        appState.selectedService != nil && appState.tripConfiguration != nil
    }
    
    private func createSampleOrder() async {
        // Setup sample booking data
        appState.selectedService = .airport
        appState.tripConfiguration = TripConfiguration(
            mode: .freeRoute,
            pickupLocation: Location(
                latitude: 37.7749,
                longitude: -122.4194,
                address: "San Francisco International Airport"
            ),
            destination: Location(
                latitude: 37.7849,
                longitude: -122.4094,
                address: "Downtown San Francisco"
            ),
            passengerCount: 2,
            notes: "Please wait at Terminal 1"
        )
        
        await bookingViewModel.createOrder()
    }
}

// Example of using BookingViewModel in a more complex booking flow
struct CompleteBookingFlow: View {
    @State private var appState = AppState()
    @State private var bookingViewModel: BookingViewModel
    @State private var currentStep: BookingStep = .serviceSelection
    
    enum BookingStep {
        case serviceSelection
        case tripConfiguration
        case orderCreation
        case orderTracking
    }
    
    init() {
        let appState = AppState()
        self.appState = appState
        self.bookingViewModel = BookingViewModel(appState: appState)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress indicator
                ProgressView(value: progressValue, total: 1.0)
                    .padding()
                
                // Current step content
                Group {
                    switch currentStep {
                    case .serviceSelection:
                        serviceSelectionView
                    case .tripConfiguration:
                        tripConfigurationView
                    case .orderCreation:
                        orderCreationView
                    case .orderTracking:
                        orderTrackingView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Navigation buttons
                HStack {
                    if currentStep != .serviceSelection {
                        Button("Back") {
                            goToPreviousStep()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    if canProceedToNextStep {
                        Button(nextButtonTitle) {
                            Task {
                                await goToNextStep()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isProcessing)
                    }
                }
                .padding()
            }
            .navigationTitle("Book a Ride")
        }
    }
    
    private var progressValue: Double {
        switch currentStep {
        case .serviceSelection: return 0.25
        case .tripConfiguration: return 0.5
        case .orderCreation: return 0.75
        case .orderTracking: return 1.0
        }
    }
    
    private var nextButtonTitle: String {
        switch currentStep {
        case .serviceSelection: return "Configure Trip"
        case .tripConfiguration: return "Create Order"
        case .orderCreation: return "Track Order"
        case .orderTracking: return "Complete"
        }
    }
    
    private var canProceedToNextStep: Bool {
        switch currentStep {
        case .serviceSelection:
            return appState.selectedService != nil
        case .tripConfiguration:
            return appState.tripConfiguration != nil
        case .orderCreation:
            return bookingViewModel.createdOrder != nil
        case .orderTracking:
            return true
        }
    }
    
    private var isProcessing: Bool {
        bookingViewModel.isCreatingOrder || bookingViewModel.isTrackingOrder
    }
    
    private func goToPreviousStep() {
        switch currentStep {
        case .tripConfiguration:
            currentStep = .serviceSelection
        case .orderCreation:
            currentStep = .tripConfiguration
        case .orderTracking:
            currentStep = .orderCreation
        case .serviceSelection:
            break
        }
    }
    
    private func goToNextStep() async {
        switch currentStep {
        case .serviceSelection:
            currentStep = .tripConfiguration
        case .tripConfiguration:
            currentStep = .orderCreation
            await bookingViewModel.createOrder()
        case .orderCreation:
            currentStep = .orderTracking
            if let orderId = bookingViewModel.createdOrder?.id {
                await bookingViewModel.startOrderTracking(orderId: orderId)
            }
        case .orderTracking:
            // Complete the flow
            bookingViewModel.resetBookingState()
            currentStep = .serviceSelection
        }
    }
    
    // MARK: - Step Views
    
    private var serviceSelectionView: some View {
        VStack(spacing: 20) {
            Text("Select a Service")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(ServiceType.allCases, id: \.self) { serviceType in
                    Button(action: {
                        appState.selectedService = serviceType
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: serviceType.icon)
                                .font(.largeTitle)
                            Text(serviceType.displayName)
                                .font(.headline)
                            Text("From $\(Int(serviceType.basePrice))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .background(
                            appState.selectedService == serviceType ?
                            Color.blue.opacity(0.2) : Color.gray.opacity(0.1)
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
    }
    
    private var tripConfigurationView: some View {
        VStack(spacing: 20) {
            Text("Configure Your Trip")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Pickup Location")
                    .font(.headline)
                TextField("Enter pickup address", text: .constant("Sample Pickup Location"))
                    .textFieldStyle(.roundedBorder)
                
                Text("Destination")
                    .font(.headline)
                TextField("Enter destination", text: .constant("Sample Destination"))
                    .textFieldStyle(.roundedBorder)
                
                Text("Passengers")
                    .font(.headline)
                Stepper("Passengers: 2", value: .constant(2), in: 1...8)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Button("Set Sample Configuration") {
                appState.tripConfiguration = TripConfiguration(
                    mode: .freeRoute,
                    pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Sample Pickup"),
                    destination: Location(latitude: 37.7849, longitude: -122.4094, address: "Sample Destination"),
                    passengerCount: 2
                )
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    private var orderCreationView: some View {
        VStack(spacing: 20) {
            Text("Create Your Order")
                .font(.title2)
                .fontWeight(.semibold)
            
            if bookingViewModel.isCreatingOrder {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Creating your order...")
                        .font(.headline)
                }
            } else if let order = bookingViewModel.createdOrder {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Order Created Successfully!")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Order ID: \(order.id)")
                        Text("Service: \(order.serviceType.displayName)")
                        Text("Status: \(order.status.displayName)")
                        Text("Estimated Price: $\(Int(order.estimatedPrice))")
                    }
                    .font(.caption)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            } else if let error = bookingViewModel.orderCreationError {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("Order Creation Failed")
                        .font(.headline)
                    
                    Text(error.localizedDescription)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
    }
    
    private var orderTrackingView: some View {
        VStack(spacing: 20) {
            Text("Track Your Order")
                .font(.title2)
                .fontWeight(.semibold)
            
            if bookingViewModel.isTrackingOrder {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Tracking your order...")
                        .font(.headline)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Order Tracking")
                        .font(.headline)
                    
                    if let activeOrder = appState.activeOrder {
                        Text("Current Status: \(activeOrder.status.displayName)")
                            .font(.subheadline)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    BookingFlowView()
}

#Preview("Complete Flow") {
    CompleteBookingFlow()
}
#endif
