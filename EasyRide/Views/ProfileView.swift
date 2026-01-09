import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var authViewModel: AuthenticationViewModel

    init() {
        _authViewModel = State(initialValue: AuthenticationViewModel(appState: AppState()))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundColor(for: colorScheme).ignoresSafeArea()
                VStack(spacing: 20) {
                    // User Info Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 100))
                            .foregroundStyle(.primary)

                        if let user = appState.currentUser {
                            Text(user.displayName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)

                            Text(user.phoneNumber)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Guest")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.top, 30)

                    // Menu List
                    List {
                        NavigationLink(destination: WalletView()) {
                            Label(LocalizationUtils.localized("Wallet"), systemImage: "wallet.pass.fill")
                        }

                        NavigationLink(destination: PaymentMethodsView()) {
                            Label(LocalizationUtils.localized("Payment_Methods"), systemImage: "creditcard.fill")
                        }

                        NavigationLink(destination: OrdersView()) {
                            Label(LocalizationUtils.localized("Order_History"), systemImage: "clock.fill")
                        }
                        
                        NavigationLink(destination: FavoriteDriversView()) {
                            Label(LocalizationUtils.localized("Favorite_Drivers"), systemImage: "heart.fill")
                        }

                        NavigationLink(destination: SettingsView()) {
                            Label(LocalizationUtils.localized("Settings"), systemImage: "gearshape.fill")
                        }
                    }
                    .listStyle(.plain)
                    .background(Theme.backgroundColor(for: colorScheme))
                    .scrollContentBackground(.hidden)

                    // Logout Button
                    Button(action: {
                        Task {
                            await authViewModel.logout()
                        }
                    }) {
                        Text(LocalizationUtils.localized("Logout"))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.primaryColor(for: colorScheme).opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle(Text(LocalizationUtils.localized("Profile")))
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            authViewModel = AuthenticationViewModel(appState: appState)
        }
    }
}
