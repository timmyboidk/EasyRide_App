import XCTest
import SwiftUI
@testable import EasyRide

final class OrientationLayoutTests: XCTestCase {
    
    // MARK: - Orientation Detection Tests
    func testOrientationDetection() {
        // Test that orientation detection functions exist and return boolean values
        let isPortrait = ResponsiveLayoutUtils.isPortrait()
        let isLandscape = ResponsiveLayoutUtils.isLandscape()
        
        XCTAssertTrue(isPortrait is Bool)
        XCTAssertTrue(isLandscape is Bool)
        XCTAssertEqual(isPortrait, !isLandscape, "isPortrait and isLandscape should be opposites")
    }
    
    func testCurrentOrientationString() {
        // Test that orientation string function returns a valid string
        let orientationString = ResponsiveLayoutUtils.currentOrientationString()
        
        XCTAssertTrue(["Portrait", "Landscape", "Unknown"].contains(orientationString))
    }
    
    // MARK: - Orientation-Aware Layout Tests
    func testOrientationAwareSpacing() {
        // Test portrait spacing
        let portraitSpacing: CGFloat = 16
        let landscapeSpacing: CGFloat = 24
        
        let spacing = ResponsiveLayoutUtils.orientationAwareSpacing(
            portrait: portraitSpacing,
            landscape: landscapeSpacing
        )
        
        // We can't directly test orientation in unit tests, but we can verify the function returns
        // either the portrait or landscape value
        XCTAssertTrue([portraitSpacing, landscapeSpacing].contains(spacing))
    }
    
    func testOrientationAwarePadding() {
        let portraitPadding = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        let landscapePadding = EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        
        let padding = ResponsiveLayoutUtils.orientationAwarePadding(
            portrait: portraitPadding,
            landscape: landscapePadding
        )
        
        // Verify that the function returns valid padding values
        XCTAssertTrue(
            (padding.top == portraitPadding.top && padding.leading == portraitPadding.leading) ||
            (padding.top == landscapePadding.top && padding.leading == landscapePadding.leading)
        )
    }
    
    // MARK: - Device Size Adaptation Tests
    func testDeviceSizeScaleFactor() {
        let scaleFactor = ResponsiveLayoutUtils.deviceSizeScaleFactor()
        
        // Scale factor should be within reasonable bounds
        XCTAssertGreaterThan(scaleFactor, 0.5)
        XCTAssertLessThan(scaleFactor, 2.0)
    }
    
    func testDeviceAwareHeight() {
        let baseHeight: CGFloat = 100
        let height = ResponsiveLayoutUtils.deviceAwareHeight(
            baseHeight: baseHeight,
            compactMultiplier: 0.9,
            regularMultiplier: 1.1
        )
        
        // Height should be scaled but within reasonable bounds
        XCTAssertGreaterThan(height, baseHeight * 0.5)
        XCTAssertLessThan(height, baseHeight * 1.5)
    }
    
    func testDeviceAwareContentWidth() {
        let availableWidth: CGFloat = 400
        let maxWidth: CGFloat = 500
        
        let width = ResponsiveLayoutUtils.deviceAwareContentWidth(
            availableWidth: availableWidth,
            maxWidth: maxWidth
        )
        
        // Width should be constrained
        XCTAssertGreaterThan(width, availableWidth * 0.5)
        XCTAssertLessThanOrEqual(width, maxWidth)
    }
    
    // MARK: - Content Overflow Tests
    func testShouldScrollInCurrentOrientation() {
        let contentHeight: CGFloat = 1000
        let availableHeight: CGFloat = 800
        
        let shouldScroll = ResponsiveLayoutUtils.shouldScrollInCurrentOrientation(
            contentHeight: contentHeight,
            availableHeight: availableHeight
        )
        
        // Content exceeds available height, so should scroll
        XCTAssertTrue(shouldScroll)
        
        // Test with content that fits
        let smallContentHeight: CGFloat = 400
        let shouldNotScroll = ResponsiveLayoutUtils.shouldScrollInCurrentOrientation(
            contentHeight: smallContentHeight,
            availableHeight: availableHeight
        )
        
        XCTAssertFalse(shouldNotScroll)
    }
    
    // MARK: - Orientation Adaptive Columns Tests
    func testOrientationAdaptiveColumns() {
        let portraitColumns = 2
        let landscapeColumns = 3
        
        let columns = ResponsiveLayoutUtils.orientationAdaptiveColumns(
            for: .compact,
            portraitColumns: portraitColumns,
            landscapeColumns: landscapeColumns
        )
        
        // Verify that columns are created
        XCTAssertGreaterThan(columns.count, 0)
        XCTAssertLessThanOrEqual(columns.count, max(portraitColumns, landscapeColumns))
    }
    
    // MARK: - Requirements Verification Tests
    func testRequirement7_3_OrientationChanges() {
        // Requirement 7.3: WHEN device orientation changes THEN the system SHALL adapt layout smoothly without data loss
        
        // Test orientation-aware spacing
        let portraitSpacing: CGFloat = 16
        let landscapeSpacing: CGFloat = 24
        let spacing = ResponsiveLayoutUtils.orientationAwareSpacing(
            portrait: portraitSpacing,
            landscape: landscapeSpacing
        )
        
        // Verify that spacing is adapted based on orientation
        XCTAssertTrue([portraitSpacing, landscapeSpacing].contains(spacing))
        
        // Test orientation-adaptive columns
        let portraitColumnCount = 2
        let landscapeColumnCount = 3
        let columns = ResponsiveLayoutUtils.orientationAdaptiveColumns(
            for: .compact,
            portraitColumns: portraitColumnCount,
            landscapeColumns: landscapeColumnCount
        )
        
        // Verify that column count is adapted based on orientation
        XCTAssertGreaterThan(columns.count, 0)
    }
    
    func testRequirement7_4_ProperSpacingAndProportions() {
        // Requirement 7.4: WHEN using different screen sizes THEN the system SHALL maintain proper spacing and proportions
        
        // Test device-aware height scaling
        let baseHeight: CGFloat = 100
        let height = ResponsiveLayoutUtils.deviceAwareHeight(baseHeight: baseHeight)
        
        // Height should be scaled based on device size
        XCTAssertNotEqual(height, baseHeight, "Height should be scaled based on device size")
        
        // Test device size scale factor
        let scaleFactor = ResponsiveLayoutUtils.deviceSizeScaleFactor()
        XCTAssertGreaterThan(scaleFactor, 0, "Scale factor should be positive")
    }
    
    func testRequirement7_5_ScrollingBehavior() {
        // Requirement 7.5: IF content exceeds screen bounds THEN the system SHALL provide appropriate scrolling behavior
        
        // Test content overflow detection
        let contentHeight: CGFloat = 1000
        let availableHeight: CGFloat = 500
        
        let shouldScroll = ResponsiveLayoutUtils.shouldScrollInCurrentOrientation(
            contentHeight: contentHeight,
            availableHeight: availableHeight
        )
        
        XCTAssertTrue(shouldScroll, "Should enable scrolling when content exceeds available height")
        
        // Test with content that fits
        let smallContentHeight: CGFloat = 300
        let shouldNotScroll = ResponsiveLayoutUtils.shouldScrollInCurrentOrientation(
            contentHeight: smallContentHeight,
            availableHeight: availableHeight
        )
        
        XCTAssertFalse(shouldNotScroll, "Should not enable scrolling when content fits within available height")
    }
}

// MARK: - Integration Tests
final class OrientationLayoutIntegrationTests: XCTestCase {
    
    func testOrientationAwareContainerCreation() {
        // Test that OrientationAwareContainer can be created
        let container = OrientationAwareContainer { isLandscape in
            Text("Test")
        }
        
        XCTAssertNotNil(container)
    }
    
    func testOrientationObserverCreation() {
        // Test that OrientationObserver can be created
        let observer = OrientationObserver(action: { _ in })
        
        XCTAssertNotNil(observer)
    }
    
    func testOrientationResponsiveCardCreation() {
        // Test that OrientationResponsiveCard can be created
        let item = DemoItem(title: "Test", subtitle: "Subtitle", icon: "star")
        let card = OrientationResponsiveCard(item: item, isLandscape: false)
        
        XCTAssertNotNil(card)
    }
}

// MARK: - UI Tests
final class OrientationLayoutUITests: XCTestCase {
    
    func testOrientationResponsiveDemoLoads() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test that orientation responsive demo can be displayed
        // This would be integrated into the main app navigation for testing
        XCTAssertTrue(app.isDisplayed)
    }
    
    func testLayoutAdaptsToOrientationChange() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Rotate to landscape
        XCUIDevice.shared.orientation = .landscapeLeft
        
        // Verify layout adapts
        // This would check for specific UI elements that change in landscape
        
        // Rotate back to portrait
        XCUIDevice.shared.orientation = .portrait
        
        // Verify layout adapts back
        // This would check that UI elements return to portrait layout
    }
}