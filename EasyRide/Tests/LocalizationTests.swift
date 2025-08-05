import XCTest
import SwiftUI
@testable import EasyRide

class LocalizationTests: XCTestCase {
    
    func testEnglishLocalization() {
        // Set locale to English
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Test basic localization
        XCTAssertEqual(LocalizationUtils.localized("app_name"), "EasyRide")
        XCTAssertEqual(LocalizationUtils.localized("tagline"), "Your reliable ride companion")
        XCTAssertEqual(LocalizationUtils.localized("welcome_back"), "Welcome Back")
        
        // Test format strings
        let formattedString = LocalizationUtils.localizedFormat("resend_in", "30s")
        XCTAssertEqual(formattedString, "Resend in 30s")
    }
    
    func testSpanishLocalization() {
        // Set locale to Spanish
        UserDefaults.standard.set(["es"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Test basic localization
        XCTAssertEqual(LocalizationUtils.localized("app_name"), "EasyRide")
        XCTAssertEqual(LocalizationUtils.localized("tagline"), "Tu compañero de viaje confiable")
        XCTAssertEqual(LocalizationUtils.localized("welcome_back"), "Bienvenido de nuevo")
        
        // Test format strings
        let formattedString = LocalizationUtils.localizedFormat("resend_in", "30s")
        XCTAssertEqual(formattedString, "Reenviar en 30s")
    }
    
    func testChineseLocalization() {
        // Set locale to Simplified Chinese
        UserDefaults.standard.set(["zh-Hans"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Test basic localization
        XCTAssertEqual(LocalizationUtils.localized("app_name"), "EasyRide")
        XCTAssertEqual(LocalizationUtils.localized("tagline"), "您可靠的出行伙伴")
        XCTAssertEqual(LocalizationUtils.localized("welcome_back"), "欢迎回来")
        
        // Test format strings
        let formattedString = LocalizationUtils.localizedFormat("resend_in", "30s")
        XCTAssertEqual(formattedString, "30s后重新发送")
    }
    
    func testDateFormatting() {
        // Create a fixed date for testing
        let dateComponents = DateComponents(year: 2025, month: 7, day: 21, hour: 14, minute: 30)
        let calendar = Calendar.current
        let testDate = calendar.date(from: dateComponents)!
        
        // Test with English locale
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        let englishDate = LocalizationUtils.formatDate(testDate)
        
        // Test with Spanish locale
        UserDefaults.standard.set(["es"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        let spanishDate = LocalizationUtils.formatDate(testDate)
        
        // Test with Chinese locale
        UserDefaults.standard.set(["zh-Hans"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        let chineseDate = LocalizationUtils.formatDate(testDate)
        
        // Verify that the formats are different
        XCTAssertNotEqual(englishDate, spanishDate)
        XCTAssertNotEqual(englishDate, chineseDate)
        XCTAssertNotEqual(spanishDate, chineseDate)
    }
    
    func testPriceFormatting() {
        let price = 123.45
        
        // Test with English locale (US)
        UserDefaults.standard.set(["en-US"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        let usPrice = LocalizationUtils.formatPrice(price)
        
        // Test with Spanish locale
        UserDefaults.standard.set(["es"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        let spanishPrice = LocalizationUtils.formatPrice(price)
        
        // Test with Chinese locale
        UserDefaults.standard.set(["zh-Hans"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        let chinesePrice = LocalizationUtils.formatPrice(price)
        
        // Verify that the formats are different
        XCTAssertTrue(usPrice.contains("$"))
        XCTAssertTrue(spanishPrice.contains("$") || spanishPrice.contains("€"))
        
        // Reset locale
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func testRTLDetection() {
        // Test with English locale (LTR)
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        XCTAssertFalse(LocalizationUtils.isRTL)
        
        // Test with Arabic locale (RTL)
        UserDefaults.standard.set(["ar"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        XCTAssertTrue(LocalizationUtils.isRTL)
        
        // Reset locale
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}