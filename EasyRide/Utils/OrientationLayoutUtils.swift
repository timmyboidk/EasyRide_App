import SwiftUI

#if canImport(UIKit)
import UIKit
#if os(iOS)

// MARK: - Orientation and Device Support Extensions
extension ResponsiveLayoutUtils {
    
    // MARK: - Orientation Change Handling
    
    /// Detects orientation changes and returns a boolean indicating if orientation has changed
    /// - Parameter previousOrientation: The previous orientation to compare against
    /// - Returns: True if orientation has changed, false otherwise
    static func hasOrientationChanged(from previousOrientation: UIDeviceOrientation?) -> Bool {
        #if os(iOS)
        guard let previousOrientation = previousOrientation else { return false }
        let currentOrientation = UIDevice.current.orientation
        
        // Check if orientation type changed (portrait to landscape or vice versa)
        let wasPortrait = previousOrientation.isPortrait || (!previousOrientation.isPortrait && !previousOrientation.isLandscape)
        let isPortrait = currentOrientation.isPortrait || (!currentOrientation.isPortrait && !currentOrientation.isLandscape)
        
        return wasPortrait != isPortrait
        #else
        return false
        #endif
    }
    
    /// Returns the current device orientation as a string
    static func currentOrientationString() -> String {
        #if os(iOS)
        if isPortrait() {
            return "Portrait"
        } else if isLandscape() {
            return "Landscape"
        } else {
            return "Unknown"
        }
        #else
        return "Portrait"
        #endif
    }
    
    // MARK: - Safe Area Handling
    
    /// Returns safe area insets adjusted for the current orientation
    static func orientationAwareSafeAreaInsets() -> EdgeInsets {
        #if os(iOS)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return EdgeInsets()
        }
        
        let safeAreaInsets = window.safeAreaInsets
        
        if isLandscape() {
            // In landscape, we might want to adjust the insets differently
            return EdgeInsets(
                top: safeAreaInsets.top,
                leading: max(safeAreaInsets.left, 8),
                bottom: safeAreaInsets.bottom,
                trailing: max(safeAreaInsets.right, 8)
            )
        } else {
            // In portrait, use standard insets
            return EdgeInsets(
                top: safeAreaInsets.top,
                leading: safeAreaInsets.left,
                bottom: safeAreaInsets.bottom,
                trailing: safeAreaInsets.right
            )
        }
        #else
        return EdgeInsets()
        #endif
    }
    
    // MARK: - Content Overflow Handling
    
    /// Determines if content should scroll based on orientation
    /// - Parameters:
    ///   - contentHeight: Height of the content
    ///   - availableHeight: Available height in the container
    /// - Returns: Boolean indicating if scrolling should be enabled
    static func shouldScrollInCurrentOrientation(contentHeight: CGFloat, availableHeight: CGFloat) -> Bool {
        #if os(iOS)
        let threshold: CGFloat = isLandscape() ? 0.9 : 0.8
        return contentHeight > (availableHeight * threshold)
        #else
        return contentHeight > (availableHeight * 0.8)
        #endif
    }
    
    // MARK: - Orientation-Specific Layout
    
    /// Returns the appropriate spacing for the current orientation
    /// - Parameters:
    ///   - portrait: Spacing to use in portrait orientation
    ///   - landscape: Spacing to use in landscape orientation
    /// - Returns: Appropriate spacing for current orientation
    static func orientationAwareSpacing(portrait: CGFloat = 16, landscape: CGFloat = 24) -> CGFloat {
        #if os(iOS)
        return isLandscape() ? landscape : portrait
        #else
        return portrait
        #endif
    }
    
    /// Returns the appropriate padding for the current orientation
    /// - Parameters:
    ///   - portrait: Padding to use in portrait orientation
    ///   - landscape: Padding to use in landscape orientation
    /// - Returns: Appropriate padding for current orientation
    static func orientationAwarePadding(
        portrait: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        landscape: EdgeInsets = EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
    ) -> EdgeInsets {
        #if os(iOS)
        return isLandscape() ? landscape : portrait
        #else
        return portrait
        #endif
    }
    
    /// Returns the appropriate font size for the current orientation
    /// - Parameters:
    ///   - portrait: Font to use in portrait orientation
    ///   - landscape: Font to use in landscape orientation
    /// - Returns: Appropriate font for current orientation
    static func orientationAwareFont(portrait: Font, landscape: Font) -> Font {
        #if os(iOS)
        return isLandscape() ? landscape : portrait
        #else
        return portrait
        #endif
    }
    
    // MARK: - Device Size Adaptation
    
    /// Returns a multiplier for scaling UI elements based on device screen size
    /// - Returns: Scale factor for UI elements
    static func deviceSizeScaleFactor() -> CGFloat {
        #if os(iOS)
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let screenSize = min(screenWidth, screenHeight)
        
        switch screenSize {
        case ...320: // iPhone SE 1st gen
            return 0.85
        case ...375: // iPhone SE 2nd/3rd gen, iPhone 12/13 mini
            return 0.9
        case ...390: // iPhone 12/13/14
            return 1.0
        case ...428: // iPhone 12/13/14 Pro Max
            return 1.1
        default: // iPad and larger devices
            return 1.2
        }
        #else
        return 1.0
        #endif
    }
    
    /// Returns appropriate frame height based on device size and orientation
    /// - Parameters:
    ///   - baseHeight: Base height to scale
    ///   - compactMultiplier: Multiplier for compact devices
    ///   - regularMultiplier: Multiplier for regular devices
    /// - Returns: Scaled height appropriate for current device
    static func deviceAwareHeight(
        baseHeight: CGFloat,
        compactMultiplier: CGFloat = 0.9,
        regularMultiplier: CGFloat = 1.1
    ) -> CGFloat {
        #if os(iOS)
        let scaleFactor = deviceSizeScaleFactor()
        let orientationMultiplier = isLandscape() ? 0.8 : 1.0
        
        switch ScreenSizeCategory.current {
        case .compact:
            return baseHeight * compactMultiplier * scaleFactor * orientationMultiplier
        case .regular:
            return baseHeight * scaleFactor * orientationMultiplier
        case .large, .extraLarge:
            return baseHeight * regularMultiplier * scaleFactor * orientationMultiplier
        }
        #else
        return baseHeight
        #endif
    }
    
    /// Returns appropriate content width based on device size and orientation
    /// - Parameters:
    ///   - availableWidth: Available width in container
    ///   - maxWidth: Maximum allowed width
    /// - Returns: Constrained width appropriate for content
    static func deviceAwareContentWidth(availableWidth: CGFloat, maxWidth: CGFloat = 500) -> CGFloat {
        #if os(iOS)
        if isLandscape() {
            // In landscape, we might want to constrain width more to prevent overly wide content
            return min(availableWidth * 0.85, maxWidth)
        } else {
            // In portrait, use more of the available width
            return min(availableWidth * 0.95, maxWidth)
        }
        #else
        return min(availableWidth * 0.95, maxWidth)
        #endif
    }
}

// MARK: - View Extensions for Orientation Support
extension View {
    /// Applies orientation-aware padding to a view
    /// - Parameters:
    ///   - portrait: Padding to use in portrait orientation
    ///   - landscape: Padding to use in landscape orientation
    /// - Returns: View with orientation-specific padding applied
    func orientationAwarePadding(
        portrait: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        landscape: EdgeInsets = EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
    ) -> some View {
        let padding = ResponsiveLayoutUtils.orientationAwarePadding(
            portrait: portrait,
            landscape: landscape
        )
        return self.padding(padding)
    }
    
    /// Applies safe area padding that adapts to the current orientation
    /// - Parameter additionalBottom: Extra padding to add to the bottom
    /// - Returns: View with safe area padding applied
    func safeAreaAdaptive(additionalBottom: CGFloat = 0) -> some View {
        #if os(iOS)
        self.padding(.bottom, ResponsiveLayoutUtils.isLandscape() ? additionalBottom * 0.5 : additionalBottom)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 1) }
        #else
        self.padding(.bottom, additionalBottom)
        #endif
    }
    
    /// Applies device-aware frame height
    /// - Parameter height: Base height to scale according to device size
    /// - Returns: View with appropriate height for current device
    func deviceAwareHeight(_ height: CGFloat) -> some View {
        self.frame(height: ResponsiveLayoutUtils.deviceAwareHeight(baseHeight: height))
    }
    
    /// Constrains content width based on device and orientation
    /// - Parameter maxWidth: Maximum allowed width
    /// - Returns: View with constrained width
    func deviceAwareWidth(maxWidth: CGFloat = 500) -> some View {
        GeometryReader { geometry in
            self.frame(
                width: ResponsiveLayoutUtils.deviceAwareContentWidth(
                    availableWidth: geometry.size.width,
                    maxWidth: maxWidth
                )
            )
        }
    }
    
    /// Applies orientation-aware scrolling behavior
    /// - Parameter threshold: Scroll threshold (0.0-1.0)
    /// - Returns: View with appropriate scrolling behavior
    func orientationAwareScrollView(threshold: CGFloat = 0.8) -> some View {
        GeometryReader { geometry in
            ScrollView {
                self.frame(minHeight: geometry.size.height * threshold)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
    
    /// Applies orientation-aware font sizing
    /// - Parameters:
    ///   - portraitFont: Font to use in portrait orientation
    ///   - landscapeFont: Font to use in landscape orientation
    /// - Returns: View with orientation-specific font applied
    func orientationAwareFont(
        portraitFont: Font,
        landscapeFont: Font
    ) -> some View {
        self.font(ResponsiveLayoutUtils.orientationAwareFont(
            portrait: portraitFont,
            landscape: landscapeFont
        ))
    }
    
    /// Applies orientation-aware spacing
    /// - Parameters:
    ///   - portrait: Spacing to use in portrait orientation
    ///   - landscape: Spacing to use in landscape orientation
    /// - Returns: View with orientation-specific spacing applied
    func orientationAwareSpacing(
        portrait: CGFloat = 16,
        landscape: CGFloat = 24
    ) -> some View {
        self.padding(ResponsiveLayoutUtils.orientationAwareSpacing(
            portrait: portrait,
            landscape: landscape
        ))
    }
}

// MARK: - Orientation Observer
/// View modifier that detects orientation changes and triggers an action
struct OrientationChangeObserver: ViewModifier {
    @State private var orientation = UIDevice.current.orientation
    let action: (Bool) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                // Start monitoring orientation changes
                NotificationCenter.default.addObserver(
                    forName: UIDevice.orientationDidChangeNotification,
                    object: nil,
                    queue: .main
                ) { _ in
                    let newOrientation = UIDevice.current.orientation
                    let didChange = ResponsiveLayoutUtils.hasOrientationChanged(from: orientation)
                    orientation = newOrientation
                    action(didChange)
                }
            }
            .onDisappear {
                // Stop monitoring orientation changes
                NotificationCenter.default.removeObserver(
                    self,
                    name: UIDevice.orientationDidChangeNotification,
                    object: nil
                )
            }
    }
}

extension View {
    /// Adds an orientation change observer to the view
    /// - Parameter action: Closure to execute when orientation changes
    /// - Returns: View with orientation observer attached
    func onOrientationChange(perform action: @escaping (Bool) -> Void) -> some View {
        self.modifier(OrientationChangeObserver(action: action))
    }
}

// MARK: - Orientation-Aware Container
/// A container view that adapts its layout based on device orientation
struct OrientationAwareContainer<Content: View>: View {
    @State private var orientation = UIDevice.current.orientation
    @State private var hasChangedOrientation = false
    
    let content: (Bool) -> Content
    
    init(@ViewBuilder content: @escaping (Bool) -> Content) {
        self.content = content
    }
    
    var body: some View {
        content(ResponsiveLayoutUtils.isLandscape())
            .animation(.easeInOut(duration: 0.3), value: ResponsiveLayoutUtils.isLandscape())
            .onOrientationChange { didChange in
                if didChange {
                    hasChangedOrientation = true
                }
            }
    }
}
#endif
#endif
