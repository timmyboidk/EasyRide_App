import SwiftUI

#if os(iOS)
import UIKit

struct WeChatPaySetupView: View {
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
                    
                    Image(systemName: "message.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    VStack(spacing: 12) {
                        Text(LocalizationUtils.localized("Bind_WeChat_Pay"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(LocalizationUtils.localized("Bind_WeChat_Desc"))
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        WeChatFeatureRow(icon: "checkmark.shield.fill", text: LocalizationUtils.localized("Regulated_Service"))
                        WeChatFeatureRow(icon: "globe.americas.fill", text: LocalizationUtils.localized("Secure_Intl_Payment"))
                        WeChatFeatureRow(icon: "qrcode", text: LocalizationUtils.localized("Fast_QR_Payment"))
                    }
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                            .padding(.bottom)
                    } else {
                        Button(action: enableWeChatPay) {
                            Text(LocalizationUtils.localized("Bind_WeChat_Pay"))
                                .fontWeight(.heavy)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
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
            Text(errorMessage ?? LocalizationUtils.localized("WeChat_Bind_Failed"))
        }
    }
    
    private func enableWeChatPay() {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let newMethod = PaymentMethod(type: .wechatPay, displayName: "微信支付", isDefault: false)
            onPaymentMethodAdded(newMethod)
            isLoading = false
            dismiss()
        }
    }
}

private struct WeChatFeatureRow: View {
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
    WeChatPaySetupView { _ in }
        .preferredColorScheme(.dark)
}
#endif
