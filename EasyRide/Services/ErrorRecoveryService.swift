import Foundation
import SwiftUI

#if os(iOS)
import UIKit

// MARK: - Error Recovery Service
/// Service for handling error recovery and retry mechanisms
@Observable
class ErrorRecoveryService {
    static let shared = ErrorRecoveryService()
    
    // MARK: - Properties
    private(set) var currentError: EasyRideError?
    private(set) var isShowingError = false
    private(set) var retryCount = 0
    private(set) var isRetrying = false
    
    private let maxRetries = 3
    private var retryAction: (() async throws -> Void)?
    private var retryDelay: TimeInterval = 1.0
    
    // MARK: - Error Handling
    
    /// Handle an error with optional retry action
    /// - Parameters:
    ///   - error: The error to handle
    ///   - retryAction: Optional retry action
    func handle(_ error: Error, retryAction: (() async throws -> Void)? = nil) {
        if let easyRideError = error as? EasyRideError {
            currentError = easyRideError
        } else {
            currentError = .unknownError
        }
        
        self.retryAction = retryAction
        isShowingError = true
        
        // Log the error
        logError(error)
    }
    
    /// Clear the current error
    func clearError() {
        currentError = nil
        isShowingError = false
        retryCount = 0
        isRetrying = false
        retryAction = nil
    }
    
    /// Retry the last failed action
    /// - Returns: Success status
    @MainActor
    func retry() async -> Bool {
        guard let retryAction = retryAction, let error = currentError else {
            return false
        }
        
        // Check if error is retryable
        guard error.isRetryable else {
            return false
        }
        
        // Check retry count
        guard retryCount < maxRetries else {
            return false
        }
        
        isRetrying = true
        retryCount += 1
        
        // Exponential backoff
        let delay = retryDelay * pow(2.0, Double(retryCount - 1))
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        do {
            try await retryAction()
            clearError()
            isRetrying = false
            return true
        } catch {
            if let easyRideError = error as? EasyRideError {
                currentError = easyRideError
            } else {
                currentError = .unknownError
            }
            isRetrying = false
            return false
        }
    }
    
    // MARK: - Private Methods
    
    private func logError(_ error: Error) {
        #if DEBUG
        print("🔴 Error: \(error.localizedDescription)")
        if let easyRideError = error as? EasyRideError {
            print("📋 Error Type: \(String(describing: easyRideError))")
            print("🔄 Retryable: \(easyRideError.isRetryable)")
        }
        #endif
    }
}

// MARK: - Error Alert View
/// A reusable error alert view with retry functionality
struct ErrorAlertView: View {
    let error: EasyRideError
    let isRetrying: Bool
    let canRetry: Bool
    let onRetry: () async -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Error icon
            Image(systemName: errorIcon)
                .font(.system(size: 40))
                .foregroundColor(errorColor)
                .padding(.bottom, 8)
            
            // Error title
            Text(errorTitle)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            // Error message
            Text(error.errorDescription ?? "An unknown error occurred")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Recovery suggestion
            if let recoverySuggestion = error.recoverySuggestion {
                Text(recoverySuggestion)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Action buttons
            HStack(spacing: 16) {
                // Dismiss button
                Button(action: onDismiss) {
                    Text("Dismiss")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                .buttonStyle(AccessibleScaleButtonStyle())
                
                // Retry button (if applicable)
                if canRetry {
                    Button {
                        Task {
                            await onRetry()
                        }
                    } label: {
                        HStack {
                            if isRetrying {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .padding(.trailing, 4)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            
                            Text(isRetrying ? "Retrying..." : "Retry")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isRetrying)
                    .buttonStyle(AccessibleScaleButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 40)
    }
    
    // MARK: - Computed Properties
    
    private var errorIcon: String {
        switch error {
        case .networkError, .noInternetConnection, .requestTimeout, .serverUnavailable:
            return "wifi.exclamationmark"
        case .authenticationRequired, .invalidCredentials, .tokenExpired, .accountSuspended:
            return "person.fill.xmark"
        case .orderNotFound, .orderAlreadyCancelled, .orderCannotBeCancelled:
            return "doc.text.magnifyingglass"
        case .driverNotAvailable, .noDriversInArea:
            return "car.fill.xmark"
        case .paymentFailed, .insufficientFunds, .paymentMethodNotSupported:
            return "creditcard.fill"
        case .locationPermissionDenied, .locationServiceDisabled:
            return "location.slash.fill"
        default:
            return "exclamationmark.triangle.fill"
        }
    }
    
    private var errorColor: Color {
        switch error {
        case .networkError, .noInternetConnection, .requestTimeout, .serverUnavailable:
            return .orange
        case .authenticationRequired, .invalidCredentials, .tokenExpired, .accountSuspended:
            return .red
        case .orderNotFound, .orderAlreadyCancelled, .orderCannotBeCancelled:
            return .orange
        case .driverNotAvailable, .noDriversInArea:
            return .orange
        case .paymentFailed, .insufficientFunds, .paymentMethodNotSupported:
            return .red
        case .locationPermissionDenied, .locationServiceDisabled:
            return .red
        default:
            return .red
        }
    }
    
    private var errorTitle: String {
        switch error {
        case .networkError, .noInternetConnection, .requestTimeout, .serverUnavailable:
            return "Connection Problem"
        case .authenticationRequired, .invalidCredentials, .tokenExpired, .accountSuspended:
            return "Authentication Error"
        case .orderNotFound, .orderAlreadyCancelled, .orderCannotBeCancelled:
            return "Order Issue"
        case .driverNotAvailable, .noDriversInArea:
            return "Driver Unavailable"
        case .paymentFailed, .insufficientFunds, .paymentMethodNotSupported:
            return "Payment Problem"
        case .locationPermissionDenied, .locationServiceDisabled:
            return "Location Access Required"
        default:
            return "Error"
        }
    }
}

// MARK: - Error Recovery View Modifier
struct ErrorRecoveryModifier: ViewModifier {
    @State private var errorRecoveryService = ErrorRecoveryService.shared
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if errorRecoveryService.isShowingError, let error = errorRecoveryService.currentError {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .overlay {
                            ErrorAlertView(
                                error: error,
                                isRetrying: errorRecoveryService.isRetrying,
                                canRetry: error.isRetryable && errorRecoveryService.retryCount < 3,
                                onRetry: {
                                    await errorRecoveryService.retry()
                                },
                                onDismiss: {
                                    errorRecoveryService.clearError()
                                }
                            )
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: errorRecoveryService.isShowingError)
                        }
                }
            }
    }
}

// MARK: - View Extension
extension View {
    /// Add error recovery handling to a view
    func withErrorRecovery() -> some View {
        modifier(ErrorRecoveryModifier())
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Text("Error Recovery Preview")
            .font(.headline)
        
        Button("Show Network Error") {
            ErrorRecoveryService.shared.handle(
                EasyRideError.networkError("Connection failed"),
                retryAction: {
                    // Simulate network request
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    // Simulate success after retry
                    if ErrorRecoveryService.shared.retryCount >= 2 {
                        return
                    } else {
                        throw EasyRideError.networkError("Still failing")
                    }
                }
            )
        }
        .buttonStyle(.borderedProminent)
        .padding()
        
        Button("Show Authentication Error") {
            ErrorRecoveryService.shared.handle(EasyRideError.authenticationRequired)
        }
        .buttonStyle(.bordered)
        .padding()
    }
    .withErrorRecovery()
}

#endif // os(iOS)
