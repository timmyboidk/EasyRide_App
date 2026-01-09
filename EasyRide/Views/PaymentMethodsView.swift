import SwiftUI
import PassKit

#if os(iOS)
import UIKit

struct PaymentMethodsView: View {
    @State private var paymentService = EasyRidePaymentService()
    @State private var paymentMethods: [PaymentMethod] = []
    @State private var wallet: Wallet?
    @State private var isLoading = false
    @State private var showingAddPaymentMethod = false
    @State private var showingApplePaySetup = false
    @State private var showingWeChatPaySetup = false
    @State private var showingAddFunds = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @Environment(AppState.self) private var appState
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                if isLoading && paymentMethods.isEmpty {
                    ProgressView()
                } else {
                    List {
                        // Wallet Section
                        if let wallet = wallet {
                            Section {
                                WalletCardView(wallet: wallet) {
                                    showingAddFunds = true
                                }
                            }
                            .listRowBackground(Color(.systemBackground))
                            .listRowInsets(EdgeInsets())
                        }
                        
                        // Payment Methods Section
                        Section(header: Text(LocalizationUtils.localized("Payment_Methods")).foregroundColor(.secondary).fontWeight(.bold)) {
                            // Example list if loaded
                            if paymentMethods.isEmpty {
                                PaymentMethodRowView(paymentMethod: PaymentMethod(type: .debitCard, displayName: "支付宝"))
                                    .listRowBackground(Color(.systemBackground))
                                PaymentMethodRowView(paymentMethod: PaymentMethod(type: .creditCard, displayName: "Card"))
                                    .listRowBackground(Color(.systemBackground))
                            } else {
                                ForEach(paymentMethods) { method in
                                    PaymentMethodRowView(paymentMethod: method)
                                    .listRowBackground(Color(.systemBackground))
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .background(Color(.systemBackground))
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        await loadPaymentData()
                    }
                }
            }
            .navigationTitle(LocalizationUtils.localized("Payment_Methods"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPaymentMethod = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .task {
            await loadPaymentData()
        }
        .sheet(isPresented: $showingAddPaymentMethod) {
            AddPaymentMethodView { newMethod in
                paymentMethods.append(newMethod)
                showingAddPaymentMethod = false
            }
        }
        .sheet(isPresented: $showingAddFunds) {
            if let wallet = wallet {
                AddFundsView(wallet: wallet) { updatedWallet in
                     self.wallet = updatedWallet
                     showingAddFunds = false
                }
            }
        }
        .alert(LocalizationUtils.localized("Error"), isPresented: $showingError) {
            Button(LocalizationUtils.localized("OK")) { }
        } message: {
            Text(errorMessage ?? LocalizationUtils.localized("Error"))
        }
    }
    
    // MARK: - Private Methods
    
    private func loadPaymentData() async {
        // Mock Data for Debug User
        if appState.currentUser?.phoneNumber == "99999999999" {
            isLoading = true
            try? await Task.sleep(nanoseconds: 500_000_000)
            self.paymentMethods = [
                PaymentMethod(id: "pm1", type: .applePay, displayName: "Apple Pay", isDefault: true, lastFourDigits: nil),
                PaymentMethod(id: "pm2", type: .wechatPay, displayName: "WeChat Pay", isDefault: false, lastFourDigits: nil),
                PaymentMethod(id: "pm3", type: .creditCard, displayName: "Visa", isDefault: false, lastFourDigits: "4242")
            ]
            self.wallet = Wallet(balance: 888.88, currency: "CNY")
            isLoading = false
            return
        }

        isLoading = true
        do {
            async let paymentMethodsTask = paymentService.getPaymentMethods()
            async let walletTask = paymentService.getWallet()
            paymentMethods = try await paymentMethodsTask
            wallet = try await walletTask
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        isLoading = false
    }
    
    private func deletePaymentMethods(offsets: IndexSet) {
        // Placeholder for delete logic
        paymentMethods.remove(atOffsets: offsets)
    }
}

// MARK: - Supporting Views

struct PaymentMethodRowView: View {
    let paymentMethod: PaymentMethod
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: paymentMethod.type.icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(paymentMethod.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                if let lastFour = paymentMethod.lastFourDigits {
                    Text("**** \(lastFour)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if paymentMethod.isDefault {
                Text(LocalizationUtils.localized("Default"))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var iconColor: Color {
        switch paymentMethod.type {
        case .applePay: return .primary
        case .wechatPay: return .green
        default: return .primary
        }
    }
}

#Preview {
    PaymentMethodsView()
}
#endif
