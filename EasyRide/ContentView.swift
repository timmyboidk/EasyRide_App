import SwiftUI

#if os(iOS)
  struct ContentView: View {
    @Environment(AppState.self) private var appState
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
    }
  }

  // MARK: - Main Tab View

  struct MainTabView: View {
    @Environment(AppState.self) private var appState

    init() {
      // Customize TabView appearance
      let appearance = UITabBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = .black

      // Set item colors
      appearance.stackedLayoutAppearance.normal.iconColor = .gray
      appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
        .foregroundColor: UIColor.gray
      ]
      appearance.stackedLayoutAppearance.selected.iconColor = .white
      appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
        .foregroundColor: UIColor.white
      ]

      UITabBar.appearance().standardAppearance = appearance
      UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
      TabView {
        HomeView()
          .tabItem {
            Image(systemName: "house.fill")
            Text("首页", bundle: nil)
          }

        OrdersView()
          .tabItem {
            Image(systemName: "list.bullet")
            Text("订单", bundle: nil)
          }

        ProfileView()
          .tabItem {
            Image(systemName: "person.fill")
            Text("个人", bundle: nil)
          }
      }
      .accentColor(.white)  // Sets the selected tab item color
    }
  }

  // MARK: - Placeholder Views

  struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var navigationPath = NavigationPath()

    var body: some View {
      NavigationStack(path: $navigationPath) {
        ServiceSelectionView(appState: appState, navigationPath: $navigationPath)
          .navigationDestination(for: BookingStep.self) { step in
            switch step {
            case .charterTypeSelection:
              ServiceSelectionView(appState: appState, navigationPath: $navigationPath)
            case .tripModeSettings:
              TripModeSettingsView(navigationPath: $navigationPath)
            case .valueAddedServicesPayment:
              ValueAddedServicesView(navigationPath: $navigationPath)
            case .orderSuccessDriverMatching:
              OrderSuccessDriverMatchingView(navigationPath: $navigationPath)
            case .currentOrder:
              OrderTrackingView(orderId: "dummy-order-id")
            }
          }
      }
    }
  }

  struct OrdersView: View {
    var body: some View {
      NavigationView {
        ZStack {
          Color.black.ignoresSafeArea()
          VStack {
            Image(systemName: "list.bullet.rectangle.portrait")
              .font(.system(size: 60))
              .foregroundStyle(.gray)

            Text("暂无订单", bundle: nil)
              .font(.title3)
              .fontWeight(.medium)
              .foregroundColor(.white)

            Text("您的行程记录将显示在这里", bundle: nil)
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
        }
        .navigationTitle(Text("订单", bundle: nil))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
      }
    }
  }

  struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var authViewModel: AuthenticationViewModel

    init() {
      _authViewModel = State(initialValue: AuthenticationViewModel(appState: AppState()))
    }

    var body: some View {
      NavigationView {
        ZStack {
          Color.black.ignoresSafeArea()
          VStack(spacing: 20) {
            // User Info Header
            VStack(spacing: 12) {
              Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.white)

              if let user = appState.currentUser {
                Text(user.name)
                  .font(.title2)
                  .fontWeight(.semibold)
                  .foregroundColor(.white)

                Text(user.phoneNumber ?? "无电话号码")
                  .font(.subheadline)
                  .foregroundStyle(.gray)
              }
            }
            .padding(.top, 30)

            // Menu List
            List {
              NavigationLink(destination: WalletView()) {
                Label("钱包", systemImage: "wallet.pass.fill")
              }

              NavigationLink(destination: PaymentMethodsView()) {
                  Label("支付方式", systemImage: "creditcard.fill")
              }

              NavigationLink(destination: OrdersView()) {
                  Label("订单历史", systemImage: "clock.fill")
              }

              NavigationLink(destination: Text("设置", bundle: nil)) {
                  Label("设置", systemImage: "gearshape.fill")
              }
            }
            .listStyle(.insetGrouped)
            .background(Color.black)
            .scrollContentBackground(.hidden)
            .foregroundColor(.white)

            // Logout Button
            Button(action: {
              Task {
                await authViewModel.logout()
              }
            }) {
              Text("退出登录", bundle: nil)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.red)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
          }
        }
        .navigationTitle(Text("个人", bundle: nil))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
      }
      .onAppear {
        authViewModel = AuthenticationViewModel(appState: appState)
      }
    }
  }

  #Preview {
    ContentView()
      .environment(AppState())
      .preferredColorScheme(.dark)
  }
#endif
