import SwiftUI
import MapKit
import CoreLocation

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var navigationPath = NavigationPath()
    @State private var locationManager = LocationManager()
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    
    // Map State
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // Simulated Drivers
    @State private var nearbyDrivers: [DriverAnnotation] = []
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .top) {
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
                
                // Floating "Where to?" Search Bar
                VStack {
                    Button(action: {
                        isSearching = true
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.primary)
                            Text("Where to?")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Spacer()
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 4)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .padding()
                        .background(Theme.backgroundColor(for: colorScheme))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.top, 60) // Safe Area
                }
            }
            .sheet(isPresented: $isSearching) {
                // Search View Placeholder
                DestinationSearchView(isPresented: $isSearching, navigationPath: $navigationPath)
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
                     OrderTrackingView(orderId: appState.activeOrder?.id ?? "")
                }
            }
        }
    }
    
    private func updateSimulatedDrivers(around center: CLLocationCoordinate2D) {
        let offsets = [
            (0.002, 0.003), (-0.003, -0.001), (0.001, -0.004)
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

// Minimal Placeholder for Search
struct DestinationSearchView: View {
    @Binding var isPresented: Bool
    @Binding var navigationPath: NavigationPath
    @Environment(\.colorScheme) private var colorScheme
    @State private var query = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search destination", text: $query)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding()
                
                List {
                    Button("San Francisco Airport (SFO)") {
                        isPresented = false
                        navigationPath.append(BookingStep.charterTypeSelection)
                    }
                    Button("Union Square") {
                        isPresented = false
                        navigationPath.append(BookingStep.charterTypeSelection)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Where to?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}

struct DriverAnnotation: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
}
