import SwiftUI

#if os(iOS)
struct BootScreenView: View {
    @State private var isLoading = true
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var taglineOpacity: Double = 0.0
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo
                Image(systemName: "car.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                // App Name
                Text("EasyRide", bundle: nil)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(logoOpacity)
                
                // Tagline
                Text("您可靠的出行伙伴", bundle: nil)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .opacity(taglineOpacity)
                
                // Loading indicator
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                        .padding(.top, 20)
                }
            }
        }
        .onAppear {
            startBootAnimation()
        }
    }
    
    private func startBootAnimation() {
        // Logo animation
        withAnimation(.easeOut(duration: 0.8)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Tagline animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.6)) {
                taglineOpacity = 1.0
            }
        }
        
        // Complete boot sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                isLoading = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onComplete()
            }
        }
    }
}

#Preview {
    BootScreenView {
        print("启动完成")
    }
}
#endif
