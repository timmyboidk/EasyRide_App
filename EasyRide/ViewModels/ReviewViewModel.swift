import SwiftUI

@MainActor
class ReviewViewModel: ObservableObject {
    @Published var rating: Int = 5
    @Published var comment: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSubmitted = false
    
    private let apiService: APIService
    
    init(apiService: APIService = EasyRideAPIService.shared) {
        self.apiService = apiService
    }
    
    func submitReview(driverId: String, orderId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Using requestWithoutResponse because rateDriver usually returns empty or status
            // Checking APIEndpoint.swift: rateDriver currently maps to .rateDriver(driverId, rating, comment)
            
            // NOTE: The API endpoint maps to /api/driver/{id}/rate.
            // Ideally it should link to the Order as well, but based on APIEndpoint it seems it's driver-centric.
            // We will proceed with what's available.
            
            let _: EmptyResponse = try await apiService.request(.rateDriver(driverId: driverId, rating: rating, comment: comment))
            
            isSubmitted = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // Helper struct for empty JSON responses if not defined
    struct EmptyResponse: Codable {}
}
