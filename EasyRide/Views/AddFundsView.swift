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
                Color.black.ignoresSafeArea()
                
                Form {
                    Section(header: Text("当前余额").foregroundColor(.gray)) {
                        Text(wallet.formattedBalance)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                    
                    Section(header: Text("选择金额").foregroundColor(.gray)) {
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

                        TextField("自定义金额", text: $customAmount)
                            .keyboardType(.decimalPad)
                            .foregroundColor(.white)
                            .onChange(of: customAmount) { _, newValue in
                                if !newValue.isEmpty, let amount = Double(newValue) {
                                    selectedAmount = amount
                                }
                            }
                    }
                    .listRowBackground(Color.gray.opacity(0.2))

                    Section(header: Text("支付方式").foregroundColor(.gray)) {
                        // Assuming payment methods are loaded and displayed here
                        Text("Apple Pay")
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                }
                .background(Color.black)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("充值")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加") {
                        addFunds()
                    }
                    .disabled(isLoading)
                }
            }
        }
        .alert("错误", isPresented: $showingError) {
            Button("确定") { }
        } message: {
            Text(errorMessage ?? "发生未知错误")
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
                .background(isSelected ? Color.white : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .black : .white)
                .cornerRadius(10)
        }
    }
}

#Preview {
    AddFundsView(wallet: Wallet(balance: 25.0)) { _ in }
        .preferredColorScheme(.dark)
}
#endif
