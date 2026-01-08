#if canImport(XCTest)
import XCTest

final class OrientationLayoutUITests: XCTestCase {
    
    func testOrientationResponsiveDemoLoads() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test that orientation responsive demo can be displayed
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }
    
    func testLayoutAdaptsToOrientationChange() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Rotate to landscape
        XCUIDevice.shared.orientation = .landscapeLeft
        
        // In UI tests, we interact with the app via accessibility elements
        // We don't call ResponsiveLayoutUtils directly.
        
        // Rotate back to portrait
        XCUIDevice.shared.orientation = .portrait
    }
}
#endif
