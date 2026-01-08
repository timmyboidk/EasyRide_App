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
      // Use system background color
      appearance.backgroundColor = UIColor.systemBackground
      
      // Set item colors to adapt
      appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
      appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
        .foregroundColor: UIColor.secondaryLabel
      ]
      appearance.stackedLayoutAppearance.selected.iconColor = UIColor.label
      appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
        .foregroundColor: UIColor.label
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
      .accentColor(.primary)  // Sets the selected tab item color
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
    @StateObject private var viewModel = OrdersViewModel()

    var body: some View {
      NavigationView {
        ZStack {
          Color(.systemBackground).ignoresSafeArea()
          
          if viewModel.isLoading {
            ProgressView()
          } else if viewModel.orders.isEmpty {
            VStack {
              Image(systemName: "list.bullet.rectangle.portrait")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

              Text("暂无订单", bundle: nil)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)

              Text("您的行程记录将显示在这里", bundle: nil)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
          } else {
            List(viewModel.orders) { order in
                OrderRowView(order: order)
            }
            .listStyle(.plain)
          }
        }
        .navigationTitle(Text("订单", bundle: nil))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchOrders()
        }
      }
    }
  }

  struct OrderRowView: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(order.serviceType.rawValue) // ServiceType
                    .font(.headline)
                Spacer()
                Text(order.status.displayName)
                    .font(.subheadline)
                    .foregroundColor(order.status.color)
            }
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.green)
                Text(order.pickupLocation.address)
                    .font(.subheadline)
            }
            
            if let dest = order.destination {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                    Text(dest.address)
                        .font(.subheadline)
                }
            }
            
            Text(LocalizationUtils.formatDate(order.createdAt))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
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
          Color(.systemBackground).ignoresSafeArea()
          VStack(spacing: 20) {
            // User Info Header
            VStack(spacing: 12) {
              Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.primary)

              if let user = appState.currentUser {
                Text(user.name)
                  .font(.title2)
                  .fontWeight(.semibold)
                  .foregroundColor(.primary)

                Text(user.phoneNumber ?? "无电话号码")
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
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
                
                NavigationLink(destination: FavoriteDriversView()) {
                    Label("已收藏的司机", systemImage: "heart.fill")
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
