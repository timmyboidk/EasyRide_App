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
            Color(.systemBackground).ignoresSafeArea()
            
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
        .navigationTitle(LocalizationUtils.localized("Trip_Details"))
        .navigationBarTitleDisplayMode(.inline)
        // toolbarColorScheme deprecated in iOS 16/17 depending on usage, but standard is .toolbarColorScheme(.dark, ...)
        // We generally want it to adapt. If we force dark, nav bar is dark.
        // Let's remove it to adapt or keep if "Native Aesthetics" implies specific look. 
        // Given user wants themes, removing forced scheme is better.
        // .toolbarColorScheme(.dark, for: .navigationBar) 
        .sheet(isPresented: $viewModel.showingTripModification) {
            // Placeholder for TripModificationView
            Text(LocalizationUtils.localized("Trip_Modification_View"))
        }
        .alert(LocalizationUtils.localized("Error"), isPresented: .constant(viewModel.errorMessage != nil)) {
            Button(LocalizationUtils.localized("OK")) {
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
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(driver.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(driver.vehicleInfo.fullDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
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
        .background(Color(.secondarySystemBackground))
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
            .onChange(of: viewModel.messages.count) {
                // iOS 17 onChange uses 0 args or older version. 
                // Using 0 args closure for compatibility if possible, or verify syntax.
                scrollToBottom()
            }
        }
    }
    
    private var messageInputArea: some View {
        HStack(spacing: 12) {
            TextField(LocalizationUtils.localized("Enter_Message"), text: $viewModel.messageText, axis: .vertical)
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(20)
                .foregroundColor(.primary)
                .focused($isMessageFieldFocused)
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundColor(canSendMessage ? .blue : .gray)
            }
            .disabled(!canSendMessage)
        }
        .padding()
        .background(Color(.systemBackground))
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
                .background(message.isFromCurrentUser ? Color.blue : Color(.secondarySystemBackground))
                .foregroundColor(message.isFromCurrentUser ? .white : .primary)
                .cornerRadius(20)
            
            if !message.isFromCurrentUser {
                Spacer()
            }
        }
    }
}

// MARK: - RealTimeMapView

struct RealTimeMapView: View {
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    var body: some View {
        Map(position: $position) {
            Marker("Location", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
                .tint(.blue)
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
                serviceType: .airport,
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
