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
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("创建新账户")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTintColor(.white) // Sets back button color
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
                .foregroundStyle(.white)
            
            Text("加入EasyRide")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }

    // MARK: - Registration Form
    private var registrationForm: some View {
        VStack(spacing: 16) {
            TextField("请输入手机号码", text: $authViewModel.phoneNumber)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .focused($focusedField, equals: .phoneNumber)

            SecureField("创建密码", text: $authViewModel.password)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .textContentType(.newPassword)
                .focused($focusedField, equals: .password)
            
            SecureField("确认密码", text: $authViewModel.confirmPassword)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .textContentType(.newPassword)
                .focused($focusedField, equals: .confirmPassword)
        }
    }
    
    // MARK: - Action Button
    private var actionButton: some View {
        Button(action: {
            Task {
                await authViewModel.register()
            }
        }) {
            Text("注册")
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
        .disabled(!authViewModel.isRegistrationFormValid)
    }
    
    // MARK: - Terms and Conditions Text
    private var termsText: some View {
        Text("注册即表示您同意我们的服务条款和隐私政策。")
            .font(.caption)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
    }
}

// MARK: - Supporting Types
enum RegistrationField {
    case phoneNumber, password, confirmPassword
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
