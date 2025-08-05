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
                Color.black.ignoresSafeArea()
                
                if isLoading && wallet == nil {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if let wallet = wallet {
                    List {
                        // Wallet Card Section
                        Section {
                            WalletCardView(wallet: wallet) {
                                showingAddFunds = true
                            }
                        }
                        .listRowBackground(Color.black)
                        .listRowInsets(EdgeInsets())

                        // Transaction History Section
                        Section(header: Text("交易记录").foregroundColor(.gray).fontWeight(.bold)) {
                            if transactions.isEmpty {
                                Text("暂无交易记录")
                                    .foregroundColor(.gray)
                                    .listRowBackground(Color.black)
                            } else {
                                ForEach(transactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                        .listRowBackground(Color.black)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .background(Color.black)
                    .scrollContentBackground(.hidden) // Makes list background transparent
                    .refreshable {
                        await loadWalletData(refresh: true)
                    }
                } else {
                    Text("无法加载钱包。")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("钱包")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
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
                        .foregroundColor(.gray)
                    Text(wallet.formattedBalance)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: "wallet.pass.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            
            Button(action: onAddFunds) {
                Text("充值")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
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
                    .foregroundColor(.white)
                Text(transaction.createdAt, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(transaction.formattedAmount)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(transaction.type == .payment ? .white : .green)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    WalletView()
        .preferredColorScheme(.dark)
}
#endif
