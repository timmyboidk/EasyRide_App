import SwiftUI

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
                    .refreshable {
                        await viewModel.fetchOrders()
                    }
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
                Text(order.serviceType.rawValue) 
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
                    .lineLimit(1)
            }
            
            if let dest = order.destination {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                    Text(dest.address)
                        .font(.subheadline)
                        .lineLimit(1)
                }
            }
            
            Text(LocalizationUtils.formatDate(order.createdAt))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
