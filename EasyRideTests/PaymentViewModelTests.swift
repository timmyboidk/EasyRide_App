import XCTest
@testable import EasyRide

@MainActor
class PaymentViewModelTests: XCTestCase {
    var viewModel: PaymentViewModel!
    var mockApiService: MockAPIService!
    var appState: AppState!
    
    override func setUp() {
        super.setUp()
        mockApiService = MockAPIService()
        appState = AppState()
        viewModel = PaymentViewModel(apiService: mockApiService, appState: appState)
    }
    
    func testFetchPaymentMethodsSuccess() async {
        // Arrange
        let methods = [
            PaymentMethod(type: .applePay, displayName: "Apple Pay", isDefault: true),
            PaymentMethod(type: .creditCard, displayName: "Visa", lastFourDigits: "1234")
        ]
        mockApiService.setMockResponse(methods, for: .getPaymentMethods)
        
        // Act
        await viewModel.fetchPaymentMethods()
        
        // Assert
        XCTAssertEqual(viewModel.paymentMethods.count, 2)
        XCTAssertEqual(viewModel.paymentMethods.first?.type, .applePay)
    }
    
    func testProcessPaymentSuccess() async {
        // Arrange
        let mockTransaction = Transaction(id: "t1", amount: 100, type: .payment, description: "Paid", createdAt: Date(), orderId: "o1")
        mockApiService.setMockResponse(mockTransaction, for: .processPayment(PaymentRequest(orderId: "o1", paymentMethodId: "m1", amount: 100)))
        viewModel.selectedMethodId = "m1"
        
        // Act
        let result = await viewModel.processPayment(orderId: "o1", amount: 100)
        
        // Assert
        XCTAssertTrue(result)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testProcessPaymentFailure() async {
        // Arrange
        mockApiService.shouldThrowError = true
        mockApiService.errorToThrow = EasyRideError.networkError("Failed")
        viewModel.selectedMethodId = "m1"
        
        // Act
        let result = await viewModel.processPayment(orderId: "o1", amount: 100)
        
        // Assert
        XCTAssertFalse(result)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
