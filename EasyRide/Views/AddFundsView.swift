import SwiftUI
import PassKit

#if os(iOS)
import UIKit

struct AddFundsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var paymentService = EasyRidePaymentService()
    @State private var selectedAmount: Double = 50.0
    @State private var customAmount: String = ""
    @State private var selectedPaymentMethodId: String?
    @State private var paymentMethods: [PaymentMethod] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    let wallet: Wallet
    let onFundsAdded: (Wallet) -> Void
    
    private let predefinedAmounts: [Double] = [10.0, 25.0, 50.0, 100.0, 200.0]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                Form {
                    Section(header: Text(LocalizationUtils.localized("Current_Balance")).foregroundColor(.secondary)) {
                        Text(wallet.formattedBalance)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .listRowBackground(Color(.systemBackground))
                    
                    Section(header: Text(LocalizationUtils.localized("Select_Amount")).foregroundColor(.secondary)) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(predefinedAmounts, id: \.self) { amount in
                                    AmountButton(
                                        amount: amount,
                                        isSelected: selectedAmount == amount && customAmount.isEmpty
                                    ) {
                                        selectedAmount = amount
                                        customAmount = ""
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowInsets(EdgeInsets())

                        TextField(LocalizationUtils.localized("Custom_Amount"), text: $customAmount)
                            .keyboardType(.decimalPad)
                            .foregroundColor(.primary)
                            .onChange(of: customAmount) { _, newValue in
                                if !newValue.isEmpty, let amount = Double(newValue) {
                                    selectedAmount = amount
                                }
                            }
                    }
                    .listRowBackground(Color(.systemBackground))

                    Section(header: Text(LocalizationUtils.localized("Payment_Methods")).foregroundColor(.secondary)) {
                        // Assuming payment methods are loaded and displayed here
                        Text(LocalizationUtils.localized("Apple_Pay"))
                            .foregroundColor(.primary)
                    }
                    .listRowBackground(Color(.systemBackground))
                }
                .background(Color(.systemBackground))
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(LocalizationUtils.localized("Top_Up"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizationUtils.localized("Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizationUtils.localized("Add")) {
                        addFunds()
                    }
                    .disabled(isLoading)
                }
            }
        }
        .alert(LocalizationUtils.localized("Error"), isPresented: $showingError) {
            Button(LocalizationUtils.localized("OK")) { }
        } message: {
            Text(errorMessage ?? LocalizationUtils.localized("Unknown_Error"))
        }
    }
    
    private func addFunds() {
        // Placeholder for add funds logic
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let updatedWallet = Wallet(balance: wallet.balance + selectedAmount)
            onFundsAdded(updatedWallet)
            isLoading = false
            dismiss()
        }
    }
}

// MARK: - Supporting Views

struct AmountButton: View {
    let amount: Double
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text("¥\(Int(amount))")
                .fontWeight(.bold)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(10)
        }
    }
}

#Preview {
    AddFundsView(wallet: Wallet(balance: 25.0)) { _ in }
        .preferredColorScheme(.dark)
}
#endif
