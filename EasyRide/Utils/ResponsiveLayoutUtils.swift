import SwiftUI
#if os(iOS)
import UIKit
#endif

// MARK: - Responsive Layout Utilities
struct ResponsiveLayoutUtils {
    
    // MARK: - Size Class Detection
    static func isCompactHorizontal(_ sizeClass: UserInterfaceSizeClass?) -> Bool {
        return sizeClass == .compact
    }
    
    static func isRegularHorizontal(_ sizeClass: UserInterfaceSizeClass?) -> Bool {
        return sizeClass == .regular
    }
    
    // MARK: - Adaptive Grid Configuration
    static func adaptiveGridColumns(
        for horizontalSizeClass: UserInterfaceSizeClass?,
        compactColumns: Int = 1,
        regularColumns: Int = 2,
        spacing: CGFloat = 16,
        minItemWidth: CGFloat = 280
    ) -> [GridItem] {
        
        let columnCount: Int
        
        if isCompactHorizontal(horizontalSizeClass) {
            columnCount = compactColumns
        } else {
            // For regular size class, use the specified regular columns
            columnCount = regularColumns
        }
        
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount)
    }
    
    // MARK: - Adaptive Spacing
    static func adaptiveSpacing(
        for horizontalSizeClass: UserInterfaceSizeClass?,
        compact: CGFloat = 16,
        regular: CGFloat = 24
    ) -> CGFloat {
        return isCompactHorizontal(horizontalSizeClass) ? compact : regular
    }
    
    // MARK: - Adaptive Padding
    static func adaptivePadding(
        for horizontalSizeClass: UserInterfaceSizeClass?,
        compact: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        regular: EdgeInsets = EdgeInsets(top: 24, leading: 32, bottom: 24, trailing: 32)
    ) -> EdgeInsets {
        return isCompactHorizontal(horizontalSizeClass) ? compact : regular
    }
    
    // MARK: - Adaptive Font Sizes
    static func adaptiveFont(
        for horizontalSizeClass: UserInterfaceSizeClass?,
        compactSize: Font = .body,
        regularSize: Font = .title3
    ) -> Font {
        return isCompactHorizontal(horizontalSizeClass) ? compactSize : regularSize
    }
    
    // MARK: - Content Overflow Handling
    static func shouldUseScrollView(
        contentHeight: CGFloat,
        availableHeight: CGFloat,
        threshold: CGFloat = 0.8
    ) -> Bool {
        return contentHeight > (availableHeight * threshold)
    }
}

// MARK: - Adaptive Layout Container
struct AdaptiveLayoutContainer<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    let content: (UserInterfaceSizeClass?) -> Content
    
    init(@ViewBuilder content: @escaping (UserInterfaceSizeClass?) -> Content) {
        self.content = content
    }
    
    var body: some View {
        content(horizontalSizeClass)
            .animation(.easeInOut(duration: 0.3), value: horizontalSizeClass)
    }
}

// MARK: - Adaptive Grid Function (Task 11.1)
extension ResponsiveLayoutUtils {
    /// Creates adaptive grid columns based on horizontal size class
    /// - Compact horizontal: Uses LazyVStack (single column)
    /// - Regular horizontal: Uses LazyHStack or LazyVGrid (multiple columns)
    static func adaptiveGridFunction<Item: Identifiable, Content: View>(
        items: [Item],
        horizontalSizeClass: UserInterfaceSizeClass?,
        spacing: CGFloat = 16,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        Group {
            if isCompactHorizontal(horizontalSizeClass) {
                // Use LazyVStack for compact horizontal size class
                LazyVStack(spacing: spacing) {
                    ForEach(items) { item in
                        content(item)
                    }
                }
            } else {
                // Use LazyHStack for regular horizontal size class
                LazyHStack(spacing: spacing) {
                    ForEach(items) { item in
                        content(item)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: horizontalSizeClass)
    }
}

// MARK: - Adaptive Grid View
struct AdaptiveGrid<Item: Identifiable, ItemView: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    let items: [Item]
    let compactColumns: Int
    let regularColumns: Int
    let spacing: CGFloat
    let itemView: (Item) -> ItemView
    
    init(
        items: [Item],
        compactColumns: Int = 1,
        regularColumns: Int = 2,
        spacing: CGFloat = 16,
        @ViewBuilder itemView: @escaping (Item) -> ItemView
    ) {
        self.items = items
        self.compactColumns = compactColumns
        self.regularColumns = regularColumns
        self.spacing = spacing
        self.itemView = itemView
    }
    
    var body: some View {
        // Use the new adaptive grid function
        ResponsiveLayoutUtils.adaptiveGridFunction(
            items: items,
            horizontalSizeClass: horizontalSizeClass,
            spacing: spacing
        ) { item in
            itemView(item)
        }
    }
}

// MARK: - Adaptive Stack View
struct AdaptiveStack<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    let spacing: CGFloat
    let content: () -> Content
    
    init(spacing: CGFloat = 16, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        if ResponsiveLayoutUtils.isCompactHorizontal(horizontalSizeClass) {
            LazyVStack(spacing: spacing) {
                content()
            }
        } else {
            LazyHStack(spacing: spacing) {
                content()
            }
        }
    }
}

// MARK: - Device-Specific Utilities (Task 11.1)
extension ResponsiveLayoutUtils {
    /// Returns device-specific spacing based on screen size
    static func deviceSpecificSpacing() -> CGFloat {
        #if os(iOS)
        let screenWidth = UIScreen.main.bounds.width
        if screenWidth <= 375 { // iPhone SE, iPhone 12 mini
            return 12
        } else if screenWidth <= 414 { // iPhone 11 Pro Max, iPhone 12 Pro Max
            return 16
        } else { // iPad
            return 20
        }
        #else
        return 16 // Default for macOS
        #endif
    }
    
    /// Determines if the device is in portrait orientation
    static func isPortrait() -> Bool {
        #if os(iOS)
        return UIDevice.current.orientation.isPortrait || 
               (!UIDevice.current.orientation.isPortrait && !UIDevice.current.orientation.isLandscape)
        #else
        return true // Default for macOS
        #endif
    }
    
    /// Determines if the device is in landscape orientation
    static func isLandscape() -> Bool {
        #if os(iOS)
        return UIDevice.current.orientation.isLandscape
        #else
        return false // Default for macOS
        #endif
    }
    
    /// Returns device-specific padding
    static func deviceSpecificPadding() -> EdgeInsets {
        #if os(iOS)
        let screenWidth = UIScreen.main.bounds.width
        if screenWidth <= 375 {
            return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        } else if screenWidth <= 414 {
            return EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        } else {
            return EdgeInsets(top: 20, leading: 24, bottom: 20, trailing: 24)
        }
        #else
        return EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        #endif
    }
    
    /// Screen size categories for more granular control
    enum ScreenSizeCategory {
        case compact    // iPhone SE, iPhone 12 mini
        case regular    // iPhone 12, iPhone 13
        case large      // iPhone 12 Pro Max, iPhone 13 Pro Max
        case extraLarge // iPad
        
        static var current: ScreenSizeCategory {
            #if os(iOS)
            let screenWidth = UIScreen.main.bounds.width
            if screenWidth <= 375 {
                return .compact
            } else if screenWidth <= 414 {
                return .regular
            } else if screenWidth <= 428 {
                return .large
            } else {
                return .extraLarge
            }
            #else
            return .regular
            #endif
        }
    }
    
    /// Orientation-adaptive columns for grid layouts
    static func orientationAdaptiveColumns(
        for horizontalSizeClass: UserInterfaceSizeClass?,
        portraitColumns: Int,
        landscapeColumns: Int,
        spacing: CGFloat = 16
    ) -> [GridItem] {
        #if os(iOS)
        let isLandscape = UIDevice.current.orientation.isLandscape
        let columnCount = isLandscape ? landscapeColumns : portraitColumns
        #else
        let columnCount = portraitColumns // Default for macOS
        #endif
        
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount)
    }
    
    /// Adaptive card width based on screen size and size class
    static func adaptiveCardWidth(
        for horizontalSizeClass: UserInterfaceSizeClass?,
        screenWidth: CGFloat
    ) -> CGFloat {
        if isCompactHorizontal(horizontalSizeClass) {
            return screenWidth - 32 // Full width with padding
        } else {
            return min(400, (screenWidth - 64) / 2) // Two columns with max width
        }
    }
}

// MARK: - Adaptive Layout View Modifier (Task 11.1)
struct AdaptiveLayoutModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let spacing: CGFloat
    
    init(spacing: CGFloat = 16) {
        self.spacing = spacing
    }
    
    func body(content: Content) -> some View {
        Group {
            if ResponsiveLayoutUtils.isCompactHorizontal(horizontalSizeClass) {
                // LazyVStack for compact horizontal size class
                LazyVStack(spacing: spacing) {
                    content
                }
            } else {
                // LazyHStack for regular horizontal size class
                LazyHStack(spacing: spacing) {
                    content
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: horizontalSizeClass)
    }
}

// MARK: - View Extensions for Responsive Layout
extension View {
    /// Applies adaptive layout based on horizontal size class
    /// - Compact: LazyVStack
    /// - Regular: LazyHStack
    func adaptiveLayout(spacing: CGFloat = 16) -> some View {
        modifier(AdaptiveLayoutModifier(spacing: spacing))
    }
    
    func adaptivePadding(
        _ horizontalSizeClass: UserInterfaceSizeClass?,
        compact: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        regular: EdgeInsets = EdgeInsets(top: 24, leading: 32, bottom: 24, trailing: 32)
    ) -> some View {
        let padding = ResponsiveLayoutUtils.adaptivePadding(
            for: horizontalSizeClass,
            compact: compact,
            regular: regular
        )
        return self.padding(padding)
    }
    
    func adaptiveFont(
        _ horizontalSizeClass: UserInterfaceSizeClass?,
        compactSize: Font = .body,
        regularSize: Font = .title3
    ) -> some View {
        let font = ResponsiveLayoutUtils.adaptiveFont(
            for: horizontalSizeClass,
            compactSize: compactSize,
            regularSize: regularSize
        )
        return self.font(font)
    }
    
    func adaptiveSpacing(
        _ horizontalSizeClass: UserInterfaceSizeClass?,
        compact: CGFloat = 16,
        regular: CGFloat = 24
    ) -> some View {
        let spacing = ResponsiveLayoutUtils.adaptiveSpacing(
            for: horizontalSizeClass,
            compact: compact,
            regular: regular
        )
        return self.padding(spacing)
    }
    
    // Content overflow scroll handling
    func adaptiveScrollable(threshold: CGFloat = 0.8) -> some View {
        GeometryReader { geometry in
            ScrollView {
                self
                    .frame(minHeight: geometry.size.height * threshold)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
    
    // Device-adaptive modifiers (Task 11.1)
    func deviceAdaptive() -> some View {
        self.padding(ResponsiveLayoutUtils.deviceSpecificPadding())
    }
    
    // Orientation-adaptive modifier
    func orientationAdaptive() -> some View {
        #if os(iOS)
        self.animation(.easeInOut(duration: 0.3), value: UIDevice.current.orientation)
        #else
        self
        #endif
    }
    
    // Orientation-stable frame modifier
    func orientationStableFrame(
        portraitHeight: CGFloat,
        landscapeHeight: CGFloat
    ) -> some View {
        #if os(iOS)
        let isLandscape = UIDevice.current.orientation.isLandscape
        let height = isLandscape ? landscapeHeight : portraitHeight
        return self.frame(height: height)
        #else
        return self.frame(height: portraitHeight)
        #endif
    }
    
    // Orientation-specific layout
    func orientationSpecific<PortraitContent: View, LandscapeContent: View>(
        portrait: @escaping () -> PortraitContent,
        landscape: @escaping () -> LandscapeContent
    ) -> some View {
        Group {
            #if os(iOS)
            if ResponsiveLayoutUtils.isPortrait() {
                portrait()
            } else {
                landscape()
            }
            #else
            portrait() // Default for macOS
            #endif
        }
        .animation(.easeInOut(duration: 0.3), value: ResponsiveLayoutUtils.isPortrait())
    }
    
    // Enhanced animation modifiers are now in AnimationUtils.swift
}