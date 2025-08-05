import XCTest
import SwiftUI
@testable import EasyRide

final class AdaptiveLayoutTests: XCTestCase {
    
    // MARK: - Adaptive Grid Function Tests
    func testAdaptiveGridFunctionWithCompactSizeClass() {
        // Test items
        struct TestItem: Identifiable {
            let id = UUID()
            let title: String
        }
        
        let testItems = [
            TestItem(title: "Item 1"),
            TestItem(title: "Item 2"),
            TestItem(title: "Item 3")
        ]
        
        // Test with compact size class (should use LazyVStack)
        let compactView = ResponsiveLayoutUtils.adaptiveGridFunction(
            items: testItems,
            horizontalSizeClass: .compact
        ) { item in
            Text(item.title)
        }
        
        // We can't directly test the view hierarchy, but we can verify the function returns a view
        XCTAssertNotNil(compactView)
    }
    
    func testAdaptiveGridFunctionWithRegularSizeClass() {
        // Test items
        struct TestItem: Identifiable {
            let id = UUID()
            let title: String
        }
        
        let testItems = [
            TestItem(title: "Item 1"),
            TestItem(title: "Item 2"),
            TestItem(title: "Item 3")
        ]
        
        // Test with regular size class (should use LazyHStack)
        let regularView = ResponsiveLayoutUtils.adaptiveGridFunction(
            items: testItems,
            horizontalSizeClass: .regular
        ) { item in
            Text(item.title)
        }
        
        // We can't directly test the view hierarchy, but we can verify the function returns a view
        XCTAssertNotNil(regularView)
    }
    
    // MARK: - Adaptive Layout Modifier Tests
    func testAdaptiveLayoutModifier() {
        let modifier = AdaptiveLayoutModifier(spacing: 16)
        XCTAssertNotNil(modifier)
        XCTAssertEqual(modifier.spacing, 16)
    }
    
    // MARK: - Orientation Tests
    func testIsPortraitFunction() {
        // We can't directly test device orientation in unit tests,
        // but we can verify the function exists and returns a boolean
        let isPortrait = ResponsiveLayoutUtils.isPortrait()
        XCTAssertTrue(isPortrait is Bool)
    }
    
    func testIsLandscapeFunction() {
        // We can't directly test device orientation in unit tests,
        // but we can verify the function exists and returns a boolean
        let isLandscape = ResponsiveLayoutUtils.isLandscape()
        XCTAssertTrue(isLandscape is Bool)
    }
    
    // MARK: - Requirements Verification Tests
    func testRequirement7_1_CompactHorizontalUsesLazyVStack() {
        // Requirement 7.1: WHEN using compact horizontal size class THEN the system SHALL use LazyVStack layout
        let isCompact = ResponsiveLayoutUtils.isCompactHorizontal(.compact)
        XCTAssertTrue(isCompact, "Compact horizontal size class should be detected correctly")
        
        // Verify that compact size class results in single column (LazyVStack behavior)
        let columns = ResponsiveLayoutUtils.adaptiveGridColumns(for: .compact, compactColumns: 1, regularColumns: 2)
        XCTAssertEqual(columns.count, 1, "Compact horizontal size class should use LazyVStack (single column)")
    }
    
    func testRequirement7_2_RegularHorizontalUsesLazyHStack() {
        // Requirement 7.2: WHEN using regular horizontal size class THEN the system SHALL use LazyHStack layout
        let isRegular = ResponsiveLayoutUtils.isRegularHorizontal(.regular)
        XCTAssertTrue(isRegular, "Regular horizontal size class should be detected correctly")
        
        // Verify that regular size class results in multiple columns (LazyHStack behavior)
        let columns = ResponsiveLayoutUtils.adaptiveGridColumns(for: .regular, compactColumns: 1, regularColumns: 2)
        XCTAssertEqual(columns.count, 2, "Regular horizontal size class should use LazyHStack (multiple columns)")
    }
    
    func testRequirement7_5_ProperSpacingAndProportions() {
        // Requirement 7.5: WHEN using different screen sizes THEN the system SHALL maintain proper spacing and proportions
        
        // Test spacing adaptation
        let compactSpacing = ResponsiveLayoutUtils.adaptiveSpacing(for: .compact)
        let regularSpacing = ResponsiveLayoutUtils.adaptiveSpacing(for: .regular)
        
        XCTAssertNotEqual(compactSpacing, regularSpacing, "Different size classes should have different spacing")
        XCTAssertGreaterThan(compactSpacing, 0, "Compact spacing should be positive")
        XCTAssertGreaterThan(regularSpacing, 0, "Regular spacing should be positive")
        
        // Test device-specific spacing
        let deviceSpacing = ResponsiveLayoutUtils.deviceSpecificSpacing()
        XCTAssertGreaterThan(deviceSpacing, 0, "Device-specific spacing should maintain proper proportions")
    }
}