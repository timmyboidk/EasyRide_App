import SwiftUI

#if os(iOS)
struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var authViewModel: AuthenticationViewModel
    @State private var loginMode: LoginMode = .password
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
            .background(Color.black.ignoresSafeArea())
            .navigationBarHidden(true)
            .alert("错误", isPresented: $authViewModel.showingError) {
                Button("确定") {
                    authViewModel.showingError = false
                }
            } message: {
                Text(authViewModel.currentError?.localizedDescription ?? "错误")
            }
        }
        .accentColor(.white)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "car.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.white)
            
            Text("EasyRide")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Login Form
    
    @ViewBuilder
    private var loginForm: some View {
        VStack(spacing: 16) {
            // Phone Number Field
            phoneNumberField
            
            // Password or OTP Field
            if loginMode == .password {
                passwordField
            } else {
                otpSection
            }
        }
    }
    
    private var phoneNumberField: some View {
        TextField("请输入手机号码", text: $authViewModel.phoneNumber)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .keyboardType(.phonePad)
            .textContentType(.telephoneNumber)
            .focused($focusedField, equals: .phoneNumber)
    }
    
    private var passwordField: some View {
        SecureField("请输入密码", text: $authViewModel.password)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .textContentType(.password)
            .focused($focusedField, equals: .password)
    }
    
    private var otpSection: some View {
        VStack(spacing: 16) {
            TextField("6位数验证码", text: $authViewModel.otp)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focusedField, equals: .otp)
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    if loginMode == .password {
                        await authViewModel.loginWithPassword()
                    } else {
                        await authViewModel.loginWithOTP()
                    }
                }
            }) {
                Text("登录")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
            }
            .disabled(loginMode == .password ? !authViewModel.isLoginFormValid : !authViewModel.isOTPFormValid)
        }
    }
    
    // MARK: - Registration Link
    
    private var registrationLink: some View {
        NavigationLink(destination: RegistrationView(appState: appState)) {
            Text("创建新账户")
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Supporting Types

enum LoginMode {
    case password
    case otp
}

enum LoginField {
    case phoneNumber
    case password
    case otp
}

// MARK: - Preview

#Preview {
    LoginView(appState: AppState())
}
#endif
