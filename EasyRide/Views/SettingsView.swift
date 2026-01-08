import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    
    // Language options
    private let languages = [
        ("English", "en"),
        ("简体中文", "zh-Hans")
    ]
    
    var body: some View {
        Form {
            Section(header: Text(LocalizationUtils.localized("Language"))) {
                Picker(selection: Binding(
                    get: { appState.preferredLanguage ?? "en" },
                    set: { newValue in
                        appState.preferredLanguage = newValue
                    }
                ), label: Text(LocalizationUtils.localized("App_Language"))) {
                    ForEach(languages, id: \.1) { language in
                        Text(language.0).tag(language.1)
                    }
                }
                .pickerStyle(.inline)
            }
            
            Section(header: Text(LocalizationUtils.localized("General"))) {
                HStack {
                    Text(LocalizationUtils.localized("Version"))
                    Spacer()
                    Text("1.0.0 (1)")
                        .foregroundColor(.secondary)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(.systemBackground))
        .navigationTitle(Text(LocalizationUtils.localized("Settings")))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environment(AppState())
    }
}
