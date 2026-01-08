import SwiftUI

#if os(iOS)
struct OrderSuccessDriverMatchingView: View {
    @State private var isMatching = true
    @State private var estimatedWaitTime = 180 // seconds
    @State private var matchingProgress: Double = 0.0
    @State private var showingShareSheet = false
    @State private var tripSharingLink = "https://easyride.com/trip/share/abc123"
    @Binding var navigationPath: NavigationPath
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Success Icon and Title
                successHeader
                
                // Matching Status
                if isMatching {
                    matchingSection
                } else {
                    matchedSection
                }
                
                // Trip Sharing
                tripSharingSection
                
                Spacer()
                
                // Action Button
                actionButton
            }
            .padding()
        }
        .navigationTitle(LocalizationUtils.localized("Order_Submitted"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onReceive(timer) { _ in
            updateMatchingProgress()
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [tripSharingLink])
        }
    }
    
    // MARK: - Success Header
    private var successHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text(LocalizationUtils.localized("Order_Submitted"))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Matching Section
    private var matchingSection: some View {
        VStack(spacing: 24) {
            // Matching Animation
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 4)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: matchingProgress)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: matchingProgress)
                    
                    Image(systemName: "car.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                }
                
                Text(LocalizationUtils.localized("Matching_Driver"))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            // Estimated Wait Time
            VStack(spacing: 8) {
                Text(LocalizationUtils.localized("Est_Wait_Time"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(formatTime(estimatedWaitTime))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            // SaveDriver Priority Notification
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                
                Text(LocalizationUtils.localized("Priority_Match_Notice"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    // MARK: - Matched Section
    private var matchedSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text(LocalizationUtils.localized("Driver_Found"))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(LocalizationUtils.localized("Driver_On_The_Way"))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Trip Sharing Section
    private var tripSharingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "square.and.arrow.up.fill")
                    .foregroundColor(.blue)
                
                Text(LocalizationUtils.localized("Share_Link_Generated"))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Button(action: copyLink) {
                    HStack {
                        Image(systemName: "doc.on.doc.fill")
                        Text(LocalizationUtils.localized("Copy_Link"))
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Button(action: { showingShareSheet = true }) {
                    HStack {
                        Image(systemName: "message.fill")
                        Text(LocalizationUtils.localized("Send_WeChat"))
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .cornerRadius(8)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Action Button
    private var actionButton: some View {
        Button(action: proceedToCurrentOrder) {
            Text(isMatching ? LocalizationUtils.localized("Check_Progress") : LocalizationUtils.localized("View_Current_Order"))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    // MARK: - Helper Methods
    private func updateMatchingProgress() {
        if isMatching && estimatedWaitTime > 0 {
            estimatedWaitTime -= 1
            matchingProgress = 1.0 - (Double(estimatedWaitTime) / 180.0)
            
            // Simulate driver found after countdown
            if estimatedWaitTime <= 0 {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isMatching = false
                }
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func copyLink() {
        UIPasteboard.general.string = tripSharingLink
        // Show toast or feedback
    }
    
    private func proceedToCurrentOrder() {
        navigationPath.append(BookingStep.currentOrder)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationView {
        OrderSuccessDriverMatchingView(navigationPath: .constant(NavigationPath()))
    }
}
#endif
