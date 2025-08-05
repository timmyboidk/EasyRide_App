import XCTest
import SwiftUI
@testable import EasyRide

/// UI tests for trip configuration mode switching
final class TripConfigurationModeTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Set up test environment
        app.launchArguments.append("--uitesting")
        app.launchArguments.append("--skip-authentication") // Skip login for UI tests
        app.launch()
        
        // Navigate to trip configuration screen
        navigateToTripConfiguration()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Mode Switching Tests
    
    func testModeSelectorDisplay() throws {
        // Verify mode selector is displayed
        let freeRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Free-Route'")).firstMatch
        let customRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Custom-Route'")).firstMatch
        
        XCTAssertTrue(freeRouteButton.exists, "Free-Route mode button should exist")
        XCTAssertTrue(customRouteButton.exists, "Custom-Route mode button should exist")
        
        // Verify Free-Route is selected by default
        XCTAssertTrue(freeRouteButton.isSelected, "Free-Route should be selected by default")
        XCTAssertFalse(customRouteButton.isSelected, "Custom-Route should not be selected by default")
    }
    
    func testSwitchingToCustomRouteMode() throws {
        // Switch to Custom-Route mode
        let customRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Custom-Route'")).firstMatch
        customRouteButton.tap()
        
        // Verify Custom-Route is selected
        XCTAssertTrue(customRouteButton.isSelected, "Custom-Route should be selected after tap")
        
        // Verify Custom-Route UI elements are displayed
        let locationList = app.tables["location-stops-list"]
        XCTAssertTrue(locationList.waitForExistence(timeout: 2), "Location stops list should be displayed in Custom-Route mode")
        
        // Verify map preview is displayed
        let mapView = app.maps.firstMatch
        XCTAssertTrue(mapView.exists, "Map preview should be displayed in Custom-Route mode")
        
        // Verify add stop button is displayed
        let addStopButton = app.buttons["Add Stop"]
        XCTAssertTrue(addStopButton.exists, "Add Stop button should be displayed in Custom-Route mode")
    }
    
    func testSwitchingToFreeRouteMode() throws {
        // First switch to Custom-Route mode
        let customRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Custom-Route'")).firstMatch
        customRouteButton.tap()
        
        // Then switch back to Free-Route mode
        let freeRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Free-Route'")).firstMatch
        freeRouteButton.tap()
        
        // Verify Free-Route is selected
        XCTAssertTrue(freeRouteButton.isSelected, "Free-Route should be selected after tap")
        
        // Verify Free-Route UI elements are displayed
        let pickupField = app.textFields["Pickup Location"]
        let destinationField = app.textFields["Destination"]
        
        XCTAssertTrue(pickupField.waitForExistence(timeout: 2), "Pickup location field should be displayed in Free-Route mode")
        XCTAssertTrue(destinationField.exists, "Destination field should be displayed in Free-Route mode")
        
        // Verify time picker is displayed
        let timePicker = app.datePickers["Scheduled pickup time"]
        XCTAssertTrue(timePicker.exists, "Time picker should be displayed in Free-Route mode")
    }
    
    func testDataPreservationBetweenModes() throws {
        // Enter data in Free-Route mode
        let pickupField = app.textFields["Pickup Location"]
        pickupField.tap()
        pickupField.typeText("123 Main St")
        
        let destinationField = app.textFields["Destination"]
        destinationField.tap()
        destinationField.typeText("456 Park Ave")
        
        // Switch to Custom-Route mode
        let customRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Custom-Route'")).firstMatch
        customRouteButton.tap()
        
        // Verify data is preserved in location list
        let locationList = app.tables["location-stops-list"]
        XCTAssertTrue(locationList.waitForExistence(timeout: 2), "Location stops list should be displayed")
        
        let firstStop = locationList.cells.element(boundBy: 0)
        let secondStop = locationList.cells.element(boundBy: 1)
        
        XCTAssertTrue(firstStop.staticTexts["123 Main St"].exists || firstStop.label.contains("123 Main St"), 
                     "Pickup location should be preserved in Custom-Route mode")
        XCTAssertTrue(secondStop.staticTexts["456 Park Ave"].exists || secondStop.label.contains("456 Park Ave"), 
                     "Destination should be preserved in Custom-Route mode")
        
        // Switch back to Free-Route mode
        let freeRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Free-Route'")).firstMatch
        freeRouteButton.tap()
        
        // Verify data is preserved
        XCTAssertEqual(pickupField.value as? String, "123 Main St", "Pickup location should be preserved when switching back to Free-Route mode")
        XCTAssertEqual(destinationField.value as? String, "456 Park Ave", "Destination should be preserved when switching back to Free-Route mode")
    }
    
    func testAddingStopsInCustomRouteMode() throws {
        // Switch to Custom-Route mode
        let customRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Custom-Route'")).firstMatch
        customRouteButton.tap()
        
        // Verify location list exists
        let locationList = app.tables["location-stops-list"]
        XCTAssertTrue(locationList.waitForExistence(timeout: 2), "Location stops list should be displayed")
        
        // Get initial number of stops
        let initialStopCount = locationList.cells.count
        
        // Add a new stop
        let addStopButton = app.buttons["Add Stop"]
        addStopButton.tap()
        
        // Enter location for new stop
        let newStopField = app.textFields.element(boundBy: locationList.cells.count - 1)
        newStopField.tap()
        newStopField.typeText("789 Broadway")
        
        // Verify new stop was added
        XCTAssertEqual(locationList.cells.count, initialStopCount + 1, "A new stop should be added to the location list")
        
        // Verify stop duration picker is available
        let durationPicker = app.pickers["Stop Duration"]
        XCTAssertTrue(durationPicker.exists, "Duration picker should be available for stops")
    }
    
    func testDraggingStopsInCustomRouteMode() throws {
        // Switch to Custom-Route mode
        let customRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Custom-Route'")).firstMatch
        customRouteButton.tap()
        
        // Add multiple stops
        let addStopButton = app.buttons["Add Stop"]
        addStopButton.tap()
        
        let locationList = app.tables["location-stops-list"]
        let lastStopField = locationList.textFields.element(boundBy: locationList.cells.count - 1)
        lastStopField.tap()
        lastStopField.typeText("Stop A")
        
        addStopButton.tap()
        let newLastStopField = locationList.textFields.element(boundBy: locationList.cells.count - 1)
        newLastStopField.tap()
        newLastStopField.typeText("Stop B")
        
        // Note: Actual drag and drop testing is limited in XCTest
        // In a real test environment, we would use drag and drop APIs
        // For now, we'll verify the reordering buttons exist
        
        let reorderButtons = locationList.buttons.matching(NSPredicate(format: "label CONTAINS 'Reorder'"))
        XCTAssertGreaterThan(reorderButtons.count, 0, "Reorder handles should exist for stops")
    }
    
    // MARK: - Accessibility Tests
    
    func testModeSelectorAccessibility() throws {
        // Verify mode selector has proper accessibility
        let freeRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Free-Route'")).firstMatch
        let customRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Custom-Route'")).firstMatch
        
        // Verify accessibility labels
        XCTAssertFalse(freeRouteButton.label.isEmpty, "Free-Route button should have accessibility label")
        XCTAssertFalse(customRouteButton.label.isEmpty, "Custom-Route button should have accessibility label")
        
        // Verify buttons are accessible
        XCTAssertTrue(freeRouteButton.isEnabled, "Free-Route button should be enabled for accessibility")
        XCTAssertTrue(customRouteButton.isEnabled, "Custom-Route button should be enabled for accessibility")
    }
    
    func testFreeRouteModeAccessibility() throws {
        // Verify Free-Route mode elements have proper accessibility
        let pickupField = app.textFields["Pickup Location"]
        let destinationField = app.textFields["Destination"]
        
        // Verify text fields have proper accessibility labels
        XCTAssertFalse(pickupField.label.isEmpty, "Pickup field should have accessibility label")
        XCTAssertFalse(destinationField.label.isEmpty, "Destination field should have accessibility label")
        
        // Verify time picker has proper accessibility
        let timePicker = app.datePickers["Scheduled pickup time"]
        XCTAssertFalse(timePicker.label.isEmpty, "Time picker should have accessibility label")
    }
    
    func testCustomRouteModeAccessibility() throws {
        // Switch to Custom-Route mode
        let customRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Custom-Route'")).firstMatch
        customRouteButton.tap()
        
        // Verify location list has proper accessibility
        let locationList = app.tables["location-stops-list"]
        XCTAssertTrue(locationList.exists, "Location list should exist")
        
        // Verify add stop button has proper accessibility
        let addStopButton = app.buttons["Add Stop"]
        XCTAssertFalse(addStopButton.label.isEmpty, "Add Stop button should have accessibility label")
        XCTAssertTrue(addStopButton.isEnabled, "Add Stop button should be enabled for accessibility")
    }
    
    // MARK: - Responsive Layout Tests
    
    func testResponsiveLayoutInFreeRouteMode() throws {
        // Verify layout adapts to different size classes
        // Note: This is limited in XCTest without the ability to resize the window
        
        // Verify basic layout elements exist
        let pickupField = app.textFields["Pickup Location"]
        let destinationField = app.textFields["Destination"]
        
        XCTAssertTrue(pickupField.exists, "Pickup field should exist in any layout")
        XCTAssertTrue(destinationField.exists, "Destination field should exist in any layout")
        
        // Verify passenger stepper exists
        let decreaseButton = app.buttons["Decrease passenger count"]
        let increaseButton = app.buttons["Increase passenger count"]
        
        XCTAssertTrue(decreaseButton.exists, "Decrease passenger button should exist in any layout")
        XCTAssertTrue(increaseButton.exists, "Increase passenger button should exist in any layout")
    }
    
    func testResponsiveLayoutInCustomRouteMode() throws {
        // Switch to Custom-Route mode
        let customRouteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Custom-Route'")).firstMatch
        customRouteButton.tap()
        
        // Verify basic layout elements exist
        let locationList = app.tables["location-stops-list"]
        let mapView = app.maps.firstMatch
        
        XCTAssertTrue(locationList.exists, "Location list should exist in any layout")
        XCTAssertTrue(mapView.exists, "Map view should exist in any layout")
        
        // Verify add stop button exists
        let addStopButton = app.buttons["Add Stop"]
        XCTAssertTrue(addStopButton.exists, "Add Stop button should exist in any layout")
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
    var isSelected: Bool {
        return (value(forKey: "selected") as? Bool) ?? false
    }
}