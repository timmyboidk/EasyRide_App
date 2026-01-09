import SwiftUI

#if os(iOS)
struct OrderTrackingView: View {
    @State private var viewModel: OrderTrackingViewModel
    @State private var showingDriverContact = false
    @State private var showingTripModification = false
    @State private var showingChat = false
    @State private var chatMessages: [ChatMessage] = []
    @State private var newMessage = ""
    
    // Flow State
    @State private var showPayment = false
    @State private var showReview = false
    private let orderId: String
    
    @Environment(AppState.self) private var appState

    @Environment(\.colorScheme) private var colorScheme

    init(orderId: String) {
        self.orderId = orderId
        _viewModel = State(initialValue: OrderTrackingViewModel(apiService: EasyRideAPIService.shared))
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundColor(for: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Driver Information Header
                driverInfoHeader
                
                // Real-time Location Map
                mapSection
                
                // Contact & Chat Section
                contactSection
                
                // Trip Modification & Cancellation
                actionButtonsSection
            }
        }
        .navigationTitle("当前订单")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
        // Debug button removed for production
        }
        .sheet(isPresented: $showingChat) {
            ChatInterfaceView(messages: $chatMessages, newMessage: $newMessage)
        }
        .sheet(isPresented: $showingTripModification) {
            TripModificationView()
        }
        .sheet(isPresented: $showPayment) {
            if let order = viewModel.currentOrder {
                PaymentView(
                    orderId: order.id,
                    amount: order.actualPrice ?? order.estimatedPrice,
                    appState: appState,
                    onPaymentSuccess: {
                        showPayment = false
                        // Delay slightly to allow sheet to dismiss
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showReview = true
                        }
                    }
                )
                .interactiveDismissDisabled()
            }
        }
        .sheet(isPresented: $showReview) {
            if let order = viewModel.currentOrder, let driver = order.driver {
                ReviewView(
                    orderId: order.id,
                    driverId: driver.id, // Using driver.id (assuming Driver struct has it or we use order.driverId logic)
                    driverName: driver.name,
                    onSubmitConfig: {
                        showReview = false
                        // Navigate back home or dismiss
                        // For now we just close the sheet, the view likely needs to pop
                    }
                )
                .interactiveDismissDisabled()
            }
        }
        .onChange(of: viewModel.currentOrder?.status) { _, newStatus in
            if newStatus == .completed {
                showPayment = true
            }
        }
        .onAppear {
            loadInitialChatMessages()
            Task {
                await viewModel.startTracking(orderId: orderId)
            }
        }
    }
    
    // MARK: - Driver Info Header
    private var driverInfoHeader: some View {
        VStack(spacing: 16) {
            Text("司机信息")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if let driver = viewModel.currentOrder?.driver {
                HStack(spacing: 16) {
                    // Driver Avatar
                    Circle()
                        .fill(Theme.primaryColor(for: colorScheme).opacity(0.1))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(driver.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                            Text("评分: \(String(format: "%.1f", driver.rating))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("车型: \(driver.vehicleInfo.model)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("车牌号: \(driver.vehicleInfo.licensePlate)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Logic to add driver to favorites
                    }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                            .padding(10)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.primaryColor(for: colorScheme).opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Map Section
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("实时位置")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("车辆位置")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Rectangle()
                .fill(Theme.primaryColor(for: colorScheme).opacity(0.1))
                .frame(height: 200)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        
                        Text("司机距离您 %@")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Text("预计%@到达")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
                .cornerRadius(12)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Contact Section
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("联系方式")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                // Call Button
                Button(action: callDriver) {
                    VStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .font(.title2)
                            .foregroundColor(Theme.backgroundColor(for: colorScheme))
                            .frame(width: 50, height: 50)
                            .background(Theme.primaryColor(for: colorScheme))
                            .clipShape(Circle())
                        
                        Text("电话")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                
                // WeChat Button
                Button(action: contactViaWeChat) {
                    VStack(spacing: 8) {
                        Image(systemName: "message.fill")
                            .font(.title2)
                            .foregroundColor(Theme.backgroundColor(for: colorScheme))
                            .frame(width: 50, height: 50)
                            .background(Theme.primaryColor(for: colorScheme))
                            .clipShape(Circle())
                        
                        Text("微信")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                
                // Chat Portal
                Button(action: { showingChat = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.title2)
                            .foregroundColor(Theme.backgroundColor(for: colorScheme))
                            .frame(width: 50, height: 50)
                            .background(Theme.primaryColor(for: colorScheme))
                            .clipShape(Circle())
                        
                        Text("聊天入口")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Trip Modification Button
            Button(action: { showingTripModification = true }) {
                HStack {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue)
                    Text("行程修改申请")
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.primaryColor(for: colorScheme), lineWidth: 1.5)
                )
            }
            
            // Cancel Order Button
            Button(action: cancelOrder) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text("取消订单")
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red, lineWidth: 1.5)
                )
            }
        }
        .padding()
    }
    
    // MARK: - Actions
    private func callDriver() {
        if let url = URL(string: "tel://13800138000") {
            UIApplication.shared.open(url)
        }
    }
    
    private func contactViaWeChat() {
        // Implement WeChat contact
        print("通过微信联系")
    }
    
    private func cancelOrder() {
        // Implement order cancellation
        print("取消订单")
    }
    
    private func loadInitialChatMessages() {
        chatMessages = [
            ChatMessage(id: UUID(), text: "您好，我是您的司机小王，正在前往接您", isFromDriver: true, timestamp: Date().addingTimeInterval(-300)),
            ChatMessage(id: UUID(), text: "好的，谢谢", isFromDriver: false, timestamp: Date().addingTimeInterval(-280))
        ]
    }
}

// MARK: - Chat Interface View
struct ChatInterfaceView: View {
    @Binding var messages: [ChatMessage]
    @Binding var newMessage: String
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingPresetPhrases = false
    
    private let presetPhrases = [
        "稍等一下",
        "可以加个停靠点吗？",
        "我在楼下等您",
        "请问您到了吗？",
        "谢谢司机师傅"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatMessageRow(message: message)
                        }
                    }
                    .padding()
                }
                
                // Preset Phrases (if shown)
                if showingPresetPhrases {
                    presetPhrasesSection
                }
                
                // Input Section
                chatInputSection
            }
            .background(Theme.backgroundColor(for: colorScheme))
            .navigationTitle("聊天")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("关闭") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    // MARK: - Preset Phrases Section
    private var presetPhrasesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("常用语")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(presetPhrases, id: \.self) { phrase in
                        Button(action: { sendPresetPhrase(phrase) }) {
                            Text(phrase)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.secondary.opacity(0.1))
                                .foregroundColor(.primary)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Theme.primaryColor(for: colorScheme).opacity(0.1))
    }
    
    // MARK: - Chat Input Section
    private var chatInputSection: some View {
        HStack(spacing: 12) {
            // Preset Phrases Button
            Button(action: { showingPresetPhrases.toggle() }) {
                Image(systemName: "text.bubble.fill")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Text Input
            TextField("输入消息...", text: $newMessage)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
                .foregroundColor(.primary)
            
            // Send Button
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.title3)
                    .foregroundColor(newMessage.isEmpty ? .secondary : .blue)
            }
            .disabled(newMessage.isEmpty)
        }
        .padding()
        .background(Theme.backgroundColor(for: colorScheme))
    }
    
    private func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = ChatMessage(
            id: UUID(),
            text: newMessage,
            isFromDriver: false,
            timestamp: Date()
        )
        
        messages.append(message)
        newMessage = ""
        showingPresetPhrases = false
    }
    
    private func sendPresetPhrase(_ phrase: String) {
        let message = ChatMessage(
            id: UUID(),
            text: phrase,
            isFromDriver: false,
            timestamp: Date()
        )
        
        messages.append(message)
        showingPresetPhrases = false
    }
}

// MARK: - Chat Message Row
struct ChatMessageRow: View {
    @Environment(\.colorScheme) var colorScheme
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromDriver {
                // Driver message (left aligned)
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Theme.primaryColor(for: colorScheme).opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(16, corners: [.topRight, .bottomLeft, .bottomRight])
                    
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            } else {
                // User message (right aligned)
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Theme.primaryColor(for: colorScheme))
                        .foregroundColor(Theme.backgroundColor(for: colorScheme))
                        .cornerRadius(16, corners: [.topLeft, .bottomLeft, .bottomRight])
                    
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isFromDriver: Bool
    let timestamp: Date
}

// MARK: - RoundedCorner Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Trip Modification View
struct TripModificationView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundColor(for: colorScheme).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("行程修改申请")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 16) {
                        ModificationOption(
                            icon: "location.fill",
                            title: "修改目的地",
                            description: "更改行程终点"
                        )
                        
                        ModificationOption(
                            icon: "plus.circle.fill",
                            title: "添加停靠点",
                            description: "添加途经点"
                        )
                        
                        ModificationOption(
                            icon: "clock.fill",
                            title: "修改时间",
                            description: "调整出发时间"
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("修改行程")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("关闭") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ModificationOption: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Theme.primaryColor(for: colorScheme).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationView {
        OrderTrackingView(orderId: "preview-order-id")
    }
}
#endif
