import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingLogoutAlert = false
    
    // Language options
    private let languages = [
        ("English", "en"),
        ("简体中文", "zh-Hans")
    ]
    
    var body: some View {
        Form {
            // Account Section
            Section {
                NavigationLink(destination: EditProfileView(appState: appState)) {
                    HStack {
                        // Avatar
                        Circle()
                            .fill(Theme.primaryColor(for: colorScheme).opacity(0.1))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.secondary)
                            )
                        
                        VStack(alignment: .leading) {
                            Text(appState.currentUser?.name ?? LocalizationUtils.localized("User_Info"))
                                .font(.headline)
                            Text(LocalizationUtils.localized("Edit_Profile"))
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Preferences
            Section(header: Text(LocalizationUtils.localized("General"))) {
                Picker(selection: Binding(
                    get: { appState.preferredLanguage ?? "en" },
                    set: { newValue in
                        appState.preferredLanguage = newValue
                    }
                ), label: HStack {
                    Image(systemName: "globe")
                    Text(LocalizationUtils.localized("App_Language"))
                }) {
                    ForEach(languages, id: \.1) { language in
                        Text(language.0).tag(language.1)
                    }
                }
                
                NavigationLink(destination: Text("Notifications Settings Placeholder")) {
                    Label(LocalizationUtils.localized("Notifications"), systemImage: "bell.fill")
                }
                
                NavigationLink(destination: Text("Privacy Settings Placeholder")) {
                    Label(LocalizationUtils.localized("Privacy"), systemImage: "hand.raised.fill")
                }
            }
            
            // Support
            Section(header: Text(LocalizationUtils.localized("Help_Support"))) {
                NavigationLink(destination: Text("About Us Content")) {
                    Label(LocalizationUtils.localized("About_Us"), systemImage: "info.circle.fill")
                }
                
                HStack {
                    Label(LocalizationUtils.localized("Version"), systemImage: "iphone")
                    Spacer()
                    Text("1.0.0 (Build 1)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            // Danger Zone
            Section {
                Button(role: .destructive, action: { showingLogoutAlert = true }) {
                    Label(LocalizationUtils.localized("Logout"), systemImage: "arrow.right.square.fill")
                }
                
                Button(role: .destructive, action: {}) {
                    Label(LocalizationUtils.localized("Delete_Account"), systemImage: "trash.fill")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.backgroundColor(for: colorScheme))
        .navigationTitle(LocalizationUtils.localized("Settings"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(LocalizationUtils.localized("Logout"), isPresented: $showingLogoutAlert) {
            Button(LocalizationUtils.localized("Cancel"), role: .cancel) { }
            Button(LocalizationUtils.localized("Logout"), role: .destructive) {
                // Perform logout
                appState.isAuthenticated = false
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environment(AppState())
    }
}
