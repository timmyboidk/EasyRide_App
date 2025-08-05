import SwiftUI
import MapKit

#if os(iOS)
import UIKit

struct OrderDetailView: View {
    @State var viewModel: OrderDetailViewModel
    let order: Order
    
    @State private var scrollProxy: ScrollViewProxy?
    @FocusState private var isMessageFieldFocused: Bool
    
    init(order: Order, apiService: APIService = EasyRideAPIService.shared) {
        self.order = order
        self._viewModel = State(initialValue: OrderDetailViewModel(apiService: apiService))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Order Status Header
                orderStatusHeader
                
                // Real-time map
                RealTimeMapView()
                
                // Chat Messages
                chatMessagesView
                
                // Message Input Area
                if viewModel.canSendMessages {
                    messageInputArea
                }
            }
        }
        .navigationTitle("行程详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $viewModel.showingTripModification) {
            // Placeholder for TripModificationView
            Text("行程修改视图")
        }
        .alert("错误", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("确定") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            await viewModel.loadOrder(order)
        }
        .onDisappear {
            viewModel.cleanUp()
        }
    }
    
    // MARK: - Subviews
    
    private var orderStatusHeader: some View {
        VStack(spacing: 12) {
            if let driver = order.driver {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(driver.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(driver.vehicleInfo.fullDescription)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: callDriver) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.green)
                            .clipShape(Circle())
                    }
                    
                    Button(action: openWeChat) {
                        Image(systemName: "message.fill")
                           .foregroundColor(.white)
                           .padding(10)
                           .background(Color.green)
                           .clipShape(Circle())
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
    
    private var chatMessagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                }
                .padding()
            }
            .onAppear {
                scrollProxy = proxy
                scrollToBottom()
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                scrollToBottom()
            }
        }
    }
    
    private var messageInputArea: some View {
        HStack(spacing: 12) {
            TextField("输入消息...", text: $viewModel.messageText, axis: .vertical)
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
                .foregroundColor(.white)
                .focused($isMessageFieldFocused)
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundColor(canSendMessage ? .white : .gray)
            }
            .disabled(!canSendMessage)
        }
        .padding()
        .background(Color.black)
    }
    
    // MARK: - Helper Methods
    
    private func sendMessage() {
        guard canSendMessage else { return }
        Task {
            await viewModel.sendMessage(viewModel.messageText)
        }
    }
    
    private var canSendMessage: Bool {
        !viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func scrollToBottom() {
        guard let lastMessageId = viewModel.messages.last?.id else { return }
        DispatchQueue.main.async {
            withAnimation {
                scrollProxy?.scrollTo(lastMessageId, anchor: .bottom)
            }
        }
    }
    
    private func callDriver() {
        if let phoneNumber = order.driver?.phoneNumber, let url = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.open(url)
        }
    }

    private func openWeChat() {
        // This would typically open WeChat with a specific user context if the API allows
        if let url = URL(string: "weixin://") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Message Bubble View

struct MessageBubbleView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer()
            }
            
            Text(message.content)
                .padding(12)
                .background(message.isFromCurrentUser ? Color.white : Color.gray.opacity(0.3))
                .foregroundColor(message.isFromCurrentUser ? .black : .white)
                .cornerRadius(20)
            
            if !message.isFromCurrentUser {
                Spacer()
            }
        }
    }
}

// MARK: - RealTimeMapView

struct RealTimeMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [
            AnnotationItem(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
        ]) { item in
            MapMarker(coordinate: item.coordinate, tint: .blue)
        }
        .frame(height: 250)
    }
}

struct AnnotationItem: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}


#Preview {
    NavigationView {
        OrderDetailView(
            order: Order(
                serviceType: .halfDay,
                pickupLocation: Location(latitude: 37.7749, longitude: -122.4194, address: "旧金山, 加州"),
                estimatedPrice: 45.0,
                driver: Driver(
                    name: "张师傅",
                    phoneNumber: "1234567890",
                    vehicleInfo: VehicleInfo(make: "丰田", model: "凯美瑞", year: 2022, color: "银色", licensePlate: "ABC123", vehicleType: .sedan)
                )
            )
        )
    }
    .preferredColorScheme(.dark)
}
#endif
