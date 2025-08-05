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
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "message.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    VStack(spacing: 12) {
                        Text("绑定微信支付")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("绑定您的账户以便快捷支付。")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        WeChatFeatureRow(icon: "checkmark.shield.fill", text: "受监管的金融服务")
                        WeChatFeatureRow(icon: "globe.americas.fill", text: "安全的国际支付")
                        WeChatFeatureRow(icon: "qrcode", text: "快捷扫码支付")
                    }
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.bottom)
                    } else {
                        Button(action: enableWeChatPay) {
                            Text("绑定微信支付")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .alert("错误", isPresented: $showingError) {
            Button("确定") { }
        } message: {
            Text(errorMessage ?? "绑定微信支付失败")
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
                .foregroundColor(.white)
            Spacer()
        }
    }
}

#Preview {
    WeChatPaySetupView { _ in }
        .preferredColorScheme(.dark)
}
#endif
