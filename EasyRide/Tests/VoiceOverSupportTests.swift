import XCTest
import SwiftUI
@testable import EasyRide

/// Tests for VoiceOver support and accessibility labels
final class VoiceOverSupportTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Set up test environment
        app.launchArguments.append("--uitesting")
        app.launchArguments.append("--skip-authentication") // Skip login for UI tests
        app.launchArguments.append("--enable-voiceover-testing") // Enable VoiceOver testing mode
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Service Selection VoiceOver Tests
    
    func testServiceSelectionVoiceOverLabels() throws {
        // Verify service cards have proper VoiceOver labels
        let serviceCards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'service-card-'"))
        
        for i in 0..<serviceCards.count {
            let card = serviceCards.element(boundBy: i)
            
            // Verify card has accessibility label
            XCTAssertFalse(card.label.isEmpty, "Service card \(i) should have accessibility label")
            
            // Verify label contains service info
            let cardLabel = card.label
            XCTAssertTrue(cardLabel.contains("service") || cardLabel.contains("Service") || 
                         cardLabel.contains("Airport") || cardLabel.contains("Charter") ||
                         cardLabel.contains("Carpooling") || cardLabel.contains("Long Distance"),
                         "Service card label should contain service information")
            
            // Verify price information is included in accessibility label
            XCTAssertTrue(cardLabel.contains("$") || cardLabel.contains("price") || cardLabel.contains("Price"),
                         "Service card label should include price information for VoiceOver")
        }
        
        // Verify continue button has proper VoiceOver label
        let airportCard = app.buttons["service-card-airport"]
        airportCard.tap()
        
        let continueButton = app.buttons["Continue to trip configuration"]
        XCTAssertFalse(continueButton.label.isEmpty, "Continue button should have accessibility label")
        XCTAssertTrue(continueButton.label.contains("Continue") || continueButton.label.contains("Next"),
                     "Continue button label should describe its action")
    }
    
    func testServiceSelectionVoiceOverFocusOrder() throws {
        // Test logical focus order for VoiceOver
        let serviceCards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'service-card-'"))
        
        // Verify cards are in logical order (top to bottom)
        for i in 0..<serviceCards.count - 1 {
            let currentCard = serviceCards.element(boundBy: i)
            let nextCard = serviceCards.element(boundBy: i + 1)
            
            // In a vertical layout, the next card should be below the current one
            XCTAssertGreaterThanOrEqual(nextCard.frame.minY, currentCard.frame.minY,
                                      "Service cards should be in logical top-to-bottom order for VoiceOver navigation")
        }
        
        // Select a service to enable continue button
        let airportCard = app.buttons["service-card-airport"]
        airportCard.tap()
        
        let continueButton = app.buttons["Continue to trip configuration"]
        
        // Continue button should be after all service cards in focus order
        let lastCard = serviceCards.element(boundBy: serviceCards.count - 1)
        XCTAssertGreaterThanOrEqual(continueButton.frame.minY, lastCard.frame.minY,
                                  "Continue button should be after service cards in VoiceOver focus order")
    }
    
    // MARK: - Trip Configuration VoiceOver Tests
    
    func testTripConfigurationVoiceOverLabels() throws {
        // Navigate to trip configuration
        navigateToTripConfiguration()
        
        // Verify mode selector has proper VoiceOver labels
        let freeRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Free-Route'")).firstMatch
        let customRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Custom-Route'")).firstMatch
        
        XCTAssertFalse(freeRouteButton.label.isEmpty, "Free-Route button should have accessibility label")
        XCTAssertFalse(customRouteButton.label.isEmpty, "Custom-Route button should have accessibility label")
        
        // Verify input fields have proper VoiceOver labels
        let pickupField = app.textFields["Pickup Location"]
        let destinationField = app.textFields["Destination"]
        
        XCTAssertFalse(pickupField.label.isEmpty, "Pickup field should have accessibility label")
        XCTAssertFalse(destinationField.label.isEmpty, "Destination field should have accessibility label")
        
        // Verify passenger stepper has proper VoiceOver labels
        let decreaseButton = app.buttons["Decrease passenger count"]
        let increaseButton = app.buttons["Increase passenger count"]
        
        XCTAssertFalse(decreaseButton.label.isEmpty, "Decrease passenger button should have accessibility label")
        XCTAssertFalse(increaseButton.label.isEmpty, "Increase passenger button should have accessibility label")
        
        // Verify time picker has proper VoiceOver label
        let timePicker = app.datePickers["Scheduled pickup time"]
        XCTAssertFalse(timePicker.label.isEmpty, "Time picker should have accessibility label")
    }
    
    func testCustomRouteModeVoiceOverLabels() throws {
        // Navigate to trip configuration
        navigateToTripConfiguration()
        
        // Switch to Custom-Route mode
        let customRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Custom-Route'")).firstMatch
        customRouteButton.tap()
        
        // Verify location list has proper VoiceOver support
        let locationList = app.tables["location-stops-list"]
        XCTAssertTrue(locationList.exists, "Location list should exist")
        
        // Verify location cells have proper VoiceOver labels
        if locationList.cells.count > 0 {
            let firstCell = locationList.cells.element(boundBy: 0)
            XCTAssertFalse(firstCell.label.isEmpty, "Location cell should have accessibility label")
        }
        
        // Verify add stop button has proper VoiceOver label
        let addStopButton = app.buttons["Add Stop"]
        XCTAssertFalse(addStopButton.label.isEmpty, "Add Stop button should have accessibility label")
        
        // Verify map has proper VoiceOver label
        let mapView = app.maps.firstMatch
        if mapView.exists {
            XCTAssertFalse(mapView.label.isEmpty, "Map view should have accessibility label")
        }
    }
    
    func testTripConfigurationVoiceOverFocusOrder() throws {
        // Navigate to trip configuration
        navigateToTripConfiguration()
        
        // Verify logical focus order for Free-Route mode
        let freeRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Free-Route'")).firstMatch
        let customRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Custom-Route'")).firstMatch
        let pickupField = app.textFields["Pickup Location"]
        let destinationField = app.textFields["Destination"]
        
        // Mode selector should be before input fields
        XCTAssertLessThan(freeRouteButton.frame.maxY, pickupField.frame.minY,
                        "Mode selector should be before input fields in VoiceOver focus order")
        
        // Pickup should be before destination
        XCTAssertLessThan(pickupField.frame.maxY, destinationField.frame.minY,
                        "Pickup field should be before destination field in VoiceOver focus order")
        
        // Switch to Custom-Route mode and verify focus order
        customRouteButton.tap()
        
        let locationList = app.tables["location-stops-list"]
        let addStopButton = app.buttons["Add Stop"]
        
        // Mode selector should be before location list
        XCTAssertLessThan(customRouteButton.frame.maxY, locationList.frame.minY,
                        "Mode selector should be before location list in VoiceOver focus order")
        
        // Location list should be before add stop button
        XCTAssertLessThan(locationList.frame.minY, addStopButton.frame.maxY,
                        "Location list should be before or contain add stop button in VoiceOver focus order")
    }
    
    // MARK: - Dynamic Content Announcement Tests
    
    func testServiceSelectionDynamicAnnouncements() throws {
        // Test that selection changes are properly announced
        let airportCard = app.buttons["service-card-airport"]
        
        // Select the card
        airportCard.tap()
        
        // Verify selection state is reflected in accessibility
        XCTAssertTrue(airportCard.isSelected, "Airport card should be selected")
        
        // In a real app, we would verify that VoiceOver announces the selection
        // For this test, we can verify that the continue button becomes enabled
        let continueButton = app.buttons["Continue to trip configuration"]
        XCTAssertTrue(continueButton.isEnabled, "Continue button should be enabled after selection")
        
        // Deselect the card
        airportCard.tap()
        
        // Verify deselection state is reflected in accessibility
        XCTAssertFalse(airportCard.isSelected, "Airport card should be deselected")
        XCTAssertFalse(continueButton.isEnabled, "Continue button should be disabled after deselection")
    }
    
    func testTripConfigurationModeSwitchAnnouncements() throws {
        // Navigate to trip configuration
        navigateToTripConfiguration()
        
        // Switch to Custom-Route mode
        let customRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Custom-Route'")).firstMatch
        customRouteButton.tap()
        
        // Verify mode change is reflected in UI
        let locationList = app.tables["location-stops-list"]
        XCTAssertTrue(locationList.exists, "Location list should appear after switching to Custom-Route mode")
        
        // Switch back to Free-Route mode
        let freeRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Free-Route'")).firstMatch
        freeRouteButton.tap()
        
        // Verify mode change is reflected in UI
        let pickupField = app.textFields["Pickup Location"]
        XCTAssertTrue(pickupField.exists, "Pickup field should appear after switching to Free-Route mode")
    }
    
    // MARK: - Accessibility Traits Tests
    
    func testServiceCardAccessibilityTraits() throws {
        // Verify service cards have proper accessibility traits
        let airportCard = app.buttons["service-card-airport"]
        
        // Verify button trait
        XCTAssertTrue(airportCard.isButton, "Service card should have button trait")
        
        // Select the card
        airportCard.tap()
        
        // Verify selected trait
        XCTAssertTrue(airportCard.isSelected, "Service card should have selected trait when selected")
    }
    
    func testTripConfigurationModeButtonTraits() throws {
        // Navigate to trip configuration
        navigateToTripConfiguration()
        
        // Verify mode buttons have proper accessibility traits
        let freeRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Free-Route'")).firstMatch
        let customRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Custom-Route'")).firstMatch
        
        // Verify button trait
        XCTAssertTrue(freeRouteButton.isButton, "Free-Route button should have button trait")
        XCTAssertTrue(customRouteButton.isButton, "Custom-Route button should have button trait")
        
        // Verify selected trait
        XCTAssertTrue(freeRouteButton.isSelected, "Free-Route button should have selected trait by default")
        XCTAssertFalse(customRouteButton.isSelected, "Custom-Route button should not have selected trait by default")
        
        // Switch mode
        customRouteButton.tap()
        
        // Verify selected trait changes
        XCTAssertFalse(freeRouteButton.isSelected, "Free-Route button should not have selected trait after switching")
        XCTAssertTrue(customRouteButton.isSelected, "Custom-Route button should have selected trait after switching")
    }
    
    // MARK: - Helper Methods
    
    private func navigateToTripConfiguration() {
        // Select a service
        let airportCard = app.buttons["service-card-airport"]
        if airportCard.exists {
            airportCard.tap()
        }
        
        // Navigate to trip configuration
        let continueButton = app.buttons["Continue to trip configuration"]
        if continueButton.exists {
            continueButton.tap()
        }
        
        // Verify we're on the trip configuration screen
        let tripConfigTitle = app.staticTexts["Trip Configuration"]
        XCTAssertTrue(tripConfigTitle.waitForExistence(timeout: 2), "Should navigate to trip configuration screen")
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