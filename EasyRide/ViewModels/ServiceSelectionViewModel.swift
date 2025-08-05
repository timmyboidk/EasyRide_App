import Foundation
import Observation

@Observable
class ServiceSelectionViewModel {
    // MARK: - Dependencies
    private let apiService: APIService
    private let appState: AppState
    
    // MARK: - State
    var selectedService: ServiceType?
    var estimatedPrices: [ServiceType: Double] = [:]
    var isLoadingPrices: Bool = false
    var priceEstimationError: EasyRideError?
    

    
    init(apiService: APIService = EasyRideAPIService.shared, appState: AppState) {
        self.apiService = apiService
        self.appState = appState
        
        // Load initial price estimates
        loadInitialPriceEstimates()
    }
    
    // MARK: - Service Selection
    func selectService(_ serviceType: ServiceType) {
        selectedService = serviceType
        appState.selectedService = serviceType
        
        // Estimate price for selected service if we have location
        if let currentLocation = appState.currentLocation {
            Task {
                await estimatePrice(for: serviceType, from: currentLocation)
            }
        }
    }
    
    func deselectService() {
        selectedService = nil
        appState.selectedService = nil
    }
    
    var canProceed: Bool {
        return selectedService != nil
    }
    
    // MARK: - Price Estimation
    func estimatePrice(for serviceType: ServiceType, from pickupLocation: Location, to destination: Location? = nil) async {
        isLoadingPrices = true
        priceEstimationError = nil
        
        let request = PriceEstimateRequest(
            serviceType: serviceType,
            pickupLocation: pickupLocation,
            destination: destination,
            stops: [],
            serviceOptions: [],
            scheduledTime: nil
        )
        
        do {
            let response: PriceEstimateResponse = try await apiService.request(.estimatePrice(request))
            
            await MainActor.run {
                estimatedPrices[serviceType] = response.totalPrice
                appState.estimatedPrice = response.totalPrice
                isLoadingPrices = false
            }
        } catch {
            await MainActor.run {
                if let easyRideError = error as? EasyRideError {
                    priceEstimationError = easyRideError
                } else {
                    priceEstimationError = .networkError(error.localizedDescription)
                }
                isLoadingPrices = false
            }
        }
    }
    
    private func loadInitialPriceEstimates() {
        // Load base prices for display
        for serviceType in ServiceType.allCases {
            estimatedPrices[serviceType] = serviceType.basePrice
        }
    }
    
    // MARK: - Helper Methods
    func formattedPrice(for serviceType: ServiceType) -> String {
        guard let price = estimatedPrices[serviceType] else {
            return "From $\(Int(serviceType.basePrice))"
        }
        
        return "$\(Int(price))"
    }
    
    func isServiceSelected(_ serviceType: ServiceType) -> Bool {
        return selectedService == serviceType
    }
    
    func serviceCardId(for serviceType: ServiceType) -> String {
        return "service-card-\(serviceType.rawValue)"
    }
}
