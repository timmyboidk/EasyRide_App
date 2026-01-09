import Foundation
import Observation
import CoreLocation

@Observable
class OrderDetailViewModel {
    private let apiService: APIService
    
    // Order and messaging state
    var currentOrder: Order?
    var messages: [Message] = []
    var unreadMessageCount: Int = 0
    var isLoadingMessages: Bool = false
    var isSendingMessage: Bool = false
    var errorMessage: String?
    
    // Chat interface state
    var messageText: String = ""
    var selectedPresetCategory: PresetMessageCategory = .general
    var showingPresetMessages: Bool = false
    var isTyping: Bool = false
    var driverIsTyping: Bool = false
    var typingIndicatorTimer: Timer?
    
    // Trip modification state
    var showingTripModification: Bool = false
    var modificationRequest: TripModificationRequest?
    var fareAdjustment: Double = 0.0
    var driverConfirmationStatus: DriverConfirmationStatus = .pending
    
    // Location sharing
    var currentLocation: Location?
    var isLocationSharingEnabled: Bool = false
    
    // Message polling
    private var messagePollingTimer: Timer?
    private let messagePollingInterval: TimeInterval = 3.0
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
//    deinit {
//        stopMessagePolling()
//        stopTypingIndicator()
//    }
    
    // MARK: - Order Management
    
    @MainActor
    func loadOrder(_ order: Order) async {
        currentOrder = order
        await loadMessages()
        startMessagePolling()
    }
    
    @MainActor
    func refreshOrder() async {
        guard let orderId = currentOrder?.id else { return }
        
        do {
            let updatedOrder: Order = try await apiService.request(.getOrder(orderId: orderId))
            currentOrder = updatedOrder
        } catch {
            errorMessage = "Failed to refresh order: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Message Management
    
    @MainActor
    func loadMessages() async {
        guard let orderId = currentOrder?.id else { return }
        
        isLoadingMessages = true
        errorMessage = nil
        
        do {
            let response: MessagesResponse = try await apiService.request(.getMessages(orderId: orderId, page: 1, limit: 50))
            messages = response.messages.sorted { $0.timestamp < $1.timestamp }
            updateUnreadCount()
            
            // Mark messages as read
            let unreadMessageIds = messages.filter { !$0.isRead && !$0.isFromCurrentUser }.map { $0.id }
            if !unreadMessageIds.isEmpty {
                await markMessagesAsRead(messageIds: unreadMessageIds)
            }
            
        } catch {
            errorMessage = "Failed to load messages: \(error.localizedDescription)"
        }
        
        isLoadingMessages = false
    }
    
    @MainActor
    func sendMessage(_ text: String, type: MessageType = .text) async {
        guard let orderId = currentOrder?.id, !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else { return }
        
        isSendingMessage = true
        
        do {
            try await apiService.requestWithoutResponse(.sendMessage(orderId: orderId, message: text, messageType: type))
            
            // Add message to local list immediately for better UX
            let newMessage = Message(
                orderId: orderId,
                senderId: "current_user", // In real app, get from user session
                senderType: .passenger,
                content: text,
                type: type,
                location: type == .location ? currentLocation : nil
            )
            messages.append(newMessage)
            
            // Clear message text
            messageText = ""
            
        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
        }
        
        isSendingMessage = false
    }
    
    @MainActor
    func sendPresetMessage(_ presetMessage: PresetMessage) async {
        await sendMessage(presetMessage.text)
        showingPresetMessages = false
    }
    
    @MainActor
    func shareLocation() async {
        guard let location = currentLocation else {
            errorMessage = "Location not available"
            return
        }
        
        let locationText = "📍 \(location.address)"
        await sendMessage(locationText, type: .location)
    }
    
    @MainActor
    func markMessagesAsRead(messageIds: [String]) async {
        guard let orderId = currentOrder?.id else { return }
        
        do {
            try await apiService.requestWithoutResponse(.markMessagesAsRead(orderId: orderId, messageIds: messageIds))
            
            // Update local messages
            for i in messages.indices {
                if messageIds.contains(messages[i].id) {
                    messages[i].isRead = true
                }
            }
            updateUnreadCount()
            
        } catch {
            print("Failed to mark messages as read: \(error.localizedDescription)")
        }
    }
    
    private func updateUnreadCount() {
        unreadMessageCount = messages.filter { !$0.isRead && !$0.isFromCurrentUser }.count
    }
    
    // MARK: - Message Polling
    
    @MainActor
    private func startMessagePolling() {
        stopMessagePolling()
        
        messagePollingTimer = Timer.scheduledTimer(withTimeInterval: messagePollingInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.pollForNewMessages()
            }
        }
    }
    
    @MainActor
    private func stopMessagePolling() {
        messagePollingTimer?.invalidate()
        messagePollingTimer = nil
    }
    
    @MainActor
    private func pollForNewMessages() async {
        guard let orderId = currentOrder?.id else { return }
        
        do {
            let response: MessagesResponse = try await apiService.request(.getMessages(orderId: orderId, page: 1, limit: 10))
            
            // Add only new messages
            let existingMessageIds = Set(messages.map { $0.id })
            let newMessages = response.messages.filter { !existingMessageIds.contains($0.id) }
            
            if !newMessages.isEmpty {
                messages.append(contentsOf: newMessages.sorted { $0.timestamp < $1.timestamp })
                updateUnreadCount()
                
                // Mark new messages from driver as read automatically if chat is open
                let newDriverMessages = newMessages.filter { $0.senderType == .driver }
                if !newDriverMessages.isEmpty {
                    await markMessagesAsRead(messageIds: newDriverMessages.map { $0.id })
                }
            }
            
        } catch {
            // Silently handle polling errors to avoid spam
            print("Failed to poll for new messages: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Trip Modification
    
    @MainActor
    func requestTripModification(_ request: TripModificationRequest) async {
        guard let orderId = currentOrder?.id else { return }
        
        modificationRequest = request
        driverConfirmationStatus = .pending
        showingTripModification = true
        
        do {
            // Calculate fare adjustment
            let adjustmentResponse: FareAdjustmentResponse = try await apiService.request(.calculateFareAdjustment(orderId: orderId, modification: request))
            fareAdjustment = adjustmentResponse.adjustment
            
            // Send modification request to driver
            try await apiService.requestWithoutResponse(.requestTripModification(orderId: orderId, modification: request))
            
            // Send system message about modification request
            let systemMessage = "Trip modification requested: \(request.description)"
            await sendMessage(systemMessage, type: .system)
            
        } catch {
            errorMessage = "Failed to request trip modification: \(error.localizedDescription)"
            showingTripModification = false
        }
    }
    
    @MainActor
    func cancelTripModification() {
        modificationRequest = nil
        fareAdjustment = 0.0
        driverConfirmationStatus = .pending
        showingTripModification = false
    }
    
    // MARK: - Location Management
    
    @MainActor
    func updateCurrentLocation(_ location: Location) {
        currentLocation = location
    }
    
    @MainActor
    func enableLocationSharing() {
        isLocationSharingEnabled = true
    }
    
    @MainActor
    func disableLocationSharing() {
        isLocationSharingEnabled = false
    }
    
    // MARK: - Typing Indicators
    
    @MainActor
    func startTypingIndicator() {
        guard !isTyping else { return }
        
        isTyping = true
        
        // Send typing indicator to server
        Task {
            do {
                try await apiService.requestWithoutResponse(.sendTypingIndicator(orderId: currentOrder?.id ?? "", isTyping: true))
            } catch {
                print("Failed to send typing indicator: \(error.localizedDescription)")
            }
        }
        
        // Auto-stop typing indicator after 3 seconds of inactivity
        typingIndicatorTimer?.invalidate()
        typingIndicatorTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.stopTypingIndicator()
            }
        }
    }
    
    @MainActor
    func stopTypingIndicator() {
        guard isTyping else { return }
        
        isTyping = false
        typingIndicatorTimer?.invalidate()
        typingIndicatorTimer = nil
        
        // Send stop typing indicator to server
        Task {
            do {
                try await apiService.requestWithoutResponse(.sendTypingIndicator(orderId: currentOrder?.id ?? "", isTyping: false))
            } catch {
                print("Failed to stop typing indicator: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    func handleMessageTextChange() {
        if !messageText.isEmpty && !isTyping {
            startTypingIndicator()
        } else if messageText.isEmpty && isTyping {
            stopTypingIndicator()
        } else if isTyping {
            // Reset the timer if user is still typing
            typingIndicatorTimer?.invalidate()
            typingIndicatorTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    self?.stopTypingIndicator()
                }
            }
        }
    }
    
    @MainActor
    func cleanUp() {
        stopMessagePolling()
        stopTypingIndicator()
    }
    
    // MARK: - Helper Methods
    
    var canSendMessages: Bool {
        guard let status = currentOrder?.status else { return false }
        return [.driverAssigned, .accepted, .arrived, .inProgress].contains(status)
    }
    
    var canModifyTrip: Bool {
        guard let status = currentOrder?.status else { return false }
        return [.driverAssigned, .accepted].contains(status)
    }
    
    var hasUnreadMessages: Bool {
        return unreadMessageCount > 0
    }
    
    var driverName: String {
        return currentOrder?.driver?.name ?? "Driver"
    }
    
    var formattedFareAdjustment: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        if fareAdjustment >= 0 {
            return "+\(formatter.string(from: NSNumber(value: fareAdjustment)) ?? "$0.00")"
        } else {
            return formatter.string(from: NSNumber(value: fareAdjustment)) ?? "$0.00"
        }
    }
}

// MARK: - Supporting Models

enum DriverConfirmationStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    
    var displayName: String {
        switch self {
        case .pending: return "Waiting for driver confirmation"
        case .accepted: return "Driver accepted"
        case .declined: return "Driver declined"
        }
    }
}
