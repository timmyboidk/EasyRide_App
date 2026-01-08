import SwiftUI

#if os(iOS)
struct LoginView: View {
    @Environment(AppState.self) private var appState
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
            // Use system background color which adapts to Light/Dark mode
            .background(Color(.systemBackground).ignoresSafeArea())
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
            
            Text(LocalizationUtils.localized("EasyRide"))
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
        TextField(LocalizationUtils.localized("Enter_Phone"), text: $authViewModel.phoneNumber)
            .padding()
            .background(Color(.systemBackground))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.2), lineWidth: 1))
            .keyboardType(.phonePad)
            .textContentType(.telephoneNumber)
            .focused($focusedField, equals: .phoneNumber)
    }
    
    private var otpSection: some View {
        HStack(spacing: 12) {
            TextField(LocalizationUtils.localized("OTP_Code"), text: $authViewModel.otp)
                .padding()
                .background(Color(.systemBackground))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.2), lineWidth: 1))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focusedField, equals: .otp)
            
            Button(action: {
                Task {
                    await authViewModel.sendOTP()
                }
            }) {
                Text(authViewModel.isOTPSent ? authViewModel.formattedCountdown : LocalizationUtils.localized("Get_OTP"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 100, height: 50)
                    .background(authViewModel.isOTPSent && !authViewModel.canResendOTP ? Color.gray : Color.blue)
                    .cornerRadius(10)
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
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                } else {
                    Text(LocalizationUtils.localized("Login"))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
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
                    Text(LocalizationUtils.localized("Login_WeChat"))
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.03, green: 0.76, blue: 0.02)) // WeChat Green
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Registration Link
    
    private var registrationLink: some View {
        NavigationLink(destination: RegistrationView(appState: appState)) {
            Text(LocalizationUtils.localized("Create_Account"))
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
