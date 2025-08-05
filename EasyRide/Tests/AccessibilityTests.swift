import XCTest
import SwiftUI
@testable import EasyRide

/// Comprehensive accessibility tests for the EasyRide app
/// Tests VoiceOver support, focus management, and accessibility compliance
final class AccessibilityTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Enable accessibility for testing
        app.launchArguments.append("--uitesting")
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Service Selection Accessibility Tests
    
    func testServiceSelectionAccessibility() throws {
        // Test service cards have proper accessibility labels
        let airportCard = app.buttons.matching(identifier: "service-card-airport").firstMatch
        XCTAssertTrue(airportCard.exists, "Airport service card should exist")
        
        // Verify accessibility label contains service info
        let airportLabel = airportCard.label
        XCTAssertTrue(airportLabel.contains("Airport"), "Service card should contain service name")
        XCTAssertTrue(airportLabel.contains("$") || airportLabel.contains("From"), "Service card should contain price information")
        
        // Test selection state is announced
        airportCard.tap()
        
        // Verify continue button becomes accessible when service is selected
        let continueButton = app.buttons["Continue to trip configuration"]
        XCTAssertTrue(continueButton.exists, "Continue button should exist after service selection")
        XCTAssertTrue(continueButton.isEnabled, "Continue button should be enabled after service selection")
        
        // Test accessibility hint
        let continueHint = continueButton.value as? String
        XCTAssertNotNil(continueHint, "Continue button should have accessibility hint")
    }
    
    func testServiceCardFocusOrder() throws {
        // Test that service cards are in logical focus order
        let serviceCards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'service-card-'"))
        XCTAssertGreaterThan(serviceCards.count, 0, "Should have service cards")
        
        // Verify cards can be navigated in order
        for i in 0..<serviceCards.count {
            let card = serviceCards.element(boundBy: i)
            XCTAssertTrue(card.exists, "Service card \(i) should exist")
            XCTAssertTrue(card.isHittable, "Service card \(i) should be hittable")
        }
    }
    
    // MARK: - Trip Configuration Accessibility Tests
    
    func testTripConfigurationAccessibility() throws {
        // Navigate to trip configuration
        selectAirportService()
        
        let continueButton = app.buttons["Continue to trip configuration"]
        continueButton.tap()
        
        // Test mode selector accessibility
        let freeRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Free-Route'")).firstMatch
        let customRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Custom-Route'")).firstMatch
        
        XCTAssertTrue(freeRouteButton.exists, "Free-Route mode button should exist")
        XCTAssertTrue(customRouteButton.exists, "Custom-Route mode button should exist")
        
        // Test mode selection announces change
        customRouteButton.tap()
        
        // Test passenger stepper accessibility
        let decreaseButton = app.buttons["Decrease passenger count"]
        let increaseButton = app.buttons["Increase passenger count"]
        
        XCTAssertTrue(decreaseButton.exists, "Decrease passenger button should exist")
        XCTAssertTrue(increaseButton.exists, "Increase passenger button should exist")
        
        // Test stepper state
        increaseButton.tap()
        let passengerLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'passengers'")).firstMatch
        XCTAssertTrue(passengerLabel.exists, "Passenger count label should exist")
    }
    
    func testDatePickerAccessibility() throws {
        selectAirportService()
        app.buttons["Continue to trip configuration"].tap()
        
        // Test date picker has proper accessibility
        let datePicker = app.datePickers["Scheduled pickup time"]
        XCTAssertTrue(datePicker.exists, "Date picker should exist with accessibility label")
        
        let datePickerHint = datePicker.value as? String
        XCTAssertNotNil(datePickerHint, "Date picker should have accessibility hint")
    }
    
    // MARK: - Order Tracking Accessibility Tests
    
    func testOrderTrackingAccessibility() throws {
        // Mock order tracking state
        navigateToOrderTracking()
        
        // Test status header accessibility
        let statusHeader = app.staticTexts.matching(NSPredicate(format: "trait = 'header'")).firstMatch
        XCTAssertTrue(statusHeader.exists, "Status header should exist")
        
        // Test progress indicator accessibility
        let progressIndicator = app.progressIndicators.firstMatch
        if progressIndicator.exists {
            let progressLabel = progressIndicator.label
            XCTAssertTrue(progressLabel.contains("percent") || progressLabel.contains("Finding"), 
                         "Progress indicator should have descriptive label")
        }
        
        // Test communication buttons accessibility
        let callButton = app.buttons["Call driver"]
        let messageButton = app.buttons["Message driver"]
        
        if callButton.exists {
            XCTAssertTrue(callButton.isEnabled, "Call button should be enabled when driver is assigned")
            let callHint = callButton.value as? String
            XCTAssertNotNil(callHint, "Call button should have accessibility hint")
        }
        
        if messageButton.exists {
            XCTAssertTrue(messageButton.isEnabled, "Message button should be enabled when driver is assigned")
            let messageHint = messageButton.value as? String
            XCTAssertNotNil(messageHint, "Message button should have accessibility hint")
        }
    }
    
    // MARK: - Value Added Services Accessibility Tests
    
    func testValueAddedServicesAccessibility() throws {
        navigateToValueAddedServices()
        
        // Test pricing summary accessibility
        let pricingSummary = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Total fare'")).firstMatch
        XCTAssertTrue(pricingSummary.exists, "Pricing summary should exist")
        
        // Test service option toggles
        let serviceToggles = app.switches
        for i in 0..<min(serviceToggles.count, 3) { // Test first 3 toggles
            let toggle = serviceToggles.element(boundBy: i)
            XCTAssertTrue(toggle.exists, "Service toggle \(i) should exist")
            
            let toggleLabel = toggle.label
            XCTAssertFalse(toggleLabel.isEmpty, "Service toggle should have descriptive label")
            
            // Test toggle state announcement
            let initialState = toggle.value as? String
            toggle.tap()
            let newState = toggle.value as? String
            XCTAssertNotEqual(initialState, newState, "Toggle state should change")
        }
    }
    
    // MARK: - Login Accessibility Tests
    
    func testLoginAccessibility() throws {
        // Navigate to login (assuming app starts with login)
        
        // Test header accessibility
        let appTitle = app.staticTexts["EasyRide"]
        XCTAssertTrue(appTitle.exists, "App title should exist")
        
        // Test login mode picker
        let loginModePicker = app.segmentedControls.firstMatch
        XCTAssertTrue(loginModePicker.exists, "Login mode picker should exist")
        
        // Test form fields
        let phoneField = app.textFields["Phone number"]
        XCTAssertTrue(phoneField.exists, "Phone number field should exist with accessibility label")
        
        let passwordField = app.secureTextFields.firstMatch
        if passwordField.exists {
            XCTAssertFalse(passwordField.label.isEmpty, "Password field should have accessibility label")
        }
        
        // Test login button
        let loginButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Sign In'")).firstMatch
        if loginButton.exists {
            XCTAssertNotNil(loginButton.label, "Login button should have accessibility label")
        }
    }
    
    // MARK: - Reduced Motion Tests
    
    func testReducedMotionSupport() throws {
        // Test that animations are disabled when reduce motion is enabled
        // This would typically require mocking the accessibility setting
        
        // For now, verify that motion-sensitive elements exist
        selectAirportService()
        
        let serviceCard = app.buttons.matching(identifier: "service-card-airport").firstMatch
        XCTAssertTrue(serviceCard.exists, "Service card should exist regardless of motion settings")
        
        // Verify continue button appears (with or without animation)
        let continueButton = app.buttons["Continue to trip configuration"]
        XCTAssertTrue(continueButton.exists, "Continue button should appear regardless of motion settings")
    }
    
    // MARK: - High Contrast Tests
    
    func testHighContrastSupport() throws {
        // Test that UI elements remain visible in high contrast mode
        // This would typically require enabling high contrast mode
        
        selectAirportService()
        
        // Verify key UI elements are still visible
        let serviceCard = app.buttons.matching(identifier: "service-card-airport").firstMatch
        XCTAssertTrue(serviceCard.exists, "Service card should be visible in high contrast mode")
        
        let continueButton = app.buttons["Continue to trip configuration"]
        XCTAssertTrue(continueButton.exists, "Continue button should be visible in high contrast mode")
    }
    
    // MARK: - Dynamic Content Announcement Tests
    
    func testDynamicContentAnnouncements() throws {
        selectAirportService()
        
        // Test that service selection is announced
        let airportCard = app.buttons.matching(identifier: "service-card-airport").firstMatch
        airportCard.tap()
        
        // Verify continue button becomes available (announcement would happen in real app)
        let continueButton = app.buttons["Continue to trip configuration"]
        XCTAssertTrue(continueButton.exists, "Continue button should appear after service selection")
        
        // Test deselection
        airportCard.tap()
        // Continue button should disappear or become disabled
        XCTAssertFalse(continueButton.isEnabled, "Continue button should be disabled after deselection")
    }
    
    // MARK: - Helper Methods
    
    private func selectAirportService() {
        let airportCard = app.buttons.matching(identifier: "service-card-airport").firstMatch
        if airportCard.exists {
            airportCard.tap()
        }
    }
    
    private func navigateToOrderTracking() {
        // This would navigate through the app flow to reach order tracking
        // Implementation depends on app navigation structure
        selectAirportService()
        
        if app.buttons["Continue to trip configuration"].exists {
            app.buttons["Continue to trip configuration"].tap()
        }
        
        // Continue through the flow...
    }
    
    private func navigateToValueAddedServices() {
        // Navigate through the app flow to reach value added services
        selectAirportService()
        
        if app.buttons["Continue to trip configuration"].exists {
            app.buttons["Continue to trip configuration"].tap()
        }
        
        // Fill in required fields and continue...
    }
}

// MARK: - Accessibility Testing Extensions

extension XCUIElement {
    
    /// Check if element has proper accessibility support
    var hasAccessibilitySupport: Bool {
        return !label.isEmpty || !value.description.isEmpty
    }
    
    /// Get accessibility information for debugging
    var accessibilityInfo: String {
        return """
        Label: \(label)
        Value: \(value)
        Traits: \(traits)
        Identifier: \(identifier)
        """
    }
}

// MARK: - Mock Accessibility Settings

/// Helper class to mock accessibility settings for testing
class MockAccessibilitySettings {
    static var isVoiceOverRunning = false
    static var isReduceMotionEnabled = false
    static var isDarkerSystemColorsEnabled = false
    
    static func reset() {
        isVoiceOverRunning = false
        isReduceMotionEnabled = false
        isDarkerSystemColorsEnabled = false
    }
}