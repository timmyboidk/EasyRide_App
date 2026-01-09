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

  struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var navigationPath = NavigationPath()
    @State private var locationManager = LocationManager()
    
    // Map State
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // Simulated Drivers
    @State private var nearbyDrivers: [DriverAnnotation] = [
        DriverAnnotation(id: "d1", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)),
        DriverAnnotation(id: "d2", coordinate: CLLocationCoordinate2D(latitude: 37.7739, longitude: -122.4184))
    ]
    
    // Bottom Sheet State
    @State private var sheetOffset: CGFloat = 400
    @State private var lastOffset: CGFloat = 400
    @GestureState private var gestureOffset: CGFloat = 0
    
    private let minOffset: CGFloat = 100
    private let midOffset: CGFloat = 400
    private let maxOffset: CGFloat = 700 // Shown at the bottom
    
    var body: some View {
      NavigationStack(path: $navigationPath) {
        ZStack {
            // Full Screen Map
            Map(position: $cameraPosition) {
                UserAnnotation()
                
                ForEach(nearbyDrivers) { driver in
                    Annotation("Driver", coordinate: driver.coordinate) {
                        Image(systemName: "car.fill")
                            .foregroundColor(Theme.primaryColor(for: colorScheme))
                            .padding(5)
                            .background(Theme.backgroundColor(for: colorScheme))
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
                if let location = locationManager.userLocation {
                    updateSimulatedDrivers(around: location.coordinate)
                }
            }
            .onChange(of: locationManager.userLocation) {
                if let location = locationManager.userLocation {
                    if cameraPosition.positionedByUser == false {
                        cameraPosition = .region(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
                    }
                    updateSimulatedDrivers(around: location.coordinate)
                }
            }

            // Uber-style Draggable Bottom Sheet
            GeometryReader { geometry in
                let fullHeight = geometry.size.height
                let currentSheetOffset = sheetOffset + gestureOffset
                
                VStack(spacing: 0) {
                    // Drag Handle Area
                    VStack(spacing: 8) {
                        Capsule()
                            .fill(Theme.primaryColor(for: colorScheme).opacity(0.3))
                            .frame(width: 40, height: 4)
                            .padding(.top, 10)
                        
                        Text(LocalizationUtils.localized("Select_Charter_Type"))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.primaryColor(for: colorScheme))
                    }
                    .frame(maxWidth: .infinity)
                    .background(Theme.backgroundColor(for: colorScheme))
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .updating($gestureOffset) { value, state, _ in
                                state = value.translation.height
                            }
                            .onEnded { value in
                                let velocity = value.predictedEndTranslation.height - value.translation.height
                                let targetOffset = sheetOffset + value.translation.height + velocity / 5
                                
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if targetOffset < (minOffset + midOffset) / 2 {
                                        sheetOffset = minOffset
                                    } else if targetOffset < (midOffset + maxOffset) / 2 {
                                        sheetOffset = midOffset
                                    } else {
                                        sheetOffset = midOffset // Stay at medium if dismissed too far
                                    }
                                    lastOffset = sheetOffset
                                }
                            }
                    )
                    
                    ServiceSelectionView(appState: appState, navigationPath: $navigationPath)
                }
                .background(Theme.backgroundColor(for: colorScheme))
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: -5)
                .offset(y: max(minOffset, currentSheetOffset))
            }
            .ignoresSafeArea(edges: .bottom)
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
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = OrdersViewModel()

    var body: some View {
      NavigationView {
        ZStack {
          Theme.backgroundColor(for: colorScheme).ignoresSafeArea()
          
          if viewModel.isLoading {
            ProgressView()
          } else if viewModel.orders.isEmpty {
            VStack {
              Image(systemName: "list.bullet.rectangle.portrait")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

              Text(LocalizationUtils.localized("No_Orders"))
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)

              Text(LocalizationUtils.localized("Orders_Empty_State"))
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
        .navigationTitle(Text(LocalizationUtils.localized("Orders")))
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
    @Environment(\.colorScheme) private var colorScheme
    @State private var authViewModel: AuthenticationViewModel

    init() {
      _authViewModel = State(initialValue: AuthenticationViewModel(appState: AppState()))
    }

    var body: some View {
      NavigationView {
        ZStack {
          Theme.backgroundColor(for: colorScheme).ignoresSafeArea()
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
                Label(LocalizationUtils.localized("Wallet"), systemImage: "wallet.pass.fill")
              }

              NavigationLink(destination: PaymentMethodsView()) {
                  Label(LocalizationUtils.localized("Payment_Methods"), systemImage: "creditcard.fill")
              }

              NavigationLink(destination: OrdersView()) {
                  Label(LocalizationUtils.localized("Order_History"), systemImage: "clock.fill")
              }
                
                NavigationLink(destination: FavoriteDriversView()) {
                    Label(LocalizationUtils.localized("Favorite_Drivers"), systemImage: "heart.fill")
                }

              NavigationLink(destination: SettingsView()) {
                  Label(LocalizationUtils.localized("Settings"), systemImage: "gearshape.fill")
              }
            }

            .listStyle(.plain)
            .background(Theme.backgroundColor(for: colorScheme))
            .scrollContentBackground(.hidden)

            // Logout Button
            Button(action: {
              Task {
                await authViewModel.logout()
              }
            }) {
              Text(LocalizationUtils.localized("Logout"))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.primaryColor(for: colorScheme).opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
          }
        }
        .navigationTitle(Text(LocalizationUtils.localized("Profile")))
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
