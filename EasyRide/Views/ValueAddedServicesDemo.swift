import SwiftUI

#if os(iOS)
struct ValueAddedServicesDemo: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationView {
            ValueAddedServicesView(navigationPath: $navigationPath)
        }
    }
}

#Preview {
    ValueAddedServicesDemo()
}
#endif
