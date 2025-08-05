import SwiftUI

#if canImport(UIKit)
import UIKit

// MARK: - Accessibility Utilities

/// Utility class for managing accessibility features throughout the app
class AccessibilityUtils {
    
    // MARK: - Environment Detection
    
    /// Check if VoiceOver is currently running
    static var isVoiceOverRunning: Bool {
        return UIAccessibility.isVoiceOverRunning
    }
    
    /// Check if Switch Control is currently running
    static var isSwitchControlRunning: Bool {
        return UIAccessibility.isSwitchControlRunning
    }
    
    /// Check if user prefers reduced motion
    static var isReduceMotionEnabled: Bool {
        return UIAccessibility.isReduceMotionEnabled
    }
    
    /// Check if user prefers reduced transparency
    static var isReduceTransparencyEnabled: Bool {
        return UIAccessibility.isReduceTransparencyEnabled
    }
    
    /// Check if user has enabled high contrast mode
    static var isDarkerSystemColorsEnabled: Bool {
        return UIAccessibility.isDarkerSystemColorsEnabled
    }
    
    // MARK: - Announcements
    
    /// Post an accessibility announcement for screen readers
    /// - Parameters:
    ///   - message: The message to announce
    ///   - priority: The priority of the announcement (default: .medium)
    static func announce(_ message: String) {
        guard isVoiceOverRunning else { return }
        
        DispatchQueue.main.async {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
    
    /// Post a layout change notification to refocus VoiceOver
    /// - Parameter element: The element to focus on (optional)
    static func announceLayoutChange(focusOn element: Any? = nil) {
        guard isVoiceOverRunning else { return }
        
        DispatchQueue.main.async {
            UIAccessibility.post(notification: .layoutChanged, argument: element)
        }
    }
    
    /// Post a screen change notification for major navigation changes
    /// - Parameter element: The element to focus on (optional)
    static func announceScreenChange(focusOn element: Any? = nil) {
        guard isVoiceOverRunning else { return }
        
        DispatchQueue.main.async {
            UIAccessibility.post(notification: .screenChanged, argument: element)
        }
    }
    
    // MARK: - Label Generation
    
    /// Generate accessibility label for service cards
    /// - Parameters:
    ///   - serviceType: The service type
    ///   - price: The estimated price
    ///   - isSelected: Whether the service is selected
    /// - Returns: Formatted accessibility label
    static func serviceCardLabel(for serviceType: ServiceType, price: String, isSelected: Bool) -> String {
        let selectionState = isSelected ? "Selected" : "Not selected"
        return "\(serviceType.displayName), \(price), \(selectionState)"
    }
    
    /// Generate accessibility hint for service cards
    /// - Parameter isSelected: Whether the service is selected
    /// - Returns: Formatted accessibility hint
    static func serviceCardHint(isSelected: Bool) -> String {
        return isSelected ? "Double tap to deselect this service" : "Double tap to select this service"
    }
    
    /// Generate accessibility label for buttons with loading states
    /// - Parameters:
    ///   - title: The button title
    ///   - isLoading: Whether the button is in loading state
    /// - Returns: Formatted accessibility label
    static func buttonLabel(title: String, isLoading: Bool) -> String {
        return isLoading ? "\(title), Loading" : title
    }
    
    /// Generate accessibility label for progress indicators
    /// - Parameters:
    ///   - progress: Progress value (0.0 to 1.0)
    ///   - description: Description of what's progressing
    /// - Returns: Formatted accessibility label
    static func progressLabel(progress: Double, description: String) -> String {
        let percentage = Int(progress * 100)
        return "\(description), \(percentage) percent complete"
    }
    
    /// Generate accessibility label for price displays
    /// - Parameters:
    ///   - amount: The price amount
    ///   - currency: The currency (default: "dollars")
    /// - Returns: Formatted accessibility label
    static func priceLabel(amount: Double, currency: String = "dollars") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        if let formattedPrice = formatter.string(from: NSNumber(value: amount)) {
            return formattedPrice.replacingOccurrences(of: "$", with: "\(Int(amount)) \(currency)")
        }
        
        return "\(Int(amount)) \(currency)"
    }
    
    // MARK: - Focus Management
    
    /// Set accessibility focus to a specific element
    /// - Parameter element: The element to focus on
    static func setFocus(to element: Any) {
        guard isVoiceOverRunning else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .layoutChanged, argument: element)
        }
    }
}

// MARK: - SwiftUI View Extensions

extension View {
    
    /// Add comprehensive accessibility support to any view
    /// - Parameters:
    ///   - label: Accessibility label
    ///   - hint: Accessibility hint (optional)
    ///   - traits: Accessibility traits (optional)
    ///   - value: Accessibility value (optional)
    /// - Returns: View with accessibility modifiers applied
    func accessibilitySupport(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits? = nil,
        value: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(Text(label))
            .accessibilityHint(Text(hint ?? ""))
            .accessibilityAddTraits(traits ?? [])
            .accessibilityValue(Text(value ?? ""))
    }
    
    /// Add button accessibility support
    /// - Parameters:
    ///   - label: Button label
    ///   - hint: Action hint (optional)
    ///   - isEnabled: Whether button is enabled
    /// - Returns: View with button accessibility applied
    func accessibilityButton(
        label: String,
        hint: String? = nil,
        isEnabled: Bool = true
    ) -> some View {
        self
            .accessibilityLabel(Text(label))
            .accessibilityHint(Text(hint ?? "Double tap to activate"))
            .accessibilityAddTraits(isEnabled ? .isButton : [.isButton])
    }
    
    /// Add toggle accessibility support
    /// - Parameters:
    ///   - label: Toggle label
    ///   - isOn: Current toggle state
    ///   - hint: Action hint (optional)
    /// - Returns: View with toggle accessibility applied
    func accessibilityToggle(
        label: String,
        isOn: Bool,
        hint: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(Text(label))
            .accessibilityValue(isOn ? Text("On") : Text("Off"))
            .accessibilityHint(Text(hint ?? "Double tap to toggle"))
            .accessibilityAddTraits(.isButton)
    }
    
    /// Add header accessibility support
    /// - Parameter level: Header level (1-6)
    /// - Returns: View with header accessibility applied
    func accessibilityHeader(level: Int = 1) -> some View {
        self
            .accessibilityAddTraits(.isHeader)
    }
    
    /// Apply reduced motion preferences to animations
    /// - Parameter animation: The animation to conditionally apply
    /// - Returns: View with motion-sensitive animation
    func motionSensitiveAnimation<V>(_ animation: Animation?, value: V) -> some View where V: Equatable {
        self.animation(AccessibilityUtils.isReduceMotionEnabled ? nil : animation, value: value)
    }
    
    /// Apply high contrast color scheme support
    /// - Parameters:
    ///   - normalColor: Color for normal contrast
    ///   - highContrastColor: Color for high contrast mode
    /// - Returns: View with appropriate color applied
    func contrastSensitiveColor(normal: Color, highContrast: Color) -> some View {
        self.foregroundColor(AccessibilityUtils.isDarkerSystemColorsEnabled ? highContrast : normal)
    }
}

// MARK: - Cross-platform Announcement Priority
// Note: UIAccessibility.AnnouncementPriority is not a public API. Announcements are posted with default priority.
enum AnnouncementPriority {
    case low
    case medium
    case high
}

// MARK: - Accessibility Notification Names
extension UIAccessibility.Notification {
    static let announcementDidFinish = UIAccessibility.announcementDidFinishNotification
    static let elementFocused = UIAccessibility.elementFocusedNotification
}
#endif
