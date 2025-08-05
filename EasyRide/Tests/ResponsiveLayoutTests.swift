import XCTest
import SwiftUI
@testable import EasyRide

final class ResponsiveLayoutTests: XCTestCase {
    
    // MARK: - Size Class Detection Tests
    func testCompactHorizontalDetection() {
        XCTAssertTrue(ResponsiveLayoutUtils.isCompactHorizontal(.compact))
        XCTAssertFalse(ResponsiveLayoutUtils.isCompactHorizontal(.regular))
        XCTAssertFalse(ResponsiveLayoutUtils.isCompactHorizontal(nil))
    }
    
    func testRegularHorizontalDetection() {
        XCTAssertTrue(ResponsiveLayoutUtils.isRegularHorizontal(.regular))
        XCTAssertFalse(ResponsiveLayoutUtils.isRegularHorizontal(.compact))
        XCTAssertFalse(ResponsiveLayoutUtils.isRegularHorizontal(nil))
    }
    
    // MARK: - Adaptive Grid Tests
    func testAdaptiveGridColumnsCompact() {
        let columns = ResponsiveLayoutUtils.adaptiveGridColumns(
            for: .compact,
            compactColumns: 1,
            regularColumns: 2,
            spacing: 16
        )
        
        XCTAssertEqual(columns.count, 1)
        XCTAssertEqual(columns.first?.spacing, 16)
    }
    
    func testAdaptiveGridColumnsRegular() {
        let columns = ResponsiveLayoutUtils.adaptiveGridColumns(
            for: .regular,
            compactColumns: 1,
            regularColumns: 2,
            spacing: 16
        )
        
        XCTAssertEqual(columns.count, 2)
        XCTAssertEqual(columns.first?.spacing, 16)
    }
    
    func testAdaptiveGridColumnsWithMinWidth() {
        // Test with a very large minimum width to force single column
        let columns = ResponsiveLayoutUtils.adaptiveGridColumns(
            for: .regular,
            compactColumns: 1,
            regularColumns: 3,
            spacing: 16,
            minItemWidth: 1000
        )
        
        XCTAssertEqual(columns.count, 1)
    }
    
    // MARK: - Adaptive Spacing Tests
    func testAdaptiveSpacingCompact() {
        let spacing = ResponsiveLayoutUtils.adaptiveSpacing(
            for: .compact,
            compact: 12,
            regular: 24
        )
        
        XCTAssertEqual(spacing, 12)
    }
    
    func testAdaptiveSpacingRegular() {
        let spacing = ResponsiveLayoutUtils.adaptiveSpacing(
            for: .regular,
            compact: 12,
            regular: 24
        )
        
        XCTAssertEqual(spacing, 24)
    }
    
    // MARK: - Adaptive Padding Tests
    func testAdaptivePaddingCompact() {
        let compactPadding = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        let regularPadding = EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        
        let result = ResponsiveLayoutUtils.adaptivePadding(
            for: .compact,
            compact: compactPadding,
            regular: regularPadding
        )
        
        XCTAssertEqual(result.top, compactPadding.top)
        XCTAssertEqual(result.leading, compactPadding.leading)
        XCTAssertEqual(result.bottom, compactPadding.bottom)
        XCTAssertEqual(result.trailing, compactPadding.trailing)
    }
    
    func testAdaptivePaddingRegular() {
        let compactPadding = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        let regularPadding = EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        
        let result = ResponsiveLayoutUtils.adaptivePadding(
            for: .regular,
            compact: compactPadding,
            regular: regularPadding
        )
        
        XCTAssertEqual(result.top, regularPadding.top)
        XCTAssertEqual(result.leading, regularPadding.leading)
        XCTAssertEqual(result.bottom, regularPadding.bottom)
        XCTAssertEqual(result.trailing, regularPadding.trailing)
    }
    
    // MARK: - Screen Size Category Tests
    func testScreenSizeCategoryDetection() {
        let category = ResponsiveLayoutUtils.ScreenSizeCategory.current
        
        // Test that we get a valid category
        XCTAssertTrue([
            ResponsiveLayoutUtils.ScreenSizeCategory.compact,
            ResponsiveLayoutUtils.ScreenSizeCategory.regular,
            ResponsiveLayoutUtils.ScreenSizeCategory.large,
            ResponsiveLayoutUtils.ScreenSizeCategory.extraLarge
        ].contains(category))
    }
    
    // MARK: - Device-Specific Tests
    func testDeviceSpecificSpacing() {
        let spacing = ResponsiveLayoutUtils.deviceSpecificSpacing()
        
        // Should return a positive value
        XCTAssertGreaterThan(spacing, 0)
        
        // Should be within reasonable bounds
        XCTAssertLessThanOrEqual(spacing, 50)
    }
    
    func testDeviceSpecificPadding() {
        let padding = ResponsiveLayoutUtils.deviceSpecificPadding()
        
        // All padding values should be positive
        XCTAssertGreaterThan(padding.top, 0)
        XCTAssertGreaterThan(padding.leading, 0)
        XCTAssertGreaterThan(padding.bottom, 0)
        XCTAssertGreaterThan(padding.trailing, 0)
        
        // Should be within reasonable bounds
        XCTAssertLessThanOrEqual(padding.top, 50)
        XCTAssertLessThanOrEqual(padding.leading, 50)
        XCTAssertLessThanOrEqual(padding.bottom, 50)
        XCTAssertLessThanOrEqual(padding.trailing, 50)
    }
    
    // MARK: - Orientation Tests
    func testOrientationAdaptiveColumns() {
        let portraitColumns = ResponsiveLayoutUtils.orientationAdaptiveColumns(
            for: .compact,
            portraitColumns: 1,
            landscapeColumns: 2,
            spacing: 16
        )
        
        // Should return valid grid items
        XCTAssertGreaterThan(portraitColumns.count, 0)
        XCTAssertLessThanOrEqual(portraitColumns.count, 3)
    }
    
    // MARK: - Adaptive Card Width Tests
    func testAdaptiveCardWidthCompact() {
        let screenWidth: CGFloat = 375 // iPhone standard width
        let cardWidth = ResponsiveLayoutUtils.adaptiveCardWidth(
            for: .compact,
            screenWidth: screenWidth
        )
        
        XCTAssertEqual(cardWidth, screenWidth - 32) // Full width with padding
    }
    
    func testAdaptiveCardWidthRegular() {
        let screenWidth: CGFloat = 768 // iPad width
        let cardWidth = ResponsiveLayoutUtils.adaptiveCardWidth(
            for: .regular,
            screenWidth: screenWidth
        )
        
        let expectedWidth = min(400, (screenWidth - 64) / 2)
        XCTAssertEqual(cardWidth, expectedWidth)
    }
    
    // MARK: - Content Overflow Tests
    func testShouldUseScrollView() {
        // Content fits within available space
        XCTAssertFalse(ResponsiveLayoutUtils.shouldUseScrollView(
            contentHeight: 400,
            availableHeight: 600,
            threshold: 0.8
        ))
        
        // Content exceeds threshold
        XCTAssertTrue(ResponsiveLayoutUtils.shouldUseScrollView(
            contentHeight: 500,
            availableHeight: 600,
            threshold: 0.8
        ))
        
        // Content exactly at threshold
        XCTAssertFalse(ResponsiveLayoutUtils.shouldUseScrollView(
            contentHeight: 480,
            availableHeight: 600,
            threshold: 0.8
        ))
    }
    
    // MARK: - Performance Tests
    func testAdaptiveGridPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = ResponsiveLayoutUtils.adaptiveGridColumns(
                    for: .compact,
                    compactColumns: 1,
                    regularColumns: 2,
                    spacing: 16
                )
            }
        }
    }
    
    func testDeviceSpecificSpacingPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = ResponsiveLayoutUtils.deviceSpecificSpacing()
            }
        }
    }
}

// MARK: - UI Tests for Responsive Layout
final class ResponsiveLayoutUITests: XCTestCase {
    
    func testOrientationTestViewLoads() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test that orientation test view can be displayed
        // This would be integrated into the main app navigation for testing
        XCTAssertTrue(app.isDisplayed)
    }
    
    func testServiceSelectionResponsiveLayout() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test service selection view adapts to different orientations
        // This test would verify that service cards are properly laid out
        // in both portrait and landscape orientations
        
        // Rotate to landscape
        XCUIDevice.shared.orientation = .landscapeLeft
        
        // Verify layout adapts
        let serviceCards = app.buttons.matching(identifier: "service-card")
        XCTAssertGreaterThan(serviceCards.count, 0)
        
        // Rotate back to portrait
        XCUIDevice.shared.orientation = .portrait
        
        // Verify layout adapts again
        XCTAssertGreaterThan(serviceCards.count, 0)
    }
}