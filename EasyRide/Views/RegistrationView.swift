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
        .navigationTitle(LocalizationUtils.localized("Create_Account"))
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
            
            Text(LocalizationUtils.localized("Join_EasyRide"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }

    // MARK: - Registration Form
    private var registrationForm: some View {
        VStack(spacing: 16) {
            TextField(LocalizationUtils.localized("Enter_Phone"), text: $authViewModel.phoneNumber)
                .padding()
                .background(Color(.systemBackground))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.2), lineWidth: 1))
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .focused($focusedField, equals: .phoneNumber)
            
            // OTP Section
            HStack(spacing: 12) {
                TextField(LocalizationUtils.localized("Enter_OTP"), text: $authViewModel.otp)
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
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 50)
                        .background(authViewModel.isOTPSent && !authViewModel.canResendOTP ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(authViewModel.isOTPSent && !authViewModel.canResendOTP)
            }

            TextField(LocalizationUtils.localized("Nickname"), text: $authViewModel.nickname)
                .padding()
                .background(Color(.systemBackground))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.2), lineWidth: 1))
                .textContentType(.nickname)
                .focused($focusedField, equals: .nickname)
            
            TextField(LocalizationUtils.localized("Email_Optional"), text: $authViewModel.email)
                .padding()
                .background(Color(.systemBackground))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.2), lineWidth: 1))
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
                    .cornerRadius(12)
            } else {
                Text(LocalizationUtils.localized("Register"))
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .disabled(!authViewModel.isRegistrationFormValid || authViewModel.isLoading)
    }
    
    // MARK: - Terms and Conditions Text
    private var termsText: some View {
        Text(LocalizationUtils.localized("Terms_Consnet"))
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
