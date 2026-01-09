import SwiftUI

#if os(iOS)
struct ValueAddedServicesView: View {
    @State private var viewModel = ValueAddedServicesViewModel()
    @State private var bookingViewModel: BookingViewModel?
    @Environment(AppState.self) private var appState
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
        .navigationTitle("增值服务")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPaymentMethods) {
            PaymentMethodsView()
        }
        .onAppear {
            if bookingViewModel == nil {
                bookingViewModel = BookingViewModel(appState: appState)
            }
        }
    }
    
    // MARK: - Itinerary & Vehicle Confirmation
    private var itineraryConfirmationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("确认车辆")
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
                    Text("商务车")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("全天包车")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("预计时长 8小时")
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
            Text("增值服务")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // Airport Pickup
                ServiceOptionRow(
                    icon: "airplane.arrival",
                    title: "接机服务",
                    description: "请输入接机姓名",
                    isSelected: viewModel.airportPickupSelected,
                    onToggle: { viewModel.airportPickupSelected.toggle() }
                ) {
                    if viewModel.airportPickupSelected {
                        TextField("请输入接机姓名", text: $airportPickupName)
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
                    title: "协助办理入住",
                    description: "酒店/民宿",
                    isSelected: viewModel.checkinAssistanceSelected,
                    onToggle: { viewModel.checkinAssistanceSelected.toggle() }
                )
                
                // Trip Sharing
                ServiceOptionRow(
                    icon: "square.and.arrow.up.fill",
                    title: "行程分享",
                    description: "与家人分享行程",
                    isSelected: viewModel.tripSharingSelected,
                    onToggle: { viewModel.tripSharingSelected.toggle() }
                )
                
                // Other Services
                ServiceOptionRow(
                    icon: "ellipsis.circle.fill",
                    title: "其他服务",
                    description: "儿童座椅等",
                    isSelected: viewModel.otherServicesSelected,
                    onToggle: { viewModel.otherServicesSelected.toggle() }
                ) {
                    if viewModel.otherServicesSelected {
                        VStack(spacing: 8) {
                            ServiceCheckbox(title: "儿童座椅", isSelected: $viewModel.childSeatSelected)
                            ServiceCheckbox(title: "翻译服务", isSelected: $viewModel.interpreterSelected)
                            ServiceCheckbox(title: "老人陪护", isSelected: $viewModel.elderlyCompanionSelected)
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
            Text("费用预览")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                PriceRow(
                    title: "基础费用",
                    amount: viewModel.baseFare
                )
                
                if viewModel.airportPickupSelected {
                    PriceRow(title: "接机服务", amount: 50.0)
                }
                
                if viewModel.checkinAssistanceSelected {
                    PriceRow(title: "协助办理入住", amount: 30.0)
                }
                
                if viewModel.tripSharingSelected {
                    PriceRow(title: "行程分享", amount: 0.0)
                }
                
                if viewModel.childSeatSelected {
                    PriceRow(title: "儿童座椅", amount: 20.0)
                }
                
                if viewModel.interpreterSelected {
                    PriceRow(title: "翻译服务", amount: 100.0)
                }
                
                if viewModel.elderlyCompanionSelected {
                    PriceRow(title: "老人陪护", amount: 80.0)
                }
                
                PriceRow(
                    title: "服务费",
                    amount: viewModel.serviceFee
                )
                
                Divider()
                    .background(Color.secondary.opacity(0.3))
                
                PriceRow(
                    title: "总计",
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
                    
                    Text("优惠券/积分抵扣")
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
                        Text("可用优惠券")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("2张可用")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text("可用积分")
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
        Button(action: processOrderCreation) {
            HStack {
                if let isCreating = bookingViewModel?.isCreatingOrder, isCreating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("\("确认并支付") ¥\(viewModel.totalAmount, specifier: "%.0f")")
                        .fontWeight(.heavy)
                }
            }
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
                Text("优先匹配")
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
    
    private func processOrderCreation() {
        guard let bookingVM = bookingViewModel else { return }
        
        Task {
            // Update trip configuration with selected options (if needed)
            // Ideally, ValueAddedServicesViewModel should update AppState or return the options.
            // For now, we assume AppState already has the base config, and we capture these options.
            
            // Note: BookingViewModel.createOrder uses AppState.tripConfiguration.
            // We need to ensure AppState.tripConfiguration is up to date with these services.
            
            // Trigger creation
            await bookingVM.createOrder()
            
            if bookingVM.createdOrder != nil {
                navigationPath.append(BookingStep.orderSuccessDriverMatching)
            }
        }
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
