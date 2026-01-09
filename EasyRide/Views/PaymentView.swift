import SwiftUI

struct PaymentView: View {
    let orderId: String
    let amount: Double
    var onPaymentSuccess: () -> Void
    
    @StateObject private var viewModel: PaymentViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    init(orderId: String, amount: Double, appState: AppState, onPaymentSuccess: @escaping () -> Void) {
        self.orderId = orderId
        self.amount = amount
        self.onPaymentSuccess = onPaymentSuccess
        _viewModel = StateObject(wrappedValue: PaymentViewModel(appState: appState))
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundColor(for: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                Text("应付金额")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Text(String(format: "%.2f", amount))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Theme.primaryColor(for: colorScheme))
                
                // Payment Methods
                List(viewModel.paymentMethods) { method in
                    Button(action: {
                        viewModel.selectMethod(method.id)
                    }) {
                        HStack {
                            Image(systemName: method.type.icon)
                                .font(.title3)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading) {
                                Text(method.type.displayName)
                                    .font(.body)
                                if let lastFour = method.lastFourDigits {
                                    Text("•••• \(lastFour)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if viewModel.selectedMethodId == method.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .scrollContentBackground(.hidden)
                .frame(height: 300)
                
                Spacer()
                
                // Pay Button
                Button(action: {
                    Task {
                        // For demo purposes, if amount is 0, just succeed
                        if await viewModel.processPayment(orderId: orderId, amount: amount) {
                            onPaymentSuccess()
                        }
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("立即支付")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primaryColor(for: colorScheme))
                    .foregroundColor(Theme.backgroundColor(for: colorScheme))
                    .cornerRadius(12)
                }
                .accessibilityIdentifier("pay_now_button")
                .padding(.horizontal)
                .padding(.bottom, 20)
                .disabled(viewModel.isLoading)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchPaymentMethods()
            }
        }
            .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                Alert(
                    title: Text("错误"),
                    message: Text(viewModel.errorMessage ?? ""),
                    dismissButton: .default(Text("确定")) {
                        viewModel.errorMessage = nil
                    }
                )
        }
    }
}
