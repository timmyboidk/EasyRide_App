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
            Color.black.ignoresSafeArea()
            
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
        .navigationTitle("订单提交成功")
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
            
            Text("订单提交成功")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Matching Section
    private var matchingSection: some View {
        VStack(spacing: 24) {
            // Matching Animation
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: matchingProgress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: matchingProgress)
                    
                    Image(systemName: "car.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                
                Text("正在为您匹配司机")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            // Estimated Wait Time
            VStack(spacing: 8) {
                Text("预计等待时间")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(formatTime(estimatedWaitTime))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            // SaveDriver Priority Notification
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                
                Text("SaveDriver优先匹配通知")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
            )
        }
    }
    
    // MARK: - Matched Section
    private var matchedSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("已找到司机！")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("司机正在前往接您")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    // MARK: - Trip Sharing Section
    private var tripSharingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "square.and.arrow.up.fill")
                    .foregroundColor(.white)
                
                Text("行程分享链接已生成")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Button(action: copyLink) {
                    HStack {
                        Image(systemName: "doc.on.doc.fill")
                        Text("复制链接")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 1)
                    )
                }
                
                Button(action: { showingShareSheet = true }) {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("微信发送")
                    }
                    .font(.subheadline)
                    .foregroundColor(.black)
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
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Action Button
    private var actionButton: some View {
        Button(action: proceedToCurrentOrder) {
            Text(isMatching ? "查看匹配进度" : "查看当前订单")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
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
