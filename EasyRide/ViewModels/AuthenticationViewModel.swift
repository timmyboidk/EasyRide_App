import Foundation
import Observation

@Observable
class AuthenticationViewModel {
    private let apiService: APIService
    private let appState: AppState
    
    // MARK: - Authentication State
    var phoneNumber: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var nickname: String = ""
    var email: String = ""
    var otp: String = ""
    
    // MARK: - UI State
    var isLoading: Bool = false
    var currentError: EasyRideError?
    var showingError: Bool = false
    var isOTPSent: Bool = false
    var otpCountdown: Int = 60
    var canResendOTP: Bool = false
    
    // MARK: - Validation State
    var phoneNumberError: String?
    var passwordError: String?
    var confirmPasswordError: String?
    var nicknameError: String?
    var emailError: String?
    var otpError: String?
    
    init(apiService: APIService = EasyRideAPIService.shared, appState: AppState) {
        self.apiService = apiService
        self.appState = appState
    }
    
    // MARK: - Login Methods
    
    func loginWithPassword() async {
        guard validateLoginInput() else { return }
        
        isLoading = true
        clearError()
        
        do {
            let authResponse: AuthResponse = try await apiService.request(.login(phoneNumber: phoneNumber, password: password))
            
            await MainActor.run {
                // Store tokens in API service
                if let apiService = apiService as? EasyRideAPIService {
                    apiService.setAuthTokens(
                        accessToken: authResponse.accessToken,
                        refreshToken: authResponse.refreshToken
                    )
                }
                
                appState.signIn(user: authResponse.user, token: authResponse.accessToken)
                clearForm()
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                handleError(error)
                isLoading = false
            }
        }
    }
    
    func sendOTP() async {
        guard validatePhoneNumber() else { return }
        
        isLoading = true
        clearError()
        
        do {
            // In a real implementation, this would be a separate endpoint to send OTP
            // For now, we'll simulate the OTP sending process
            try await apiService.requestWithoutResponse(.loginOTP(phoneNumber: phoneNumber, otp: "000000"))
            
            await MainActor.run {
                isOTPSent = true
                startOTPCountdown()
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                handleError(error)
                isLoading = false
            }
        }
    }
    
    func loginWithOTP() async {
        guard validateOTPInput() else { return }
        
        isLoading = true
        clearError()
        
        do {
            let authResponse: AuthResponse = try await apiService.request(.loginOTP(phoneNumber: phoneNumber, otp: otp))
            
            await MainActor.run {
                // Store tokens in API service
                if let apiService = apiService as? EasyRideAPIService {
                    apiService.setAuthTokens(
                        accessToken: authResponse.accessToken,
                        refreshToken: authResponse.refreshToken
                    )
                }
                
                appState.signIn(user: authResponse.user, token: authResponse.accessToken)
                clearForm()
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                handleError(error)
                isLoading = false
            }
        }
    }
    
    // MARK: - Registration Methods
    
    func register() async {
        guard validateRegistrationInput() else { return }
        
        isLoading = true
        clearError()
        
        do {
            let registerRequest = RegisterRequest(
                phoneNumber: phoneNumber,
                password: password,
                nickname: nickname,
                email: email.isEmpty ? nil : email
            )
            
            let authResponse: AuthResponse = try await apiService.request(.register(registerRequest))
            
            await MainActor.run {
                // Store tokens in API service
                if let apiService = apiService as? EasyRideAPIService {
                    apiService.setAuthTokens(
                        accessToken: authResponse.accessToken,
                        refreshToken: authResponse.refreshToken
                    )
                }
                
                appState.signIn(user: authResponse.user, token: authResponse.accessToken)
                clearForm()
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                handleError(error)
                isLoading = false
            }
        }
    }
    
    // MARK: - Logout
    
    func logout() async {
        isLoading = true
        
        do {
            try await apiService.requestWithoutResponse(.logout)
        } catch {
            // Even if logout fails on server, we still clear local state
            print("Logout request failed: \(error)")
        }
        
        await MainActor.run {
            // Clear tokens from API service
            if let apiService = apiService as? EasyRideAPIService {
                apiService.clearAuthTokens()
            }
            
            appState.signOut()
            clearForm()
            isLoading = false
        }
    }
    
    // MARK: - Validation Methods
    
    private func validateLoginInput() -> Bool {
        clearValidationErrors()
        var isValid = true
        
        if !validatePhoneNumber() {
            isValid = false
        }
        
        if password.isEmpty {
            passwordError = "Password is required"
            isValid = false
        }
        
        return isValid
    }
    
    private func validateOTPInput() -> Bool {
        clearValidationErrors()
        var isValid = true
        
        if !validatePhoneNumber() {
            isValid = false
        }
        
        if otp.isEmpty {
            otpError = "OTP is required"
            isValid = false
        } else if otp.count != 6 {
            otpError = "OTP must be 6 digits"
            isValid = false
        } else if !otp.allSatisfy({ $0.isNumber }) {
            otpError = "OTP must contain only numbers"
            isValid = false
        }
        
        return isValid
    }
    
    private func validateRegistrationInput() -> Bool {
        clearValidationErrors()
        var isValid = true
        
        if !validatePhoneNumber() {
            isValid = false
        }
        
        if password.isEmpty {
            passwordError = "Password is required"
            isValid = false
        } else if password.count < 6 {
            passwordError = "Password must be at least 6 characters"
            isValid = false
        }
        
        if confirmPassword != password {
            confirmPasswordError = "Passwords do not match"
            isValid = false
        }
        
        if nickname.isEmpty {
            nicknameError = "Nickname is required"
            isValid = false
        } else if nickname.count < 2 {
            nicknameError = "Nickname must be at least 2 characters"
            isValid = false
        }
        
        if !email.isEmpty && !isValidEmail(email) {
            emailError = "Please enter a valid email address"
            isValid = false
        }
        
        return isValid
    }
    
    @discardableResult
    private func validatePhoneNumber() -> Bool {
        if phoneNumber.isEmpty {
            phoneNumberError = "Phone number is required"
            return false
        }
        
        // Basic phone number validation (can be enhanced)
        let phoneRegex = "^[+]?[1-9]\\d{1,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        if !phoneTest.evaluate(with: phoneNumber) {
            phoneNumberError = "Please enter a valid phone number"
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    // MARK: - Helper Methods
    
    private func clearValidationErrors() {
        phoneNumberError = nil
        passwordError = nil
        confirmPasswordError = nil
        nicknameError = nil
        emailError = nil
        otpError = nil
    }
    
    private func clearForm() {
        phoneNumber = ""
        password = ""
        confirmPassword = ""
        nickname = ""
        email = ""
        otp = ""
        isOTPSent = false
        otpCountdown = 60
        canResendOTP = false
        clearValidationErrors()
    }
    
    private func handleError(_ error: Error) {
        if let easyRideError = error as? EasyRideError {
            currentError = easyRideError
        } else {
            currentError = .networkError(error.localizedDescription)
        }
        showingError = true
    }
    
    private func clearError() {
        currentError = nil
        showingError = false
    }
    
    // MARK: - OTP Countdown
    
    private func startOTPCountdown() {
        canResendOTP = false
        otpCountdown = 60
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            Task { @MainActor in
                self.otpCountdown -= 1
                
                if self.otpCountdown <= 0 {
                    self.canResendOTP = true
                    timer.invalidate()
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var isLoginFormValid: Bool {
        !phoneNumber.isEmpty && !password.isEmpty
    }
    
    var isRegistrationFormValid: Bool {
        !phoneNumber.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && !nickname.isEmpty && password == confirmPassword
    }
    
    var isOTPFormValid: Bool {
        !phoneNumber.isEmpty && otp.count == 6
    }
    
    var formattedCountdown: String {
        let minutes = otpCountdown / 60
        let seconds = otpCountdown % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}