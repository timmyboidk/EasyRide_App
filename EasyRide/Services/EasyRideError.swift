import Foundation

enum EasyRideError: Error, LocalizedError, Equatable {
    // Network errors
    case networkError(String)
    case noInternetConnection
    case requestTimeout
    case serverUnavailable
    
    // Authentication errors
    case authenticationRequired
    case invalidCredentials
    case tokenExpired
    case accountSuspended
    
    // Request errors
    case invalidRequest(String)
    case missingRequiredFields([String])
    case invalidPhoneNumber
    case invalidLocation
    
    // Order errors
    case orderNotFound
    case orderAlreadyCancelled
    case orderCannotBeCancelled
    case driverNotAvailable
    case noDriversInArea
    case priceEstimationFailed
    
    // Payment errors
    case paymentFailed(String)
    case insufficientFunds
    case paymentMethodNotSupported
    case paymentMethodNotAvailable(String)
    case paymentProcessingError
    
    // Location errors
    case locationPermissionDenied
    case locationServiceDisabled
    case locationNotFound
    case invalidCoordinates
    
    // General errors
    case unknownError
    case decodingError(String)
    case encodingError(String)
    
    var errorDescription: String? {
        switch self {
        // Network errors
        case .networkError(let message):
            return "Network error: \(message)"
        case .noInternetConnection:
            return "No internet connection available"
        case .requestTimeout:
            return "Request timed out. Please try again."
        case .serverUnavailable:
            return "Server is temporarily unavailable"
            
        // Authentication errors
        case .authenticationRequired:
            return "Please log in to continue"
        case .invalidCredentials:
            return "Invalid phone number or password"
        case .tokenExpired:
            return "Your session has expired. Please log in again."
        case .accountSuspended:
            return "Your account has been suspended. Please contact support."
            
        // Request errors
        case .invalidRequest(let message):
            return "Invalid request: \(message)"
        case .missingRequiredFields(let fields):
            return "Missing required fields: \(fields.joined(separator: ", "))"
        case .invalidPhoneNumber:
            return "Please enter a valid phone number"
        case .invalidLocation:
            return "Invalid location provided"
            
        // Order errors
        case .orderNotFound:
            return "Order not found"
        case .orderAlreadyCancelled:
            return "This order has already been cancelled"
        case .orderCannotBeCancelled:
            return "This order cannot be cancelled at this time"
        case .driverNotAvailable:
            return "Selected driver is no longer available"
        case .noDriversInArea:
            return "No drivers available in your area"
        case .priceEstimationFailed:
            return "Unable to estimate price. Please try again."
            
        // Payment errors
        case .paymentFailed(let reason):
            return "Payment failed: \(reason)"
        case .insufficientFunds:
            return "Insufficient funds in your account"
        case .paymentMethodNotSupported:
            return "Payment method not supported"
        case .paymentMethodNotAvailable(let reason):
            return "Payment method not available: \(reason)"
        case .paymentProcessingError:
            return "Error processing payment. Please try again."
            
        // Location errors
        case .locationPermissionDenied:
            return "Location access is required for this feature"
        case .locationServiceDisabled:
            return "Location services are disabled"
        case .locationNotFound:
            return "Location not found"
        case .invalidCoordinates:
            return "Invalid location coordinates"
            
        // General errors
        case .unknownError:
            return "An unexpected error occurred"
        case .decodingError(let message):
            return "Data parsing error: \(message)"
        case .encodingError(let message):
            return "Data encoding error: \(message)"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .networkError, .noInternetConnection, .requestTimeout, .serverUnavailable:
            return "Network connectivity issue"
        case .authenticationRequired, .invalidCredentials, .tokenExpired, .accountSuspended:
            return "Authentication problem"
        case .invalidRequest, .missingRequiredFields, .invalidPhoneNumber, .invalidLocation:
            return "Invalid input data"
        case .orderNotFound, .orderAlreadyCancelled, .orderCannotBeCancelled, .driverNotAvailable, .noDriversInArea, .priceEstimationFailed:
            return "Order processing issue"
        case .paymentFailed, .insufficientFunds, .paymentMethodNotSupported, .paymentProcessingError:
            return "Payment processing issue"
        case .paymentMethodNotAvailable: 
                return "Payment method unavailable"
        case .locationPermissionDenied, .locationServiceDisabled, .locationNotFound, .invalidCoordinates:
            return "Location service issue"
        case .unknownError, .decodingError, .encodingError:
            return "System error"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noInternetConnection:
            return "Check your internet connection and try again"
        case .requestTimeout:
            return "Check your connection and retry"
        case .serverUnavailable:
            return "Please try again in a few minutes"
        case .authenticationRequired, .tokenExpired:
            return "Please log in to your account"
        case .invalidCredentials:
            return "Check your phone number and password"
        case .accountSuspended:
            return "Contact customer support for assistance"
        case .invalidPhoneNumber:
            return "Enter a valid phone number with country code"
        case .noDriversInArea:
            return "Try again later or choose a different pickup location"
        case .locationPermissionDenied:
            return "Enable location access in Settings"
        case .locationServiceDisabled:
            return "Enable location services in Settings"
        case .insufficientFunds:
            return "Add funds to your account or use a different payment method"
        case .paymentMethodNotSupported:
            return "Choose a different payment method"
        default:
            return "Please try again or contact support if the problem persists"
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkError, .noInternetConnection, .requestTimeout, .serverUnavailable, .priceEstimationFailed:
            return true
        case .authenticationRequired, .tokenExpired:
            return false // Requires user action
        case .invalidCredentials, .accountSuspended, .invalidRequest, .missingRequiredFields, .invalidPhoneNumber, .invalidLocation:
            return false // Requires user correction
        case .orderNotFound, .orderAlreadyCancelled, .orderCannotBeCancelled:
            return false // State-based errors
        case .driverNotAvailable, .noDriversInArea:
            return true
        case .paymentFailed, .paymentProcessingError:
            return true
        case .insufficientFunds, .paymentMethodNotSupported, .paymentMethodNotAvailable:
            return false // Requires user action
        case .locationPermissionDenied, .locationServiceDisabled:
            return false // Requires user action
        case .locationNotFound, .invalidCoordinates:
            return true
        case .unknownError:
            return true
        case .decodingError, .encodingError:
            return false // System errors
        }
    }
}

// MARK: - HTTP Status Code Mapping
extension EasyRideError {
    static func from(httpStatusCode: Int, data: Data? = nil) -> EasyRideError {
        switch httpStatusCode {
        case 400:
            return .invalidRequest("Bad request")
        case 401:
            return .authenticationRequired
        case 403:
            return .accountSuspended
        case 404:
            return .orderNotFound
        case 408:
            return .requestTimeout
        case 422:
            return .missingRequiredFields([])
        case 429:
            return .requestTimeout
        case 500...599:
            return .serverUnavailable
        default:
            return .networkError("HTTP \(httpStatusCode)")
        }
    }
}
