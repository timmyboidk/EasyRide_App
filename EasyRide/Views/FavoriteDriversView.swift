import SwiftUI

#if os(iOS)
struct FavoriteDriversView: View {
    @Environment(AppState.self) private var appState
    // Sample data for demonstration purposes
    @State private var favoriteDrivers: [Driver] = [
        Driver(name: "John Smith", phoneNumber: "+1234567890", rating: 4.8, totalTrips: 1250, vehicleInfo: VehicleInfo(make: "Toyota", model: "Camry", year: 2022, color: "Silver", licensePlate: "ABC123", vehicleType: .sedan)),
        Driver(name: "Maria Garcia", phoneNumber: "+1987654321", rating: 4.9, totalTrips: 1500, vehicleInfo: VehicleInfo(make: "Honda", model: "CR-V", year: 2023, color: "Blue", licensePlate: "XYZ789", vehicleType: .suv))
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            List {
                ForEach(favoriteDrivers) { driver in
                    DriverRow(driver: driver)
                        .listRowBackground(Color.gray.opacity(0.2))
                }
                .onDelete(perform: removeDriver)
            }
            .listStyle(.insetGrouped)
            .background(Color.black)
            .scrollContentBackground(.hidden)
            .navigationTitle("Favorite Drivers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func removeDriver(at offsets: IndexSet) {
        favoriteDrivers.remove(atOffsets: offsets)
    }
}

struct DriverRow: View {
    let driver: Driver
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(driver.name)
                    .font(.headline)
                    .foregroundColor(.white)
                HStack {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                    Text(String(format: "%.1f", driver.rating))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Text(driver.vehicleInfo.fullDescription)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        FavoriteDriversView()
            .environment(AppState())
    }
}
#endif
