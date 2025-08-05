import Foundation

struct Wallet: Codable, Identifiable {
    let id: String
    let balance: Double
    let currency: String
    let isActive: Bool
    let lastUpdated: Date
    
    init(
        id: String = UUID().uuidString,
        balance: Double = 0.0,
        currency: String = "USD",
        isActive: Bool = true,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.balance = balance
        self.currency = currency
        self.isActive = isActive
        self.lastUpdated = lastUpdated
    }
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: balance)) ?? "$0.00"
    }
    
    var hasInsufficientFunds: Bool {
        return balance <= 0
    }
}

struct PaymentTransaction: Codable, Identifiable {
    let id: String
    let amount: Double
    let type: TransactionType
    let status: TransactionStatus
    let description: String
    let orderId: String?
    let paymentMethodId: String?
    let createdAt: Date
    let completedAt: Date?
    
    init(
        id: String = UUID().uuidString,
        amount: Double,
        type: TransactionType,
        status: TransactionStatus = .pending,
        description: String,
        orderId: String? = nil,
        paymentMethodId: String? = nil,
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.status = status
        self.description = description
        self.orderId = orderId
        self.paymentMethodId = paymentMethodId
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        let prefix = type == .payment || type == .topUp ? "" : "-"
        return prefix + (formatter.string(from: NSNumber(value: abs(amount))) ?? "$0.00")
    }
    
    var statusColor: String {
        switch status {
        case .completed: return "green"
        case .pending: return "orange"
        case .failed: return "red"
        case .cancelled: return "gray"
        }
    }
}

enum TransactionStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        }
    }
}

struct PaymentProcessingRequest: Codable {
    let orderId: String
    let paymentMethodId: String
    let amount: Double
    let currency: String
    let description: String?
    let metadata: [String: String]?
    
    init(
        orderId: String,
        paymentMethodId: String,
        amount: Double,
        currency: String = "USD",
        description: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.orderId = orderId
        self.paymentMethodId = paymentMethodId
        self.amount = amount
        self.currency = currency
        self.description = description
        self.metadata = metadata
    }
}

struct PaymentProcessingResponse: Codable {
    let transactionId: String
    let status: TransactionStatus
    let amount: Double
    let currency: String
    let paymentMethodUsed: PaymentType
    let processedAt: Date
    let receiptUrl: String?
}