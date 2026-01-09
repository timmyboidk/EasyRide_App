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
            ZStack(alignment: .bottom) { // Changed alignment to bottom

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
                        
                        // Sync with AppState
                        appState.currentLocation = Location(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude,
                            address: "Current Location" // Ideally reverse geocode here
                        )
                    }
                }
                
                // Floating "Where to?" Search Bar at Bottom
                VStack(spacing: 16) {
                    // Current Location Button
                    HStack {
                        Spacer()
                        Button(action: {
                            if let location = locationManager.userLocation {
                                withAnimation {
                                    cameraPosition = .region(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                                }
                            } else {
                                locationManager.requestPermission()
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .padding()
                                .background(Theme.backgroundColor(for: colorScheme))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing)
                    }
                    
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
                    .padding(.bottom, 20) // Safe Area
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

// Polished Search View
struct DestinationSearchView: View {
    @Binding var isPresented: Bool
    @Binding var navigationPath: NavigationPath
    @Environment(\.colorScheme) private var colorScheme
    @State private var query = ""
    
    // Mock Recent/Suggested Locations
    let suggestions = [
        Location(latitude: 37.6213, longitude: -122.3790, address: "San Francisco International Airport (SFO)"),
        Location(latitude: 37.7879, longitude: -122.4075, address: "Union Square, San Francisco"),
        Location(latitude: 37.8199, longitude: -122.4783, address: "Golden Gate Bridge"),
        Location(latitude: 37.7765, longitude: -122.4173, address: "Twitter HQ")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Where to?", text: $query)
                        .autocorrectionDisabled()
                    if !query.isEmpty {
                        Button(action: { query = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()
                
                // Results List
                List {
                    Section(header: Text("Recent")) {
                        ForEach(suggestions.filter { query.isEmpty || $0.address.localizedCaseInsensitiveContains(query) }) { location in
                            Button(action: {
                                isPresented = false
                                // Simulate selection
                                navigationPath.append(BookingStep.charterTypeSelection)
                            }) {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(.gray)
                                    VStack(alignment: .leading) {
                                        Text(location.address)
                                            .foregroundColor(.primary)
                                        Text("San Francisco, CA")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Destination")
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
