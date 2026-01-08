import SwiftUI
import PassKit

#if os(iOS)
struct ApplePaySetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var paymentService = EasyRidePaymentService()
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    let onPaymentMethodAdded: (PaymentMethod) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "apple.logo")
                        .font(.system(size: 80))
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        Text(LocalizationUtils.localized("Setup_Apple_Pay"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(LocalizationUtils.localized("Apple_Pay_Description"))
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        FeatureRow(icon: "checkmark.shield.fill", text: LocalizationUtils.localized("Secure_Private"))
                        FeatureRow(icon: "creditcard.fill", text: LocalizationUtils.localized("No_Card_Sharing"))
                        FeatureRow(icon: "bolt.fill", text: LocalizationUtils.localized("Fast_Payment"))
                    }
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                            .padding(.bottom)
                    } else {
                        Button(action: enableApplePay) {
                            Text(LocalizationUtils.localized("Enable_Apple_Pay"))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.primary)
                                .foregroundColor(Color(.systemBackground))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
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
            Text(errorMessage ?? LocalizationUtils.localized("Apple_Pay_Setup_Failed"))
        }
    }
    
    private func enableApplePay() {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let newMethod = PaymentMethod(type: .applePay, displayName: "Apple Pay", isDefault: false)
            onPaymentMethodAdded(newMethod)
            isLoading = false
            dismiss()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
            Text(text)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

#Preview {
    ApplePaySetupView { _ in }
        .preferredColorScheme(.dark)
}
#endif
