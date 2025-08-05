# EasyRide Internationalization Guide

This document provides an overview of the internationalization (i18n) implementation in the EasyRide app.

## Supported Languages

The EasyRide app currently supports the following languages:

- English (en) - Default
- Spanish (es)
- Simplified Chinese (zh-Hans)

## Localization Files

Localization files are stored in language-specific `.lproj` directories:

- `EasyRide/Resources/en.lproj/Localizable.strings` - English
- `EasyRide/Resources/es.lproj/Localizable.strings` - Spanish
- `EasyRide/Resources/zh-Hans.lproj/Localizable.strings` - Simplified Chinese

## How to Use Localized Strings

### In SwiftUI Views

Use the `Text` view with a string key and specify the bundle:

```swift
Text("welcome_back", bundle: nil)
```

For string interpolation or when you need to use the string in other contexts:

```swift
let welcomeText = LocalizationUtils.localized("welcome_back")
```

For formatted strings with parameters:

```swift
Text(LocalizationUtils.localizedFormat("resend_in", "30s"))
```

### In ViewModels and Other Classes

Use the `LocalizationUtils` class:

```swift
let message = LocalizationUtils.localized("welcome_back")
let formattedMessage = LocalizationUtils.localizedFormat("resend_in", "30s")
```

## Date and Number Formatting

The app uses the system locale for formatting dates and numbers:

```swift
// Format a date according to the user's locale
let dateString = LocalizationUtils.formatDate(date)

// Format a price according to the user's locale
let priceString = LocalizationUtils.formatPrice(price)
```

You can also use the extensions on `Date` and `Double`:

```swift
let dateString = date.localizedString()
let priceString = price.localizedPrice()
```

## Right-to-Left (RTL) Support

The app automatically adapts to right-to-left languages:

```swift
// Check if the current language is RTL
if LocalizationUtils.isRTL {
    // Apply RTL-specific adjustments
}
```

Apply RTL layout to a view:

```swift
someView
    .applyLocalizedLayout()
```

## Dynamic Language Changes

The app supports changing the language at runtime. When the system language changes, the app will automatically update all localized content.

## Adding a New Language

To add support for a new language:

1. Create a new directory in `EasyRide/Resources/` with the language code followed by `.lproj` (e.g., `fr.lproj` for French)
2. Copy the `Localizable.strings` file from an existing language directory
3. Translate all the strings in the file
4. Build and run the app with the new language selected in the device settings

## Testing Localization

Use the `LocalizationTests.swift` file to test the localization implementation. This file contains tests for:

- Basic string localization
- Formatted strings
- Date formatting
- Price formatting
- RTL detection

## Best Practices

1. Always use string keys instead of hardcoded strings
2. Use descriptive keys that indicate the purpose of the string
3. Group related strings together in the localization files
4. Add comments in the localization files to provide context for translators
5. Test the app with different languages and regions
6. Consider text expansion/contraction when designing layouts
7. Use dynamic font sizes to accommodate different text lengths
8. Test with right-to-left languages to ensure proper layout adaptation