import Foundation
@testable import EasyRide

class MockAPIService: APIService {
    // Mock response storage
    var mockResponses: [String: Any] = [:]
    var mockErrors: [String: Error] = [:]
    var requestLog: [APIEndpoint] = []
    var shouldThrowError = false
    var errorToThrow: Error = EasyRideError.networkError("Mock error")
    
    // Authentication state
    private var accessToken: String?
    private var refreshToken: String?
    
    init() {
        // Initialize with default mock responses
        setupDefaultMockResponses()
    }
    
    // MARK: - APIService Protocol Methods
    
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        // Log the request
        requestLog.append(endpoint)
        
        // Check if we should throw a global error
        if shouldThrowError {
            throw errorToThrow
        }
        
        // Check if we should throw a specific error for this endpoint
        let endpointKey = getEndpointKey(endpoint)
        if let error = mockErrors[endpointKey] {
            throw error
        }
        
        // Return mock response if available
        if let mockData = mockResponses[endpointKey] as? T {
            return mockData
        }
        
        // Generate default mock response based on endpoint type
        return try generateMockResponse(for: endpoint)
    }
    
    func requestWithoutResponse(_ endpoint: APIEndpoint) async throws {
        // Log the request
        requestLog.append(endpoint)
        
        // Check if we should throw a global error
        if shouldThrowError {
            throw errorToThrow
        }
        
        // Check if we should throw a specific error for this endpoint
        let endpointKey = getEndpointKey(endpoint)
        if let error = mockErrors[endpointKey] {
            throw error
        }
        
        // Success - no response needed
    }
    
    func uploadImage(_ endpoint: APIEndpoint, imageData: Data) async throws -> String {
        // Log the request
        requestLog.append(endpoint)
        
        // Check if we should throw a global error
        if shouldThrowError {
            throw errorToThrow
        }
        
        // Check if we should throw a specific error for this endpoint
        let endpointKey = getEndpointKey(endpoint)
        if let error = mockErrors[endpointKey] {
            throw error
        }
        
        return "https://example.com/mock-image-\(UUID().uuidString).jpg"
    }
    
    // MARK: - Authentication Management
    
    func setAuthTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    func clearAuthTokens() {
        self.accessToken = nil
        self.refreshToken = nil
    }
    
    var isAuthenticated: Bool {
        return accessToken != nil
    }
    
    // MARK: - Mock Configuration
    
    func setMockResponse<T: Codable>(_ response: T, for endpoint: APIEndpoint) {
        let key = getEndpointKey(endpoint)
        mockResponses[key] = response
    }
    
    func setMockError(_ error: Error, for endpoint: APIEndpoint) {
        let key = getEndpointKey(endpoint)
        mockErrors[key] = error
    }
    
    func clearMockResponses() {
        mockResponses.removeAll()
        mockErrors.removeAll()
        setupDefaultMockResponses()
    }
    
    func resetRequestLog() {
        requestLog.removeAll()
    }
    
    // MARK: - Helper Methods
    
    private func getEndpointKey(_ endpoint: APIEndpoint) -> String {
        return "\(endpoint.path)-\(endpoint.httpMethod.rawValue)"
    }
    
    private func setupDefaultMockResponses() {
        // Set up default mock responses for common endpoints
        
        // Authentication responses
        let mockUser = User(
            id: "mock-user-123",
            nickname: "Test User",
            profileImage: "https://example.com/profile.jpg",
            phoneNumber: "+1234567890",
            frequentAddresses: [],
            paymentMethods: [],
            favoriteDrivers: [],
            vipLevel: .standard
        )
        
        let mockAuthResponse = AuthResponse(
            accessToken: "mock-access-token",
            refreshToken: "mock-refresh-token",
            user: mockUser,
            expiresIn: 3600
        )
        
        setMockResponse(mockAuthResponse, for: .login(phoneNumber: "", password: ""))
        setMockResponse(mockAuthResponse, for: .loginOTP(phoneNumber: "", otp: ""))
        setMockResponse(mockAuthResponse, for: .register(RegisterRequest(phoneNumber: "", password: "", nickname: "", email: nil)))
        setMockResponse(mockAuthResponse, for: .refreshToken(refreshToken: ""))
        
        // Order responses
        let mockOrder = Order(
            id: "mock-order-123",
            serviceType: .airport,
            status: .matched,
            pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup"),
            destination: Location(latitude: 37.7849, longitude: -122.4094, address: "Test Destination"),
            estimatedPrice: 25.0,
            driver: Driver(
                id: "mock-driver-123",
                name: "John Driver",
                phoneNumber: "+1987654321",
                rating: 4.8,
                profileImage: "https://example.com/driver.jpg",
                carModel: "Tesla Model Y",
                carColor: "White",
                licensePlate: "ABC123",
                estimatedArrival: Date().addingTimeInterval(300)
            ),
            createdAt: Date(),
            scheduledTime: nil
        )
        
        setMockResponse(mockOrder, for: .createOrder(OrderRequest(
            serviceType: .airport,
            pickupLocation: Location(latitude: 0, longitude: 0, address: ""),
            destination: nil,
            scheduledTime: nil,
            passengerCount: 1,
            notes: nil,
            stops: [],
            serviceOptions: []
        )))
        
        setMockResponse(mockOrder, for: .getOrder(orderId: "mock-order-123"))
        
        // Order history response
        let mockOrderHistory = OrderHistoryResponse(
            orders: [
                Order(
                    id: "order-1",
                    serviceType: .airport,
                    status: .completed,
                    pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Test Pickup 1"),
                    estimatedPrice: 25.0
                ),
                Order(
                    id: "order-2",
                    serviceType: .longDistance,
                    status: .cancelled,
                    pickupLocation: Location(latitude: 37.7849, longitude: -122.4294, address: "Test Pickup 2"),
                    estimatedPrice: 45.0
                )
            ],
            hasMore: false,
            totalCount: 2,
            currentPage: 1
        )
        
        setMockResponse(mockOrderHistory, for: .getOrderHistory(page: 1, limit: 10))
        
        // Location update response
        let mockLocationUpdate = LocationUpdateResponse(
            location: Location(latitude: 37.7749, longitude: -122.4194, address: "Driver Location"),
            estimatedArrival: Date().addingTimeInterval(300),
            status: .driverEnRoute
        )
        
        setMockResponse(mockLocationUpdate, for: .getDriverLocation(orderId: "mock-order-123"))
        
        // Price estimate response
        let mockPriceEstimate = PriceEstimateResponse(
            basePrice: 20.0,
            serviceFeesTotal: 5.0,
            totalPrice: 25.0,
            estimatedDuration: 1200, // 20 minutes
            estimatedDistance: 10.0, // 10 km
            breakdown: [
                PriceBreakdownItem(name: "Base Fare", amount: 20.0, type: .baseFare),
                PriceBreakdownItem(name: "Service Fee", amount: 3.0, type: .serviceFee),
                PriceBreakdownItem(name: "Tax", amount: 2.0, type: .tax)
            ]
        )
        
        setMockResponse(mockPriceEstimate, for: .estimatePrice(PriceEstimateRequest(
            serviceType: .airport,
            pickupLocation: Location(latitude: 0, longitude: 0, address: ""),
            destination: nil,
            stops: [],
            serviceOptions: [],
            scheduledTime: nil
        )))
        
        // Wallet response
        let mockWallet = WalletResponse(
            balance: 100.0,
            currency: "USD",
            transactions: [
                Transaction(
                    id: "tx-1",
                    amount: 25.0,
                    type: .payment,
                    description: "Airport Transfer",
                    createdAt: Date().addingTimeInterval(-86400), // 1 day ago
                    orderId: "order-1"
                ),
                Transaction(
                    id: "tx-2",
                    amount: 50.0,
                    type: .topUp,
                    description: "Add Funds",
                    createdAt: Date().addingTimeInterval(-172800), // 2 days ago
                    orderId: nil
                )
            ]
        )
        
        setMockResponse(mockWallet, for: .getWallet)
    }
    
    private func generateMockResponse<T: Codable>(for endpoint: APIEndpoint) throws -> T {
        // Generate a mock response based on the expected return type
        
        switch endpoint {
        case .getOrder:
            let mockOrder = Order(
                id: "generated-order-123",
                serviceType: .airport,
                status: .matched,
                pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "Generated Pickup"),
                estimatedPrice: 25.0
            )
            
            if let response = mockOrder as? T {
                return response
            }
            
        case .getDriverLocation:
            let mockLocationUpdate = LocationUpdateResponse(
                location: Location(latitude: 37.7749, longitude: -122.4194, address: "Generated Driver Location"),
                estimatedArrival: Date().addingTimeInterval(300),
                status: .driverEnRoute
            )
            
            if let response = mockLocationUpdate as? T {
                return response
            }
            
        case .login, .loginOTP, .register, .refreshToken:
            let mockUser = User(
                id: "generated-user-123",
                nickname: "Generated User",
                profileImage: "https://example.com/profile.jpg",
                phoneNumber: "+1234567890",
                frequentAddresses: [],
                paymentMethods: [],
                favoriteDrivers: [],
                vipLevel: .standard
            )
            
            let mockAuthResponse = AuthResponse(
                accessToken: "generated-access-token",
                refreshToken: "generated-refresh-token",
                user: mockUser,
                expiresIn: 3600
            )
            
            if let response = mockAuthResponse as? T {
                return response
            }
            
        default:
            break
        }
        
        // If we can't generate a specific mock, throw an error
        throw EasyRideError.unknownError
    }
}