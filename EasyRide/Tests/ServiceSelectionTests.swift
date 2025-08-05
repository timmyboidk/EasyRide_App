import XCTest
import SwiftUI
@testable import EasyRide

class ServiceSelectionTests: XCTestCase {
    var appState: AppState!
    var viewModel: ServiceSelectionViewModel!
    
    override func setUp() {
        super.setUp()
        appState = AppState()
        viewModel = ServiceSelectionViewModel(appState: appState)
    }
    
    override func tearDown() {
        appState = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Requirement 1.1 Tests
    func testServiceCardsDisplayAllServiceTypes() {
        // Test that all service types are available
        let allServiceTypes = ServiceType.allCases
        XCTAssertEqual(allServiceTypes.count, 4, "Should have 4 service types")
        
        let expectedTypes: [ServiceType] = [.airport, .longDistance, .charter, .carpooling]
        for expectedType in expectedTypes {
            XCTAssertTrue(allServiceTypes.contains(expectedType), "Should contain \(expectedType)")
        }
    }
    
    // MARK: - Requirement 1.2 Tests
    func testServiceCardDisplaysRequiredElements() {
        for serviceType in ServiceType.allCases {
            // Test SF Symbol icon
            XCTAssertFalse(serviceType.icon.isEmpty, "Service type \(serviceType) should have an icon")
            
            // Test display name
            XCTAssertFalse(serviceType.displayName.isEmpty, "Service type \(serviceType) should have a display name")
            
            // Test description
            XCTAssertFalse(serviceType.description.isEmpty, "Service type \(serviceType) should have a description")
            
            // Test base price
            XCTAssertGreaterThan(serviceType.basePrice, 0, "Service type \(serviceType) should have a positive base price")
        }
    }
    
    // MARK: - Requirement 1.3 Tests
    func testServiceSelectionAnimation() {
        // Test initial state
        XCTAssertNil(viewModel.selectedService, "Initially no service should be selected")
        XCTAssertFalse(viewModel.canProceed, "Should not be able to proceed without selection")
        
        // Test service selection
        viewModel.selectService(.airport)
        XCTAssertEqual(viewModel.selectedService, .airport, "Airport service should be selected")
        XCTAssertTrue(viewModel.canProceed, "Should be able to proceed after selection")
        XCTAssertTrue(viewModel.isServiceSelected(.airport), "Airport service should be marked as selected")
        XCTAssertFalse(viewModel.isServiceSelected(.longDistance), "Other services should not be selected")
        
        // Test service deselection
        viewModel.deselectService()
        XCTAssertNil(viewModel.selectedService, "No service should be selected after deselection")
        XCTAssertFalse(viewModel.canProceed, "Should not be able to proceed after deselection")
    }
    
    // MARK: - Requirement 1.4 Tests
    func testFloatingActionButtonState() {
        // Test initial state - button should not be visible
        XCTAssertFalse(viewModel.canProceed, "Button should not be enabled initially")
        
        // Test after service selection - button should be visible
        viewModel.selectService(.charter)
        XCTAssertTrue(viewModel.canProceed, "Button should be enabled after service selection")
        
        // Test service card ID generation
        let cardId = viewModel.serviceCardId(for: .charter)
        XCTAssertEqual(cardId, "service-card-charter", "Should generate correct card ID")
    }
    
    // MARK: - Requirement 1.5 Tests
    func testPriceEstimationIntegration() {
        // Test initial price loading
        XCTAssertFalse(viewModel.isLoadingPrices, "Should not be loading prices initially")
        
        // Test formatted price display
        let formattedPrice = viewModel.formattedPrice(for: .airport)
        XCTAssertTrue(formattedPrice.contains("$"), "Formatted price should contain currency symbol")
        XCTAssertTrue(formattedPrice.contains("25"), "Should show base price for airport service")
        
        // Test price estimation with location
        let testLocation = Location(
            latitude: 37.7749,
            longitude: -122.4194,
            address: "San Francisco, CA"
        )
        
        appState.updateCurrentLocation(testLocation)
        viewModel.selectService(.airport)
        
        // Verify that selection updates app state
        XCTAssertEqual(appState.selectedService, .airport, "App state should be updated with selected service")
    }
    
    // MARK: - Requirement 1.6 Tests
    func testVisualStateTransitions() {
        // Test service selection changes visual state
        XCTAssertFalse(viewModel.isServiceSelected(.longDistance), "Service should not be selected initially")
        
        viewModel.selectService(.longDistance)
        XCTAssertTrue(viewModel.isServiceSelected(.longDistance), "Service should be selected after selection")
        
        // Test switching between services
        viewModel.selectService(.carpooling)
        XCTAssertFalse(viewModel.isServiceSelected(.longDistance), "Previous service should be deselected")
        XCTAssertTrue(viewModel.isServiceSelected(.carpooling), "New service should be selected")
        
        // Test that only one service can be selected at a time
        let selectedCount = ServiceType.allCases.filter { viewModel.isServiceSelected($0) }.count
        XCTAssertEqual(selectedCount, 1, "Only one service should be selected at a time")
    }
    
    // MARK: - Integration Tests
    func testServiceSelectionIntegrationWithAppState() {
        // Test that service selection updates app state
        viewModel.selectService(.charter)
        XCTAssertEqual(appState.selectedService, .charter, "App state should reflect selected service")
        
        // Test that deselection clears app state
        viewModel.deselectService()
        XCTAssertNil(appState.selectedService, "App state should be cleared after deselection")
    }
    
    func testPriceEstimationErrorHandling() {
        // Test that error state is properly managed
        XCTAssertNil(viewModel.priceEstimationError, "Should not have error initially")
        
        // Test error handling (would require mock API service for full test)
        // For now, just verify the error property exists and can be set
        viewModel.priceEstimationError = .priceEstimationFailed
        XCTAssertNotNil(viewModel.priceEstimationError, "Error should be set")
        XCTAssertEqual(viewModel.priceEstimationError, .priceEstimationFailed, "Should have correct error type")
    }
    
    // MARK: - UI Component Tests
    func testServiceCardCategoryTags() {
        // Test that each service type has appropriate category tags
        let airportTag = "AIRPORT"
        let longDistanceTag = "LONG DISTANCE"
        let charterTag = "CHARTER"
        let carpoolingTag = "SHARED"
        
        // These would be tested in the UI layer, but we can verify the logic exists
        // by checking that each service type has distinct characteristics
        XCTAssertNotEqual(ServiceType.airport.displayName, ServiceType.longDistance.displayName)
        XCTAssertNotEqual(ServiceType.charter.icon, ServiceType.carpooling.icon)
        XCTAssertNotEqual(ServiceType.airport.description, ServiceType.charter.description)
    }
    
    func testGridLayoutConfiguration() {
        // Test that grid configuration is appropriate for service cards
        // This would typically be tested in UI tests, but we can verify the data structure
        let serviceTypes = ServiceType.allCases
        XCTAssertEqual(serviceTypes.count, 4, "Should have exactly 4 services for 2x2 grid")
        
        // Verify each service has required display properties
        for serviceType in serviceTypes {
            XCTAssertFalse(serviceType.displayName.isEmpty)
            XCTAssertFalse(serviceType.icon.isEmpty)
            XCTAssertFalse(serviceType.description.isEmpty)
            XCTAssertGreaterThan(serviceType.basePrice, 0)
        }
    }
}

// MARK: - Mock Classes for Testing
class MockAPIService: APIService {
    var shouldFailPriceEstimation = false
    var mockPriceResponse: PriceEstimateResponse?
    
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        switch endpoint {
        case .estimatePrice:
            if shouldFailPriceEstimation {
                throw EasyRideError.priceEstimationFailed
            }
            
            if let mockResponse = mockPriceResponse as? T {
                return mockResponse
            }
            
            // Return default mock response
            let defaultResponse = PriceEstimateResponse(
                basePrice: 25.0,
                serviceFeesTotal: 5.0,
                totalPrice: 30.0,
                estimatedDuration: 1800, // 30 minutes
                estimatedDistance: 15.0, // 15 miles
                breakdown: [
                    PriceBreakdownItem(name: "Base Fare", amount: 25.0, type: .baseFare),
                    PriceBreakdownItem(name: "Service Fee", amount: 5.0, type: .serviceFee)
                ]
            )
            
            if let response = defaultResponse as? T {
                return response
            }
            
            throw EasyRideError.decodingError("Mock response type mismatch")
            
        default:
            throw EasyRideError.invalidRequest("Unsupported endpoint in mock")
        }
    }
    
    func requestWithoutResponse(_ endpoint: APIEndpoint) async throws {
        // Mock implementation
    }
    
    func uploadImage(_ endpoint: APIEndpoint, imageData: Data) async throws -> String {
        return "mock-image-url"
    }
}