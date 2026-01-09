import SwiftUI

#if os(iOS)
struct RegistrationView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var authViewModel: AuthenticationViewModel
    @FocusState private var focusedField: RegistrationField?

    init(appState: AppState) {
        _authViewModel = State(initialValue: AuthenticationViewModel(appState: appState))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                headerSection

                // Registration Form
                registrationForm

                // Action Button
                actionButton

                // "Terms and Conditions" Text
                termsText
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }

        .background(Theme.backgroundColor(for: colorScheme).ignoresSafeArea())
        .navigationTitle("创建账户")
        .navigationBarTitleDisplayMode(.inline)
        .alert("错误", isPresented: $authViewModel.showingError) {
            Button("确定") {
                authViewModel.showingError = false
            }
        } message: {
            Text(authViewModel.currentError?.localizedDescription ?? "错误")
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill.badge.plus")
                .font(.system(size: 80))
                .foregroundStyle(.primary)
            
            Text("加入 EasyRide")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }

    // MARK: - Registration Form
    private var registrationForm: some View {
        VStack(spacing: 16) {
            TextField("请输入手机号", text: $authViewModel.phoneNumber)
                .padding()
                .background(Theme.backgroundColor(for: colorScheme))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.primaryColor(for: colorScheme).opacity(0.2), lineWidth: 1))
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .focused($focusedField, equals: .phoneNumber)
            
            // OTP Section
            HStack(spacing: 12) {
                TextField("请输入验证码", text: $authViewModel.otp)
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
                        .cornerRadius(10)
                }
                .disabled(authViewModel.isOTPSent && !authViewModel.canResendOTP)
            }

            TextField("昵称", text: $authViewModel.nickname)
                .padding()
                .background(Theme.backgroundColor(for: colorScheme))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.primaryColor(for: colorScheme).opacity(0.2), lineWidth: 1))
                .textContentType(.nickname)
                .focused($focusedField, equals: .nickname)
            
            TextField("邮箱 (可选)", text: $authViewModel.email)
                .padding()
                .background(Theme.backgroundColor(for: colorScheme))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.primaryColor(for: colorScheme).opacity(0.2), lineWidth: 1))
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .focused($focusedField, equals: .email)
        }
    }
    
    // MARK: - Action Button
    private var actionButton: some View {
        Button(action: {
            Task {
                await authViewModel.register()
            }
        }) {
            if authViewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.backgroundColor(for: colorScheme)))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primaryColor(for: colorScheme))
                    .cornerRadius(12)
            } else {
                Text("注册")
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primaryColor(for: colorScheme))
                    .foregroundColor(Theme.backgroundColor(for: colorScheme))
                    .cornerRadius(12)
            }
        }
        .disabled(!authViewModel.isRegistrationFormValid || authViewModel.isLoading)
    }
    
    // MARK: - Terms and Conditions Text
    private var termsText: some View {
        Text("注册即代表您同意我们的条款和隐私政策")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
    }
}

// MARK: - Supporting Types
enum RegistrationField {
    case phoneNumber, otp, nickname, email
}

// MARK: - Preview
#Preview {
    NavigationView {
        RegistrationView(appState: AppState())
    }
}
#endif
