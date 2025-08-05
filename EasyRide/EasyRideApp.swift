import SwiftUI

#if os(iOS)
@main
struct EasyRideApp: App {
    @State private var appState = AppState()
    @Environment(\.locale) private var locale
    @Environment(\.colorScheme) private var colorScheme
    
    init() {
        // Force the app to use Simplified Chinese localization
        UserDefaults.standard.set(["zh-Hans"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(\.locale, Locale(identifier: "zh-Hans")) // Set locale for formatting
                .onAppear {
                    // Configure appearance for RTL languages if needed
                    configureAppearanceForLocale()
                }
                .onChange(of: locale) { _, _ in
                    // Handle locale changes
                    configureAppearanceForLocale()
                }
        }
    }
    
    private func configureAppearanceForLocale() {
        // Configure any locale-specific appearance settings
        // This is called when the app launches and when the locale changes
        print("Current locale: \(Locale.current.identifier), RTL: \(LocalizationUtils.isRTL)")
    }
}
#else
@main
struct EasyRideApp: App {
    var body: some Scene {
        WindowGroup {
            Text("This app is only available on iOS.")
        }
    }
}
#endif
