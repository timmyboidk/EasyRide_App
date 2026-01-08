import SwiftUI
import MapKit
import CoreLocation

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
      .id(appState.preferredLanguage)
    }
  }

  // MARK: - Main Tab View

  struct MainTabView: View {
    @Environment(AppState.self) private var appState

    init() {
      // Standard adaptive appearance
    }

    var body: some View {
      TabView {
        HomeView()
          .tabItem {
            Image(systemName: "house.fill")
            Text(NSLocalizedString("Home", comment: ""))
          }

        OrdersView()
          .tabItem {
            Image(systemName: "list.bullet")
            Text(NSLocalizedString("Orders", comment: ""))
          }

        ProfileView()
          .tabItem {
            Image(systemName: "person.fill")
            Text(NSLocalizedString("Profile", comment: ""))
          }
      }
      .accentColor(.primary)  // Sets the selected tab item color
    }
  }

  // MARK: - Placeholder Views

  struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var navigationPath = NavigationPath()
    @State private var locationManager = LocationManager()
    
    // Map State
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // Simulated Drivers
    @State private var nearbyDrivers: [DriverAnnotation] = [
        DriverAnnotation(id: "d1", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)), // Placeholder
        DriverAnnotation(id: "d2", coordinate: CLLocationCoordinate2D(latitude: 37.7739, longitude: -122.4184))
    ]
    
    var body: some View {
      NavigationStack(path: $navigationPath) {
        ZStack {
            // Full Screen Map
            Map(position: $cameraPosition) {
                UserAnnotation()
                
                ForEach(nearbyDrivers) { driver in
                    Annotation("Driver", coordinate: driver.coordinate) {
                        Image(systemName: "car.fill")
                            .foregroundColor(.black)
                            .padding(5)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
            }

            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .onAppear {
                locationManager.requestPermission()
                // Update simulated driver locations to be around user if available
                if let location = locationManager.userLocation {
                    updateSimulatedDrivers(around: location.coordinate)
                }
            }
            .onChange(of: locationManager.userLocation) {
                if let location = locationManager.userLocation {
                    cameraPosition = .region(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
                    updateSimulatedDrivers(around: location.coordinate)
                }
            }
        }
            // Service Selection Overlay (Sheet-like, non-modal to keep TabBar accessible)
            VStack {
                Spacer()
                ServiceSelectionView(appState: appState, navigationPath: $navigationPath)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                    .padding(.bottom, 10) // Lift slightly above TabBar
            }

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
    
    private func updateSimulatedDrivers(around center: CLLocationCoordinate2D) {
        // Create random drivers around the center
        let offsets = [
            (0.002, 0.003),
            (-0.003, -0.001),
            (0.001, -0.004)
        ]
        
        nearbyDrivers = offsets.enumerated().map { index, offset in
            DriverAnnotation(
                id: "d\(index)",
                coordinate: CLLocationCoordinate2D(
                    latitude: center.latitude + offset.0,
                    longitude: center.longitude + offset.1
                )
            )
        }
    }
  }
  
  struct DriverAnnotation: Identifiable {
      let id: String
      let coordinate: CLLocationCoordinate2D
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

                Text(user.phoneNumber ?? LocalizationUtils.localized("No_Phone"))
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
              }
            }
            .padding(.top, 30)

            // Menu List
            List {
              NavigationLink(destination: WalletView()) {
                Label(NSLocalizedString("Wallet", comment: ""), systemImage: "wallet.pass.fill")
              }

              NavigationLink(destination: PaymentMethodsView()) {
                  Label(NSLocalizedString("Payment_Methods", comment: ""), systemImage: "creditcard.fill")
              }

              NavigationLink(destination: OrdersView()) {
                  Label(NSLocalizedString("Order_History", comment: ""), systemImage: "clock.fill")
              }
                
                NavigationLink(destination: FavoriteDriversView()) {
                    Label(NSLocalizedString("Favorite_Drivers", comment: ""), systemImage: "heart.fill")
                }

              NavigationLink(destination: SettingsView()) {
                  Label(NSLocalizedString("Settings", comment: ""), systemImage: "gearshape.fill")
              }
            }

            .listStyle(.plain)
            .background(Color(.systemBackground))
            .scrollContentBackground(.hidden)

            // Logout Button
            Button(action: {
              Task {
                await authViewModel.logout()
              }
            }) {
              Text(NSLocalizedString("Logout", comment: ""))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
          }
        }
        .navigationTitle(Text(NSLocalizedString("Profile", comment: "")))
        .navigationBarTitleDisplayMode(.inline)
        // Removed .toolbarColorScheme(.dark)
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
