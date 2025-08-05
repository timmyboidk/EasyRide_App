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
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "apple.logo")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        Text("设置Apple Pay")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("使用您日常使用的设备安全私密地付款。")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        FeatureRow(icon: "checkmark.shield.fill", text: "安全私密")
                        FeatureRow(icon: "creditcard.fill", text: "不共享卡详细信息")
                        FeatureRow(icon: "bolt.fill", text: "快捷支付")
                    }
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.bottom)
                    } else {
                        Button(action: enableApplePay) {
                            Text("启用Apple Pay")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
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
            Text(errorMessage ?? "设置Apple Pay失败")
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
                .foregroundColor(.white)
            Spacer()
        }
    }
}

#Preview {
    ApplePaySetupView { _ in }
        .preferredColorScheme(.dark)
}
#endif
