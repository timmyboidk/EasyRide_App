import SwiftUI

struct Theme {
    static func backgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .black : .white
    }
    
    static func primaryColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white : .black
    }
    
    static func secondaryColor(for colorScheme: ColorScheme) -> Color {
        .gray
    }
}

struct ThemeBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(Theme.backgroundColor(for: colorScheme))
            .foregroundColor(Theme.primaryColor(for: colorScheme))
    }
}

extension View {
    func applyTheme() -> some View {
        self.modifier(ThemeBackgroundModifier())
    }
}
