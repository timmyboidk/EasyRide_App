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
                            Text(appState.currentUser?.name ?? "用户信息")
                                .font(.headline)
                            Text("编辑资料")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Preferences
            Section(header: Text("通用")) {
                Picker(selection: Binding(
                    get: { appState.preferredLanguage ?? "en" },
                    set: { newValue in
                        appState.preferredLanguage = newValue
                    }
                ), label: HStack {
                    Image(systemName: "globe")
                    Text("应用语言")
                }) {
                    ForEach(languages, id: \.1) { language in
                        Text(language.0).tag(language.1)
                    }
                }
                
                NavigationLink(destination: Text("Notifications Settings Placeholder")) {
                    Label("通知", systemImage: "bell.fill")
                }
                
                NavigationLink(destination: Text("Privacy Settings Placeholder")) {
                    Label("隐私", systemImage: "hand.raised.fill")
                }
            }
            
            // Support
            Section(header: Text("帮助与支持")) {
                NavigationLink(destination: Text("About Us Content")) {
                    Label("关于我们", systemImage: "info.circle.fill")
                }
                
                HStack {
                    Label("版本", systemImage: "iphone")
                    Spacer()
                    Text("1.0.0 (Build 1)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            // Danger Zone
            Section {
                Button(role: .destructive, action: { showingLogoutAlert = true }) {
                    Label("退出登录", systemImage: "arrow.right.square.fill")
                }
                
                Button(role: .destructive, action: {}) {
                    Label("注销账户", systemImage: "trash.fill")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.backgroundColor(for: colorScheme))
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .alert("退出登录", isPresented: $showingLogoutAlert) {
            Button("取消", role: .cancel) { }
            Button("退出登录", role: .destructive) {
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
