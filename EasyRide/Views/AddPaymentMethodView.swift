import SwiftUI

#if os(iOS)
import UIKit

struct AddPaymentMethodView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var paymentService = EasyRidePaymentService()
    
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var cardholderName = ""
    @State private var isDefault = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    let onPaymentMethodAdded: (PaymentMethod) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                Form {
                    Section(header: Text("银行卡信息").foregroundColor(.secondary)) {
                        TextField("卡号", text: $cardNumber)
                            .keyboardType(.numberPad)
                        
                        TextField("MM/YY", text: $expiryDate)
                            .keyboardType(.numberPad)

                        TextField("CVV", text: $cvv)
                            .keyboardType(.numberPad)

                        TextField("持卡人姓名", text: $cardholderName)
                    }
                    .listRowBackground(Color(.systemBackground))
                    .foregroundColor(.primary)
                    
                    Section {
                        Toggle("设为默认", isOn: $isDefault)
                            .foregroundColor(.primary)
                    }
                    .listRowBackground(Color(.systemBackground))
                    
                    Section {
                        Button("添加卡片") {
                            addPaymentMethod()
                        }
                        .disabled(!isFormValid || isLoading)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.blue)
                    }
                    .listRowBackground(Color(.systemBackground))
                }
                .background(Color(.systemBackground))
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("添加卡片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
        .alert("错误", isPresented: $showingError) {
            Button("确定") { }
        } message: {
            Text(errorMessage ?? "添加卡片时出错")
        }
    }
    
    // MARK: - Private Methods
    
    private var isFormValid: Bool {
        !cardNumber.isEmpty && !expiryDate.isEmpty && !cvv.isEmpty && !cardholderName.isEmpty
    }
    
    private func addPaymentMethod() {
        // Placeholder for add payment logic
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let newMethod = PaymentMethod(
                type: .creditCard,
                displayName: "Visa **** \(String(cardNumber.suffix(4)))",
                isDefault: isDefault,
                lastFourDigits: String(cardNumber.suffix(4))
            )
            onPaymentMethodAdded(newMethod)
            isLoading = false
            dismiss()
        }
    }
}

#Preview {
    AddPaymentMethodView { _ in }
        .preferredColorScheme(.dark)
}
#endif
