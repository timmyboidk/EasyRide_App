import SwiftUI

#if os(iOS)
struct LoginView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    @State private var authViewModel: AuthenticationViewModel
    @FocusState private var focusedField: LoginField?
    
    init(appState: AppState) {
        _authViewModel = State(initialValue: AuthenticationViewModel(appState: appState))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection
                    
                    // Login Form
                    loginForm
                    
                    // Action Buttons
                    actionButtons
                    
                    // Registration Link
                    registrationLink
                    
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            // Use pure white for light mode and all black for dark mode
            .background(Theme.backgroundColor(for: colorScheme).ignoresSafeArea())
            .navigationBarHidden(true)
            .alert("错误", isPresented: $authViewModel.showingError) {
                Button("确定") {
                    authViewModel.showingError = false
                }
            } message: {
                Text(authViewModel.currentError?.localizedDescription ?? "错误")
            }
        }
        .accentColor(.primary)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "car.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.primary)
            
            Text("EasyRide")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Login Form
    
    @ViewBuilder
    private var loginForm: some View {
        VStack(spacing: 16) {
            // Phone Number Field
            phoneNumberField
            
            // OTP Field
            otpSection
        }
    }
    
    private var phoneNumberField: some View {
        TextField("请输入手机号", text: $authViewModel.phoneNumber)
            .padding()
            .background(Theme.backgroundColor(for: colorScheme))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.primaryColor(for: colorScheme).opacity(0.2), lineWidth: 1))
            .keyboardType(.phonePad)
            .textContentType(.telephoneNumber)
            .focused($focusedField, equals: .phoneNumber)
    }
    
    private var otpSection: some View {
        HStack(spacing: 12) {
            TextField("验证码", text: $authViewModel.otp)
                .padding()
                .background(Theme.backgroundColor(for: colorScheme))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.primaryColor(for: colorScheme).opacity(0.2), lineWidth: 1))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focusedField, equals: .otp)
            
            Button(action: {
                Task {
                    await authViewModel.sendOTP()
                }
            }) {
                Text(authViewModel.isOTPSent ? authViewModel.formattedCountdown : "获取验证码")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.backgroundColor(for: colorScheme))
                    .frame(width: 100, height: 50)
                    .background(authViewModel.isOTPSent && !authViewModel.canResendOTP ? Color.gray : Theme.primaryColor(for: colorScheme))
                    .cornerRadius(12)
            }
            .disabled(authViewModel.isOTPSent && !authViewModel.canResendOTP)
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task {
                    await authViewModel.loginWithOTP()
                }
            }) {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.backgroundColor(for: colorScheme)))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primaryColor(for: colorScheme))
                        .cornerRadius(10)
                } else {
                    Text("登录")
                        .fontWeight(.heavy)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primaryColor(for: colorScheme))
                        .foregroundColor(Theme.backgroundColor(for: colorScheme))
                        .cornerRadius(12)
                }
            }
            .disabled(!authViewModel.isOTPFormValid || authViewModel.isLoading)

            // WeChat Login
            Button(action: {
                Task {
                    await authViewModel.loginWithWeChat()
                }
            }) {
                HStack {
                    Image(systemName: "message.fill")
                    Text("微信登录")
                }
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.primaryColor(for: colorScheme))
                .foregroundColor(Theme.backgroundColor(for: colorScheme))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.primaryColor(for: colorScheme), lineWidth: 1))
            }
        }
    }
    
    // MARK: - Registration Link
    
    private var registrationLink: some View {
        NavigationLink(destination: RegistrationView(appState: appState)) {
            Text("创建账户")
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
    

}

// MARK: - Supporting Types

enum LoginField {
    case phoneNumber
    case otp
}

// MARK: - Preview

#Preview {
    LoginView(appState: AppState())
}
#endif
