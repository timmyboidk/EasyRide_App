import Foundation
import SwiftUI

/// Utility class for handling internationalization and localization
enum LocalizationUtils {
    
    /// Returns a localized string using the key
    /// - Parameter key: The key to look up in the Localizable.strings file
    /// - Returns: A localized string
    static func localized(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
    /// Returns a localized string with format arguments
    /// - Parameters:
    ///   - key: The key to look up in the Localizable.strings file
    ///   - arguments: The arguments to insert into the format string
    /// - Returns: A formatted localized string
    static func localizedFormat(_ key: String, _ arguments: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, arguments: arguments)
    }
    
    /// Formats a date according to the current locale
    /// - Parameters:
    ///   - date: The date to format
    ///   - style: The date style to use
    ///   - timeStyle: The time style to use
    /// - Returns: A localized date string
    static func formatDate(_ date: Date, dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
    
    /// Formats a price according to the current locale
    /// - Parameters:
    ///   - price: The price to format
    ///   - currencyCode: The currency code (default: USD)
    /// - Returns: A localized price string
    static func formatPrice(_ price: Double, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
    
    /// Returns whether the current locale uses right-to-left text direction
    static var isRTL: Bool {
        if let languageCode = Locale.current.language.languageCode {
            return Locale.characterDirection(forLanguage: languageCode.identifier) == .rightToLeft
        }
        return false
    }
    
    /// Returns the current locale's language code
    static var currentLanguageCode: String {
        return Locale.current.language.languageCode?.identifier ?? "en"
    }
    
#if canImport(UIKit)
    /// Returns the semantic content attribute based on the current locale's text direction
    static var semanticContentAttribute: UISemanticContentAttribute {
        return isRTL ? .forceRightToLeft : .forceLeftToRight
    }
#endif
}

// MARK: - String Extension for Localization

extension String {
    /// Returns a localized version of the string
    var localized: String {
        return LocalizationUtils.localized(self)
    }
    
    /// Returns a localized version of the string with format arguments
    /// - Parameter arguments: The arguments to insert into the format string
    /// - Returns: A formatted localized string
    func localizedFormat(_ arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

// MARK: - View Extension for RTL Support

extension View {
    /// Applies the correct semantic content attribute based on the current locale
    func applyLocalizedLayout() -> some View {
        return self.environment(\.layoutDirection, LocalizationUtils.isRTL ? .rightToLeft : .leftToRight)
    }
}

// MARK: - Date Extension for Localization

extension Date {
    /// Returns a localized string representation of the date
    func localizedString(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short) -> String {
        return LocalizationUtils.formatDate(self, dateStyle: dateStyle, timeStyle: timeStyle)
    }
}

// MARK: - Double Extension for Price Formatting

extension Double {
    /// Returns a localized string representation of the price
    func localizedPrice(currencyCode: String = "USD") -> String {
        return LocalizationUtils.formatPrice(self, currencyCode: currencyCode)
    }
}
