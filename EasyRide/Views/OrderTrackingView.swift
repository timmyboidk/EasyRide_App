import SwiftUI

#if os(iOS)
struct OrderTrackingView: View {
    @State private var viewModel: OrderTrackingViewModel
    @State private var showingDriverContact = false
    @State private var showingTripModification = false
    @State private var showingChat = false
    @State private var chatMessages: [ChatMessage] = []
    @State private var newMessage = ""

    init(orderId: String) {
        _viewModel = State(initialValue: OrderTrackingViewModel(apiService: EasyRideAPIService.shared))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
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
        .sheet(isPresented: $showingChat) {
            ChatInterfaceView(messages: $chatMessages, newMessage: $newMessage)
        }
        .sheet(isPresented: $showingTripModification) {
            TripModificationView()
        }
        .onAppear {
            loadInitialChatMessages()
        }
    }
    
    // MARK: - Driver Info Header
    private var driverInfoHeader: some View {
        VStack(spacing: 16) {
            Text("司机信息")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            if let driver = viewModel.currentOrder?.driver {
                HStack(spacing: 16) {
                    // Driver Avatar
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(driver.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                            Text("评分: \(String(format: "%.1f", driver.rating))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Text("车型: \(driver.vehicleInfo.model)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("车牌号: \(driver.vehicleInfo.licensePlate)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("车辆位置")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 200)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        
                        Text("司机距离您 2.3公里")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Text("预计5分钟到达")
                            .font(.caption)
                            .foregroundColor(.gray)
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
                .foregroundColor(.white)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                // Call Button
                Button(action: callDriver) {
                    VStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.green)
                            .clipShape(Circle())
                        
                        Text("电话")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                
                // WeChat Button
                Button(action: contactViaWeChat) {
                    VStack(spacing: 8) {
                        Image(systemName: "message.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.green)
                            .clipShape(Circle())
                        
                        Text("微信")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                
                // Chat Portal
                Button(action: { showingChat = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.blue)
                            .clipShape(Circle())
                        
                        Text("聊天入口")
                            .font(.caption)
                            .foregroundColor(.white)
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
                        .foregroundColor(.white)
                    Text("行程修改申请")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
                )
            }
            
            // Cancel Order Button
            Button(action: cancelOrder) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text("订单取消")
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.red, lineWidth: 1)
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
            .background(Color.black)
            .navigationTitle("聊天界面")
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
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(presetPhrases, id: \.self) { phrase in
                        Button(action: { sendPresetPhrase(phrase) }) {
                            Text(phrase)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
    }
    
    // MARK: - Chat Input Section
    private var chatInputSection: some View {
        HStack(spacing: 12) {
            // Preset Phrases Button
            Button(action: { showingPresetPhrases.toggle() }) {
                Image(systemName: "text.bubble.fill")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            // Text Input
            TextField("输入消息...", text: $newMessage)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .foregroundColor(.white)
            
            // Send Button
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.title3)
                    .foregroundColor(newMessage.isEmpty ? .gray : .blue)
            }
            .disabled(newMessage.isEmpty)
        }
        .padding()
        .background(Color.black)
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
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromDriver {
                // Driver message (left aligned)
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(16, corners: [.topRight, .bottomLeft, .bottomRight])
                    
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            } else {
                // User message (right aligned)
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16, corners: [.topLeft, .bottomLeft, .bottomRight])
                    
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)
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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("行程修改申请")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        ModificationOption(
                            icon: "location.fill",
                            title: "修改目的地",
                            description: "更改行程终点"
                        )
                        
                        ModificationOption(
                            icon: "plus.circle.fill",
                            title: "添加停靠点",
                            description: "在路线中增加停靠点"
                        )
                        
                        ModificationOption(
                            icon: "clock.fill",
                            title: "修改时间",
                            description: "调整出发或到达时间"
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
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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
