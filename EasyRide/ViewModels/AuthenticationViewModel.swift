import Foundation
import Observation

@Observable
class AuthenticationViewModel {
    private let apiService: APIService
    private let appState: AppState
    
    // MARK: - Authentication State
    var phoneNumber: String = ""
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
    var nicknameError: String?
    var emailError: String?
    var otpError: String?
    
    init(apiService: APIService = EasyRideAPIService.shared, appState: AppState) {
        self.apiService = apiService
        self.appState = appState
    }
    
    // MARK: - Login Methods
    
    func loginWithOTP() async {
        guard validateOTPInput() else { return }
        
        isLoading = true
        clearError()
        
        do {
            let authResponse: AuthResponse = try await apiService.request(.loginOTP(phoneNumber: phoneNumber, otp: otp))
            await handleAuthSuccess(authResponse)
        } catch {
            await handleErrorOnMain(error)
        }
    }
    
    func loginWithWeChat() async {
        // Mock WeChat Login Flow for now or integrate SDK later
        print("WeChat Login Tapped")
        // 1. Get code from WeChat SDK
        // 2. Call .loginWeChat(code: code)
        // For demonstration/mock:
        isLoading = true
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await handleErrorOnMain(EasyRideError.unknownError) // Placeholder until SDK is integrated
    }
    
    func sendOTP() async {
        guard validatePhoneNumber() else { return }
        
        isLoading = true
        clearError()
        
        do {
            try await apiService.requestWithoutResponse(.otpRequest(phoneNumber: phoneNumber))
            
            await MainActor.run {
                isOTPSent = true
                startOTPCountdown()
                isLoading = false
            }
            
        } catch {
            await handleErrorOnMain(error)
        }
    }
    
    // MARK: - Registration Methods
    
    func register() async {
        guard validateRegistrationInput() else { return }
        
        isLoading = true
        clearError()
        
        do {
            // Registration now uses OTP instead of password
            let registerRequest = RegisterRequest(
                phoneNumber: phoneNumber,
                otp: otp,
                nickname: nickname,
                email: email.isEmpty ? nil : email
            )
            
            let authResponse: AuthResponse = try await apiService.request(.register(registerRequest))
            await handleAuthSuccess(authResponse)
            
        } catch {
            await handleErrorOnMain(error)
        }
    }
    
    // MARK: - Logout
    
    func logout() async {
        isLoading = true
        
        do {
            try await apiService.requestWithoutResponse(.logout)
        } catch {
            print("Logout request failed: \(error)")
        }
        
        await MainActor.run {
            if let apiService = apiService as? EasyRideAPIService {
                apiService.clearAuthTokens()
            }
            
            appState.signOut()
            clearForm()
            isLoading = false
        }
    }
    
    // MARK: - Validation Methods
    
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
        
        if !validateOTPInput() {
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
        
        // Basic phone number validation
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
    
    private func handleAuthSuccess(_ authResponse: AuthResponse) async {
        await MainActor.run {
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
    }
    
    private func handleErrorOnMain(_ error: Error) async {
        await MainActor.run {
            handleError(error)
            isLoading = false
        }
    }
    
    private func clearValidationErrors() {
        phoneNumberError = nil
        nicknameError = nil
        emailError = nil
        otpError = nil
    }
    
    private func clearForm() {
        phoneNumber = ""
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
    
    var isOTPFormValid: Bool {
        !phoneNumber.isEmpty && otp.count == 6
    }
    
    var isRegistrationFormValid: Bool {
        !phoneNumber.isEmpty && otp.count == 6 && !nickname.isEmpty
    }
    
    var formattedCountdown: String {
        let minutes = otpCountdown / 60
        let seconds = otpCountdown % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}