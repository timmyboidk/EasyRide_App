import Foundation

enum APIEndpoint {
    // Authentication
    case login(phoneNumber: String, password: String)
    case loginOTP(phoneNumber: String, otp: String)
    case register(RegisterRequest)
    case refreshToken(refreshToken: String)
    case logout
    
    // User Management
    case getUserProfile
    case updateUserProfile(User)
    case uploadProfileImage(Data)
    
    // Order Management
    case createOrder(OrderRequest)
    case getOrder(orderId: String)
    case updateOrderStatus(orderId: String, status: OrderStatus)
    case cancelOrder(orderId: String, reason: String?)
    case getOrderHistory(page: Int, limit: Int)
    case estimatePrice(PriceEstimateRequest)
    
    // Location Services
    case getDriverLocation(orderId: String)
    case updateDriverLocation(orderId: String, location: Location)
    case searchLocations(query: String, latitude: Double?, longitude: Double?)
    case getLocationDetails(placeId: String)
    
    // Driver Management
    case getAvailableDrivers(location: Location, serviceType: ServiceType)
    case getDriverProfile(driverId: String)
    case rateDriver(driverId: String, rating: Int, comment: String?)
    
    // Payment
    case getPaymentMethods
    case addPaymentMethod(PaymentMethodRequest)
    case removePaymentMethod(paymentMethodId: String)
    case processPayment(PaymentRequest)
    case getWallet
    case addFundsToWallet(amount: Double, paymentMethodId: String)
    case getTransactionHistory(page: Int, limit: Int)
    
    // Messaging
    case sendMessage(orderId: String, message: String, messageType: MessageType)
    case getMessages(orderId: String, page: Int, limit: Int)
    case markMessagesAsRead(orderId: String, messageIds: [String])
    case sendTypingIndicator(orderId: String, isTyping: Bool)
    
    // Trip Modification
    case calculateFareAdjustment(orderId: String, modification: TripModificationRequest)
    case requestTripModification(orderId: String, modification: TripModificationRequest)
    
    var httpMethod: HTTPMethod {
        switch self {
        case .login, .loginOTP, .register, .refreshToken, .createOrder, .estimatePrice, .updateDriverLocation, .addPaymentMethod, .processPayment, .addFundsToWallet, .sendMessage, .sendTypingIndicator, .calculateFareAdjustment, .requestTripModification:
            return .POST
        case .updateUserProfile, .updateOrderStatus, .cancelOrder:
            return .PUT
        case .removePaymentMethod:
            return .DELETE
        case .logout:
            return .POST
        default:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        // Authentication
        case .login:
            return "/api/user/login"
        case .loginOTP:
            return "/api/user/login/otp"
        case .register:
            return "/api/user/register"
        case .refreshToken:
            return "/api/user/refresh"
        case .logout:
            return "/api/user/logout"
            
        // User Management
        case .getUserProfile:
            return "/api/user/profile"
        case .updateUserProfile:
            return "/api/user/profile"
        case .uploadProfileImage:
            return "/api/user/profile/image"
            
        // Order Management
        case .createOrder:
            return "/api/order"
        case .getOrder(let orderId):
            return "/api/order/\(orderId)"
        case .updateOrderStatus(let orderId, _):
            return "/api/order/\(orderId)/status"
        case .cancelOrder(let orderId, _):
            return "/api/order/\(orderId)/cancel"
        case .getOrderHistory:
            return "/api/order/history"
        case .estimatePrice:
            return "/api/order/estimate-price"
            
        // Location Services
        case .getDriverLocation(let orderId):
            return "/api/location/order/\(orderId)"
        case .updateDriverLocation(let orderId, _):
            return "/api/location/order/\(orderId)"
        case .searchLocations:
            return "/api/location/search"
        case .getLocationDetails(let placeId):
            return "/api/location/details/\(placeId)"
            
        // Driver Management
        case .getAvailableDrivers:
            return "/api/driver/available"
        case .getDriverProfile(let driverId):
            return "/api/driver/\(driverId)"
        case .rateDriver(let driverId, _, _):
            return "/api/driver/\(driverId)/rate"
            
        // Payment
        case .getPaymentMethods:
            return "/api/payment/methods"
        case .addPaymentMethod:
            return "/api/payment/methods"
        case .removePaymentMethod(let paymentMethodId):
            return "/api/payment/methods/\(paymentMethodId)"
        case .processPayment:
            return "/api/payment/payments"
        case .getWallet:
            return "/api/payment/wallet"
        case .addFundsToWallet:
            return "/api/payment/wallet/add-funds"
        case .getTransactionHistory:
            return "/api/payment/transactions"
            
        // Messaging
        case .sendMessage(let orderId, _, _):
            return "/api/message/\(orderId)"
        case .getMessages(let orderId, _, _):
            return "/api/message/\(orderId)"
        case .markMessagesAsRead(let orderId, _):
            return "/api/message/\(orderId)/read"
        case .sendTypingIndicator(let orderId, _):
            return "/api/message/\(orderId)/typing"
            
        // Trip Modification
        case .calculateFareAdjustment(let orderId, _):
            return "/api/order/\(orderId)/fare-adjustment"
        case .requestTripModification(let orderId, _):
            return "/api/order/\(orderId)/modify"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getOrderHistory(let page, let limit):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        case .searchLocations(let query, let latitude, let longitude):
            var items = [URLQueryItem(name: "q", value: query)]
            if let lat = latitude, let lng = longitude {
                items.append(URLQueryItem(name: "lat", value: "\(lat)"))
                items.append(URLQueryItem(name: "lng", value: "\(lng)"))
            }
            return items
        case .getAvailableDrivers(let location, let serviceType):
            return [
                URLQueryItem(name: "lat", value: "\(location.latitude)"),
                URLQueryItem(name: "lng", value: "\(location.longitude)"),
                URLQueryItem(name: "service_type", value: serviceType.rawValue)
            ]
        case .getTransactionHistory(let page, let limit):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        case .getMessages(_, let page, let limit):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        default:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .login(let phoneNumber, let password):
            return try? JSONEncoder().encode(LoginRequest(phoneNumber: phoneNumber, password: password))
        case .loginOTP(let phoneNumber, let otp):
            return try? JSONEncoder().encode(OTPRequest(phoneNumber: phoneNumber, otp: otp))
        case .register(let request):
            return try? JSONEncoder().encode(request)
        case .refreshToken(let refreshToken):
            return try? JSONEncoder().encode(RefreshTokenRequest(refreshToken: refreshToken))
        case .updateUserProfile(let user):
            return try? JSONEncoder().encode(user)
        case .createOrder(let request):
            return try? JSONEncoder().encode(request)
        case .updateOrderStatus(_, let status):
            return try? JSONEncoder().encode(OrderStatusUpdate(status: status))
        case .cancelOrder(_, let reason):
            return try? JSONEncoder().encode(CancelOrderRequest(reason: reason))
        case .estimatePrice(let request):
            return try? JSONEncoder().encode(request)
        case .updateDriverLocation(_, let location):
            return try? JSONEncoder().encode(LocationUpdate(location: location))
        case .rateDriver(_, let rating, let comment):
            return try? JSONEncoder().encode(DriverRatingRequest(rating: rating, comment: comment))
        case .addPaymentMethod(let request):
            return try? JSONEncoder().encode(request)
        case .processPayment(let request):
            return try? JSONEncoder().encode(request)
        case .addFundsToWallet(let amount, let paymentMethodId):
            return try? JSONEncoder().encode(AddFundsRequest(amount: amount, paymentMethodId: paymentMethodId))
        case .sendMessage(_, let message, let messageType):
            return try? JSONEncoder().encode(SendMessageRequest(message: message, type: messageType))
        case .markMessagesAsRead(_, let messageIds):
            return try? JSONEncoder().encode(MarkMessagesReadRequest(messageIds: messageIds))
        case .sendTypingIndicator(_, let isTyping):
            return try? JSONEncoder().encode(TypingIndicatorRequest(isTyping: isTyping))
        case .calculateFareAdjustment(_, let modification):
            return try? JSONEncoder().encode(modification)
        case .requestTripModification(_, let modification):
            return try? JSONEncoder().encode(modification)
        case .uploadProfileImage(let imageData):
            return imageData
        default:
            return nil
        }
    }
    
    var headers: [String: String] {
        var headers = ["Content-Type": "application/json"]
        
        switch self {
        case .uploadProfileImage:
            headers["Content-Type"] = "multipart/form-data"
        default:
            break
        }
        
        return headers
    }
    
    var requiresAuthentication: Bool {
        switch self {
        case .login, .loginOTP, .register, .refreshToken:
            return false
        default:
            return true
        }
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

enum MessageType: String, Codable {
    case text = "text"
    case location = "location"
    case image = "image"
    case system = "system"
}

// MARK: - Request Models
struct LoginRequest: Codable {
    let phoneNumber: String
    let password: String
}

struct OTPRequest: Codable {
    let phoneNumber: String
    let otp: String
}

struct RegisterRequest: Codable {
    let phoneNumber: String
    let password: String
    let nickname: String
    let email: String?
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct OrderRequest: Codable {
    let serviceType: ServiceType
    let pickupLocation: Location
    let destination: Location?
    let scheduledTime: Date?
    let passengerCount: Int
    let notes: String?
    let stops: [TripStop]
    let serviceOptions: [ServiceOption]
}

struct PriceEstimateRequest: Codable {
    let serviceType: ServiceType
    let pickupLocation: Location
    let destination: Location?
    let stops: [TripStop]
    let serviceOptions: [ServiceOption]
    let scheduledTime: Date?
}

struct OrderStatusUpdate: Codable {
    let status: OrderStatus
}

struct CancelOrderRequest: Codable {
    let reason: String?
}

struct LocationUpdate: Codable {
    let location: Location
}

struct DriverRatingRequest: Codable {
    let rating: Int
    let comment: String?
}

struct PaymentMethodRequest: Codable {
    let type: PaymentType
    let token: String
    let isDefault: Bool
    let metadata: [String: String]?
    
    init(type: PaymentType, token: String, isDefault: Bool, metadata: [String: String]? = nil) {
        self.type = type
        self.token = token
        self.isDefault = isDefault
        self.metadata = metadata
    }
}

struct PaymentRequest: Codable {
    let orderId: String
    let paymentMethodId: String
    let amount: Double
}

struct AddFundsRequest: Codable {
    let amount: Double
    let paymentMethodId: String
}

struct SendMessageRequest: Codable {
    let message: String
    let type: MessageType
}

struct MarkMessagesReadRequest: Codable {
    let messageIds: [String]
}

struct TypingIndicatorRequest: Codable {
    let isTyping: Bool
}

struct TripModificationRequest: Codable {
    let type: ModificationType
    let newDestination: Location?
    let additionalStops: [TripStop]
    let notes: String?
    
    var description: String {
        switch type {
        case .changeDestination:
            return "Change destination to \(newDestination?.address ?? "new location")"
        case .addStops:
            return "Add \(additionalStops.count) stop(s)"
        case .changeRoute:
            return "Change route"
        case .other:
            return notes ?? "Trip modification"
        }
    }
}

enum ModificationType: String, Codable {
    case changeDestination = "change_destination"
    case addStops = "add_stops"
    case changeRoute = "change_route"
    case other = "other"
}

// MARK: - Response Models
struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: User
    let expiresIn: Int
}

struct PriceEstimateResponse: Codable {
    let basePrice: Double
    let serviceFeesTotal: Double
    let totalPrice: Double
    let estimatedDuration: TimeInterval
    let estimatedDistance: Double
    let breakdown: [PriceBreakdownItem]
}

struct PriceBreakdownItem: Codable {
    let name: String
    let amount: Double
    let type: PriceItemType
}

enum PriceItemType: String, Codable {
    case baseFare = "base_fare"
    case serviceFee = "service_fee"
    case discount = "discount"
    case tax = "tax"
    case tip = "tip"
}

struct LocationSearchResponse: Codable {
    let results: [LocationSearchResult]
}

struct LocationSearchResult: Codable {
    let placeId: String
    let name: String
    let address: String
    let location: Location
    let category: AddressType
}

struct AvailableDriversResponse: Codable {
    let drivers: [Driver]
    let estimatedWaitTime: TimeInterval
}

struct WalletResponse: Codable {
    let balance: Double
    let currency: String
    let transactions: [Transaction]
}

struct Transaction: Codable, Identifiable {
    let id: String
    let amount: Double
    let type: TransactionType
    let description: String
    let createdAt: Date
    let orderId: String?
}

enum TransactionType: String, Codable {
    case payment = "payment"
    case refund = "refund"
    case topUp = "top_up"
    case bonus = "bonus"
    
    var displayName: String {
        switch self {
        case .payment: return "Payment"
        case .refund: return "Refund"
        case .topUp: return "Add Funds"
        case .bonus: return "Bonus"
        }
    }
    
    var icon: String {
        switch self {
        case .payment: return "arrow.up.circle.fill"
        case .refund: return "arrow.down.circle.fill"
        case .topUp: return "plus.circle.fill"
        case .bonus: return "gift.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .payment: return "red"
        case .refund: return "green"
        case .topUp: return "blue"
        case .bonus: return "purple"
        }
    }
}

struct MessagesResponse: Codable {
    let messages: [Message]
    let hasMore: Bool
    let unreadCount: Int
}

struct OrderHistoryResponse: Codable {
    let orders: [Order]
    let hasMore: Bool
    let totalCount: Int
    let currentPage: Int
}

struct FareAdjustmentResponse: Codable {
    let adjustment: Double
    let newTotalFare: Double
    let breakdown: [PriceBreakdownItem]
}
