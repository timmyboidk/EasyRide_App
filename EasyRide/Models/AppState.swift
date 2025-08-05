import Foundation
import Observation

@Observable
class AppState {
    // MARK: - Authentication State
    var currentUser: User?
    var isAuthenticated: Bool = false
    var authToken: String?
    
    // MARK: - Booking State
    var selectedService: ServiceType?
    var tripConfiguration: TripConfiguration?
    var estimatedPrice: Double?
    var activeOrder: Order?
    
    // MARK: - UI State
    var isLoading: Bool = false
    var currentError: EasyRideError?
    var showingError: Bool = false
    
    // MARK: - Localization State
    var preferredLanguage: String? {
        didSet {
            if let language = preferredLanguage {
                UserDefaults.standard.set([language], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    // MARK: - Location State
    var currentLocation: Location?
    var hasLocationPermission: Bool = false
    
    // MARK: - Order History
    var orderHistory: [Order] = []
    var favoriteLocations: [Address] = []
    
    init() {
        // Initialize with default state
        loadPersistedState()
    }
    
    // MARK: - Authentication Methods
    func signIn(user: User, token: String) {
        currentUser = user
        authToken = token
        isAuthenticated = true
        
        // Store tokens securely
        SecureStorage.shared.storeAccessToken(token)
        
        savePersistedState()
    }
    
    func signOut() {
        currentUser = nil
        authToken = nil
        isAuthenticated = false
        activeOrder = nil
        selectedService = nil
        tripConfiguration = nil
        estimatedPrice = nil
        
        // Clear secure storage
        SecureStorage.shared.clearAllTokens()
        
        clearPersistedState()
    }
    
    // MARK: - Booking Methods
    func startBooking(serviceType: ServiceType) {
        selectedService = serviceType
        tripConfiguration = nil
        estimatedPrice = nil
    }
    
    func updateTripConfiguration(_ config: TripConfiguration) {
        tripConfiguration = config
    }
    
    func updateEstimatedPrice(_ price: Double) {
        estimatedPrice = price
    }
    
    func createOrder(_ order: Order) {
        activeOrder = order
        orderHistory.insert(order, at: 0)
        savePersistedState()
    }
    
    func updateOrderStatus(_ status: OrderStatus) {
        activeOrder?.status = status
        
        // Update order in history
        if let activeOrder = activeOrder,
           let index = orderHistory.firstIndex(where: { $0.id == activeOrder.id }) {
            orderHistory[index] = activeOrder
        }
        
        savePersistedState()
    }
    
    func completeOrder() {
        if let order = activeOrder {
            var completedOrder = order
            completedOrder.status = .completed
            completedOrder.completedAt = Date()
            
            if let index = orderHistory.firstIndex(where: { $0.id == order.id }) {
                orderHistory[index] = completedOrder
            }
        }
        
        activeOrder = nil
        selectedService = nil
        tripConfiguration = nil
        estimatedPrice = nil
        savePersistedState()
    }
    
    func cancelOrder() {
        if let order = activeOrder {
            var cancelledOrder = order
            cancelledOrder.status = .cancelled
            
            if let index = orderHistory.firstIndex(where: { $0.id == order.id }) {
                orderHistory[index] = cancelledOrder
            }
        }
        
        activeOrder = nil
        selectedService = nil
        tripConfiguration = nil
        estimatedPrice = nil
        savePersistedState()
    }
    
    // MARK: - Error Handling
    func handleError(_ error: Error) {
        if let easyRideError = error as? EasyRideError {
            currentError = easyRideError
        } else {
            currentError = .networkError(error.localizedDescription)
        }
        showingError = true
    }
    
    func clearError() {
        currentError = nil
        showingError = false
    }
    
    // MARK: - Location Methods
    func updateCurrentLocation(_ location: Location) {
        currentLocation = location
    }
    
    func addFavoriteLocation(_ address: Address) {
        if !favoriteLocations.contains(where: { $0.id == address.id }) {
            favoriteLocations.append(address)
            savePersistedState()
        }
    }
    
    func removeFavoriteLocation(_ address: Address) {
        favoriteLocations.removeAll { $0.id == address.id }
        savePersistedState()
    }
    
    // MARK: - Persistence
    private func savePersistedState() {
        // Save essential state to UserDefaults
        if let userData = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
        
        if let historyData = try? JSONEncoder().encode(orderHistory) {
            UserDefaults.standard.set(historyData, forKey: "orderHistory")
        }
        
        if let favoritesData = try? JSONEncoder().encode(favoriteLocations) {
            UserDefaults.standard.set(favoritesData, forKey: "favoriteLocations")
        }
        
        // Authentication state is managed by SecureStorage
    }
    
    private func loadPersistedState() {
        // Load persisted state from UserDefaults
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }
        
        if let historyData = UserDefaults.standard.data(forKey: "orderHistory"),
           let history = try? JSONDecoder().decode([Order].self, from: historyData) {
            orderHistory = history
            
            // Set active order if there's one in progress
            activeOrder = history.first { $0.status.isActive }
        }
        
        if let favoritesData = UserDefaults.standard.data(forKey: "favoriteLocations"),
           let favorites = try? JSONDecoder().decode([Address].self, from: favoritesData) {
            favoriteLocations = favorites
        }
        
        // Load preferred language
        if let languages = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String],
           let language = languages.first {
            preferredLanguage = language
        }
        
        // Check authentication state from secure storage
        authToken = SecureStorage.shared.getAccessToken()
        isAuthenticated = authToken != nil
    }
    
    private func clearPersistedState() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.removeObject(forKey: "orderHistory")
        UserDefaults.standard.removeObject(forKey: "favoriteLocations")
        // Authentication state is managed by SecureStorage
    }
}
