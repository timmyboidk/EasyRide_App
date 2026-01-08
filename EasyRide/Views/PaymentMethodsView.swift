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
                        Section(header: Text("支付方式").foregroundColor(.secondary).fontWeight(.bold)) {
                            // Example list if loaded
                            if paymentMethods.isEmpty {
                                PaymentMethodRowView(paymentMethod: PaymentMethod(type: .debitCard, displayName: "支付宝"))
                                    .listRowBackground(Color(.secondarySystemBackground))
                                PaymentMethodRowView(paymentMethod: PaymentMethod(type: .creditCard, displayName: "Card"))
                                    .listRowBackground(Color(.secondarySystemBackground))
                            } else {
                                ForEach(paymentMethods) { method in
                                    PaymentMethodRowView(paymentMethod: method)
                                    .listRowBackground(Color(.secondarySystemBackground))
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
            .navigationTitle("支付")
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
            // Placeholder for AddPaymentMethodView
            Text("添加支付方式视图")
        }
        .sheet(isPresented: $showingAddFunds) {
            if let wallet = wallet {
                // Placeholder for AddFundsView
                Text("充值视图")
            }
        }
        .alert("错误", isPresented: $showingError) {
            Button("确定") { }
        } message: {
            Text(errorMessage ?? "发生未知错误")
        }
    }
    
    // MARK: - Private Methods
    
    private func loadPaymentData() async {
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
                Text("默认")
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
