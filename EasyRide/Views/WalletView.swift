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
    @Environment(AppState.self) private var appState
    
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
                        Section(header: Text(LocalizationUtils.localized("Transaction_History")).foregroundColor(.secondary).fontWeight(.bold)) {
                            if transactions.isEmpty {
                                Text(LocalizationUtils.localized("No_Transactions"))
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
                    Text(LocalizationUtils.localized("Wallet_Load_Error"))
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(LocalizationUtils.localized("Wallet"))
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
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "Unknown Error")
        }
    }
    
    // MARK: - Private Methods
    
    private func loadWalletData(refresh: Bool = false) async {
        // Mock Data for Debug User
        if appState.currentUser?.phoneNumber == "99999999999" {
            isLoading = true
            try? await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
            self.wallet = Wallet(balance: 888.88, currency: "CNY")
            self.transactions = [
                PaymentTransaction(id: "t1", amount: -50.0, type: .payment, description: "Ride to Airport", createdAt: Date().addingTimeInterval(-3600)),
                PaymentTransaction(id: "t2", amount: 20.0, type: .refund, description: "Refund", createdAt: Date().addingTimeInterval(-86400)),
                PaymentTransaction(id: "t3", amount: 1000.0, type: .topUp, description: "Top Up", createdAt: Date().addingTimeInterval(-172800))
            ]
            isLoading = false
            return
        }

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
                    Text(LocalizationUtils.localized("Balance"))
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
                Text(LocalizationUtils.localized("Top_Up"))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .padding()
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.primary, lineWidth: 1)
                    )
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.primary.opacity(0.1), radius: 2, x: 0, y: 1)
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
