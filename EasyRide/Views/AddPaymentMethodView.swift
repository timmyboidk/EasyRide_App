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
                    Section(header: Text(LocalizationUtils.localized("Card_Info")).foregroundColor(.secondary)) {
                        TextField(LocalizationUtils.localized("Card_Number"), text: $cardNumber)
                            .keyboardType(.numberPad)
                        
                        TextField("MM/YY", text: $expiryDate)
                            .keyboardType(.numberPad)

                        TextField("CVV", text: $cvv)
                            .keyboardType(.numberPad)

                        TextField(LocalizationUtils.localized("Name_On_Card"), text: $cardholderName)
                    }
                    .listRowBackground(Color(.systemBackground))
                    .foregroundColor(.primary)
                    
                    Section {
                        Toggle(LocalizationUtils.localized("Set_As_Default"), isOn: $isDefault)
                            .foregroundColor(.primary)
                    }
                    .listRowBackground(Color(.systemBackground))
                    
                    Section {
                        Button(LocalizationUtils.localized("Add_Card")) {
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
            .navigationTitle(LocalizationUtils.localized("Add_Card"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizationUtils.localized("Cancel")) {
                        dismiss()
                    }
                }
            }
        }
        .alert(LocalizationUtils.localized("Error"), isPresented: $showingError) {
            Button(LocalizationUtils.localized("OK")) { }
        } message: {
            Text(errorMessage ?? LocalizationUtils.localized("Error_Adding_Card"))
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
