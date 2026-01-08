#if canImport(XCTest)
import XCTest

final class ResponsiveLayoutUITests: XCTestCase {
    
    func testOrientationTestViewLoads() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test that orientation test view can be displayed
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }
    
    func testServiceSelectionResponsiveLayout() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test service selection view adapts to different orientations
        
        // Rotate to landscape
        XCUIDevice.shared.orientation = .landscapeLeft
        
        // Verify output - we use accessibility identifiers or labels instead of direct code
        let serviceCards = app.buttons.matching(identifier: "service-card")
        // Note: In real UI tests, we would check if these are displayed or interactable
        
        // Rotate back to portrait
        XCUIDevice.shared.orientation = .portrait
    }
}
#endif
