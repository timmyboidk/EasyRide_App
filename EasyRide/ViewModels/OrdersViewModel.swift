
import Foundation
import Combine

@MainActor
class OrdersViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService: APIService
    
    init(apiService: APIService = EasyRideAPIService.shared) {
        self.apiService = apiService
    }
    
    func fetchOrders() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Hardcoded page/limit for now
            let response: OrderHistoryResponse = try await apiService.request(.getOrderHistory(page: 1, limit: 20))
            self.orders = response.orders
        } catch {
            self.errorMessage = error.localizedDescription
            // For demo purposes, if it fails (e.g. no backend), we might want to show dummy data or just empty.
            // But let's keep it real.
        }
        
        isLoading = false
    }
}
