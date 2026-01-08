import SwiftUI

#if os(iOS)
struct WalletView: View {
    @State private var paymentService = EasyRidePaymentService()
    @State private var wallet: Wallet?
    @State private var transactions: [PaymentTransaction] = []
    @State private var isLoading = false
    @State private var showingAddFunds = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {

        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                if isLoading && wallet == nil {
                    ProgressView()
                } else if let wallet = wallet {
                    List {
                        // Wallet Card Section
                        Section {
                            WalletCardView(wallet: wallet) {
                                showingAddFunds = true
                            }
                        }
                        .listRowBackground(Color(.systemBackground))
                        .listRowInsets(EdgeInsets())

                        // Transaction History Section
                        Section(header: Text("交易记录").foregroundColor(.secondary).fontWeight(.bold)) {
                            if transactions.isEmpty {
                                Text("暂无交易记录")
                                    .foregroundColor(.secondary)
                                    .listRowBackground(Color(.systemBackground))
                            } else {
                                ForEach(transactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                        .listRowBackground(Color(.systemBackground))
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .background(Color(.systemBackground))
                    .scrollContentBackground(.hidden) // Makes list background transparent
                    .refreshable {
                        await loadWalletData(refresh: true)
                    }
                } else {
                    Text("无法加载钱包。")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("钱包")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddFunds = true }) {
                        Image(systemName: "plus")
                    }
                    .disabled(wallet == nil)
                }
            }
        }
        .task {
            await loadWalletData()
        }
        .sheet(isPresented: $showingAddFunds) {
            if let wallet = wallet {
                // Note: AddFundsView would also need to be redesigned for a dark theme
                AddFundsView(wallet: wallet) { updatedWallet in
                    self.wallet = updatedWallet
                    Task {
                        await loadWalletData(refresh: true)
                    }
                }
            }
        }
        .alert("错误", isPresented: $showingError) {
            Button("确定") { }
        } message: {
            Text(errorMessage ?? "发生未知错误")
        }
    }
    
    // MARK: - Private Methods
    
    private func loadWalletData(refresh: Bool = false) async {
        isLoading = true
        do {
            async let walletTask = paymentService.getWallet()
            async let transactionsTask = paymentService.getTransactionHistory(page: 1, limit: 20)
            
            wallet = try await walletTask
            transactions = try await transactionsTask
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        isLoading = false
    }
}

// MARK: - Supporting Views

struct WalletCardView: View {
    let wallet: Wallet
    let onAddFunds: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("余额")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(wallet.formattedBalance)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                Spacer()
                Image(systemName: "wallet.pass.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue) // Use a tint color instead of white
            }
            
            Button(action: onAddFunds) {
                Text("充值")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct TransactionRow: View {
    let transaction: PaymentTransaction
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: transaction.type.icon)
                .font(.title2)
                .foregroundColor(Color(transaction.type.color))
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(LocalizationUtils.formatDate(transaction.createdAt))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(transaction.formattedAmount)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(transaction.type == .payment ? .primary : .green)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    WalletView()
}
#endif
