import SwiftUI

#if os(iOS)
struct RegistrationView: View {
    @Environment(AppState.self) private var appState
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

        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("创建新账户")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTintColor(Color.primary) // Sets back button color
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
            
            Text("加入EasyRide")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }

    // MARK: - Registration Form
    private var registrationForm: some View {
        VStack(spacing: 16) {
            TextField("请输入手机号码", text: $authViewModel.phoneNumber)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .focused($focusedField, equals: .phoneNumber)
            
            // OTP Section
            HStack(spacing: 12) {
                TextField("6位数验证码", text: $authViewModel.otp)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
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
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 50)
                        .background(authViewModel.isOTPSent && !authViewModel.canResendOTP ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(authViewModel.isOTPSent && !authViewModel.canResendOTP)
            }

            TextField("昵称", text: $authViewModel.nickname)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .textContentType(.nickname)
                .focused($focusedField, equals: .nickname)
            
            TextField("电子邮件 (可选)", text: $authViewModel.email)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
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
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            } else {
                Text("注册")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .disabled(!authViewModel.isRegistrationFormValid || authViewModel.isLoading)
    }
    
    // MARK: - Terms and Conditions Text
    private var termsText: some View {
        Text("注册即表示您同意我们的服务条款和隐私政策。")
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

// Custom extension to set the navigation bar back button color
extension View {
    func navigationBarTintColor(_ color: Color) -> some View {
        self.modifier(NavigationBarTintColor(color: color))
    }
}

struct NavigationBarTintColor: ViewModifier {
    var color: Color

    init(color: Color) {
        self.color = color
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(color)]
        
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(color)]
        appearance.backButtonAppearance = backButtonAppearance
        
        let image = UIImage(systemName: "chevron.backward")?.withTintColor(UIColor(color), renderingMode: .alwaysOriginal)
        appearance.setBackIndicatorImage(image, transitionMaskImage: image)

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    func body(content: Content) -> some View {
        content
    }
}
#endif
