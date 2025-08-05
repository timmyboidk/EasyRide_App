import XCTest
import SwiftUI
@testable import EasyRide

/// UI tests for the service selection flow
final class ServiceSelectionUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Set up test environment
        app.launchArguments.append("--uitesting")
        app.launchArguments.append("--skip-authentication") // Skip login for UI tests
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Service Selection Tests
    
    func testServiceCardDisplay() throws {
        // Verify all service cards are displayed
        let airportCard = app.buttons["service-card-airport"]
        let longDistanceCard = app.buttons["service-card-long_distance"]
        let charterCard = app.buttons["service-card-charter"]
        let carpoolingCard = app.buttons["service-card-carpooling"]
        
        XCTAssertTrue(airportCard.exists, "Airport service card should be displayed")
        XCTAssertTrue(longDistanceCard.exists, "Long Distance service card should be displayed")
        XCTAssertTrue(charterCard.exists, "Charter service card should be displayed")
        XCTAssertTrue(carpoolingCard.exists, "Carpooling service card should be displayed")
        
        // Verify each card has the required elements
        for card in [airportCard, longDistanceCard, charterCard, carpoolingCard] {
            // Check for icon
            let icon = card.images.firstMatch
            XCTAssertTrue(icon.exists, "Service card should have an icon")
            
            // Check for price badge
            let priceText = card.staticTexts.matching(NSPredicate(format: "label CONTAINS '$'")).firstMatch
            XCTAssertTrue(priceText.exists, "Service card should display price information")
            
            // Check for service name
            let nameExists = card.staticTexts.element(boundBy: 0).exists
            XCTAssertTrue(nameExists, "Service card should display service name")
        }
    }
    
    func testServiceCardSelection() throws {
        // Test selecting a service card
        let airportCard = app.buttons["service-card-airport"]
        XCTAssertTrue(airportCard.exists, "Airport service card should exist")
        
        // Verify continue button is initially disabled or not visible
        let continueButton = app.buttons["Continue to trip configuration"]
        XCTAssertFalse(continueButton.isEnabled, "Continue button should be disabled before selection")
        
        // Select the airport service
        airportCard.tap()
        
        // Verify continue button is now enabled
        XCTAssertTrue(continueButton.isEnabled, "Continue button should be enabled after selection")
        
        // Test deselection
        airportCard.tap()
        
        // Verify continue button is disabled again
        XCTAssertFalse(continueButton.isEnabled, "Continue button should be disabled after deselection")
    }
    
    func testMultipleServiceSelection() throws {
        // Test that only one service can be selected at a time
        let airportCard = app.buttons["service-card-airport"]
        let longDistanceCard = app.buttons["service-card-long_distance"]
        
        // Select airport service
        airportCard.tap()
        
        // Verify airport card is selected
        let airportSelected = airportCard.isSelected
        XCTAssertTrue(airportSelected, "Airport card should be selected")
        
        // Select long distance service
        longDistanceCard.tap()
        
        // Verify long distance card is selected and airport card is deselected
        let longDistanceSelected = longDistanceCard.isSelected
        XCTAssertTrue(longDistanceSelected, "Long distance card should be selected")
        XCTAssertFalse(airportCard.isSelected, "Airport card should be deselected")
    }
    
    func testContinueButtonNavigation() throws {
        // Test that continue button navigates to trip configuration
        let airportCard = app.buttons["service-card-airport"]
        airportCard.tap()
        
        let continueButton = app.buttons["Continue to trip configuration"]
        XCTAssertTrue(continueButton.isEnabled, "Continue button should be enabled after selection")
        
        // Tap continue button
        continueButton.tap()
        
        // Verify navigation to trip configuration screen
        let tripConfigTitle = app.staticTexts["Trip Configuration"]
        XCTAssertTrue(tripConfigTitle.waitForExistence(timeout: 2), "Should navigate to trip configuration screen")
        
        // Verify mode selector is displayed
        let freeRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Free-Route'")).firstMatch
        XCTAssertTrue(freeRouteButton.exists, "Free-Route mode button should exist on trip configuration screen")
    }
    
    func testPriceEstimationDisplay() throws {
        // Test that price estimation is displayed on service cards
        let airportCard = app.buttons["service-card-airport"]
        
        // Verify price text exists
        let priceText = airportCard.staticTexts.matching(NSPredicate(format: "label CONTAINS '$'")).firstMatch
        XCTAssertTrue(priceText.exists, "Service card should display price information")
        
        // Select the card to trigger price update (if applicable)
        airportCard.tap()
        
        // Verify price is still displayed
        XCTAssertTrue(priceText.exists, "Price should remain visible after selection")
    }
    
    func testServiceCardAnimations() throws {
        // Test that service cards animate on selection
        // Note: Visual animations can't be fully verified in XCTest, but we can check for state changes
        
        let airportCard = app.buttons["service-card-airport"]
        
        // Get initial frame
        let initialFrame = airportCard.frame
        
        // Select the card
        airportCard.tap()
        
        // Wait for animation to complete
        Thread.sleep(forTimeInterval: 0.5)
        
        // Get new frame
        let newFrame = airportCard.frame
        
        // In a real app with matchedGeometryEffect, the frame might change
        // For this test, we're just verifying the card still exists after animation
        XCTAssertTrue(airportCard.exists, "Airport card should exist after animation")
        
        // Verify selection state changed
        XCTAssertTrue(airportCard.isSelected, "Airport card should be selected after tap")
    }
    
    // MARK: - Responsive Layout Tests
    
    func testCompactLayoutDisplay() throws {
        // This test would ideally be run on a device with compact horizontal size class
        // For simulator testing, we can check that the layout adapts
        
        // Verify service cards are arranged vertically in compact mode
        let serviceCards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'service-card-'"))
        
        // Get the frames of the first two cards
        if serviceCards.count >= 2 {
            let firstCard = serviceCards.element(boundBy: 0)
            let secondCard = serviceCards.element(boundBy: 1)
            
            // In compact layout (LazyVStack), cards should be stacked vertically
            // So the Y position of the second card should be greater than the first
            XCTAssertGreaterThan(secondCard.frame.minY, firstCard.frame.maxY - 5, 
                               "In compact layout, cards should be stacked vertically")
        }
    }
    
    func testLayoutAdaptationOnRotation() throws {
        // Note: This test requires device rotation which is not fully supported in XCTest
        // We can simulate by checking layout before and after orientation change
        
        // Get initial layout
        let serviceCards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'service-card-'"))
        let initialLayout = serviceCards.count
        
        // Rotate device (this is a simulation, actual rotation not possible in XCTest)
        XCUIDevice.shared.orientation = .landscapeLeft
        
        // Wait for rotation
        Thread.sleep(forTimeInterval: 1.0)
        
        // Verify cards still exist after rotation
        XCTAssertEqual(serviceCards.count, initialLayout, "Service cards should still exist after rotation")
        
        // Reset orientation
        XCUIDevice.shared.orientation = .portrait
    }
    
    // MARK: - Accessibility Tests
    
    func testServiceCardAccessibility() throws {
        // Test that service cards have proper accessibility labels
        let airportCard = app.buttons["service-card-airport"]
        
        // Verify accessibility label
        let accessibilityLabel = airportCard.label
        XCTAssertFalse(accessibilityLabel.isEmpty, "Service card should have accessibility label")
        XCTAssertTrue(accessibilityLabel.contains("Airport"), "Accessibility label should include service name")
        
        // Verify accessibility traits
        let isButton = airportCard.isButton
        XCTAssertTrue(isButton, "Service card should have button trait for accessibility")
    }
    
    func testContinueButtonAccessibility() throws {
        // Select a service to enable continue button
        let airportCard = app.buttons["service-card-airport"]
        airportCard.tap()
        
        let continueButton = app.buttons["Continue to trip configuration"]
        
        // Verify accessibility label
        let accessibilityLabel = continueButton.label
        XCTAssertFalse(accessibilityLabel.isEmpty, "Continue button should have accessibility label")
        XCTAssertTrue(accessibilityLabel.contains("Continue"), "Accessibility label should describe button action")
        
        // Verify accessibility traits
        let isButton = continueButton.isButton
        XCTAssertTrue(isButton, "Continue button should have button trait for accessibility")
        
        // Verify button is enabled for accessibility
        XCTAssertTrue(continueButton.isEnabled, "Continue button should be enabled for accessibility")
    }
    
    // MARK: - Helper Methods
    
    private func selectAirportService() {
        let airportCard = app.buttons["service-card-airport"]
        if airportCard.exists {
            airportCard.tap()
        }
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    var isButton: Bool {
        return (value(forKey: "traits") as? Int ?? 0) & 2 != 0
    }
    
    var isSelected: Bool {
        return (value(forKey: "selected") as? Bool) ?? false
    }
}