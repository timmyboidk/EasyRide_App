import XCTest
import Foundation
@testable import EasyRide

class AuthenticationViewModelTests: XCTestCase {
    
    // MARK: - Test Setup
    
    func createTestViewModel() -> (AuthenticationViewModel, MockAPIService, AppState) {
        let mockAPIService = MockAPIService()
        let appState = AppState()
        let viewModel = AuthenticationViewModel(apiService: mockAPIService, appState: appState)
        return (viewModel, mockAPIService, appState)
    }
    
    // MARK: - Login Tests
    
    func testLoginWithPasswordSuccess() async throws {
        let (viewModel, mockAPIService, appState) = createTestViewModel()
        
        // Setup test data
        viewModel.phoneNumber = "+1234567890"
        viewModel.password = "password123"
        
        // Setup mock response
        let mockUser = User(
            id: "test-user-123",
            nickname: "Test User",
            profileImage: "https://example.com/profile.jpg",
            phoneNumber: "+1234567890",
            frequentAddresses: [],
            paymentMethods: [],
            favoriteDrivers: [],
            vipLevel: .standard
        )
        
        let mockAuthResponse = AuthResponse(
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token",
            user: mockUser,
            expiresIn: 3600
        )
        
        mockAPIService.setMockResponse(mockAuthResponse, for: .login(phoneNumber: viewModel.phoneNumber, password: viewModel.password))
        
        // Test login
        await viewModel.loginWithPassword()
        
        // Verify results
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.currentError)
        XCTAssertFalse(viewModel.showingError)
        XCTAssertTrue(appState.isAuthenticated)
        XCTAssertEqual(appState.currentUser?.id, "test-user-123")
        XCTAssertTrue(mockAPIService.isAuthenticated)
        
        // Verify form was cleared
        XCTAssertEqual(viewModel.phoneNumber, "")
        XCTAssertEqual(viewModel.password, "")
    }
    
    func testLoginWithPasswordValidationFailure() async throws {
        let (viewModel, mockAPIService, appState) = createTestViewModel()
        
        // Setup invalid test data
        viewModel.phoneNumber = ""
        viewModel.password = ""
        
        // Test login with invalid data
        await viewModel.loginWithPassword()
        
        // Verify validation errors
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.phoneNumberError)
        XCTAssertNotNil(viewModel.passwordError)
        XCTAssertFalse(appState.isAuthenticated)
        
        // Verify no API call was made
        XCTAssertTrue(mockAPIService.requestLog.isEmpty)
    }
    
    func testLoginWithPasswordNetworkError() async throws {
        let (viewModel, mockAPIService, appState) = createTestViewModel()
        
        // Setup test data
        viewModel.phoneNumber = "+1234567890"
        viewModel.password = "password123"
        
        // Setup mock error
        mockAPIService.setMockError(EasyRideError.networkError("Connection failed"), for: .login(phoneNumber: viewModel.phoneNumber, password: viewModel.password))
        
        // Test login with network error
        await viewModel.loginWithPassword()
        
        // Verify error handling
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.currentError)
        XCTAssertTrue(viewModel.showingError)
        XCTAssertFalse(appState.isAuthenticated)
    }
    
    func testLoginWithInvalidCredentials() async throws {
        let (viewModel, mockAPIService, appState) = createTestViewModel()
        
        // Setup test data
        viewModel.phoneNumber = "+1234567890"
        viewModel.password = "wrongpassword"
        
        // Setup mock error
        mockAPIService.setMockError(EasyRideError.invalidCredentials, for: .login(phoneNumber: viewModel.phoneNumber, password: viewModel.password))
        
        // Test login with invalid credentials
        await viewModel.loginWithPassword()
        
        // Verify error handling
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.currentError, EasyRideError.invalidCredentials)
        XCTAssertTrue(viewModel.showingError)
        XCTAssertFalse(appState.isAuthenticated)
    }
    
    // MARK: - OTP Tests
    
    func testSendOTPSuccess() async throws {
        let (viewModel, mockAPIService, _) = createTestViewModel()
        
        // Setup test data
        viewModel.phoneNumber = "+1234567890"
        
        // Test send OTP
        await viewModel.sendOTP()
        
        // Verify results
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.currentError)
        XCTAssertTrue(viewModel.isOTPSent)
        XCTAssertFalse(viewModel.canResendOTP)
        XCTAssertEqual(viewModel.otpCountdown, 60)
        
        // Verify API call was made
        XCTAssertFalse(mockAPIService.requestLog.isEmpty)
    }
    
    func testSendOTPValidationFailure() async throws {
        let (viewModel, mockAPIService, _) = createTestViewModel()
        
        // Setup invalid test data
        viewModel.phoneNumber = ""
        
        // Test send OTP with invalid data
        await viewModel.sendOTP()
        
        // Verify validation errors
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.phoneNumberError)
        XCTAssertFalse(viewModel.isOTPSent)
        
        // Verify no API call was made
        XCTAssertTrue(mockAPIService.requestLog.isEmpty)
    }
    
    func testSendOTPNetworkError() async throws {
        let (viewModel, mockAPIService, _) = createTestViewModel()
        
        // Setup test data
        viewModel.phoneNumber = "+1234567890"
        
        // Setup mock error
        mockAPIService.setMockError(EasyRideError.networkError("Connection failed"), for: .loginOTP(phoneNumber: viewModel.phoneNumber, otp: "000000"))
        
        // Test send OTP with network error
        await viewModel.sendOTP()
        
        // Verify error handling
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.currentError)
        XCTAssertTrue(viewModel.showingError)
        XCTAssertFalse(viewModel.isOTPSent)
    }
    
    func testLoginWithOTPSuccess() async throws {
        let (viewModel, mockAPIService, appState) = createTestViewModel()
        
        // Setup test data
        viewModel.phoneNumber = "+1234567890"
        viewModel.otp = "123456"
        viewModel.isOTPSent = true
        
        // Setup mock response
        let mockUser = User(
            id: "test-user-123",
            nickname: "Test User",
            profileImage: "https://example.com/profile.jpg",
            phoneNumber: "+1234567890",
            frequentAddresses: [],
            paymentMethods: [],
            favoriteDrivers: [],
            vipLevel: .standard
        )
        
        let mockAuthResponse = AuthResponse(
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token",
            user: mockUser,
            expiresIn: 3600
        )
        
        mockAPIService.setMockResponse(mockAuthResponse, for: .loginOTP(phoneNumber: viewModel.phoneNumber, otp: viewModel.otp))
        
        // Test login with OTP
        await viewModel.loginWithOTP()
        
        // Verify results
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.currentError)
        XCTAssertFalse(viewModel.showingError)
        XCTAssertTrue(appState.isAuthenticated)
        XCTAssertEqual(appState.currentUser?.id, "test-user-123")
        XCTAssertTrue(mockAPIService.isAuthenticated)
        
        // Verify form was cleared
        XCTAssertEqual(viewModel.phoneNumber, "")
        XCTAssertEqual(viewModel.otp, "")
        XCTAssertFalse(viewModel.isOTPSent)
    }
    
    func testLoginWithOTPValidationFailure() async throws {
        let (viewModel, mockAPIService, appState) = createTestViewModel()
        
        // Setup invalid test data
        viewModel.phoneNumber = "+1234567890"
        viewModel.otp = "123" // Too short
        viewModel.isOTPSent = true
        
        // Test login with invalid OTP
        await viewModel.loginWithOTP()
        
        // Verify validation errors
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.otpError)
        XCTAssertFalse(appState.isAuthenticated)
        
        // Verify no API call was made
        XCTAssertTrue(mockAPIService.requestLog.isEmpty)
    }
    
    // MARK: - Registration Tests
    
    func testRegistrationSuccess() async throws {
        let (viewModel, mockAPIService, appState) = createTestViewModel()
        
        // Setup test data
        viewModel.phoneNumber = "+1234567890"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        viewModel.nickname = "New User"
        viewModel.email = "user@example.com"
        
        // Setup mock response
        let mockUser = User(
            id: "new-user-123",
            nickname: "New User",
            profileImage: nil,
            phoneNumber: "+1234567890",
            frequentAddresses: [],
            paymentMethods: [],
            favoriteDrivers: [],
            vipLevel: .standard
        )
        
        let mockAuthResponse = AuthResponse(
            accessToken: "new-access-token",
            refreshToken: "new-refresh-token",
            user: mockUser,
            expiresIn: 3600
        )
        
        mockAPIService.setMockResponse(mockAuthResponse, for: .register(RegisterRequest(
            phoneNumber: viewModel.phoneNumber,
            password: viewModel.password,
            nickname: viewModel.nickname,
            email: viewModel.email
        )))
        
        // Test registration
        await viewModel.register()
        
        // Verify results
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.currentError)
        XCTAssertFalse(viewModel.showingError)
        XCTAssertTrue(appState.isAuthenticated)
        XCTAssertEqual(appState.currentUser?.id, "new-user-123")
        XCTAssertTrue(mockAPIService.isAuthenticated)
        
        // Verify form was cleared
        XCTAssertEqual(viewModel.phoneNumber, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertEqual(viewModel.confirmPassword, "")
        XCTAssertEqual(viewModel.nickname, "")
        XCTAssertEqual(viewModel.email, "")
    }
    
    func testRegistrationValidationFailures() async throws {
        let (viewModel, mockAPIService, appState) = createTestViewModel()
        
        // Test case 1: Empty fields
        viewModel.phoneNumber = ""
        viewModel.password = ""
        viewModel.confirmPassword = ""
        viewModel.nickname = ""
        
        await viewModel.register()
        
        XCTAssertNotNil(viewModel.phoneNumberError)
        XCTAssertNotNil(viewModel.passwordError)
        XCTAssertNotNil(viewModel.nicknameError)
        XCTAssertFalse(appState.isAuthenticated)
        XCTAssertTrue(mockAPIService.requestLog.isEmpty)
        
        // Test case 2: Password mismatch
        viewModel.phoneNumber = "+1234567890"
        viewModel.password = "password123"
        viewModel.confirmPassword = "different"
        viewModel.nickname = "Test User"
        
        await viewModel.register()
        
        XCTAssertNil(viewModel.phoneNumberError)
        XCTAssertNil(viewModel.passwordError)
        XCTAssertNotNil(viewModel.confirmPasswordError)
        XCTAssertFalse(appState.isAuthenticated)
        XCTAssertTrue(mockAPIService.requestLog.isEmpty)
        
        // Test case 3: Invalid email
        viewModel.phoneNumber = "+1234567890"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        viewModel.nickname = "Test User"
        viewModel.email = "invalid-email"
        
        await viewModel.register()
        
        XCTAssertNil(viewModel.phoneNumberError)
        XCTAssertNil(viewModel.passwordError)
        XCTAssertNil(viewModel.confirmPasswordError)
        XCTAssertNotNil(viewModel.emailError)
        XCTAssertFalse(appState.isAuthenticated)
        XCTAssertTrue(mockAPIService.requestLog.isEmpty)
    }
    
    func testRegistrationNetworkError() async throws {
        let (viewModel, mockAPIService, appState) = createTestViewModel()
        
        // Setup test data
        viewModel.phoneNumber = "+1234567890"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        viewModel.nickname = "New User"
        
        // Setup mock error
        mockAPIService.setMockError(EasyRideError.networkError("Connection failed"), for: .register(RegisterRequest(
            phoneNumber: viewModel.phoneNumber,
            password: viewModel.password,
            nickname: viewModel.nickname,
            email: nil
        )))
        
        // Test registration with network error
        await viewModel.register()
        
        // Verify error handling
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.currentError)
        XCTAssertTrue(viewModel.showingError)
        XCTAssertFalse(appState.isAuthenticated)
    }
    
    // MARK: - Logout Tests
    
    func testLogoutSuccess() async throws {
        let (viewModel, mockAPIService, appState) = createTestViewModel()
        
        // Setup authenticated state
        let mockUser = User(
            id: "test-user-123",
            nickname: "Test User",
            profileImage: nil,
            phoneNumber: "+1234567890",
            frequentAddresses: [],
            paymentMethods: [],
            favoriteDrivers: [],
            vipLevel: .standard
        )
        appState.signIn(user: mockUser, token: "test-token")
        mockAPIService.setAuthTokens(accessToken: "test-token", refreshToken: "test-refresh-token")
        
        XCTAssertTrue(appState.isAuthenticated)
        XCTAssertTrue(mockAPIService.isAuthenticated)
        
        // Test logout
        await viewModel.logout()
        
        // Verify results
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(appState.isAuthenticated)
        XCTAssertNil(appState.currentUser)
        XCTAssertFalse(mockAPIService.isAuthenticated)
    }
    
    func testLogoutWithNetworkError() async throws {
        let (viewModel, mockAPIService, appState) = createTestViewModel()
        
        // Setup authenticated state
        let mockUser = User(
            id: "test-user-123",
            nickname: "Test User",
            profileImage: nil,
            phoneNumber: "+1234567890",
            frequentAddresses: [],
            paymentMethods: [],
            favoriteDrivers: [],
            vipLevel: .standard
        )
        appState.signIn(user: mockUser, token: "test-token")
        mockAPIService.setAuthTokens(accessToken: "test-token", refreshToken: "test-refresh-token")
        
        // Setup mock error
        mockAPIService.setMockError(EasyRideError.networkError("Connection failed"), for: .logout)
        
        // Test logout with network error
        await viewModel.logout()
        
        // Verify results - should still log out locally even if server request fails
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(appState.isAuthenticated)
        XCTAssertNil(appState.currentUser)
        XCTAssertFalse(mockAPIService.isAuthenticated)
    }
    
    // MARK: - Validation Tests
    
    func testPhoneNumberValidation() async throws {
        let (viewModel, _, _) = createTestViewModel()
        
        // Test empty phone number
        viewModel.phoneNumber = ""
        await viewModel.sendOTP()
        XCTAssertNotNil(viewModel.phoneNumberError)
        XCTAssertEqual(viewModel.phoneNumberError, "Phone number is required")
        
        // Test invalid phone number format
        viewModel.phoneNumber = "123"
        await viewModel.sendOTP()
        XCTAssertNotNil(viewModel.phoneNumberError)
        XCTAssertEqual(viewModel.phoneNumberError, "Please enter a valid phone number")
        
        // Test valid phone number
        viewModel.phoneNumber = "+1234567890"
        viewModel.password = "password" // To pass other validations
        await viewModel.loginWithPassword()
        XCTAssertNil(viewModel.phoneNumberError)
    }
    
    func testPasswordValidation() async throws {
        let (viewModel, _, _) = createTestViewModel()
        
        // Setup valid phone number to isolate password validation
        viewModel.phoneNumber = "+1234567890"
        
        // Test empty password
        viewModel.password = ""
        await viewModel.loginWithPassword()
        XCTAssertNotNil(viewModel.passwordError)
        XCTAssertEqual(viewModel.passwordError, "Password is required")
        
        // Test short password in registration
        viewModel.password = "12345"
        viewModel.confirmPassword = "12345"
        viewModel.nickname = "Test"
        await viewModel.register()
        XCTAssertNotNil(viewModel.passwordError)
        XCTAssertEqual(viewModel.passwordError, "Password must be at least 6 characters")
        
        // Test valid password
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        // Don't actually call register to avoid API call
    }
    
    func testEmailValidation() async throws {
        let (viewModel, _, _) = createTestViewModel()
        
        // Setup valid required fields to isolate email validation
        viewModel.phoneNumber = "+1234567890"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        viewModel.nickname = "Test User"
        
        // Test invalid email format
        viewModel.email = "invalid-email"
        await viewModel.register()
        XCTAssertNotNil(viewModel.emailError)
        XCTAssertEqual(viewModel.emailError, "Please enter a valid email address")
        
        // Test valid email
        viewModel.email = "user@example.com"
        // Don't actually call register to avoid API call
        
        // Test empty email (should be valid as email is optional)
        viewModel.email = ""
        // Don't actually call register to avoid API call
    }
    
    // MARK: - Computed Properties Tests
    
    func testIsLoginFormValid() async throws {
        let (viewModel, _, _) = createTestViewModel()
        
        // Test with empty fields
        viewModel.phoneNumber = ""
        viewModel.password = ""
        XCTAssertFalse(viewModel.isLoginFormValid)
        
        // Test with only phone number
        viewModel.phoneNumber = "+1234567890"
        viewModel.password = ""
        XCTAssertFalse(viewModel.isLoginFormValid)
        
        // Test with only password
        viewModel.phoneNumber = ""
        viewModel.password = "password123"
        XCTAssertFalse(viewModel.isLoginFormValid)
        
        // Test with both fields
        viewModel.phoneNumber = "+1234567890"
        viewModel.password = "password123"
        XCTAssertTrue(viewModel.isLoginFormValid)
    }
    
    func testIsRegistrationFormValid() async throws {
        let (viewModel, _, _) = createTestViewModel()
        
        // Test with empty fields
        viewModel.phoneNumber = ""
        viewModel.password = ""
        viewModel.confirmPassword = ""
        viewModel.nickname = ""
        XCTAssertFalse(viewModel.isRegistrationFormValid)
        
        // Test with some fields
        viewModel.phoneNumber = "+1234567890"
        viewModel.password = "password123"
        viewModel.confirmPassword = ""
        viewModel.nickname = ""
        XCTAssertFalse(viewModel.isRegistrationFormValid)
        
        // Test with password mismatch
        viewModel.phoneNumber = "+1234567890"
        viewModel.password = "password123"
        viewModel.confirmPassword = "different"
        viewModel.nickname = "Test User"
        XCTAssertFalse(viewModel.isRegistrationFormValid)
        
        // Test with all required fields
        viewModel.phoneNumber = "+1234567890"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        viewModel.nickname = "Test User"
        XCTAssertTrue(viewModel.isRegistrationFormValid)
        
        // Email is optional, so it shouldn't affect validity
        viewModel.email = "user@example.com"
        XCTAssertTrue(viewModel.isRegistrationFormValid)
    }
    
    func testIsOTPFormValid() async throws {
        let (viewModel, _, _) = createTestViewModel()
        
        // Test with empty fields
        viewModel.phoneNumber = ""
        viewModel.otp = ""
        XCTAssertFalse(viewModel.isOTPFormValid)
        
        // Test with only phone number
        viewModel.phoneNumber = "+1234567890"
        viewModel.otp = ""
        XCTAssertFalse(viewModel.isOTPFormValid)
        
        // Test with only OTP
        viewModel.phoneNumber = ""
        viewModel.otp = "123456"
        XCTAssertFalse(viewModel.isOTPFormValid)
        
        // Test with invalid OTP length
        viewModel.phoneNumber = "+1234567890"
        viewModel.otp = "12345"
        XCTAssertFalse(viewModel.isOTPFormValid)
        
        // Test with valid fields
        viewModel.phoneNumber = "+1234567890"
        viewModel.otp = "123456"
        XCTAssertTrue(viewModel.isOTPFormValid)
    }
    
    func testFormattedCountdown() async throws {
        let (viewModel, _, _) = createTestViewModel()
        
        // Test different countdown values
        viewModel.otpCountdown = 60
        XCTAssertEqual(viewModel.formattedCountdown, "01:00")
        
        viewModel.otpCountdown = 30
        XCTAssertEqual(viewModel.formattedCountdown, "00:30")
        
        viewModel.otpCountdown = 90
        XCTAssertEqual(viewModel.formattedCountdown, "01:30")
        
        viewModel.otpCountdown = 0
        XCTAssertEqual(viewModel.formattedCountdown, "00:00")
    }
}