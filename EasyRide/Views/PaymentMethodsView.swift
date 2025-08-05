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
                Color.black.ignoresSafeArea()
                
                if isLoading && paymentMethods.isEmpty {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    List {
                        // Wallet Section
                        if let wallet = wallet {
                            Section {
                                WalletCardView(wallet: wallet) {
                                    showingAddFunds = true
                                }
                            }
                            .listRowBackground(Color.black)
                            .listRowInsets(EdgeInsets())
                        }
                        
                        // Payment Methods Section
                        Section(header: Text("支付方式").foregroundColor(.gray).fontWeight(.bold)) {
                            ForEach(paymentMethods) { paymentMethod in
                                PaymentMethodRowView(paymentMethod: paymentMethod)
                            }
                            .onDelete(perform: deletePaymentMethods)
                            .listRowBackground(Color.gray.opacity(0.2))
                            
                            // Add Payment Method Options
                            Button(action: { showingAddPaymentMethod = true }) {
                                Label("添加信用卡/借记卡", systemImage: "creditcard.fill")
                            }
                            .foregroundColor(.white)
                            .listRowBackground(Color.gray.opacity(0.2))
                        }
                    }
                    .listStyle(.insetGrouped)
                    .background(Color.black)
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        await loadPaymentData()
                    }
                }
            }
            .navigationTitle("支付")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
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
                    .foregroundColor(.white)
                if let lastFour = paymentMethod.lastFourDigits {
                    Text("**** \(lastFour)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
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
        case .applePay: return .white
        case .wechatPay: return .green
        default: return .white
        }
    }
}

#Preview {
    PaymentMethodsView()
        .preferredColorScheme(.dark)
}
#endif
