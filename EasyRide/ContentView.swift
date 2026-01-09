import SwiftUI
import MapKit
import CoreLocation

#if os(iOS)
  struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingBootScreen = true

    var body: some View {
      Group {
        if showingBootScreen {
          BootScreenView {
            showingBootScreen = false
          }
        } else if appState.isAuthenticated {
          MainTabView()
        } else {
          LoginView(appState: appState)
        }
      }
      .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
      .animation(.easeInOut(duration: 0.3), value: showingBootScreen)
      .applyLocalizedLayout()
      .id(appState.preferredLanguage)
      .background(Theme.backgroundColor(for: colorScheme).ignoresSafeArea())
    }
  }

  // MARK: - Main Tab View

  struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    init() {
      // Standard adaptive appearance
    }

    var body: some View {
      TabView {
        HomeView()
          .tabItem {
            Image(systemName: "house.fill")
            Text(LocalizationUtils.localized("Home"))
          }

        OrdersView()
          .tabItem {
            Image(systemName: "list.bullet")
            Text(LocalizationUtils.localized("Orders"))
          }

        ProfileView()
          .tabItem {
            Image(systemName: "person.fill")
            Text(LocalizationUtils.localized("Profile"))
          }
      }
      .accentColor(Theme.primaryColor(for: colorScheme))  // Sets the selected tab item color
    }
  }

  // MARK: - Placeholder Views

    // MARK: - Safe Area for Global Modifiers
    // Add any global overlays or sheets here in the future


  #Preview {
    ContentView()
      .environment(AppState())
      .preferredColorScheme(.dark)
  }
#endif
