import XCTest
@testable import EasyRide

@MainActor
class ProfileViewModelTests: XCTestCase {
    var viewModel: ProfileViewModel!
    var mockApiService: MockAPIService!
    var appState: AppState!
    
    override func setUp() {
        super.setUp()
        mockApiService = MockAPIService()
        appState = AppState()
        viewModel = ProfileViewModel(apiService: mockApiService, appState: appState)
    }
    
    override func tearDown() {
        viewModel = nil
        mockApiService = nil
        appState = nil
        super.tearDown()
    }
    
    func testFetchProfileSuccess() async {
        // Arrange
        let mockUser = User(
            id: "user123",
            name: "Test User",
            email: "test@example.com",
            phoneNumber: "13800138000",
            profileImage: nil
        )
        mockApiService.setMockResponse(mockUser, for: .getUserProfile)
        
        // Act
        await viewModel.fetchProfile()
        
        // Assert
        XCTAssertEqual(viewModel.name, "Test User")
        XCTAssertEqual(viewModel.phoneNumber, "13800138000")
        XCTAssertNotNil(appState.currentUser)
        XCTAssertEqual(appState.currentUser?.id, "user123")
    }
    
    func testUpdateProfileSuccess() async {
        // Arrange
        let initialUser = User(id: "u1", name: "Old", email: "old@ex.com")
        viewModel.user = initialUser
        viewModel.name = "New Name"
        
        let updatedUser = User(id: "u1", name: "New Name", email: "old@ex.com")
        mockApiService.setMockResponse(updatedUser, for: .updateUserProfile(updatedUser))
        
        // Act
        let success = await viewModel.updateProfile()
        
        // Assert
        XCTAssertTrue(success)
        XCTAssertEqual(viewModel.user?.name, "New Name")
        XCTAssertEqual(appState.currentUser?.name, "New Name")
    }
    
    func testFetchProfileFailure() async {
        // Arrange
        mockApiService.shouldThrowError = true
        mockApiService.errorToThrow = EasyRideError.networkError("Failed")
        
        // Act
        await viewModel.fetchProfile()
        
        // Assert
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
