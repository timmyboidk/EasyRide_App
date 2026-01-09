import Foundation

public enum APIEndpoint {
    // Authentication
    case loginOTP(phoneNumber: String, otp: String)
    case loginPassword(phoneNumber: String, password: String)
    case loginWeChat(code: String, phoneNumber: String?)
    case register(RegisterRequest)
    case otpRequest(phoneNumber: String)
    case passwordReset(phoneNumber: String, otp: String, newPassword: String)
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
    
    public var httpMethod: HTTPMethod {
        switch self {
        case .loginOTP, .loginPassword, .loginWeChat, .register, .otpRequest, .passwordReset, .refreshToken, .createOrder, .estimatePrice, .updateDriverLocation, .addPaymentMethod, .processPayment, .addFundsToWallet, .sendMessage, .sendTypingIndicator, .calculateFareAdjustment, .requestTripModification:
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
    
    public var path: String {
        switch self {
        // Authentication
        case .loginOTP:
            return "/api/user/auth/login/otp"
        case .loginPassword:
            return "/api/user/auth/login/password"
        case .loginWeChat:
            return "/api/user/auth/login/wechat"
        case .register:
            return "/api/user/auth/register"
        case .otpRequest:
            return "/api/user/auth/otp/request"
        case .passwordReset:
            return "/api/user/auth/password/reset"
        case .refreshToken:
            return "/api/user/auth/refresh"
        case .logout:
            return "/api/user/auth/logout"
            
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
    
    public var queryItems: [URLQueryItem]? {
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
    
    public var body: Data? {
        switch self {
        case .loginOTP(let phoneNumber, let otp):
            return try? JSONEncoder().encode(OTPRequest(phoneNumber: phoneNumber, otp: otp))
        case .loginPassword(let phoneNumber, let password):
            return try? JSONEncoder().encode(PasswordLoginRequest(phoneNumber: phoneNumber, password: password))
        case .loginWeChat(let code, let phoneNumber):
            return try? JSONEncoder().encode(WeChatLoginRequest(code: code, phoneNumber: phoneNumber))
        case .otpRequest(let phoneNumber):
             return try? JSONEncoder().encode(["phoneNumber": phoneNumber])
        case .passwordReset(let phoneNumber, let otp, let newPassword):
             return try? JSONEncoder().encode(PasswordResetRequest(phoneNumber: phoneNumber, otp: otp, newPassword: newPassword))
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
    
    public var headers: [String: String] {
        var headers = ["Content-Type": "application/json"]
        
        switch self {
        case .uploadProfileImage:
            headers["Content-Type"] = "multipart/form-data"
        default:
            break
        }
        
        return headers
    }
    
    public var requiresAuthentication: Bool {
        switch self {
        case .loginOTP, .loginPassword, .loginWeChat, .register, .otpRequest, .passwordReset, .refreshToken:
            return false
        default:
            return true
        }
    }
}

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

public enum MessageType: String, Codable {
    case text = "text"
    case location = "location"
    case image = "image"
    case system = "system"
}

// MARK: - Request Models
public struct WeChatLoginRequest: Codable {
    public let code: String
    public let phoneNumber: String?
    
    public init(code: String, phoneNumber: String? = nil) {
        self.code = code
        self.phoneNumber = phoneNumber
    }
}

public struct OTPRequest: Codable {
    public let phoneNumber: String
    public let otp: String
    
    public init(phoneNumber: String, otp: String) {
        self.phoneNumber = phoneNumber
        self.otp = otp
    }
}

public struct PasswordLoginRequest: Codable {
    public let phoneNumber: String
    public let password: String
    
    public init(phoneNumber: String, password: String) {
        self.phoneNumber = phoneNumber
        self.password = password
    }
}

public struct PasswordResetRequest: Codable {
    public let phoneNumber: String
    public let otp: String
    public let newPassword: String
    
    public init(phoneNumber: String, otp: String, newPassword: String) {
        self.phoneNumber = phoneNumber
        self.otp = otp
        self.newPassword = newPassword
    }
}


public struct RegisterRequest: Codable {
    public let phoneNumber: String
    // let password: String // REMOVED PASSWORD
    public let otp: String // Added OTP
    public let nickname: String
    public let email: String?
    
    public init(phoneNumber: String, otp: String, nickname: String, email: String? = nil) {
        self.phoneNumber = phoneNumber
        self.otp = otp
        self.nickname = nickname
        self.email = email
    }
}

public struct RefreshTokenRequest: Codable {
    public let refreshToken: String
    
    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}

public struct OrderRequest: Codable {
    public let serviceType: ServiceType
    public let pickupLocation: Location
    public let destination: Location?
    public let scheduledTime: Date?
    public let passengerCount: Int
    public let notes: String?
    public let stops: [TripStop]
    public let serviceOptions: [ServiceOption]
    
    public init(serviceType: ServiceType, pickupLocation: Location, destination: Location?, scheduledTime: Date?, passengerCount: Int, notes: String?, stops: [TripStop], serviceOptions: [ServiceOption]) {
        self.serviceType = serviceType
        self.pickupLocation = pickupLocation
        self.destination = destination
        self.scheduledTime = scheduledTime
        self.passengerCount = passengerCount
        self.notes = notes
        self.stops = stops
        self.serviceOptions = serviceOptions
    }
}

public struct PriceEstimateRequest: Codable {
    public let serviceType: ServiceType
    public let pickupLocation: Location
    public let destination: Location?
    public let stops: [TripStop]
    public let serviceOptions: [ServiceOption]
    public let scheduledTime: Date?
    
    public init(serviceType: ServiceType, pickupLocation: Location, destination: Location? = nil, stops: [TripStop] = [], serviceOptions: [ServiceOption] = [], scheduledTime: Date? = nil) {
        self.serviceType = serviceType
        self.pickupLocation = pickupLocation
        self.destination = destination
        self.stops = stops
        self.serviceOptions = serviceOptions
        self.scheduledTime = scheduledTime
    }
}

public struct OrderStatusUpdate: Codable {
    public let status: OrderStatus
    
    public init(status: OrderStatus) {
        self.status = status
    }
}

public struct CancelOrderRequest: Codable {
    public let reason: String?
    
    public init(reason: String? = nil) {
        self.reason = reason
    }
}

public struct LocationUpdate: Codable {
    public let location: Location
    
    public init(location: Location) {
        self.location = location
    }
}

public struct DriverRatingRequest: Codable {
    public let rating: Int
    public let comment: String?
    
    public init(rating: Int, comment: String? = nil) {
        self.rating = rating
        self.comment = comment
    }
}

public struct PaymentMethodRequest: Codable {
    public let type: PaymentType
    public let token: String
    public let isDefault: Bool
    public let metadata: [String: String]?
    
    public init(type: PaymentType, token: String, isDefault: Bool, metadata: [String: String]? = nil) {
        self.type = type
        self.token = token
        self.isDefault = isDefault
        self.metadata = metadata
    }
}

public struct PaymentRequest: Codable {
    public let orderId: String
    public let paymentMethodId: String
    public let amount: Double
    
    public init(orderId: String, paymentMethodId: String, amount: Double) {
        self.orderId = orderId
        self.paymentMethodId = paymentMethodId
        self.amount = amount
    }
}

public struct AddFundsRequest: Codable {
    public let amount: Double
    public let paymentMethodId: String
    
    public init(amount: Double, paymentMethodId: String) {
        self.amount = amount
        self.paymentMethodId = paymentMethodId
    }
}

public struct SendMessageRequest: Codable {
    public let message: String
    public let type: MessageType
    
    public init(message: String, type: MessageType) {
        self.message = message
        self.type = type
    }
}

public struct MarkMessagesReadRequest: Codable {
    public let messageIds: [String]
    
    public init(messageIds: [String]) {
        self.messageIds = messageIds
    }
}

public struct TypingIndicatorRequest: Codable {
    public let isTyping: Bool
    
    public init(isTyping: Bool) {
        self.isTyping = isTyping
    }
}

public struct TripModificationRequest: Codable {
    public let type: ModificationType
    public let newDestination: Location?
    public let additionalStops: [TripStop]
    public let notes: String?
    
    public init(type: ModificationType, newDestination: Location? = nil, additionalStops: [TripStop] = [], notes: String? = nil) {
        self.type = type
        self.newDestination = newDestination
        self.additionalStops = additionalStops
        self.notes = notes
    }
    
    public var description: String {
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

public enum ModificationType: String, Codable {
    case changeDestination = "change_destination"
    case addStops = "add_stops"
    case changeRoute = "change_route"
    case other = "other"
}

// MARK: - Response Models
public struct AuthResponse: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let user: User
    public let expiresIn: Int
    
    public init(accessToken: String, refreshToken: String, user: User, expiresIn: Int) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.user = user
        self.expiresIn = expiresIn
    }
}

public struct PriceEstimateResponse: Codable {
    public let basePrice: Double
    public let serviceFeesTotal: Double
    public let totalPrice: Double
    public let estimatedDuration: TimeInterval
    public let estimatedDistance: Double
    public let breakdown: [PriceBreakdownItem]
    
    public init(basePrice: Double, serviceFeesTotal: Double, totalPrice: Double, estimatedDuration: TimeInterval, estimatedDistance: Double, breakdown: [PriceBreakdownItem]) {
        self.basePrice = basePrice
        self.serviceFeesTotal = serviceFeesTotal
        self.totalPrice = totalPrice
        self.estimatedDuration = estimatedDuration
        self.estimatedDistance = estimatedDistance
        self.breakdown = breakdown
    }
}

public struct PriceBreakdownItem: Codable {
    public let name: String
    public let amount: Double
    public let type: PriceItemType
    
    public init(name: String, amount: Double, type: PriceItemType) {
        self.name = name
        self.amount = amount
        self.type = type
    }
}

public enum PriceItemType: String, Codable {
    case baseFare = "base_fare"
    case serviceFee = "service_fee"
    case discount = "discount"
    case tax = "tax"
    case tip = "tip"
}

public struct LocationSearchResponse: Codable {
    public let results: [LocationSearchResult]
    
    public init(results: [LocationSearchResult]) {
        self.results = results
    }
}

public struct LocationSearchResult: Codable {
    public let placeId: String
    public let name: String
    public let address: String
    public let location: Location
    public let category: AddressType
    
    public init(placeId: String, name: String, address: String, location: Location, category: AddressType) {
        self.placeId = placeId
        self.name = name
        self.address = address
        self.location = location
        self.category = category
    }
}

public struct AvailableDriversResponse: Codable {
    public let drivers: [Driver]
    public let estimatedWaitTime: TimeInterval
    
    public init(drivers: [Driver], estimatedWaitTime: TimeInterval) {
        self.drivers = drivers
        self.estimatedWaitTime = estimatedWaitTime
    }
}

public struct WalletResponse: Codable {
    public let balance: Double
    public let currency: String
    public let transactions: [Transaction]
    
    public init(balance: Double, currency: String, transactions: [Transaction]) {
        self.balance = balance
        self.currency = currency
        self.transactions = transactions
    }
}

public struct Transaction: Codable, Identifiable {
    public let id: String
    public let amount: Double
    public let type: TransactionType
    public let description: String
    public let createdAt: Date
    public let orderId: String?
    
    public init(id: String, amount: Double, type: TransactionType, description: String, createdAt: Date, orderId: String? = nil) {
        self.id = id
        self.amount = amount
        self.type = type
        self.description = description
        self.createdAt = createdAt
        self.orderId = orderId
    }
}

public enum TransactionType: String, Codable {
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

public struct MessagesResponse: Codable {
    public let messages: [Message]
    public let hasMore: Bool
    public let unreadCount: Int
    
    public init(messages: [Message], hasMore: Bool, unreadCount: Int) {
        self.messages = messages
        self.hasMore = hasMore
        self.unreadCount = unreadCount
    }
}

public struct OrderHistoryResponse: Codable {
    public let orders: [Order]
    public let hasMore: Bool
    public let totalCount: Int
    public let currentPage: Int
    
    public init(orders: [Order], hasMore: Bool, totalCount: Int, currentPage: Int) {
        self.orders = orders
        self.hasMore = hasMore
        self.totalCount = totalCount
        self.currentPage = currentPage
    }
}

public struct FareAdjustmentResponse: Codable {
    public let adjustment: Double
    public let newTotalFare: Double
    public let breakdown: [PriceBreakdownItem]
    
    public init(adjustment: Double, newTotalFare: Double, breakdown: [PriceBreakdownItem]) {
        self.adjustment = adjustment
        self.newTotalFare = newTotalFare
        self.breakdown = breakdown
    }
}
