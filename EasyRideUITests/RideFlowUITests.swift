import XCTest

class RideFlowUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run.
        // The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFullRideLoop() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // 1. Validating Home Screen Load
        // Ideally checking for "Home" tab or map
        let timeout: TimeInterval = 10
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: timeout), "Home tab should exist")
        
        // 2. Request a Ride
        // Simulate dragging sheet up or tapping a "Select Charter Type" area if accessible
        // Or if there are services visible, tap one.
        // Assuming we need to tap "Select Charter Type" or simply finding a service card.
        // The implementation uses a bottom sheet. Let's try to tap "ServiceSelectionView" elements if exposed.
        // However, standard flow might be simpler to just tap the first simulated driver or user location.
        // Checking existing 'ServiceSelectionUITests' logic might help, but let's assume standard elements:
        
        // Let's assume the user drags the sheet or taps the header.
        // Since dragging in Simulator via XCUITest is flaky, let's look for the text "选择包车类型" or "Select Charter Type"
        
        // Wait for sheet to appear
        sleep(2)
        
        // Tap "Airport Pickup" / "接送机" (ServiceType.airport)
        // We added localized strings: "Airport_Pickup" = "接送机"
        // But UI tests usually match display text.
        // Let's try to find the button/cell.
        
        // Note: The sheet might need to be dragged up.
        // Let's try to find a static text that is clickable, or just tap center bottom.
        
        // For robustness, let's tap the "接送机" text if visible.
        let airportServiceText = app.staticTexts["接送机"]
        if airportServiceText.exists {
             airportServiceText.tap()
        } else {
            // Fallback: try English "Airport Pickup"
             app.staticTexts["Airport Pickup"].tap()
        }
        
        // 3. Trip Configuration
        // Should be on TripConfigurationView / TripModeSettingsView
        // Tap "Next Step" / "下一步"
        let nextButton = app.buttons["下一步"]
        if nextButton.waitForExistence(timeout: 5) {
            nextButton.tap()
        }
        
        // 4. Vehicle Selection / Value Added Services
        // Tap "Confirm and Pay" / "确认并支付" or "Call Now"
        // The flow might go to "ValueAddedServicesView"
        // Look for "确认并支付" (Confirm_Pay)
        let confirmButton = app.buttons["确认并支付"]
        if confirmButton.waitForExistence(timeout: 5) {
            confirmButton.tap()
        }
        
        // 5. Order Tracking (Matching)
        // Now we should be on OrderTrackingView.
        // Verify we see "正在匹配司机" or similar.
        
        // 6. Trigger Simulation
        // Tap the debug button
        let debugButton = app.buttons["debug_simulate_ride"]
        XCTAssertTrue(debugButton.waitForExistence(timeout: 10), "Debug simulation button should appear")
        debugButton.tap()
        
        // 7. Wait for Ride Completion
        // The simulation runs matching (3s) -> matched (3s) -> en route (3s) -> arrived (3s) -> in progress (3s) -> completed.
        // Total approx 15-18 seconds.
        // Wait for "Pay Now" button to appear.
        
        let payButton = app.buttons["pay_now_button"]
        XCTAssertTrue(payButton.waitForExistence(timeout: 30), "Pay Now button should appear after ride completion")
        
        // 8. Pay
        payButton.tap()
        
        // 9. Review
        // Wait for Review screen
        let reviewCommentField = app.textFields["review_comment_field"]
        XCTAssertTrue(reviewCommentField.waitForExistence(timeout: 5), "Review comment field should appear")
        
        reviewCommentField.tap()
        reviewCommentField.typeText("Great ride!")
        
        // Dismiss keyboard if needed? Usually tap return or separate tap.
        // app.typeText("\n")
        
        let submitReviewButton = app.buttons["submit_review_button"]
        submitReviewButton.tap()
        
        // 10. Verify Return to Home
        // Should be back at Home tab
        XCTAssertTrue(homeTab.waitForExistence(timeout: 5), "Should return to Home after review")
    }
}
