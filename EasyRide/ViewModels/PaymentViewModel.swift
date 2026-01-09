import SwiftUI

@MainActor
class PaymentViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var paymentMethods: [PaymentMethod] = []
    @Published var selectedMethodId: String?
    @Published var walletBalance: Double = 0.0
    
    // For payment processing results
    @Published var paymentSuccess = false
    
    private let apiService: APIService
    private let appState: AppState
    
    init(apiService: APIService = EasyRideAPIService.shared, appState: AppState) {
        self.apiService = apiService
        self.appState = appState
    }
    
    // MARK: - Fetch Data
    
    func fetchPaymentMethods() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let methods: [PaymentMethod] = try await apiService.request(.getPaymentMethods)
            self.paymentMethods = methods
            
            // Set default if none selected
            if selectedMethodId == nil, let defaultMethod = methods.first(where: { $0.isDefault }) {
                selectedMethodId = defaultMethod.id
            } else if selectedMethodId == nil {
                selectedMethodId = methods.first?.id
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchWalletBalance() async {
        do {
            let wallet: WalletResponse = try await apiService.request(.getWallet)
            self.walletBalance = wallet.balance
        } catch {
            print("Failed to fetch wallet: \(error)")
        }
    }
    
    // MARK: - Actions
    
    func processPayment(orderId: String, amount: Double) async -> Bool {
        guard let methodId = selectedMethodId else {
            errorMessage = "Please select a payment method"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        paymentSuccess = false
        
        let validAmount = max(amount, 0.01) // Ensure positive amount
        
        let request = PaymentRequest(
            orderId: orderId,
            paymentMethodId: methodId,
            amount: validAmount
        )
        
        do {
            // Assuming the endpoint returns a transaction or success object. 
            // If it returns Transaction object:
            let _: Transaction = try await apiService.request(.processPayment(request))
            
            paymentSuccess = true
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func selectMethod(_ methodId: String) {
        selectedMethodId = methodId
    }
}
