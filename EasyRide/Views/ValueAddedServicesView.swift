import SwiftUI

#if os(iOS)
struct ValueAddedServicesView: View {
    @State private var viewModel = ValueAddedServicesViewModel()
    @State private var showingPaymentMethods = false
    @State private var selectedPaymentMethod: PaymentMethod = PaymentMethod(
        type: .applePay,
        displayName: "Apple Pay",
        isDefault: true
    )
    @State private var showingCouponExpansion = false
    @State private var airportPickupName = ""
    @Binding var navigationPath: NavigationPath
    
    init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Itinerary & Vehicle Confirmation
                    itineraryConfirmationSection
                    
                    // Value Added Services
                    valueAddedServicesSection
                    
                    // prioritizeFavoritesSection
                    prioritizeFavoritesSection
                    
                    // Cost Preview
                    costPreviewSection
                    
                    // Coupon/Points Section
                    couponPointsSection
                    
                    // Payment Button
                    paymentButton
                }
                .padding()
            }
        }
        .navigationTitle(LocalizationUtils.localized("Value_Added_Services"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPaymentMethods) {
            PaymentMethodsView()
        }
    }
    
    // MARK: - Itinerary & Vehicle Confirmation
    private var itineraryConfirmationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizationUtils.localized("Confirm_Vehicle"))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                // Vehicle Image Placeholder
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
                    .frame(width: 80, height: 60)
                    .overlay(
                        Image(systemName: "car.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizationUtils.localized("Business_Van"))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(LocalizationUtils.localized("Full_Day_Charter"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(LocalizationUtils.localized("Estimated_Duration"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Value Added Services
    private var valueAddedServicesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizationUtils.localized("Value_Added_Services"))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // Airport Pickup
                ServiceOptionRow(
                    icon: "airplane.arrival",
                    title: LocalizationUtils.localized("Airport_Pickup"),
                    description: LocalizationUtils.localized("Enter_Pickup_Name"),
                    isSelected: viewModel.airportPickupSelected,
                    onToggle: { viewModel.airportPickupSelected.toggle() }
                ) {
                    if viewModel.airportPickupSelected {
                        TextField(LocalizationUtils.localized("Enter_Pickup_Name"), text: $airportPickupName)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                            .foregroundColor(.primary)
                    }
                }
                
                // Check-in Assistance
                ServiceOptionRow(
                    icon: "building.2.fill",
                    title: LocalizationUtils.localized("Checkin_Assistance"),
                    description: LocalizationUtils.localized("Hotel_BnB"),
                    isSelected: viewModel.checkinAssistanceSelected,
                    onToggle: { viewModel.checkinAssistanceSelected.toggle() }
                )
                
                // Trip Sharing
                ServiceOptionRow(
                    icon: "square.and.arrow.up.fill",
                    title: LocalizationUtils.localized("Trip_Sharing"),
                    description: LocalizationUtils.localized("Share_With_Family"),
                    isSelected: viewModel.tripSharingSelected,
                    onToggle: { viewModel.tripSharingSelected.toggle() }
                )
                
                // Other Services
                ServiceOptionRow(
                    icon: "ellipsis.circle.fill",
                    title: LocalizationUtils.localized("Other_Services"),
                    description: LocalizationUtils.localized("Child_Seat_Etc"),
                    isSelected: viewModel.otherServicesSelected,
                    onToggle: { viewModel.otherServicesSelected.toggle() }
                ) {
                    if viewModel.otherServicesSelected {
                        VStack(spacing: 8) {
                            ServiceCheckbox(title: LocalizationUtils.localized("Child_Seat"), isSelected: $viewModel.childSeatSelected)
                            ServiceCheckbox(title: LocalizationUtils.localized("Interpreter"), isSelected: $viewModel.interpreterSelected)
                            ServiceCheckbox(title: LocalizationUtils.localized("Elderly_Companion"), isSelected: $viewModel.elderlyCompanionSelected)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Cost Preview Section
    // MARK: - Cost Preview Section
    private var costPreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizationUtils.localized("Cost_Preview"))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                PriceRow(
                    title: LocalizationUtils.localized("Base_Fare"),
                    amount: viewModel.baseFare
                )
                
                if viewModel.airportPickupSelected {
                    PriceRow(title: LocalizationUtils.localized("Airport_Pickup"), amount: 50.0)
                }
                
                if viewModel.checkinAssistanceSelected {
                    PriceRow(title: LocalizationUtils.localized("Checkin_Assistance"), amount: 30.0)
                }
                
                if viewModel.tripSharingSelected {
                    PriceRow(title: LocalizationUtils.localized("Trip_Sharing"), amount: 0.0)
                }
                
                if viewModel.childSeatSelected {
                    PriceRow(title: LocalizationUtils.localized("Child_Seat"), amount: 20.0)
                }
                
                if viewModel.interpreterSelected {
                    PriceRow(title: LocalizationUtils.localized("Interpreter"), amount: 100.0)
                }
                
                if viewModel.elderlyCompanionSelected {
                    PriceRow(title: LocalizationUtils.localized("Elderly_Companion"), amount: 80.0)
                }
                
                PriceRow(
                    title: LocalizationUtils.localized("Service_Fee"),
                    amount: viewModel.serviceFee
                )
                
                Divider()
                    .background(Color.secondary.opacity(0.3))
                
                PriceRow(
                    title: LocalizationUtils.localized("Total"),
                    amount: viewModel.totalAmount,
                    isTotal: true
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Coupon/Points Section
    private var couponPointsSection: some View {
        VStack(spacing: 12) {
            Button(action: { showingCouponExpansion.toggle() }) {
                HStack {
                    Image(systemName: "ticket.fill")
                        .foregroundColor(.orange)
                    
                    Text(LocalizationUtils.localized("Coupon_Point_Deduction"))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: showingCouponExpansion ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            }
            
            if showingCouponExpansion {
                VStack(spacing: 8) {
                    HStack {
                        Text(LocalizationUtils.localized("Available_Coupons"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(LocalizationUtils.localized("Two_Coupons"))
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text(LocalizationUtils.localized("Available_Points"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("1,250")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    // MARK: - Payment Button
    private var paymentButton: some View {
        Button(action: processPayment) {
            Text("\(LocalizationUtils.localized("Confirm_Pay")) ¥\(viewModel.totalAmount, specifier: "%.0f")")
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
    
    private var prioritizeFavoritesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle(isOn: .constant(true)) {
                Text(LocalizationUtils.localized("Priority_Match"))
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func processPayment() {
        navigationPath.append(BookingStep.orderSuccessDriverMatching)
    }
}

// MARK: - Service Option Row
struct ServiceOptionRow<Content: View>: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let onToggle: () -> Void
    let content: () -> Content
    
    init(
        icon: String,
        title: String,
        description: String,
        isSelected: Bool,
        onToggle: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.isSelected = isSelected
        self.onToggle = onToggle
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundColor(isSelected ? .blue : .secondary)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Service Checkbox
struct ServiceCheckbox: View {
    let title: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: { isSelected.toggle() }) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .secondary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Price Row
struct PriceRow: View {
    let title: String
    let amount: Double
    var isTotal: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(isTotal ? .headline : .body)
                .fontWeight(isTotal ? .bold : .regular)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("¥\(amount, specifier: "%.0f")")
                .font(isTotal ? .headline : .body)
                .fontWeight(isTotal ? .bold : .regular)
                .foregroundColor(isTotal ? .blue : .primary)
        }
    }
}

#Preview {
    NavigationView {
        ValueAddedServicesView(navigationPath: .constant(NavigationPath()))
    }
}
#endif
