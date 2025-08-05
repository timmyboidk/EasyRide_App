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
                Color.black.ignoresSafeArea()
                
                Form {
                    Section(header: Text("卡信息").foregroundColor(.gray)) {
                        TextField("卡号", text: $cardNumber)
                            .keyboardType(.numberPad)
                        
                        TextField("月/年", text: $expiryDate)
                            .keyboardType(.numberPad)

                        TextField("CVV", text: $cvv)
                            .keyboardType(.numberPad)

                        TextField("持卡人姓名", text: $cardholderName)
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                    .foregroundColor(.white)
                    
                    Section {
                        Toggle("设为默认付款方式", isOn: $isDefault)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                    
                    Section {
                        Button("添加卡") {
                            addPaymentMethod()
                        }
                        .disabled(!isFormValid || isLoading)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.white)
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                }
                .background(Color.black)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("添加卡")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
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
            Text(errorMessage ?? "添加付款方式失败")
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
